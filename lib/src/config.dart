import 'package:blake/src/build/build_config.dart';
import 'package:blake/src/commands/serve_command.dart';
import 'package:blake/src/serve/serve_config.dart';
import 'package:blake/src/template/environment.dart';
import 'package:blake/src/template/templates_config.dart';
import 'package:jinja/loaders.dart';
import 'package:yaml/yaml.dart';

class Config {
  Config({
    this.title = '',
    this.author = '',
    this.baseUrl = '',
    required this.build,
    required this.serve,
    required this.templates,
    YamlMap? extra,
  }) : extra = extra ?? YamlMap();

  factory Config.fromYaml(YamlMap map) {
    return Config(
      build: BuildConfig.fromYaml(map[_kBuild] as YamlMap?),
      serve: ServeConfig.fromYaml(map[_kServe] as YamlMap?),
      templates: TemplatesConfig.fromYaml(map[_kTemplates] as YamlMap?),
      title: map[_kTitle] as String? ?? '',
      author: map[_kAuthor] as String? ?? '',
      baseUrl: map[_kBaseUrl] as String? ?? '',
      extra: map[_kExtra] as YamlMap? ?? YamlMap(),
    );
  }

  /// Populated config used during `blake init`.
  factory Config.initial() {
    final serveConfig = ServeConfig();
    return Config(
      author: 'William Blake',
      title: 'Static Site',
      baseUrl: 'http://127.0.0.1:${serveConfig.port}',
      extra: YamlMap(),
      build: const BuildConfig(),
      serve: serveConfig,
      templates: const TemplatesConfig(),
    );
  }

  final String title;
  final String author;
  final String baseUrl;
  final BuildConfig build;
  final ServeConfig serve;
  final TemplatesConfig templates;
  final YamlMap extra;

  /// [FileSystemLoader.autoReload] is not required because we handle reloading
  /// templates ourselves inside [ServeCommand]. Only this way we can ensure
  /// the template is updated before triggering rebuild.
  late final environment = CustomEnvironment(
    loader: FileSystemLoader(
      paths: [build.templatesDir],
    ),
  );

  String getBaseUrl({bool isServe = false}) {
    return isServe ? 'http://127.0.0.1:${serve.port}/' : baseUrl;
  }

  Map<String, Object?> toMap() {
    return {
      _kTitle: title,
      _kAuthor: author,
      'baseUrl': baseUrl,
      _kBuild: build.toMap(),
      _kServe: serve.toMap(),
      _kTemplates: templates.toMap(),
      _kExtra: extra,
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
const _kTemplates = 'templates';
const _kExtra = 'extra';
