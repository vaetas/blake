import 'package:blake/src/config.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
import 'package:path/path.dart' as p;

/// [Content] symbolizes node in content tree. See [Page] or [Section] for
/// concrete implementation.
abstract class Content {
  String get title => p.basename(path);

  String get path;

  R when<R>({R Function(Section section) section, R Function(Page page) page});

  Map<String, dynamic> toMap(Config config) {
    return <String, dynamic>{
      'title': title,
      'path': path,
    };
  }
}
