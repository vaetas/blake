import 'dart:async';

import 'package:args/command_runner.dart';
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

    // ignore: unawaited_futures
    LocalServer('./public').start();

    await watch('.').listen((event) {
      printInfo('Event: $event');
    });

    return 0;
  }

  /// Watch [directory] for changes in whole subtree.
  Stream<WatchEvent> watch(String directory) {
    return DirectoryWatcher(
      directory,
      pollingDelay: const Duration(milliseconds: 250),
    ).events;
  }
}

final _description = '''Starts local web server and watches for file changes. 
After every change the website will be rebuilt.''';