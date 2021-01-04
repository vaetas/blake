import 'package:meta/meta.dart';

class Shortcode {
  const Shortcode({
    @required this.name,
    @required this.template,
  })  : assert(name != null),
        assert(template != null);

  final String name;
  final String template;

  @override
  String toString() => 'Shortcode{name: $name}';
}
