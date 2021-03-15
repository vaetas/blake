import 'package:yaml/yaml.dart';

class TemplatesConfig {
  TemplatesConfig({
    this.page = 'index.mustache',
    this.section = 'section.mustache',
  });

  factory TemplatesConfig.fromYaml(YamlMap? map) {
    if (map == null) {
      return TemplatesConfig();
    }

    return TemplatesConfig(
      page: map['page'] as String? ?? 'index.mustache',
      section: map['section'] as String? ?? 'section.mustache',
    );
  }

  final String page;
  final String section;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'page': page,
      'section': section,
    };
  }

  @override
  String toString() => 'TemplatesConfig${toMap()}';
}
