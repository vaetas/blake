import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/utils.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final _kIndexGlob = Glob('{index,_index}');

/// [Page] is leaf node which cannot have other subpages.
class Page extends Content {
  Page({
    @required this.path,
    this.content,
    this.metadata,
  });

  @override
  String get title => metadata?.get<String>('title', p.basename(path));

  DateTime get date {
    final _date = metadata?.get<String>('date');
    if (_date == null) {
      return null;
    }
    return DateTime.parse(_date);
  }

  DateTime get updated {
    final _updated = metadata?.get<String>('updated');
    if (_updated != null) {
      return DateTime.parse(_updated);
    } else {
      return date;
    }

    // TODO: Check Git times.
  }

  @override
  final String path;

  final String content;

  final YamlMap metadata;

  /// Get final build path for this [Page].
  ///
  /// Index file is kept as is, only file extension is changed to HTML.
  /// For regular page is created a subdirectory with `index.html` file.
  ///
  /// Example:
  ///   content/post.md   ->  public/post/index.html
  ///   content/index.md  ->  public/index.html
  String getCanonicalPath(Config config) {
    final buildPath = path.replaceFirst(
      config.build.contentDir,
      config.build.publicDir,
    );

    final basename = p.basenameWithoutExtension(buildPath);
    final dirName = p.dirname(buildPath);

    if (isIndex) {
      // Index file may be named `index` or `_index`.
      // Underscore needs to be removed.
      final name = basename.startsWith('_') ? basename.substring(1) : basename;
      return '$dirName/$name.html';
    } else {
      return '$dirName/$basename/index.html';
    }
  }

  String getPublicUrl(Config config) {
    return getCanonicalPath(config);

    final buildPath = path.replaceFirst(
      config.build.contentDir,
      '',
    );
    final basename = p.basenameWithoutExtension(buildPath);
    final dirName = p.dirname(buildPath);

    String url;
    if (isIndex) {
      // Index file may be named `index` or `_index`.
      // Underscore needs to be removed.
      final name = basename.startsWith('_') ? basename.substring(1) : basename;
      url = '$dirName/';
    } else {
      url = '$dirName/$basename/';
    }

    log.warning(config.baseUrl);
    return p.join(config.baseUrl, url);
  }

  bool get isIndex => _kIndexGlob.matches(p.basenameWithoutExtension(path));

  @override
  Map<String, dynamic> toMap(Config config) {
    // TODO: Remove dependency from [config]?
    return <String, dynamic>{
      'title': title,
      'path': getCanonicalPath(config)
          .replaceFirst(config.build.publicDir, '')
          .replaceFirst('index.html', ''),
      'content': content,
      'metadata': metadata,
    };
  }

  @override
  R when<R>({R Function(Section section) section, R Function(Page page) page}) {
    return page?.call(this);
  }

  @override
  String toString() => 'Page{path: $path, metadata: $metadata}';

  @override
  List<Page> getPages() => [this];
}
