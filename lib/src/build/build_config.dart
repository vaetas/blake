import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

/// Configuration for building static site.
class BuildConfig {
  const BuildConfig({
    this.verbose = false,
    this.publicFolder = 'public',
    this.contentFolder = 'content',
    this.templatesFolder = 'templates',
    this.staticFolder = 'static',
    this.dataFolder = 'data',
  });

  factory BuildConfig.fromYaml(YamlMap map) {
    assert(map != null);
    return BuildConfig(
      verbose: map.get(_kVerbose, false),
      publicFolder: map.get(_kPublicFolder, 'public'),
      contentFolder: map.get(_kContentFolder, 'content'),
      templatesFolder: map.get(_kTemplatesFolder, 'templates'),
      staticFolder: map.get(_kStaticFolder, 'static'),
      dataFolder: map.get(_kDataFolder, 'data'),
    );
  }

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _kVerbose: verbose,
      _kPublicFolder: publicFolder,
      _kContentFolder: contentFolder,
      _kTemplatesFolder: templatesFolder,
      _kStaticFolder: staticFolder,
      _kDataFolder: dataFolder,
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
