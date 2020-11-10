import 'package:blake/src/build/build_config.dart';
import 'package:blake/src/serve/serve_config.dart';
import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

class Config {
  Config.fromYaml(YamlMap map) {
    title = map?.get<String>('title') ?? '';
    author = map?.get<String>('author') ?? '';
    baseUrl = map?.get<String>('base_url') ?? '';
    build = BuildConfig.fromYaml(map?.get<YamlMap>('build'));
    serve = ServeConfig.fromYaml(map?.get<YamlMap>('serve'));
  }

  String title;
  String author;
  String baseUrl;
  BuildConfig build;
  ServeConfig serve;
}
