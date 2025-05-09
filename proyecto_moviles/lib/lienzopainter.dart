import 'package:flutter/material.dart';
import 'package:proyecto_moviles/conexion.dart';

class LienzoPainter extends CustomPainter {
  List<Offset> ciudades;
  double tam;
  List<Conexion> conexiones;

  LienzoPainter(this.ciudades, this.tam, this.conexiones);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    var paintNodo =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    var paintLinea =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2;

    var estiloTexto = TextStyle(color: Colors.black, fontSize: 12);

    for (var conexion in conexiones) {
      var c1 = ciudades[conexion.ciudad1];
      var c2 = ciudades[conexion.ciudad2];
      canvas.drawLine(c1, c2, paintLinea);
      var centro = Offset((c1.dx + c2.dx) / 2, (c1.dy + c2.dy) / 2);
      var pesoText = TextSpan(
        text: conexion.peso.toStringAsFixed(1),
        style: estiloTexto,
      );

      var tp = TextPainter(
        text: pesoText,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      var posicionPeso = Offset(
        centro.dx - tp.width / 2,
        centro.dy - tp.height / 2 + 8,
      );
      tp.paint(canvas, posicionPeso);
    }

    for (var i = 0; i < ciudades.length; i++) {
      var ciudad = ciudades[i];
      canvas.drawCircle(ciudad, tam / 2, paintNodo);

      var label = TextSpan(text: 'Ciudad ${i + 1}', style: estiloTexto);
      var tp = TextPainter(
        text: label,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      var offsetLabel = Offset(
        ciudad.dx - tp.width / 2,
        ciudad.dy + tam / 2 + 4,
      );
      tp.paint(canvas, offsetLabel);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
