import 'package:flutter/material.dart';

class LienzoPainter extends CustomPainter {
  final List<Offset> ciudades;

  LienzoPainter(this.ciudades);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    for (final ciudad in ciudades) {
      canvas.drawCircle(ciudad, 8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LienzoPainter oldDelegate) => true;
}
