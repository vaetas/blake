import 'package:jinja/jinja.dart';

final _regExp = RegExp(r'''({{<\s*\/?[^(}})]+\s*\/?>}})''');

/// Custom Jinja environment to support shortcode syntax.
///
/// [CustomEnvironment] wraps every shortcode inside Markdown file with Jinja's
/// escape tags so they are skipped. Otherwise Jinja throws an error.
class CustomEnvironment extends Environment {
  CustomEnvironment({Loader? loader}) : super(loader: loader);

  @override
  Template fromString(String source, {String? path}) {
    source = source.replaceAllMapped(
      _regExp,
      (match) => '{% raw %}${match[1]}{% endraw %}',
    );
    return super.fromString(source, path: path);
  }
}
