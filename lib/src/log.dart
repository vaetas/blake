import 'package:blake/src/cli.dart';
import 'package:logging/logging.dart';

void setupLogging({bool verbose = false}) {
  Logger.root.onRecord.listen((record) {
    final name = record.loggerName;
    final level = record.level;
    final message = record.message;

    final output = '${name.isNotEmpty ? '[$name] ' : ''}${message}';

    if (level == Level.SEVERE) {
      printError(output);
      return;
    }

    if (level == Level.WARNING) {
      printWarning(output);
      return;
    }

    if (level == Level.INFO) {
      printInfo(output);
      return;
    }

    if (verbose) {
      print(output);
    }
  });
}

final log = Logger('');
