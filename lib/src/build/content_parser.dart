import 'dart:io';

import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/errors.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/git_util.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/markdown/markdown_file.dart';
import 'package:blake/src/shortcode.dart';
import 'package:blake/src/utils.dart';
import 'package:file/file.dart';
import 'package:jinja/jinja.dart';
import 'package:yaml/yaml.dart' as yaml;

final _delimiter = RegExp(r'(---)(\n|\r)?');

class ContentParser {
  const ContentParser({
    required this.shortcodeTemplates,
    required this.config,
  });

  final List<ShortcodeTemplate> shortcodeTemplates;
  final Config config;

  /// Recursively parse file tree starting from [entity].
  Future<Content> parse(FileSystemEntity entity) async {
    return entity.when(
      file: (file) async {
        final content = await file.readAsString();
        final parsed = await _parseFile(content);

        // Remove leading 'content/' part of the directory.
        final path = Path.normalize(file.path).replaceFirst(
          '${config.build.contentDir}/',
          '',
        );

        final metadata = Map<String, dynamic>.from(parsed.metadata);

        if (!metadata.containsKey('date')) {
          if (await GitUtil.isGitInstalled()) {
            final date = await GitUtil.getModified(file);
            if (date != null) {
              metadata['date'] = date.toIso8601String();
            }
          }
        }

        return Page(
          path: path,
          content: parsed.content,
          metadata: metadata,
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

        final indexes = content
            .where((element) => element is Page && element.isIndex)
            .whereType<Page>();

        return Section(
          path: path,
          index: indexes.isEmpty ? null : indexes.first,
          children: content
              .where((element) => !(element is Page && element.isIndex))
              .toList(),
        );
      },
      link: (link) {
        throw UnimplementedError('Link file is not yet supported.');
      },
    )!;
  }

  Future<MarkdownFile> _parseFile(String markdown) async {
    if (_delimiter.allMatches(markdown).length < 2 ||
        _delimiter.firstMatch(markdown)!.start != 0) {
      throw const MissingFrontmatterError(
        'Front matter is invalid or missing.',
      );
    }

    final matches = _delimiter.allMatches(markdown).toList();
    final rawMetadata = markdown.substring(matches[0].start, matches[1].end);
    final metadata = rawMetadata.substring(3, rawMetadata.length - 4).trim();

    final m = yaml.loadYaml(metadata) as yaml.YamlMap?;

    final content = markdown.substring(matches[1].end).trim();

    return MarkdownFile(
      content: content,
      metadata: m ?? yaml.YamlMap.wrap(<String, Object?>{}),
    );
  }
}

class MissingFrontmatterError extends BuildError {
  const MissingFrontmatterError(
    String message, [
    String? help,
  ]) : super(message, help);

  @override
  String get name => 'MissingFrontmatterError';
}

/// Replace every shortcode inside text file with its value.
///
/// To render an `input` call [ShortcodeRenderer.render] method.
class ShortcodeRenderer {
  ShortcodeRenderer({
    required this.environment,
    required this.shortcodeTemplates,
  });

  final Environment environment;
  final List<ShortcodeTemplate> shortcodeTemplates;

  final parser = ShortcodeParser();

  String render(String input) {
    var _result = input;

    for (final shortcode in shortcodeTemplates) {
      /*
       Inline shortcodes
      */

      final pattern = RegExp('\\{{2}< ${shortcode.name} ((?!\\/).)* />\\}{2}');
      final inlineMatches = pattern.allMatches(input);

      for (final match in inlineMatches) {
        final variables = _parseInlineShortcode(
          input.substring(match.start, match.end),
        );

        final output = shortcode.render(
          environment: environment,
          values: variables.getValues(),
        );

        _result = _result.replaceFirst(
          input.substring(match.start, match.end),
          output,
        );
      }

      /*
       Block shortcodes
      */

      final startPattern =
          RegExp('\\{{2}< ${shortcode.name}((?!\\/).)* >\\}{2}');
      final endPattern = RegExp('\\{{2}< /${shortcode.name} >\\}{2}');

      final startMatches = startPattern.allMatches(input);
      final endMatches = endPattern.allMatches(input);

      if (startMatches.length != endMatches.length) {
        log.error(
          'Body shortcodes must have both opening closing tag.',
          help: 'Invalid use of ${shortcode.name} shortcode.',
        );

        throw const BuildError(
          'Body shortcodes must have both opening closing tag.',
        );
      }

      for (var x = 0; x < startMatches.length; x++) {
        final startMatch = startMatches.elementAt(x);
        final endMatch = endMatches.elementAt(x);

        final variables = _parseBodyShortcode(
          input.substring(startMatch.start, endMatch.end),
        );
        final output = shortcode.render(
          environment: environment,
          values: variables.getValues(),
        );

        _result = _result.replaceFirst(
          input.substring(startMatch.start, endMatch.end),
          output,
        );
      }
    }
    return _result;
  }

  // TODO: Parser might throw an error.
  Shortcode _parseInlineShortcode(String input) {
    final shortcode = parser.parseInline(input);
    return shortcode;
    // return _parseArgs(input);
  }

  Shortcode _parseBodyShortcode(String input) {
    final _shortcode = parser.parseBlock(input);
    return _shortcode;
  }
}
