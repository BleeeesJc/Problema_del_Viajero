import 'package:flutter/material.dart';
import 'package:proyecto_moviles/conexion.dart';

class LienzoPainter extends CustomPainter {
  List<Offset> ciudades;
  List<String> nombres;
  double tam;
  List<Conexion> conexiones;

  LienzoPainter(this.ciudades, this.nombres, this.tam, this.conexiones);

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

      var tpPeso = TextPainter(
        text: pesoText,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tpPeso.layout();
      var posicionPeso = Offset(
        centro.dx - tpPeso.width / 2,
        centro.dy - tpPeso.height / 2 + 8,
      );
      tpPeso.paint(canvas, posicionPeso);
    }

    for (var i = 0; i < ciudades.length; i++) {
      var ciudad = ciudades[i];
      canvas.drawCircle(ciudad, tam / 2, paintNodo);

      var labelText = TextSpan(text: nombres[i], style: estiloTexto);
      var tpLabel = TextPainter(
        text: labelText,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tpLabel.layout();
      var offsetLabel = Offset(
        ciudad.dx - tpLabel.width / 2,
        ciudad.dy + tam / 2 + 4,
      );
      tpLabel.paint(canvas, offsetLabel);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
