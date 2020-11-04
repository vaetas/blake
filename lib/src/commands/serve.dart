import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:blake/blake.dart';
import 'package:blake/src/cli.dart';
import 'package:blake/src/local_server.dart';
import 'package:watcher/watcher.dart';

class ServeCommand extends Command<int> {
  @override
  final String name = 'serve';

  @override
  final String summary = 'Start local server.';

  @override
  final String description = _description;

  @override
  FutureOr<int> run() async {
    printInfo('Serving...');

    await watch('.').listen((event) async {
      final stopwatch = Stopwatch()..start();
      await blake.runner.commands['build'].run();
      stopwatch.stop();
      printInfo('Rebuild successful (${stopwatch.elapsedMilliseconds} ms)');
    });

    await LocalServer('./public').start();

    return 0;
  }

  /// Watch [directory] for changes in whole subtree except `public` directory.
  Stream<WatchEvent> watch(String directory) {
    return DirectoryWatcher(
      directory,
      pollingDelay: const Duration(milliseconds: 250),
    ).events.where((e) => !_publicDirRegexp.hasMatch(e.path));
  }
}

/// Valid for paths starting with `public` directory.
///
/// Examples: public/index.html, public\index.html, ./public/index.html
final _publicDirRegexp = RegExp(r'^(\.\\|\.\/|\\|\/)?public[\\\/]{1}');

final _description = '''Starts local web server and watches for file changes. 
After every change the website will be rebuilt.''';
