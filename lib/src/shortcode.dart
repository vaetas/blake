import 'package:blake/src/util/equals.dart';
import 'package:meta/meta.dart';
import 'package:mustache_template/mustache_template.dart';
import 'package:petitparser/petitparser.dart';

/// [ShortcodeTemplate] is a single file inside `templates/shortcodes` folder.
/// Shortcode template has a [name] which equals file name and a [template]
/// which is this file's content.
class ShortcodeTemplate {
  const ShortcodeTemplate({
    @required this.name,
    @required this.template,
  })  : assert(name != null),
        assert(template != null);

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
/// {{ block x=123 }}
/// ```
///
/// Example of a shortcode with body. Body will be set as a `body` argument.
/// ```dart
/// {{< block x=123 >}}
///   This is a block body
/// {{< /block >}}
/// ```
class Shortcode {
  Shortcode.inline({this.name, this.arguments});

  Shortcode.block({this.name, this.arguments, String body}) {
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
          listEquals(arguments, other.arguments);

  @override
  int get hashCode => name.hashCode ^ arguments.hashCode;

  @override
  String toString() {
    return 'Shortcode{name: $name, arguments: ${getValues()}}';
  }
}

/// Single shortcode argument.
///
/// `body` name is reserved for block-styled shortcodes.
class Argument {
  Argument({
    this.name,
    this.value,
  }) : assert(name != 'body');

  String name;
  String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Argument &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;

  @override
  String toString() => 'Argument{name: $name, value: $value}';
}

final shortcodeName = letter().star().flatten();
final argumentName = letter().plus().flatten();

// TODO: Uvozovky escapable
final argumentValue = ((char('"') & noneOf('"').plus().flatten() & char('"'))
        .map<dynamic>((value) => value[1]) |
    word().plus().flatten());
// ignore: top_level_function_literal_block
final argument = (argumentName & char('=') & argumentValue).map((value) {
  return Argument(
    name: value[0] as String,
    value: value[2] as String,
  );
});

// ignore: top_level_function_literal_block
final grammar = (shortcodeName & argument.trim().star()).map((value) {
  return Shortcode.inline(
    name: value[0] as String,
    arguments: value[1] as List<Argument>,
  );
});

final inlineShortcode = (string('{{') & grammar.trim() & string('}}'))
    .map<dynamic>((value) => value[1] as Shortcode);

final blockStart = (string('{{<').trim() & grammar.trim() & string('>}}'));
final blockEnd =
    string('{{<') & char('/').trim() & shortcodeName & string('>}}').trim();

final blockShortcode = (blockStart &
        blockEnd.neg().star().flatten().map<String>((value) => value.trim()) &
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
