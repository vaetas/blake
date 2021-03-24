import 'package:yaml/yaml.dart';

class MarkdownFile {
  MarkdownFile({
    required this.metadata,
    required this.content,
  });

  final YamlMap metadata;

  /// Unrendered markdown content.
  final String content;
}
