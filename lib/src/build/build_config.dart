import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

/// Configuration for building static site.
class BuildConfig {
  const BuildConfig({
    bool verbose = false,
    String publicFolder,
    String contentFolder,
    String templatesFolder,
    String staticFolder,
    String dataFolder,
    String typesFolder,
  })  : verbose = verbose ?? false,
        publicFolder = publicFolder ?? 'public',
        contentFolder = contentFolder ?? 'content',
        templatesFolder = templatesFolder ?? 'templates',
        staticFolder = staticFolder ?? 'static',
        dataFolder = dataFolder ?? 'data',
        typesFolder = typesFolder ?? 'types';

  factory BuildConfig.fromYaml(YamlMap map) {
    assert(map != null);
    return BuildConfig(
      verbose: map.get<bool>(_kVerbose),
      publicFolder: map.get<String>(_kPublicFolder),
      contentFolder: map.get<String>(_kContentFolder),
      templatesFolder: map.get<String>(_kTemplatesFolder),
      staticFolder: map.get<String>(_kStaticFolder),
      dataFolder: map.get<String>(_kDataFolder),
      typesFolder: map.get<String>(_kTypesFolder),
    );
  }

  /// Enable debug prints.
  final bool verbose;

  /// Folder with generated site files.
  final String publicFolder;

  /// Markdown content.
  final String contentFolder;

  /// Templates for rendering markdown files.
  final String templatesFolder;

  /// Static assets like CSS or JS.
  final String staticFolder;

  /// YAML/JSON data accessible for rendering
  final String dataFolder;

  final String typesFolder;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _kVerbose: verbose,
      _kPublicFolder: publicFolder,
      _kContentFolder: contentFolder,
      _kTemplatesFolder: templatesFolder,
      _kStaticFolder: staticFolder,
      _kDataFolder: dataFolder,
      _kTypesFolder: typesFolder,
    };
  }

  @override
  String toString() => '${toMap()}';
}

const _kVerbose = 'verbose';
const _kPublicFolder = 'public_folder';
const _kContentFolder = 'content_folder';
const _kTemplatesFolder = 'templates_folder';
const _kStaticFolder = 'static_folder';
const _kDataFolder = 'data_folder';
const _kTypesFolder = 'types_folder';
