import 'package:meta/meta.dart';

abstract class Content {
  Content({this.name});

  final String name;
}

/// [Section] is node with other subsections or pages.
class Section implements Content {
  Section({
    @required this.name,
    this.children = const [],
  }) : assert(name != null);

  @override
  final String name;

  /// [Page] or [Section] content.
  final List<Content> children;

  @override
  String toString() => 'Section{name: $name, children: $children}';
}

/// [Page] is leaf node which cannot have other subpages.
class Page implements Content {
  Page({
    this.name,
    this.content,
    this.metadata = const <String, dynamic>{},
  });

  @override
  final String name;

  final String content;

  final Map<String, dynamic> metadata;

  @override
  String toString() => 'Page{name: $name}';
}
