import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

class MarkdownFile {
  MarkdownFile({
    @required this.metadata,
    @required this.content,
  });

  final YamlMap metadata;

  /// Raw markdown content.
  final String content;
}
