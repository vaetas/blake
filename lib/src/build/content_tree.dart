import 'dart:io';

import 'package:blake/blake.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/markdown/parser.dart';
import 'package:blake/src/utils.dart';

/// Recursively parse file tree starting from [entity].
Future<Content> parseContentTree(FileSystemEntity entity) async {
  return entity.when(
    file: (file) async {
      final content = await file.readAsString();
      final parsed = parse(content);

      return Page(
        path: file.path,
        content: parsed.content,
        metadata: parsed.metadata,
      );
    },
    directory: (directory) async {
      final children = await directory.list().toList();

      final content = (await children.asyncMap(parseContentTree)).toList();

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
