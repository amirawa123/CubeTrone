import 'package:flutter/material.dart';

Widget buildLinePainter(
    {required Offset startPoint, required Offset endPoint, Color? color}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final startPointPixel = Offset(
        constraints.maxWidth * startPoint.dx,
        constraints.maxHeight * startPoint.dy,
      );
      final endPointPixel = Offset(
        constraints.maxWidth * endPoint.dx,
        constraints.maxHeight * endPoint.dy,
      );
      return CustomPaint(
        painter: LinePainter(
          startPoint: startPointPixel,
          endPoint: endPointPixel,
          color: color ?? const Color(0xFFAD0000),
        ),
      );
    },
  );
}

class LinePainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;
  final Color color;

  LinePainter({
    required this.startPoint,
    required this.endPoint,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 10;
    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

Widget buildCirclePainter({required double centerX, required double centerY}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final centerXPixel = constraints.maxWidth * centerX;
      final centerYPixel = constraints.maxHeight * centerY;
      final radiusPixel = constraints.maxWidth * 0.013;
      return CustomPaint(
        painter: CirclePainter(
          centerX: centerXPixel,
          centerY: centerYPixel,
          radius: radiusPixel,
        ),
      );
    },
  );
}

class CirclePainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double radius;

  CirclePainter({
    required this.centerX,
    required this.centerY,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFAD0000)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
