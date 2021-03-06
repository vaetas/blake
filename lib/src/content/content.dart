import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/utils.dart';

/// [Content] symbolizes node in content tree. See [Page] or [Section] for
/// concrete implementation.
abstract class Content {
  String get title => Path.basename(path);

  String get path;

  List<Page> getPages();

  R? when<R>({
    R Function(Section section)? section,
    R Function(Page page)? page,
  });

  Map<String, Object?> toMap();
}
