import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';

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
