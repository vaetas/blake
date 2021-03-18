import 'package:yaml/yaml.dart';

class TemplatesConfig {
  const TemplatesConfig({
    this.page = 'index.html',
    this.section = 'section.html',
  });

  factory TemplatesConfig.fromYaml(YamlMap? map) {
    if (map == null) {
      return const TemplatesConfig();
    }

    return TemplatesConfig(
      page: map['page'] as String? ?? 'index.html',
      section: map['section'] as String? ?? 'section.html',
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
