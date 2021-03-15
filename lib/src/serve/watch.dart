import 'package:glob/glob.dart';
import 'package:watcher/watcher.dart';

/// Watch [directory] for changes in whole subtree except `public` directory.
Stream<WatchEvent> watch(
  String directory, {
  required Glob files,
}) {
  return DirectoryWatcher(
    directory,
    pollingDelay: const Duration(milliseconds: 250),
  )
      .events
      .where((e) => files.matches(e.path))
      .map((event) => WatchEvent(event.type, Uri.file(event.path).toString()));
}
