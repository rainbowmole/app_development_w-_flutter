import 'package:flutter/material.dart';

class GridBackground extends StatelessWidget {
  final double cellSize;

  const GridBackground({
    this.cellSize = 32,
  });

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
    final gridPaint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.2)
      ..strokeWidth = 2;

    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return false;
  }
}

class GridHighlightLayer extends StatelessWidget {
  final double cellSize;
  final List<Offset> highlightedCells;

  const GridHighlightLayer({
    required this.cellSize,
    required this.highlightedCells,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: GridHighlightPainter(cellSize, highlightedCells),
    );
  }
}

class GridHighlightPainter extends CustomPainter {
  final double cellSize;
  final List<Offset> highlightedCells;

  GridHighlightPainter(this.cellSize, this.highlightedCells);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color.fromRGBO(106, 137, 167, 0.5)
      ..style = PaintingStyle.fill;

    for (final cell in highlightedCells) {
      final rect = Rect.fromCenter(
        center: Offset(cell.dx * cellSize + cellSize / 2,
                       cell.dy * cellSize + cellSize / 2),
        width: cellSize,
        height: cellSize,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridHighlightPainter oldDelegate) {
    return oldDelegate.highlightedCells != highlightedCells;
  }
}