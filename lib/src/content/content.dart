import 'package:blake/src/config.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/utils.dart';

/// [Content] symbolizes node in content tree. See [Page] or [Section] for
/// concrete implementation.
abstract class Content {
  String get title => Path.basename(path);

  String get path;

  R when<R>({R Function(Section section) section, R Function(Page page) page});

  Map<String, dynamic> toMap(Config config) {
    return <String, dynamic>{
      'title': title,
      'path': path,
    };
  }

  List<Page> getPages();
}
