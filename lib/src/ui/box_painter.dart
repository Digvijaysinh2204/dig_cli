import 'package:ansicolor/ansicolor.dart';

class BoxPainter {
  final AnsiPen titlePen = AnsiPen()..cyan(bold: true);
  final AnsiPen borderPen = AnsiPen()..white();
  final AnsiPen textPen = AnsiPen()..white();

  void drawHeader(String title, {int width = 50}) {
    final horizontalLine = '═' * (width - 2);
    print(borderPen('╔$horizontalLine╗'));

    final padding = (width - title.length - 2) ~/ 2;
    final leftPadding = ' ' * padding;
    final rightPadding = ' ' * (width - title.length - padding - 2);

    print(
        '${borderPen('║')}$leftPadding${titlePen(title)}$rightPadding${borderPen('║')}');
    print(borderPen('╠$horizontalLine╣'));
  }

  void drawRow(String key, String value, {int width = 50}) {
    final labelWidth = 15;
    final contentWidth = width - labelWidth - 5;

    final label = key.padRight(labelWidth);
    final content = value.length > contentWidth
        ? '${value.substring(0, contentWidth - 3)}...'
        : value.padRight(contentWidth);

    print(
        '${borderPen('║')}  ${textPen(label)}: ${textPen(content)} ${borderPen('║')}');
  }

  void drawMenuItem(String index, String label, {int width = 50}) {
    final item = ' [$index] $label';
    final padding = ' ' * (width - item.length - 2);
    print('${borderPen('║')}${textPen(item)}$padding${borderPen('║')}');
  }

  void drawFooter({int width = 50}) {
    final horizontalLine = '═' * (width - 2);
    print(borderPen('╚$horizontalLine╝'));
  }

  void drawSimpleBox(String text, {int width = 50}) {
    final horizontalLine = '─' * (width - 2);
    print(borderPen('┌$horizontalLine┐'));

    final padding = ' ' * (width - text.length - 4);
    print('${borderPen('│')}  ${textPen(text)}$padding ${borderPen('│')}');

    print(borderPen('└$horizontalLine┘'));
  }
}
