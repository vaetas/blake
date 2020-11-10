import 'package:blake/src/build/build_config.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

abstract class Content {
  String get name;

  String get path;

  R when<R>({R Function(Section section) section, R Function(Page page) page});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'path': path,
    };
  }
}

/// [Section] is node with other subsections or pages.
class Section extends Content {
  Section({
    @required this.name,
    this.path,
    this.children = const [],
  }) : assert(name != null);

  @override
  final String name;

  @override
  final String path;

  /// [Page] or [Section] content.
  final List<Content> children;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'path': path,
      'children': children.map((e) => e.toMap()).toList(),
    };
  }

  @override
  R when<R>({R Function(Section section) section, R Function(Page page) page}) {
    return section?.call(this);
  }

  @override
  String toString() => 'Section{name: $name, path: $path, children: $children}';
}

/// [Page] is leaf node which cannot have other subpages.
class Page extends Content {
  Page({
    @required this.name,
    @required this.path,
    this.content,
    this.metadata = const <String, dynamic>{},
  });

  @override
  final String name;

  @override
  final String path;

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

    if (basename == 'index') {
      return '$dirName/$basename.html';
    } else {
      return '$dirName/$basename/index.html';
    }
  }

  final String content;

  final Map<String, dynamic> metadata;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'path': path,
      'content': content,
    };
  }

  @override
  R when<R>({R Function(Section section) section, R Function(Page page) page}) {
    return page?.call(this);
  }

  @override
  String toString() => 'Page{name: $name, path: $path}';
}
