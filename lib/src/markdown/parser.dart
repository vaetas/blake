import 'package:blake/src/cli.dart';
import 'package:blake/src/markdown/footnote_syntax.dart';
import 'package:blake/src/markdown/markdown_file.dart';
import 'package:markdown/markdown.dart';

final _delimiter = RegExp(r'(---)(\n|\r)');

MarkdownFile parse(String markdown) {
  if (_delimiter.allMatches(markdown).length < 2 ||
      _delimiter.firstMatch(markdown).start != 0) {
    printWarning('Front matter is invalid or missing.');
  }

  final matches = _delimiter.allMatches(markdown).toList();
  final rawMetadata = markdown.substring(matches[0].start, matches[1].end);
  final metadata = rawMetadata.substring(3, rawMetadata.length - 4).trim();

  final content = markdown.substring(matches[1].end).trim();

  final parsed = markdownToHtml(
    content,
    extensionSet: ExtensionSet.gitHubWeb,
    blockSyntaxes: [
      FootnoteSyntax(),
    ],
    inlineSyntaxes: [
      FootnoteReferenceSyntax(),
    ],
  );

  return MarkdownFile(
    content: parsed,
    metadata: metadata,
  );
}
