import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/log.dart';
import 'package:mustache_template/mustache_template.dart';
import 'package:path/path.dart' as p;

/// Allows adding new content based on predefined types.
///
/// Usage: blake add <type> <name>
///
/// <type> must be an existing file inside `types_dir` without the extension.
/// For example, say you have following content of `types_dir`:
///
/// types:
///   - post.yaml
///   - essay.yaml
///   - ...
///
/// To create a new post based on `post.yaml` inside `blog` subfolder, you would
/// call following command: `blake add post blog/my-post`. This will create file
/// with this path: `content/blog/my-post.md` and fills the Markdown frontmatter
/// based on `post.yaml` type.
class AddCommand extends Command<int> {
  AddCommand(this.config) {
    argParser.addFlag(
      'force',
      defaultsTo: false,
      negatable: false,
      help: 'Delete file if already exists.',
    );
  }

  @override
  final String name = 'add';

  @override
  final String description = 'Add new content';

  final Config config;

  @override
  FutureOr<int> run() async {
    final types = await getTypes();
    final args = argResults.rest;
    final shouldForce = argResults['force'] as bool;

    if (args.length != 2) {
      log.severe(
        'Invalid usage of `add` command. '
        'Correct usage is `blake add <type> <name>`',
      );
      return 1;
    }

    if (shouldForce) {
      log.debug(
        'Force option is enabled. Existing files will be overwritten.',
      );
    }

    final type = args[0];
    final name = args[1];

    if (!types.containsKey(type)) {
      log.severe(
        'Type $type does not exists. '
        'To use this type create a `$type.yaml` file inside types folder.',
      );
    }

    log.debug('Available types: ${types.keys.toList()}');

    final file = File('${config.build.contentDir}/$name.md');

    if (await file.exists()) {
      if (shouldForce) {
        log.warning(
          'File ${file.path} already exists and will be overwritten.',
        );
        await file.delete();
      } else {
        log.severe(
          'File with path ${file.path} already exists. '
          'Nothing will be created.',
          help: 'Either manually delete this file or choose a different name.',
        );
        return 1;
      }
    } else {
      await file.create(recursive: true);
    }

    // TODO: Transform to pretty title.
    final title = p.basename(name);

    final template = Template(types[type]);
    final data = <String, dynamic>{
      'name': title,
      'date': DateTime.now().toIso8601String(),
    };
    final output = template.renderString(data);
    await file.writeAsString('---\n$output\n---\n');

    log.debug('New file: ${file.path}');

    return 0;
  }

  Future<Map<String, String>> getTypes() async {
    final dirContent = await getTypesDir().list().toList();
    final types = dirContent.whereType<File>();

    return {
      for (final t in types)
        p.basenameWithoutExtension(t.path): await t.readAsString()
    };
  }

  Directory getTypesDir() {
    return Directory(config.build.typesDir);
  }
}
