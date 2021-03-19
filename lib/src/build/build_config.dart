import 'package:yaml/yaml.dart';

/// Configuration for building static site.
class BuildConfig {
  const BuildConfig({
    this.verbose = false,
    this.publicDir = 'public',
    this.contentDir = 'content',
    this.templatesDir = 'templates',
    this.staticDir = 'static',
    this.dataDir = 'data',
    this.typesDir = 'types',
    this.generateSearchIndex = false,
  });

  // TODO: Is it necessary to specify default values inside both constructors?
  factory BuildConfig.fromYaml(YamlMap? map) {
    if (map == null) {
      return const BuildConfig();
    }
    return BuildConfig(
      verbose: map[_kVerbose] as bool? ?? false,
      publicDir: map[_kPublicDir] as String? ?? 'public',
      contentDir: map[_kContentDir] as String? ?? 'templates',
      templatesDir: map[_kTemplatesDir] as String? ?? 'templates',
      staticDir: map[_kStaticDir] as String? ?? 'static',
      dataDir: map[_kDataDir] as String? ?? 'data',
      typesDir: map[_kTypesDir] as String? ?? 'types',
      generateSearchIndex: map[_kGenerateSearchIndex] as bool? ?? false,
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

  /// Types used for creating new content.
  final String typesDir;

  /// Create public JSON search index when true.
  final bool generateSearchIndex;

  Map<String, Object?> toMap() {
    return {
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
const _kGenerateSearchIndex = 'generate_search_index';
