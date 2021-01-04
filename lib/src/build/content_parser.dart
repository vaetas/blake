import 'package:blake/blake.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/errors.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/markdown/footnote_syntax.dart';
import 'package:blake/src/markdown/markdown_file.dart';
import 'package:blake/src/shortcode.dart';
import 'package:blake/src/utils.dart';
import 'package:markdown/markdown.dart';
import 'package:yaml/yaml.dart' as yaml;

final _delimiter = RegExp(r'(---)(\n|\r)?');

class ContentParser {
  const ContentParser({
    this.shortcodes = const [],
  });

  final List<Shortcode> shortcodes;

  /// Recursively parse file tree starting from [entity].
  Future<Content> parse(FileSystemEntity entity) async {
    return entity.when(
      file: (file) async {
        final content = await file.readAsString();
        final parsed = _parseFile(content);

        return Page(
          path: file.path,
          content: parsed.content,
          metadata: parsed.metadata,
        );
      },
      directory: (directory) async {
        final children = await directory.list().toList();

        final content = (await children.asyncMap(parse)).toList();

        final index = content.where((e) => e is Page && e.isIndex);
        if (index.length > 1) {
          throw BuildError(
            'Only one index file can be provided: '
                '${index.map((e) => e.path).toList()}',
            "Use either 'index.md' or '_index.md' file, not both.",
          );
        }

        return Section(
          path: directory.path,
          index: content.firstWhere(
            (element) => element is Page && element.isIndex,
            orElse: () => null,
          ) as Page,
          children: content
              .where((element) => !(element is Page && element.isIndex))
              .toList(),
        );
      },
      link: (link) {
        throw UnimplementedError('Link file is not yet supported.');
      },
    );
  }

  MarkdownFile _parseFile(String markdown) {
    if (_delimiter.allMatches(markdown).length < 2 ||
        _delimiter.firstMatch(markdown).start != 0) {
      log.warning('Front matter is invalid or missing.');
    }

    final matches = _delimiter.allMatches(markdown).toList();
    final rawMetadata = markdown.substring(matches[0].start, matches[1].end);
    final metadata = rawMetadata.substring(3, rawMetadata.length - 4).trim();

    final m = yaml.loadYaml(metadata) as yaml.YamlMap;

    final content = markdown.substring(matches[1].end).trim();
    _renderShortcodes(content);

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

  String _renderShortcodes(String content) {
    return null;
    // final bodyStartPattern = RegExp(r'\{{2}< ((?!\/).)* >\}{2}(\n|\r)');
    // final bodyEndPattern = RegExp(r'\{{2}< \/.* >\}{2}(\n|\r)');
    //
    // final bodyMatches = bodyStartPattern.allMatches(content);
    //
    // for (final match in bodyMatches) {
    //   log.info(
    //     '${match.start} ${match.end} '
    //     '${content.substring(match.start, match.end - 1)}',
    //   );
    // }
    //
    // final inlinePattern = RegExp(r'\{{2} .* \}{2}(\n|\r)');
    // final matches = inlinePattern.allMatches(content);

    // for (final match in matches) {
    //   log.info('Match: $match');
    // }
  }
}

class ShortcodeRenderer {
  const ShortcodeRenderer({this.shortcode, this.content});

  final Shortcode shortcode;
  final String content;
}
