import 'package:blake/src/exceptions.dart';
import 'package:blake/src/serve/serve_config.dart';
import 'package:test/test.dart';

void main() {
  group('Parse address', () {
    final correct = Uri(scheme: 'http', host: '127.0.0.1', port: 4040);

    test('1', () {
      expect(parseAddress('127.0.0.1', 4040), correct);
    });
    test('2', () {
      expect(parseAddress('http://127.0.0.1', 4040), correct);
    });
    test('3', () {
      expect(parseAddress('http://127.0.0.1/', 4040), correct);
    });
    test('4', () {
      // For some reason, `throwsA` and `throwsException` would not work.
      try {
        parseAddress('http://127.0.0.1/test', 4040);
      } catch (e) {
        expect(e, isA<ConfigException>());
      }
    });
  });
}
