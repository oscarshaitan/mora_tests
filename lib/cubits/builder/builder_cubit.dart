import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../injection.dart';
import '../../models/test_case.dart';
import '../../models/test_step.dart';
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

  Future<void> openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['yaml'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
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
