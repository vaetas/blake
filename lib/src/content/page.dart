import 'package:blake/blake.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/git_util.dart';
import 'package:blake/src/utils.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';

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
    return _date != null ? DateTime.parse(_date) : null;
  }

  Future<DateTime> getUpdated(Config config) async {
    final _updated = metadata?.get<String>('updated');
    if (_updated != null) {
      return DateTime.parse(_updated);
    } else {
      // TODO: Git value may be cached after obtaining.
      final _gitModified = await GitUtil.getModified(
        fs.file(Path.join(config.build.contentDir, path)),
      );
      return _gitModified ?? date;
    }
  }

  @override
  final String path;

  final String content;

  final Map<String, dynamic> metadata;

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
