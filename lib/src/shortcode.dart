import 'package:blake/src/util/equals.dart';
import 'package:mustache_template/mustache_template.dart';
import 'package:petitparser/petitparser.dart';

/// [ShortcodeTemplate] is a single file inside `templates/shortcodes` folder.
/// Shortcode template has a [name] which equals file name and a [template]
/// which is this file's content.
class ShortcodeTemplate {
  const ShortcodeTemplate({
    required this.name,
    required this.template,
  });

  final String name;
  final String template;

  /// Render shortcode [template] using [values].
  ///
  /// As of now this uses Mustache templating. This might change in the future.
  String render(Map<String, dynamic> values) {
    return Template(template).renderString(values);
  }

  @override
  String toString() => 'ShortcodeTemplate{name: $name}';
}

/// [Shortcode] is a single instance/usage of a shortcode inside Markdown file.
/// Each shortcode has a name and zero or more arguments.
///
/// [Shortcode] can be either be with or without body.
///
/// Example of a shortcode without body.
///
/// ```dart
/// {{ inline x=123 }}
/// ```
///
/// Example of a shortcode with body. Body will be set as a `body` argument.
///
/// ```dart
/// {{< block x=123 >}}
///   This is a block body
/// {{< /block >}}
/// ```
class Shortcode {
  Shortcode.inline({
    required this.name,
    required this.arguments,
  });

  Shortcode.block({
    required this.name,
    required this.arguments,
    required String body,
  }) {
    arguments.add(Argument(name: 'body', value: body));
  }

  final String name;
  final List<Argument> arguments;

  Map<String, dynamic> getValues() {
    return <String, dynamic>{
      for (final arg in arguments) arg.name: arg.value,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shortcode &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          mapEquals<String, dynamic>(getValues(), other.getValues());

  @override
  int get hashCode => name.hashCode ^ arguments.hashCode;

  @override
  String toString() {
    return 'Shortcode{name: $name, arguments: ${getValues()}}';
  }
}

/// Single shortcode argument.
///
/// [value] can be either String, bool, int, or double.
class Argument {
  Argument({
    required this.name,
    this.value,
  });

  String name;
  dynamic value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Argument &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value.runtimeType == other.value.runtimeType &&
          value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;

  @override
  String toString() => 'Argument{name: $name, value: $value}';
}

class ShortcodeParser {
  final grammar = ShortcodeGrammar();

  /// Parses inline shortcode.
  ///
  /// ```dart
  /// {{ block x=123 }}
  /// ```
  Shortcode parseInline(String input) {
    return grammar.inlineShortcode.parse(input).value;
  }

  /// Parses body shortcode.
  ///
  /// ```dart
  /// {{< block x=123 >}}
  ///   This is a block body
  /// {{< /block >}}
  /// ```
  Shortcode parseBlock(String input) {
    return grammar.blockShortcode.parse(input).value;
  }
}

class ShortcodeGrammar {
  Parser<String> shortcodeName = letter().star().flatten().trim();
  Parser<String> argumentName = letter().plus().flatten().trim();

  Parser<dynamic> get argumentValue =>
      doubleToken | intToken | boolToken | stringToken;

  Parser<Argument> get argument =>
      (argumentName & char('=') & argumentValue).trim().map((value) {
        return Argument(
          name: value[0] as String,
          value: value[2],
        );
      });

  Parser<Shortcode> get shortcode =>
      (shortcodeName & argument.star()).map<Shortcode>((value) {
        return Shortcode.inline(
          name: value[0] as String,
          arguments: value[1] as List<Argument>,
        );
      });

  Parser<Shortcode> get inlineShortcode =>
      (string('{{') & shortcode.trim() & string('}}'))
          .map((value) => value[1] as Shortcode);

  Parser<List<dynamic>> get blockStart =>
      (string('{{<').trim() & shortcode.trim() & string('>}}'));

  Parser<List<dynamic>> get blockEnd =>
      string('{{<') & char('/').trim() & shortcodeName & string('>}}').trim();

  Parser<Shortcode> get blockShortcode => (blockStart &
              blockEnd
                  .neg()
                  .star()
                  .flatten()
                  .map<String>((value) => value.trim()) &
              blockEnd)
          .map((value) {
        final shortcode = value[1] as Shortcode;
        final body = value[3] as String;
        return Shortcode.block(
          name: shortcode.name,
          arguments: [
            ...shortcode.arguments,
          ],
          body: body,
        );
      });

  Parser<String> stringToken = (char('"') &
          (string(r'\"') | char('"').neg()).star().flatten() &
          char('"'))
      .flatten()
      .trim()
      .map((value) => value.substring(1, value.length - 1));

  Parser<bool> boolToken = (string('true') | string('false'))
      .trim()
      .map<bool>((dynamic value) => value == 'true');

  Parser<int> intToken = digit().plus().flatten().trim().map(int.parse);
  Parser<double> doubleToken = digit()
      .plus()
      .seq(char('.').seq(digit().plus()))
      .flatten()
      .trim()
      .map(double.parse);
}
