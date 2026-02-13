import 'package:flutter/material.dart';

class CustomLine extends StatelessWidget {
  final bool isVertical;
  final double thickness;
  final double length;
  final Color color;
  final bool isDotted;

  const CustomLine({
    super.key,
    this.isVertical = false,
    this.thickness = 2,
    this.length = double.infinity,
    this.color = Colors.black,
    this.isDotted = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: isVertical ? Size(thickness, length) : Size(length, thickness),
      painter: _LinePainter(
        isVertical: isVertical,
        thickness: thickness,
        color: color,
        isDotted: isDotted,
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final bool isVertical;
  final double thickness;
  final Color color;
  final bool isDotted;

  _LinePainter({
    required this.isVertical,
    required this.thickness,
    required this.color,
    required this.isDotted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    if (isDotted) {
      final double totalLength = isVertical ? size.height : size.width;
      final int dashCount = (totalLength / 5).ceil();
      final double dashLength = totalLength / (2 * dashCount - 1);
      final double dashSpace = dashLength;

      double start = 0;
      for (int i = 0; i < dashCount; i++) {
        if (isVertical) {
          canvas.drawLine(
            Offset(size.width / 2, start),
            Offset(size.width / 2, start + dashLength),
            paint,
          );
        } else {
          canvas.drawLine(
            Offset(start, size.height / 2),
            Offset(start + dashLength, size.height / 2),
            paint,
          );
        }
        start += dashLength + dashSpace;
      }
    } else {
      if (isVertical) {
        canvas.drawLine(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.isVertical != isVertical ||
      oldDelegate.thickness != thickness ||
      oldDelegate.color != color ||
      oldDelegate.isDotted != isDotted;
}
