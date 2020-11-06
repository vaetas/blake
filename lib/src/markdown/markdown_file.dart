import 'package:meta/meta.dart';

class MarkdownFile {
  MarkdownFile({
    @required this.metadata,
    @required this.content,
  });

  final String metadata;

  /// Raw markdown content.
  final String content;
}
