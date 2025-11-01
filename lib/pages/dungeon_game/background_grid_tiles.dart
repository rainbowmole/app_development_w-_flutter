import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GridBackground extends StatelessWidget {
  final double cellSize;
  const GridBackground({this.cellSize = 50});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: GridPainter(cellSize),
    );
  }
}

class GridPainter extends CustomPainter {
  final double cellSize;
  GridPainter(this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}