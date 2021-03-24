import 'package:blake/src/content/page.dart';

/// Special [Page] used for aliasing/redirecting pages. Whenever you specify
/// `aliases` inside your frontmatter, [RedirectPage] is created.
class RedirectPage extends Page {
  RedirectPage({
    required String path,
    required this.destinationUrl,
  }) : super(path: path);

  final String destinationUrl;

  @override
  Map<String, Object> toMap() {
    return {};
  }

  // FIXME: This should not be inside Markdown content.
  @override
  String? get content {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="refresh" content="0; url=$destinationUrl" />
</head>
</html>
''';
  }
}
