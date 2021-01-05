import 'package:meta/meta.dart';
import 'package:mustache_template/mustache_template.dart';

class Shortcode {
  const Shortcode({
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
  String toString() => 'Shortcode{name: $name}';
}
