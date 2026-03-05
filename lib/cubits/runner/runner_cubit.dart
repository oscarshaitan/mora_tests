import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection.dart';
import '../../models/step_result.dart';
import '../../models/test_case.dart';
import '../../models/test_run.dart';
import '../../services/http_hook_service.dart';
import '../../services/llm_service.dart';
import '../../services/storage_service.dart';
import '../../services/test_runner.dart';
import '../../services/webview_service.dart';
import 'runner_state.dart';

class RunnerCubit extends Cubit<RunnerState> {
  final StorageService _storage;
  TestRunner? _runner;

  /// Single WebViewService instance for the lifetime of this cubit.
  /// Created eagerly so RunView and runSelected() share the same object.
  final WebViewService webViewService;

  RunnerCubit()
      : _storage = sl<StorageService>(),
        webViewService = sl<WebViewService>(),
        super(const RunnerState.idle());

  // ── File / Folder loading ──────────────────────────────────────────────────

  Future<void> openFolder() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select test folder',
    );
    if (path == null) return;
    try {
      final cases = await _storage.loadTestCasesFromDirectory(path);
      if (cases.isEmpty) {
        emit(const RunnerState.error('No YAML files found in folder'));
        return;
      }
      emit(RunnerState.ready(
        testCases: cases,
        selectedIds: cases.map((c) => c.id).toList(),
        sourcePath: path,
      ));
    } catch (e) {
      emit(RunnerState.error(e.toString()));
    }
  }

  Future<void> openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['yaml'],
    );
    if (result == null || result.files.single.path == null) return;
    try {
      final testCase = await _storage.loadTestCase(result.files.single.path!);
      emit(RunnerState.ready(
        testCases: [testCase],
        selectedIds: [testCase.id],
        sourcePath: result.files.single.path,
      ));
    } catch (e) {
      emit(RunnerState.error(e.toString()));
    }
  }

  void toggleSelection(String id) {
    final ready = state;
    if (ready is! RunnerReady) return;
    final selected = [...ready.selectedIds];
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    emit(ready.copyWith(selectedIds: selected));
  }

  void selectAll() {
    final ready = state;
    if (ready is! RunnerReady) return;
    emit(ready.copyWith(
      selectedIds: ready.testCases.map((c) => c.id).toList(),
    ));
  }

  void deselectAll() {
    final ready = state;
    if (ready is! RunnerReady) return;
    emit(ready.copyWith(selectedIds: []));
  }

  // ── Run ────────────────────────────────────────────────────────────────────

  Future<void> runSelected() async {
    final ready = state;
    if (ready is! RunnerReady) return;

    final toRun = ready.testCases
        .where((c) => ready.selectedIds.contains(c.id))
        .toList();

    if (toRun.isEmpty) return;

    final allRuns = <TestRun>[];

    for (final testCase in toRun) {
      // Reset the WebViewService so it waits for the NEW InAppWebView's
      // onWebViewCreated, instead of reusing the dead controller from any
      // previous run (which causes MissingPluginException on second run).
      webViewService.reset();

      // Emit RunnerRunning immediately so the WebView widget mounts.
      // waitUntilReady() below will block until attach() is called.
      if (testCase.steps.isNotEmpty) {
        emit(RunnerState.running(
          currentTest: testCase,
          completedSteps: const [],
          activeStep: testCase.steps.first,
          stepIndex: 0,
          totalSteps: testCase.steps.length,
        ));
        // Give Flutter one frame to build the WebView widget
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Wait for WebView controller to attach (up to 5 s)
      if (!webViewService.isReady) {
        try {
          await webViewService.waitUntilReady().timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('WebView not initialised — '
                'ensure the Runner tab is visible before pressing Run'),
          );
        } catch (e) {
          emit(RunnerState.error(e.toString()));
          return;
        }
      }

      _runner = TestRunner(
        webViewService: webViewService,
        llmService: sl<LlmService>(),
        httpHookService: sl<HttpHookService>(),
        storageService: _storage,
      );

      final completedSteps = <StepResult>[];

      final run = await _runner!.run(
        testCase: testCase,
        onStepResult: (result) {
          completedSteps.add(result);
          final step = testCase.steps.firstWhere(
            (s) => s.id == result.stepId,
            orElse: () => testCase.steps.first,
          );
          emit(RunnerState.running(
            currentTest: testCase,
            completedSteps: List.unmodifiable(completedSteps),
            activeStep: step,
            stepIndex: completedSteps.length - 1,
            totalSteps: testCase.steps.length,
            lastLlmReasoning: result.actionTaken?.reasoning,
            lastLlmConfidence: result.actionTaken?.confidence,
            lastActionName: result.actionTaken?.type.name,
          ));
        },
      );

      final finalRun = run.copyWith(results: completedSteps);
      allRuns.add(finalRun);
      // Persist run to disk — non-fatal if it fails
      await _storage.saveTestRun(finalRun);
    }

    emit(RunnerState.finished(
      runs: allRuns,
      testCases: ready.testCases,
      selectedIds: ready.selectedIds,
    ));
  }

  void abort() {
    _runner?.abort();
  }

  /// Loads all previously saved runs from disk and shows them in the results
  /// view. Can be called from any state (idle, ready, or finished).
  Future<void> loadHistory() async {
    final runs = await _storage.loadSavedRuns();
    if (runs.isEmpty) return;

    // Preserve testCases/selectedIds if we are in a ready/finished state so
    // the user can go back to the same test list.
    final (testCases, selectedIds) = switch (state) {
      RunnerFinished(:final testCases, :final selectedIds) =>
        (testCases, selectedIds),
      RunnerReady(:final testCases, :final selectedIds) =>
        (testCases, selectedIds),
      _ => (const <TestCase>[], const <String>[]),
    };

    emit(RunnerState.finished(
      runs: runs,
      testCases: testCases,
      selectedIds: selectedIds,
    ));
  }

  /// Persists the selected run index across tab switches.
  void selectRun(int index) {
    final finished = state;
    if (finished is! RunnerFinished) return;
    final clamped = index.clamp(0, finished.runs.length - 1);
    emit(finished.copyWith(selectedRunIndex: clamped));
  }

  void backToReady() {
    final finished = state;
    if (finished is RunnerFinished) {
      emit(RunnerState.ready(
        testCases: finished.testCases,
        selectedIds: finished.selectedIds,
      ));
    } else {
      emit(const RunnerState.idle());
    }
  }
}
