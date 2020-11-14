import 'package:blake/src/build/build_config.dart';
import 'package:blake/src/serve/serve_config.dart';
import 'package:blake/src/templates_config.dart';
import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

class Config {
  Config.fromYaml(YamlMap map) {
    final _emptyMap = YamlMap();

    title = map.get<String>(_kTitle, '');
    author = map.get<String>(_kAuthor, '');
    baseUrl = map.get<String>(_kBaseUrl, '');
    build = BuildConfig.fromYaml(map.get(_kBuild, _emptyMap));
    serve = ServeConfig.fromYaml(map.get(_kServe, _emptyMap));
    templates = TemplatesConfig.fromYaml(map.get('templates', _emptyMap));
    extra = map.get(_kExtra, _emptyMap);
  }

  String title;
  String author;
  String baseUrl;
  BuildConfig build;
  ServeConfig serve;
  TemplatesConfig templates;
  YamlMap extra;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'author': author,
      'base_url': baseUrl,
      'build': build.toMap(),
      'serve': serve.toMap(),
      'extra': extra,
      'templates': templates,
    };
  }

  @override
  String toString() => toMap().toString();
}

const _kTitle = 'title';
const _kAuthor = 'author';
const _kBaseUrl = 'base_url';
const _kBuild = 'build';
const _kServe = 'serve';
const _kExtra = 'extra';
