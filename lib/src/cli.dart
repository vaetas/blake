import 'package:ansicolor/ansicolor.dart';

final bluePen = AnsiPen()..blue(bg: false, bold: true);
final errorPen = AnsiPen()..red(bg: false, bold: true);
final warningPen = AnsiPen()..yellow(bg: false, bold: true);

void printInfo(Object msg) => print(bluePen(msg.toString()));

void printError(Object e) => print(errorPen(e.toString()));

void printWarning(Object msg) => print(warningPen(msg.toString()));
