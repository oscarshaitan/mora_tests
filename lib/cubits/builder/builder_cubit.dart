import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../injection.dart';
import '../../models/test_case.dart';
import '../../models/test_step.dart';
import '../../services/maestro_translator.dart'
    show MaestroTranslator, TranslationResult;
import '../../services/storage_service.dart';
import 'builder_state.dart';

class BuilderCubit extends Cubit<BuilderState> {
  final StorageService _storage;
  static const _uuid = Uuid();

  BuilderCubit() : _storage = sl<StorageService>(), super(const BuilderState());

  // ── Test list ──────────────────────────────────────────────────────────────

  void createNewTest() {
    final newTest = TestCase(
      id: _uuid.v4(),
      name: 'New Test',
      startUrl: 'https://',
      steps: [
        TestStep(id: _uuid.v4(), instruction: ''),
      ],
    );
    emit(state.copyWith(
      testCases: [...state.testCases, newTest],
      selectedTest: newTest,
      isDirty: true,
      savedPath: null,
    ));
  }

  void selectTest(TestCase test) {
    emit(state.copyWith(
      selectedTest: test,
      isDirty: false,
      savedPath: test.filePath,
    ));
  }

  void deleteTest(String id) {
    final updated = state.testCases.where((t) => t.id != id).toList();
    final selected = state.selectedTest?.id == id ? null : state.selectedTest;
    emit(state.copyWith(testCases: updated, selectedTest: selected));
  }

  // ── Editor mutations ───────────────────────────────────────────────────────

  void updateTest(TestCase test) {
    final updated = state.testCases
        .map((t) => t.id == test.id ? test : t)
        .toList();
    emit(state.copyWith(
      testCases: updated,
      selectedTest: test,
      isDirty: true,
    ));
  }

  void addStep() {
    final test = state.selectedTest;
    if (test == null) return;
    final newStep = TestStep(id: _uuid.v4(), instruction: '');
    updateTest(test.copyWith(steps: [...test.steps, newStep]));
  }

  void addStepAt(int index) {
    final test = state.selectedTest;
    if (test == null) return;
    final newStep = TestStep(id: _uuid.v4(), instruction: '');
    final steps = [...test.steps]..insert(index, newStep);
    updateTest(test.copyWith(steps: steps));
  }

  void removeStep(String stepId) {
    final test = state.selectedTest;
    if (test == null) return;
    updateTest(
      test.copyWith(steps: test.steps.where((s) => s.id != stepId).toList()),
    );
  }

  void reorderSteps(int oldIndex, int newIndex) {
    final test = state.selectedTest;
    if (test == null) return;
    final steps = [...test.steps];
    final item = steps.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    steps.insert(insertAt, item);
    updateTest(test.copyWith(steps: steps));
  }

  // ── Save / Load ────────────────────────────────────────────────────────────

  Future<void> save() async {
    final test = state.selectedTest;
    if (test == null) return;

    String? path = state.savedPath;
    if (path == null) {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save test file',
        fileName: '${test.name.toLowerCase().replaceAll(' ', '_')}.yaml',
        type: FileType.custom,
        allowedExtensions: ['yaml'],
      );
      if (result == null) return;
      path = result;
    }

    try {
      await _storage.saveTestCase(test, path);
      final saved = test.copyWith(filePath: path);
      final updated =
          state.testCases.map((t) => t.id == saved.id ? saved : t).toList();
      emit(state.copyWith(
        testCases: updated,
        selectedTest: saved,
        isDirty: false,
        savedPath: path,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> saveAs() async {
    emit(state.copyWith(savedPath: null));
    await save();
  }

  /// Picks a Maestro YAML file, translates it to Mora Tests format, prompts
  /// for a save location, writes the file, and selects it in the builder.
  Future<void> importFromMaestro() async {
    final pick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['yaml'],
      dialogTitle: 'Select Maestro test file',
    );
    if (pick == null || pick.files.single.path == null) return;
    final sourcePath = pick.files.single.path!;

    late TranslationResult result;
    try {
      final content = await File(sourcePath).readAsString();
      result = MaestroTranslator.translate(content, sourcePath);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to parse Maestro file: $e'));
      return;
    }

    // Ask where to save the Mora Tests YAML.
    final defaultName =
        '${result.testCase.name.toLowerCase().replaceAll(' ', '_')}.yaml';
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save translated Mora Tests file',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: ['yaml'],
    );
    if (savePath == null) return;

    try {
      await _storage.saveTestCase(result.testCase, savePath);
      final saved = result.testCase.copyWith(filePath: savePath);
      final errorMsg = result.hasErrors
          ? '${result.errors.length} command(s) could not be translated:\n'
              '${result.errors.map((e) => '  • $e').join('\n')}'
          : null;
      emit(state.copyWith(
        testCases: [...state.testCases, saved],
        selectedTest: saved,
        isDirty: false,
        savedPath: savePath,
        errorMessage: errorMsg,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to save: $e'));
    }
  }

  /// Picks a Maestro tests folder, translates every `.yaml` file found
  /// recursively, and saves them into a new sibling folder named
  /// `{source}_mora_tests`, preserving the directory structure.
  ///
  /// The output folder is always freshly created so original files are
  /// never overwritten.
  Future<void> importFromMaestroFolder() async {
    final sourceDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Maestro tests folder',
    );
    if (sourceDir == null) return;

    // Auto-create a sibling output folder so originals are never touched.
    final outputDir = '${sourceDir}_mora_tests';
    await Directory(outputDir).create(recursive: true);

    // Collect all .yaml files recursively in the source folder.
    final sourceFiles = <String>[];
    await for (final entity
        in Directory(sourceDir).list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.yaml')) {
        sourceFiles.add(entity.path);
      }
    }

    if (sourceFiles.isEmpty) {
      emit(state.copyWith(errorMessage: 'No YAML files found in the selected folder.'));
      return;
    }

    final translated = <TestCase>[];
    int failed = 0;
    final allErrors = <String>[];

    for (final srcPath in sourceFiles) {
      try {
        final content = await File(srcPath).readAsString();
        final result = MaestroTranslator.translate(content, srcPath);

        // Mirror the relative path from source root into the output directory.
        final relative = p.relative(srcPath, from: sourceDir);
        final outPath = p.join(outputDir, relative);
        await Directory(p.dirname(outPath)).create(recursive: true);

        await _storage.saveTestCase(result.testCase, outPath);
        translated.add(result.testCase.copyWith(filePath: outPath));

        if (result.hasErrors) {
          allErrors.addAll(result.errors.map((e) => e.toString()));
        }
      } catch (_) {
        failed++;
      }
    }

    if (translated.isEmpty) {
      emit(state.copyWith(
          errorMessage: 'All $failed file(s) failed to translate.'));
      return;
    }

    final newCases = [...state.testCases, ...translated];
    final parts = <String>[
      if (failed > 0) '$failed file(s) could not be translated and were skipped.',
      if (allErrors.isNotEmpty)
        '${allErrors.length} command(s) could not be translated:\n'
            '${allErrors.map((e) => '  • $e').join('\n')}',
    ];
    emit(state.copyWith(
      testCases: newCases,
      selectedTest: translated.first,
      isDirty: false,
      savedPath: translated.first.filePath,
      errorMessage: parts.isEmpty ? null : parts.join('\n\n'),
    ));
  }

  Future<void> openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['yaml'],
    );
    if (result == null || result.files.single.path == null) return;
    await openFileByPath(result.files.single.path!);
  }

  Future<void> openFileByPath(String path) async {
    try {
      final test = await _storage.loadTestCase(path);
      final exists = state.testCases.any((t) => t.id == test.id);
      final updated = exists
          ? state.testCases.map((t) => t.id == test.id ? test : t).toList()
          : [...state.testCases, test];
      emit(state.copyWith(
        testCases: updated,
        selectedTest: test,
        isDirty: false,
        savedPath: path,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
