import 'package:blake/src/config.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/utils.dart';
import 'package:xml/xml.dart';

class SitemapBuilder {
  const SitemapBuilder({
    required this.pages,
    required this.config,
  });

  final List<Page> pages;
  final Config config;

  Future<void> build() async {
    final builder = XmlBuilder();

    // ignore: cascade_invocations
    builder
      ..processing('xml', 'version="1.0" encoding="utf-8" standalone="yes"')
      ..element(
        'urlset',
        nest: await _buildNodes(),
        attributes: {
          'xmlns': 'http://www.sitemaps.org/schemas/sitemap/0.9',
          'xmlns:xhtml': 'http://www.w3.org/1999/xhtml',
        },
      );

    await _createFile(builder.buildDocument().toXmlString(pretty: true));
  }

  Future<Iterable<XmlNode>> _buildNodes() async {
    return pages.asyncMap((e) async {
      final _updated = await e.getUpdated(config);
      final url = e.getPublicUrl(config);
      print(url);
      return XmlElement(
        XmlName('url'),
        [],
        [
          XmlElement(
            XmlName('loc'),
            [],
            [XmlText(url)],
          ),
          if (_updated != null)
            XmlElement(
              XmlName('lastmod'),
              [],
              [XmlText(_updated.toIso8601String())],
            )
        ],
      );
    });
  }

  Future<void> _createFile(String content) async {
    final file = await fs
        .file(Path.join(config.build.publicDir, 'sitemap.xml'))
        .create(recursive: true);

    await file.writeAsString(content);
  }
}
