import 'dart:io';

import 'package:blake/blake.dart';

void main() {
  File('lib/post.md').readAsString().then((value) {
    print(parse(value));
  });
}
