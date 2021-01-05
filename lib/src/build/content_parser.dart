import 'dart:io';

import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/errors.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/markdown/footnote_syntax.dart';
import 'package:blake/src/markdown/markdown_file.dart';
import 'package:blake/src/shortcode.dart';
import 'package:blake/src/utils.dart';
import 'package:file/file.dart';
import 'package:markdown/markdown.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart' as yaml;

final _delimiter = RegExp(r'(---)(\n|\r)?');

class ContentParser {
  const ContentParser({
    @required this.shortcodes,
    @required this.config,
  })  : assert(shortcodes != null),
        assert(config != null);

  final List<Shortcode> shortcodes;
  final Config config;

  /// Recursively parse file tree starting from [entity].
  Future<Content> parse(FileSystemEntity entity) async {
    return entity.when(
      file: (file) async {
        final content = await file.readAsString();
        final parsed = _parseFile(content);

        // Remove leading 'content/' part of the directory.
        final path = Path.normalize(file.path).replaceFirst(
          '${config.build.contentDir}/',
          '',
        );

        return Page(
          path: path,
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

        // Remove leading 'content/' part of the directory.
        final path = Path.normalize(directory.path).replaceFirst(
          '${config.build.contentDir}/',
          '',
        );

        return Section(
          path: path,
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
    for (final shortcode in shortcodes) {
      // Inline shortcodes
      final pattern = RegExp('\\{{2} ${shortcode.name} ((?!\\/).)* \\}{2}');
      final inlineMatches = pattern.allMatches(content);

      for (final match in inlineMatches) {
        final variables =
            _parseInlineShortcode(content.substring(match.start, match.end));
      }

      // Block shortcodes

      // final startPattern = RegExp('\\{{2}< code ((?!\\/).)* >\\}{2}');
      // final endPattern = RegExp('\\{{2}< /code >\\}{2}');
      //
      // final startMatches = startPattern.allMatches(content);
      // final endMatches = endPattern.allMatches(content);
      //
      // for (final match in startMatches) {}
    }
    return null;
  }

  Map<String, dynamic> _parseInlineShortcode(String content) {
    final values = <String, dynamic>{};

    // Raw arguments will look like [{{ ,shorcode, arg="hello", }}]. This hack
    // will remove initial {{ and shortcode name together with trailing }}.
    final args = content.split(' ').sublist(2)..removeLast();

    for (final arg in args) {
      final parts = arg.split('=');
      final key = parts[0];
      final dynamic value = _parseArgValue(parts[1]);

      values[key] = value;
    }

    return values;
  }

  dynamic _parseArgValue(String value) {
    switch (value) {
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        String _value;

        if (value.startsWith('"') && value.endsWith('"')) {
          _value = value.substring(1, value.length - 1);
        }

        return _value;
    }
  }
}
