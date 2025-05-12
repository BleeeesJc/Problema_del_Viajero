import 'package:flutter/material.dart';
import 'package:proyecto_moviles/ciudades.dart';
import 'package:proyecto_moviles/conexion.dart';
import 'package:proyecto_moviles/viajero.dart';

class LienzoPainter extends CustomPainter {
  List<Offset> ciudades;
  List<String> nombres;
  List<Color> colores;
  double tam;
  List<Conexion> conexiones;
  List<int>? ruta;
  Offset? posViajero;
  double tamViajero;

  LienzoPainter(
    this.ciudades,
    this.nombres,
    this.colores,
    this.tam,
    this.conexiones, [
    this.ruta,
    this.posViajero,
    this.tamViajero = 20,
  ]);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Paint paintNormal =
        Paint()
          ..color = Colors.black
          ..strokeWidth = tam * 0.02;

    Paint paintRuta =
        Paint()
          ..color = Colors.red
          ..strokeWidth = tam * 0.04;

    double pesoFontSize = tam * 0.20;
    for (var conexion in conexiones) {
      var c1 = ciudades[conexion.ciudad1];
      var c2 = ciudades[conexion.ciudad2];
      bool enRuta = false;
      if (ruta != null) {
        for (int i = 0; i < ruta!.length - 1; i++) {
          int a = ruta![i];
          int b = ruta![i + 1];
          if ((a == conexion.ciudad1 && b == conexion.ciudad2) ||
              (a == conexion.ciudad2 && b == conexion.ciudad1)) {
            enRuta = true;
            break;
          }
        }
      }
      canvas.drawLine(c1, c2, enRuta ? paintRuta : paintNormal);
      TextStyle estiloPeso = TextStyle(
        color: Colors.black,
        fontSize: pesoFontSize,
      );
      TextSpan pesoText = TextSpan(
        text: conexion.peso.toStringAsFixed(1),
        style: estiloPeso,
      );
      TextPainter tpPeso = TextPainter(
        text: pesoText,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      Offset centro = Offset((c1.dx + c2.dx) / 2, (c1.dy + c2.dy) / 1.95);
      Offset posicionPeso = Offset(
        centro.dx - tpPeso.width / 2,
        centro.dy - tpPeso.height / 2 + tam * 0.08, // separación proporcional
      );
      tpPeso.paint(canvas, posicionPeso);
    }
    for (var i = 0; i < ciudades.length; i++) {
      var ciudad = ciudades[i];
      Ciudades(
        Offset(ciudad.dx - tam / 2, ciudad.dy - tam / 2),
        tam,
        tam,
        colores[i],
      ).paint(canvas, Size(tam, tam));

      double textoFontSize = tam * 0.2;
      TextStyle estiloTexto = TextStyle(
        color: Colors.black,
        fontSize: textoFontSize,
      );

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

    if (posViajero != null) {
      Viajero(
        Offset(
          posViajero!.dx - tamViajero / 2,
          posViajero!.dy - tamViajero / 2,
        ),
        tamViajero,
        tamViajero,
        Colors.red,
      ).paint(canvas, Size(tamViajero, tamViajero));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
