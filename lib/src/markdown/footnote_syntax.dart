import 'package:markdown/markdown.dart';

class FootnoteReferenceSyntax extends TextSyntax {
  FootnoteReferenceSyntax() : super(_referencePattern.pattern);

  @override
  bool onMatch(InlineParser parser, Match match) {
    final index = _parseFootnoteIndex(match.group(0)!);
    parser.addNode(Element.text('sup', index));
    return true;
  }
}

// TODO: Render footnotes as ordered list.
class FootnoteSyntax extends LongBlockHtmlSyntax {
  FootnoteSyntax() : super(_startPattern, _endPattern);

  static const _startPattern = r'\[\^[0-9]+\]:';
  static const _endPattern = r'(?:    | {0,3}\t)(.*)|(^(?:[ \t]*)$)';

  @override
  Node parse(BlockParser parser) {
    final childLines = <String>[];

    while (!parser.isDone) {
      childLines.add(parser.current);
      parser.advance();

      if (!parser.matches(RegExp(_endPattern))) {
        break;
      }
    }

    final lines =
        childLines.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final index = _referencePattern.firstMatch(lines.first)!.group(0);

    return Element(
      'p',
      [
        Element.text('span', index!),
      ],
    );
  }
}

/// Footnote reference can only contain number and letter.
final _referencePattern = RegExp(r'\[\^[0-9a-zA-Z]+\]');

/// Example: '[^123]' => '123'
String _parseFootnoteIndex(String markdown) {
  if (!_referencePattern.hasMatch(markdown)) {
    throw ArgumentError('$markdown is not a footnote reference');
  }

  return markdown.substring(2, markdown.length - 1);
}
