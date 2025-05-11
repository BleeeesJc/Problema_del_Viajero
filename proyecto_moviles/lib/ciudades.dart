import 'package:flutter/material.dart';

class Ciudades extends CustomPainter {
  Offset posicion;
  double ancho;
  double alto;
  Color color = Colors.blue;

  Ciudades(this.posicion, this.ancho, this.alto, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = color;

    double x = posicion.dx;
    double y = posicion.dy;

    Path path = Path();
    path.addRect(Rect.fromLTWH(x, y + alto * 0.4, ancho * 0.1, alto * 0.6));
    path.addRect(
      Rect.fromLTWH(x + ancho * 0.12, y + alto * 0.3, ancho * 0.12, alto * 0.7),
    );
    path.moveTo(x + ancho * 0.26, y + alto);
    path.lineTo(x + ancho * 0.26, y + alto * 0.1);
    path.lineTo(x + ancho * 0.31, y + alto * 0.1);
    path.lineTo(x + ancho * 0.31, y);
    path.lineTo(x + ancho * 0.37, y);
    path.lineTo(x + ancho * 0.37, y + alto * 0.1);
    path.lineTo(x + ancho * 0.43, y + alto * 0.1);
    path.lineTo(x + ancho * 0.43, y + alto);
    path.close();
    path.moveTo(x + ancho * 0.45, y + alto);
    path.lineTo(x + ancho * 0.45, y + alto * 0.2);
    path.quadraticBezierTo(
      x + ancho * 0.7,
      y + alto * 0.1,
      x + ancho * 0.7,
      y + alto,
    );
    path.close();
    path.addRect(
      Rect.fromLTWH(x + ancho * 0.72, y + alto * 0.3, ancho * 0.1, alto * 0.7),
    );
    path.addRect(
      Rect.fromLTWH(x + ancho * 0.84, y + alto * 0.4, ancho * 0.1, alto * 0.6),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
