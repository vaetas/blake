import 'package:meta/meta.dart';

abstract class Content {
  String get name;

  String get path;

  R when<R>({R Function(Section section) section, R Function(Page page) page});
}

/// [Section] is node with other subsections or pages.
class Section implements Content {
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
  String toString() => 'Section{name: $name, children: $children}';

  @override
  R when<R>({R Function(Section section) section, R Function(Page page) page}) {
    return section?.call(this);
  }
}

/// [Page] is leaf node which cannot have other subpages.
class Page implements Content {
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
  String toString() => 'Page{name: $name}';

  @override
  R when<R>({R Function(Section section) section, R Function(Page page) page}) {
    return page?.call(this);
  }
}
