import 'package:ansicolor/ansicolor.dart';
import 'package:args/command_runner.dart';
import 'package:blake/src/commands/build_command.dart';
import 'package:blake/src/commands/init_command.dart';
import 'package:blake/src/commands/new_command.dart';
import 'package:blake/src/commands/serve_command.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/log.dart';

export 'src/assets/live_reload.dart';
export 'src/build/build_config.dart';
export 'src/build/content_parser.dart';
export 'src/config.dart';
export 'src/content/content.dart';
export 'src/content/content.dart';
export 'src/content/page.dart';
export 'src/content/redirect_page.dart';
export 'src/content/section.dart';
export 'src/data.dart';
export 'src/errors.dart';
export 'src/file_system.dart';
export 'src/git_util.dart';
export 'src/markdown/markdown_file.dart';
export 'src/search.dart';
export 'src/serve/local_server.dart';
export 'src/serve/serve_config.dart';
export 'src/serve/watch.dart';
export 'src/shortcode.dart' show Shortcode, ShortcodeTemplate, ShortcodeParser;
export 'src/sitemap_builder.dart';
export 'src/taxonomy.dart';
export 'src/templates_config.dart';
export 'src/yaml.dart';

/// [Blake] class ties together all commands and exports callable method for
/// running this program.
class Blake {
  final runner = CommandRunner<int>('blake', 'Blake Static Site Generator');

  Future<int?> call(List<String> args) async {
    runner.addCommand(InitCommand());
    ansiColorDisabled = false;

    if (!await isProjectDirectory()) {
      return runner.run(args);
    } else {
      final config = await getConfig();
      return config.when(
        (error) {
          log.error(error.message);
          return 1;
        },
        (config) {
          runner
            ..addCommand(BuildCommand(config))
            ..addCommand(ServeCommand(config))
            ..addCommand(NewCommand(config));

          return runner.run(args);
        },
      );
    }
  }
}
