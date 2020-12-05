import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/log.dart';
import 'package:mustache_template/mustache_template.dart';
import 'package:path/path.dart' as p;

/// Create new content based on predefined types.
///
/// Usage: blake new <type> <name>
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
/// call following command: `blake new post blog/my-post`. This will create file
/// with this path: `content/blog/my-post.md` and fills the Markdown frontmatter
/// based on `post.yaml` type.
class NewCommand extends Command<int> {
  NewCommand(this.config) {
    argParser.addFlag(
      'force',
      defaultsTo: false,
      negatable: false,
      help: 'Delete file if already exists.',
    );
  }

  @override
  final String name = 'new';

  @override
  final String description = 'Create new content based on predefined type.';

  @override
  String get invocation => 'blake new <type> <name>';

  final Config config;

  @override
  FutureOr<int> run() async {
    if (argResults.rest.length != 2) {
      log.severe(
        'Invalid usage of `new` command. '
        'Correct usage is `blake new <type> <name>`',
      );
      return 1;
    }

    final args = _CommandArgs.fromResults(argResults);

    if (args.force) {
      log.debug(
        'Force option is enabled. Existing files will be overwritten.',
      );
    }

    final types = await getTypes();

    if (!types.containsKey(args.type)) {
      log.severe(
        'Type ${args.type} does not exists. '
        'You need to create a `${args.type}.yaml` file inside types folder.',
      );
    }

    log.debug('Available types: ${types.keys.toList()}');

    final _pattern = RegExp(r'\.md$');

    final file = File(
      '${config.build.contentDir}/${_pattern.hasMatch(args.name) ? args.name : '${args.name}.md'}',
    );

    if (await file.exists()) {
      if (args.force) {
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
    final title = p.basename(args.name);

    final template = Template(types[args.type]);
    final data = <String, dynamic>{
      'title': title,
      'date': DateTime.now().toIso8601String(),
    };
    final output = template.renderString(data);
    await file.writeAsString('---\n$output\n---\n');

    log.info('File ${file.path} created.');

    return 0;
  }

  Future<Map<String, String>> getTypes() async {
    final dirContent = await Directory(config.build.typesDir).list().toList();
    final types = dirContent.whereType<File>();

    return {
      for (final t in types)
        p.basenameWithoutExtension(t.path): await t.readAsString()
    };
  }
}

class _CommandArgs {
  _CommandArgs.fromResults(
    ArgResults results,
  )   : force = results['force'] as bool,
        type = results.rest[0],
        name = results.rest[1];

  final bool force;
  final String type;
  final String name;

  @override
  String toString() => '_CommandArgs{force: $force, type: $type, name: $name}';
}
