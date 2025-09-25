// file: lib/src/utils/logger.dart

import 'dart:io';

import 'package:ansicolor/ansicolor.dart';

enum LogType { info, success, warning, error }

final AnsiPen _infoPen = AnsiPen()..blue();
final AnsiPen _successPen = AnsiPen()..green();
final AnsiPen _warningPen = AnsiPen()..yellow();
final AnsiPen _errorPen = AnsiPen()..red();

void kLog(String message, {LogType type = LogType.info}) {
  switch (type) {
    case LogType.success:
      print(_successPen(message));
      break;
    case LogType.warning:
      print(_warningPen(message));
      break;
    case LogType.error:
      stderr.writeln(_errorPen(message));
      break;
    default:
      print(_infoPen(message));
  }
}
