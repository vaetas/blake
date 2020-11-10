import 'package:blake/src/build/build_config.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
import 'package:path/path.dart' as p;

abstract class Content {
  String get name => p.basename(path);

  String get path;

  R when<R>({R Function(Section section) section, R Function(Page page) page});

  Map<String, dynamic> toMap(BuildConfig config) {
    return <String, dynamic>{
      'name': name,
      'path': path,
    };
  }
}
