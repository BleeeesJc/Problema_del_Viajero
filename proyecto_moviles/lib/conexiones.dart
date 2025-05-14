import 'dart:math';
import 'package:flutter/material.dart';

class Conexiones extends CustomPainter {
  Offset inicio;
  Offset fin;
  bool destacada;
  double tam;

  Conexiones(this.inicio, this.fin, this.destacada, this.tam);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintConexion =
        Paint()
          ..color = destacada ? Colors.green : Colors.black
          ..strokeWidth = tam * 0.04
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;

    Offset mid = Offset((inicio.dx + fin.dx) / 2, (inicio.dy + fin.dy) / 2);
    double dx = fin.dx - inicio.dx;
    double dy = fin.dy - inicio.dy;
    double length = sqrt(dx * dx + dy * dy);
    double ux = -dy / length;
    double uy = dx / length;

    Offset controlPoint = mid + Offset(ux * tam * 0.4, uy * tam * 0.4);
    Path path =
        Path()
          ..moveTo(inicio.dx, inicio.dy)
          ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, fin.dx, fin.dy);

    canvas.drawPath(path, paintConexion);
  }

  @override
  bool shouldRepaint(covariant Conexiones old) {
    return true;
  }
}
