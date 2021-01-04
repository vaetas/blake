import 'dart:io';

import 'package:blake/src/config.dart';
import 'package:blake/src/content/page.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

class SitemapBuilder {
  const SitemapBuilder({
    @required this.pages,
    @required this.config,
  })  : assert(pages != null),
        assert(config != null);

  final List<Page> pages;
  final Config config;

  Future<void> build() async {
    final builder = XmlBuilder();

    // ignore: cascade_invocations
    builder
      ..processing('xml', 'version="1.0" encoding="utf-8" standalone="yes"')
      ..element(
        'urlset',
        nest: () {
          for (final page in pages) {
            _buildPageElement(builder, page);
          }
        },
        attributes: {
          'xmlns': 'http://www.sitemaps.org/schemas/sitemap/0.9',
          'xmlns:xhtml': 'http://www.w3.org/1999/xhtml',
        },
      );

    await _createFile(builder.buildDocument().toXmlString(pretty: true));
  }

  void _buildPageElement(XmlBuilder builder, Page page) {
    builder.element('url', nest: () {
      builder.element('loc', nest: () {
        builder.text(page.getPublicUrl(config));
      });

      if (page.updated != null) {
        builder.element('lastmod', nest: () {
          builder.text(page.updated.toIso8601String());
        });
      }
    });
  }

  Future<void> _createFile(String content) async {
    final file = await File(
      p.join(config.build.publicDir, 'sitemap.xml'),
    ).create();

    await file.writeAsString(content);
  }
}
