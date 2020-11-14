import 'package:blake/src/log.dart';
import 'package:blake/src/markdown/footnote_syntax.dart';
import 'package:blake/src/markdown/markdown_file.dart';
import 'package:markdown/markdown.dart';
import 'package:yaml/yaml.dart' as yaml;

final _delimiter = RegExp(r'(---)(\n|\r)');

MarkdownFile parse(String markdown) {
  if (_delimiter.allMatches(markdown).length < 2 ||
      _delimiter.firstMatch(markdown).start != 0) {
    log.warning('Front matter is invalid or missing.');
  }

  final matches = _delimiter.allMatches(markdown).toList();
  final rawMetadata = markdown.substring(matches[0].start, matches[1].end);
  final metadata = rawMetadata.substring(3, rawMetadata.length - 4).trim();

  final m = yaml.loadYaml(metadata) as yaml.YamlMap;

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
    metadata: m ?? yaml.YamlMap.wrap(<dynamic, dynamic>{}),
  );
}
