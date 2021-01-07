import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/page.dart';
import 'package:meta/meta.dart';

/// Build JSON search index for static search of your content.
///
/// This is still very elementary and only outputs page title & path. In the
/// future might be possible to search though the page content.
class SearchIndexBuilder {
  const SearchIndexBuilder({
    @required this.config,
    @required this.pages,
  })  : assert(config != null),
        assert(pages != null);

  final Config config;
  final List<Page> pages;

  List<Map<String, dynamic>> build() {
    return pages.where((e) => e.public).map((e) {
      return <String, dynamic>{
        'title': e.title,
        'url': e.getPublicUrl(config),
      };
    }).toList();
  }
}

List<Map<String, dynamic>> createSearchIndex(
  Content content,
  Config config,
) {
  final list = <Map<String, dynamic>>[];

  content.when(
    page: (page) {
      final metadata = page.toMap(config);
      list.add(
        <String, dynamic>{
          'title': metadata['name'],
          'url': '${config.baseUrl}${metadata['path']}',
        },
      );
    },
    section: (section) {
      for (final element in section.children) {
        list.addAll(createSearchIndex(element, config));
      }
    },
  );

  return list;
}
