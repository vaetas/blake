import 'package:args/args.dart';
import 'package:blake/src/utils.dart';

class BuildConfig {
  const BuildConfig({
    this.verbose = false,
    this.buildFolder = 'public',
    this.contentFolder = 'content',
    this.templatesFolder = 'templates',
    this.staticFolder = 'static',
  });

  BuildConfig.fromArgResult(ArgResults results)
      : this(
          verbose: results?.get('verbose') as bool,
          buildFolder: results?.get('build_folder') as String,
        );

  final bool verbose;

  final String buildFolder;

  final String contentFolder;

  final String templatesFolder;

  final String staticFolder;
}
