import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/page.dart';

/// [Section] is node with other subsections or pages.
class Section extends Content {
  Section({
    this.index,
    required this.path,
    this.children = const [],
  });

  @override
  final String path;

  final Page? index;

  /// [Page] or [Section] content.
  final List<Content> children;

  @override
  Map<String, dynamic> toMap(Config config) {
    return <String, dynamic>{
      'title': title,
      'path': path,
    };
  }

  @override
  R? when<R>({
    R Function(Section section)? section,
    R Function(Page page)? page,
  }) {
    return section?.call(this);
  }

  @override
  String toString() {
    return 'Section{path: $path, index: $index, children: $children}';
  }

  @override
  List<Page> getPages() {
    final list = <Page>[];

    if (index != null) {
      list.add(index!);
    }

    for (final child in children) {
      list.addAll(child.getPages());
    }
    return list;
  }
}
