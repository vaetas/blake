import 'package:blake/src/config.dart';
import 'package:blake/src/content/page.dart';

class Tag {
  Tag({
    required this.name,
    required this.pages,
  });

  final String name;
  final List<Page> pages;

  @override
  String toString() => 'Tag{name: $name, pages: ${pages.length}}';

  Map<String, dynamic> toMap(Config config) {
    return <String, dynamic>{
      'name': name,
      'pages': pages.map((e) => e.toMap(config)).toList()
    };
  }
}
