import 'package:yaml/yaml.dart';

/// Configures default behavior for template selection.
///
/// [page] and [section] values are only used when the frontmatter's `template`
/// is not specified.
class TemplatesConfig {
  const TemplatesConfig({
    String? page,
    String? section,
  })  : page = page ?? 'index.html',
        section = section ?? 'section.html';

  factory TemplatesConfig.fromYaml(YamlMap? map) {
    if (map == null || map.isEmpty) {
      return const TemplatesConfig();
    }

    return TemplatesConfig(
      page: map['page'] as String?,
      section: map['section'] as String?,
    );
  }

  final String page;
  final String section;

  Map<String, Object?> toMap() {
    return <String, dynamic>{
      'page': page,
      'section': section,
    };
  }

  @override
  String toString() => 'TemplatesConfig${toMap()}';
}
