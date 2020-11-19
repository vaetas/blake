import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

/// Configuration for building static site.
class BuildConfig {
  const BuildConfig({
    bool verbose = false,
    String publicDir,
    String contentDir,
    String templatesDir,
    String staticDir,
    String dataDir,
    String typesDir,
  })  : verbose = verbose ?? false,
        publicDir = publicDir ?? 'public',
        contentDir = contentDir ?? 'content',
        templatesDir = templatesDir ?? 'templates',
        staticDir = staticDir ?? 'static',
        dataDir = dataDir ?? 'data',
        typesDir = typesDir ?? 'types';

  factory BuildConfig.fromYaml(YamlMap map) {
    assert(map != null);
    return BuildConfig(
      verbose: map.get<bool>(_kVerbose),
      publicDir: map.get<String>(_kPublicDir),
      contentDir: map.get<String>(_kContentDir),
      templatesDir: map.get<String>(_kTemplatesDir),
      staticDir: map.get<String>(_kStaticDir),
      dataDir: map.get<String>(_kDataDir),
      typesDir: map.get<String>(_kTypesDir),
    );
  }

  /// Enable debug prints.
  final bool verbose;

  /// Folder with generated site files.
  final String publicDir;

  /// Markdown content.
  final String contentDir;

  /// Templates for rendering markdown files.
  final String templatesDir;

  /// Static assets like CSS or JS.
  final String staticDir;

  /// YAML/JSON data accessible for rendering
  final String dataDir;

  final String typesDir;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _kVerbose: verbose,
      _kPublicDir: publicDir,
      _kContentDir: contentDir,
      _kTemplatesDir: templatesDir,
      _kStaticDir: staticDir,
      _kDataDir: dataDir,
      _kTypesDir: typesDir,
    };
  }

  @override
  String toString() => '${toMap()}';
}

const _kVerbose = 'verbose';
const _kPublicDir = 'public_dir';
const _kContentDir = 'content_dir';
const _kTemplatesDir = 'templates_dir';
const _kStaticDir = 'static_dir';
const _kDataDir = 'data_dir';
const _kTypesDir = 'types_dir';
