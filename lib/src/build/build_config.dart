import 'package:args/args.dart';
import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

class BuildConfig {
  const BuildConfig({
    this.verbose = false,
    this.buildFolder = 'public',
    this.contentFolder = 'content',
    this.templatesFolder = 'templates',
    this.staticFolder = 'static',
    this.baseUrl = 'http://127.0.0.1',
  });

  BuildConfig.fromArgResult(ArgResults results)
      : this(
          verbose: results.get<bool>('verbose'),
        );

  BuildConfig.fromYaml(YamlMap map)
      : this(
          verbose: map.get<bool>('verbose'),
          buildFolder: map.get<String>('folder').replaceFirst('/', ''),
        );

  final bool verbose;

  final String buildFolder;

  final String contentFolder;

  final String templatesFolder;

  final String staticFolder;

  final String baseUrl;
}
