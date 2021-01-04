import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/utils.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
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
  String get title => metadata?.get<String>('title', Path.basename(path));

  bool get public => metadata?.get<bool>('public') ?? true;

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
  String getBuildPath(Config config) {
    final basename = Path.basenameWithoutExtension(path);
    final dirName = Path.dirname(path);

    if (isIndex) {
      // Index file may be named `index` or `_index`.
      // Underscore needs to be removed.
      final name = basename.startsWith('_') ? basename.substring(1) : basename;
      return Path.normalize(
        Path.join(
          config.build.publicDir,
          dirName,
          '$name.html',
        ),
      );
    } else {
      return Path.normalize(
        Path.join(
          config.build.publicDir,
          dirName,
          basename,
          'index.html',
        ),
      );
    }
  }

  String getPublicUrl(Config config) {
    return getBuildPath(config)
        .replaceFirst(
          config.build.publicDir,
          config.baseUrl,
        )
        .replaceFirst('index.html', '');
    log.warning(getBuildPath(config));
    return getBuildPath(config);

    final buildPath = path.replaceFirst(
      config.build.contentDir,
      '',
    );
    final basename = Path.basenameWithoutExtension(buildPath);
    final dirName = Path.dirname(buildPath);

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
    return Path.join(config.baseUrl, url);
  }

  bool get isIndex => _kIndexGlob.matches(Path.basenameWithoutExtension(path));

  @override
  Map<String, dynamic> toMap(Config config) {
    // TODO: Remove dependency from [config]?
    return <String, dynamic>{
      'title': title,
      'path': getBuildPath(config)
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
  List<Page> getPages() => public ? [this] : [];
}
