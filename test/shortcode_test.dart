import 'package:blake/src/shortcode.dart';
import 'package:blake/src/template/environment.dart';
import 'package:test/test.dart';

void main() {
  final parser = ShortcodeParser();
  final grammar = parser.grammar;

  final exampleInlineShortcode = Shortcode.inline(
    name: 'inline',
    arguments: [
      Argument(name: 'x', value: 1),
      Argument(name: 'y', value: 'hello world'),
    ],
  );

  group('Parse tokens', () {
    test('String', () {
      expect(
        grammar.stringToken.parse('"hello world"').value,
        equals('hello world'),
      );
    });
    test('bool', () {
      expect(grammar.boolToken.parse('true').value, equals(true));
    });
    test('int', () {
      expect(grammar.intToken.parse('123').value, equals(123));
    });
    test('double', () {
      expect(grammar.doubleToken.parse('123.456').value, equals(123.456));
    });
  });
  group('Parse shortcode', () {
    test('argument', () {
      expect(
        grammar.argument.parse('   x="lorem ipsum"').value,
        equals(Argument(name: 'x', value: 'lorem ipsum')),
      );
    });
    test('argument with markdown value', () {
      expect(
        grammar.shortcode.parse('inline x="**hello world**"').value,
        equals(
          Shortcode.inline(name: 'inline', arguments: [
            Argument(
              name: 'x',
              value: '**hello world**',
            ),
          ]),
        ),
      );
    });
    test('arguments transformed into map', () {
      expect(
        grammar.shortcode.parse('inline x=1 y=2').value.getValues(),
        equals(
          <String, dynamic>{
            'y': 2,
            'x': 1,
          },
        ),
      );
    });
    test('full content', () {
      expect(
        grammar.shortcode.parse('inline x=1 y="hello world"').value,
        equals(exampleInlineShortcode),
      );
    });
  });
  group('Parse inline shortcode', () {
    test('1', () {
      expect(
        grammar.inlineShortcode
            .parse('{{< inline x=1 y="hello world" />}}')
            .value,
        equals(exampleInlineShortcode),
      );
    });
  });
  group('Parse block shortcode', () {
    test('2', () {
      const input = '''
  {{< block x=1 y="2" >}}
    This is a block body
  {{< /block >}}
  ''';
      expect(
        grammar.blockShortcode.parse(input).value,
        equals(
          Shortcode.block(
            name: 'block',
            arguments: [
              Argument(name: 'x', value: 1),
              Argument(name: 'y', value: '2'),
            ],
            body: 'This is a block body',
          ),
        ),
      );
    });
  });
  group('Jinja skips shortcodes', () {
    final env = CustomEnvironment();
    test('inline', () {
      final template = env.fromString(
        '{{< code >}}Hello {{ name }}!{{< /user >}} {{ "abc" }}',
      );
      expect(
        template.render(name: 'Jhon'),
        '{{< code >}}Hello Jhon!{{< /user >}} abc',
      );
    });
    test('body', () {
      final template = env.fromString(
        '{{ "abc" }} {{< code \>}} Hello {{ name }}',
      );
      expect(
        template.render(name: 'Jhon'),
        'abc {{< code >}} Hello Jhon',
      );
    });
  });
}
