import 'package:meta/meta.dart';

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
