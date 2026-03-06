import 'package:flutter_test/flutter_test.dart';
import 'package:mora_tests/core/exceptions.dart';

void main() {
  group('LlmException', () {
    test('stores message', () {
      const e = LlmException('API timeout');
      expect(e.message, equals('API timeout'));
    });

    test('toString includes class name and message', () {
      const e = LlmException('bad response');
      expect(e.toString(), equals('LlmException: bad response'));
    });

    test('implements Exception', () {
      expect(const LlmException(''), isA<Exception>());
    });
  });

  group('HookException', () {
    test('stores message', () {
      const e = HookException('POST /seed returned 500');
      expect(e.message, equals('POST /seed returned 500'));
    });

    test('toString includes class name and message', () {
      const e = HookException('connection refused');
      expect(e.toString(), equals('HookException: connection refused'));
    });

    test('implements Exception', () {
      expect(const HookException(''), isA<Exception>());
    });
  });

  group('WebViewException', () {
    test('stores message', () {
      const e = WebViewException('screenshot failed');
      expect(e.message, equals('screenshot failed'));
    });

    test('toString includes class name and message', () {
      const e = WebViewException('JS eval error');
      expect(e.toString(), equals('WebViewException: JS eval error'));
    });

    test('implements Exception', () {
      expect(const WebViewException(''), isA<Exception>());
    });
  });

  group('StorageException', () {
    test('stores message', () {
      const e = StorageException('file not found');
      expect(e.message, equals('file not found'));
    });

    test('toString includes class name and message', () {
      const e = StorageException('write permission denied');
      expect(
          e.toString(), equals('StorageException: write permission denied'));
    });

    test('implements Exception', () {
      expect(const StorageException(''), isA<Exception>());
    });
  });
}
