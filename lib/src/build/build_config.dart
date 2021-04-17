import 'package:yaml/yaml.dart';

/// Configuration for building static site.
class BuildConfig {
  const BuildConfig({
    bool? verbose,
    String? publicDir,
    String? contentDir,
    String? templatesDir,
    String? staticDir,
    String? dataDir,
    String? typesDir,
    bool? generateSearchIndex,
  })  : verbose = verbose ?? false,
        publicDir = publicDir ?? 'public',
        contentDir = contentDir ?? 'content',
        templatesDir = templatesDir ?? 'templates',
        staticDir = staticDir ?? 'static',
        dataDir = dataDir ?? 'data',
        typesDir = typesDir ?? 'types',
        generateSearchIndex = generateSearchIndex ?? false;

  factory BuildConfig.fromYaml(YamlMap? map) {
    if (map == null || map.isEmpty) {
      return const BuildConfig();
    }

    return BuildConfig(
      verbose: map[_kVerbose] as bool?,
      publicDir: map[_kPublicDir] as String?,
      contentDir: map[_kContentDir] as String?,
      templatesDir: map[_kTemplatesDir] as String?,
      staticDir: map[_kStaticDir] as String?,
      dataDir: map[_kDataDir] as String?,
      typesDir: map[_kTypesDir] as String?,
      generateSearchIndex: map[_kGenerateSearchIndex] as bool?,
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
      _kGenerateSearchIndex: generateSearchIndex,
    };
  }

  @override
  String toString() => 'BuildConfig{${toMap()}}';
}

const _kVerbose = 'verbose';
const _kPublicDir = 'public_dir';
const _kContentDir = 'content_dir';
const _kTemplatesDir = 'templates_dir';
const _kStaticDir = 'static_dir';
const _kDataDir = 'data_dir';
const _kTypesDir = 'types_dir';
const _kGenerateSearchIndex = 'generate_search_index';
