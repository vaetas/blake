import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

class TemplatesConfig {
  TemplatesConfig({String page, String section})
      : page = page ?? 'index.mustache',
        section = section ?? 'section.mustache';

  factory TemplatesConfig.fromYaml(YamlMap map) {
    assert(map != null);
    return TemplatesConfig(
      page: map.get('page'),
      section: map.get('section'),
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
