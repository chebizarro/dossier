import 'package:flutter/material.dart';

class EdgeWidget extends StatelessWidget {
  final Offset start;
  final Offset end;

  EdgeWidget({required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: EdgePainter(start: start, end: end),
    );
  }
}

class EdgePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  EdgePainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
