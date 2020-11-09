import 'package:watcher/watcher.dart';

/// Watch [directory] for changes in whole subtree except `public` directory.
Stream<WatchEvent> watch(String directory) {
  return DirectoryWatcher(
    directory,
    pollingDelay: const Duration(milliseconds: 250),
  ).events.where((e) => !_publicDirRegexp.hasMatch(e.path));
}

/// Valid for paths starting with `public` directory.
///
/// Examples: public/index.html, public\index.html, ./public/index.html
final _publicDirRegexp = RegExp(r'^(\.\\|\.\/|\\|\/)?public[\\\/]{1}');
