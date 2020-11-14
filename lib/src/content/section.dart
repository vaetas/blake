import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/page.dart';

/// [Section] is node with other subsections or pages.
class Section extends Content {
  Section({
    this.index,
    this.path,
    this.children = const [],
  }) : assert(name != null);

  @override
  final String path;

  final Page index;

  /// [Page] or [Section] content.
  final List<Content> children;

  @override
  Map<String, dynamic> toMap(Config config) {
    return <String, dynamic>{
      'name': name,
      'path': path,
    };
  }

  @override
  R when<R>({R Function(Section section) section, R Function(Page page) page}) {
    return section?.call(this);
  }

  @override
  String toString() {
    return 'Section{path: $path, index: $index, children: $children}';
  }
}
