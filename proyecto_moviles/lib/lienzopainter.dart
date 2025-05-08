import 'package:flutter/material.dart';

class LienzoPainter extends CustomPainter {
  List<Offset> ciudades;
  double tam;
  List<List<int>> conexiones;

  LienzoPainter(this.ciudades, this.tam, this.conexiones);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Paint paintNodo =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    Paint paintLinea =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2;

    TextStyle estiloTexto = TextStyle(color: Colors.black, fontSize: 12);
    for (List<int> conexion in conexiones) {
      Offset c1 = ciudades[conexion[0]];
      Offset c2 = ciudades[conexion[1]];
      canvas.drawLine(c1, c2, paintLinea);
    }
    for (int i = 0; i < ciudades.length; i++) {
      Offset ciudad = ciudades[i];
      canvas.drawCircle(ciudad, tam / 2, paintNodo);

      TextSpan span = TextSpan(text: 'Ciudad ${i + 1}', style: estiloTexto);

      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      tp.layout();
      Offset offsetTexto = Offset(
        ciudad.dx - tp.width / 2,
        ciudad.dy + tam / 2 + 4,
      );

      tp.paint(canvas, offsetTexto);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
