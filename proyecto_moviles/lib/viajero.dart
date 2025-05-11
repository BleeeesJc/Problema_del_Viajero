import 'package:flutter/material.dart';

class Viajero extends CustomPainter {
  Offset posicion;
  double ancho;
  double alto;
  Color color = Colors.red;

  Viajero(this.posicion, this.ancho, this.alto, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = color;

    double x = posicion.dx;
    double y = posicion.dy;

    Path path = Path();
    double radioCabeza = ancho * 0.15;
    path.addOval(
      Rect.fromCircle(
        center: Offset(x + ancho * 0.5, y + radioCabeza),
        radius: radioCabeza,
      ),
    );
    double troncoTop = y + radioCabeza * 2;
    double troncoHeight = alto * 0.4;
    double troncoWidth = ancho * 0.2;
    path.addRect(
      Rect.fromCenter(
        center: Offset(x + ancho * 0.5, troncoTop + troncoHeight / 2),
        width: troncoWidth,
        height: troncoHeight,
      ),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
