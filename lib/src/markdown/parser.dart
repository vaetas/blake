import 'package:blake/src/markdown/footnote_syntax.dart';
import 'package:markdown/markdown.dart';

String parse(String markdown) {
  return markdownToHtml(
    markdown,
    extensionSet: ExtensionSet.gitHubWeb,
    blockSyntaxes: [
      FootnoteSyntax(),
    ],
    inlineSyntaxes: [
      FootnoteReferenceSyntax(),
    ],
  );
}
