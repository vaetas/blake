import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:blake/blake.dart';
import 'package:blake/src/build/build_config.dart';
import 'package:blake/src/cli.dart';
import 'package:blake/src/local_server.dart';
import 'package:watcher/watcher.dart';

class ServeCommand extends Command<int> {
  ServeCommand() {
    argParser
      ..addOption('address', abbr: 'a', defaultsTo: '127.0.0.1')
      ..addOption('port', abbr: 'p', defaultsTo: '4040')
      ..addOption('websocketPort', defaultsTo: '4041');
  }

  @override
  final String name = 'serve';

  @override
  final String summary = 'Start local server.';

  @override
  final String description = _description;

  @override
  FutureOr<int> run() async {
    printInfo('Serving...');
    final config = _ServeConfig(argResults);
    final buildConfig = const BuildConfig();

    // Build once before starting server to ensure there is something to show.
    await build(buildConfig);

    final _onReload = StreamController<void>();

    await watch('.').listen((event) async {
      final stopwatch = Stopwatch()..start();
      await build(buildConfig);
      stopwatch.stop();
      _onReload.add(null);
    });

    await LocalServer(
      './public',
      address: config.address,
      port: config.port,
      onReload: _onReload.stream.asBroadcastStream(),
    ).start();

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

class _ServeConfig {
  _ServeConfig(this.argResults)
      : address = argResults['address'] as String,
        port = int.parse(argResults['port'] as String);

  final ArgResults argResults;

  final String address;
  final int port;
}

/// Valid for paths starting with `public` directory.
///
/// Examples: public/index.html, public\index.html, ./public/index.html
final _publicDirRegexp = RegExp(r'^(\.\\|\.\/|\\|\/)?public[\\\/]{1}');

final _description = '''Starts local web server and watches for file changes. 
After every change the website will be rebuilt.''';
