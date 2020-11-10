import 'package:blake/src/build/build_config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/utils.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// [Page] is leaf node which cannot have other subpages.
class Page extends Content {
  Page({
    @required this.path,
    this.content,
    this.metadata,
  });

  @override
  String get name => metadata?.get<String>('title') ?? p.basename(path);

  @override
  final String path;

  final String content;

  final YamlMap metadata;

  /// Get final build path for this [Page].
  ///
  /// Index file is kept as is, only file extension is changed to HTML.
  /// For regular page is created a subdirectory with `index.html` file.
  ///
  /// Example:
  ///   content/post.md   ->  public/post/index.html
  ///   content/index.md  ->  public/index.html
  String getCanonicalPath(BuildConfig config) {
    final buildPath = path.replaceFirst(
      config.contentFolder,
      config.buildFolder,
    );

    final basename = p.basenameWithoutExtension(buildPath);
    final dirName = p.dirname(buildPath);

    if (isIndex) {
      return '$dirName/$basename.html';
    } else {
      return '$dirName/$basename/index.html';
    }
  }

  bool get isIndex => p.basenameWithoutExtension(path) == 'index';

  @override
  Map<String, dynamic> toMap(BuildConfig config) {
    // TODO: Refactor path.
    return <String, dynamic>{
      'name': name,
      'path': getCanonicalPath(config)
          .replaceFirst(config.buildFolder, '')
          .replaceFirst('index.html', ''),
      'content': content,
      'metadata': metadata,
    };
  }

  @override
  R when<R>({R Function(Section section) section, R Function(Page page) page}) {
    return page?.call(this);
  }

  @override
  String toString() => 'Page{name: $name, path: $path}';
}
