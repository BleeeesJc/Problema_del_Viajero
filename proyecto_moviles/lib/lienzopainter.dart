import 'dart:math';

import 'package:flutter/material.dart';
import 'package:proyecto_moviles/ciudades.dart';
import 'package:proyecto_moviles/conexion.dart';
import 'package:proyecto_moviles/conexiones.dart';
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
    this.tamViajero = 15,
  ]);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Set<String> aristasRuta = {};
    if (ruta != null && ruta!.length > 1) {
      for (int i = 0; i < ruta!.length; i++) {
        int a = ruta![i];
        int b = ruta![(i + 1) % ruta!.length];
        int mn = a < b ? a : b;
        int mx = a < b ? b : a;
        aristasRuta.add('$mn-$mx');
      }
    }

    double pesoFontSize = tam * 0.20;
    TextStyle textStylePeso = TextStyle(
      color: Colors.black,
      fontSize: pesoFontSize,
    );

    for (var conexion in conexiones) {
      var p1 = ciudades[conexion.ciudad1];
      var p2 = ciudades[conexion.ciudad2];

      bool enRuta = false;
      int mn =
          conexion.ciudad1 < conexion.ciudad2
              ? conexion.ciudad1
              : conexion.ciudad2;
      int mx =
          conexion.ciudad1 < conexion.ciudad2
              ? conexion.ciudad2
              : conexion.ciudad1;
      if (aristasRuta.contains('$mn-$mx')) {
        enRuta = true;
      }

      Conexiones painter = Conexiones(p1, p2, enRuta, tam);
      painter.paint(canvas, Size.zero);

      double dx = p2.dx - p1.dx;
      double dy = p2.dy - p1.dy;
      double length = sqrt(dx * dx + dy * dy);
      double ux = -dy / length;
      double uy = dx / length;
      Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      Offset offsetPeso = mid + Offset(ux * tam * 0.2, uy * tam * 0.2);

      TextSpan spanPeso = TextSpan(
        text: conexion.peso.toStringAsFixed(1),
        style: textStylePeso,
      );
      TextPainter tpPeso = TextPainter(
        text: spanPeso,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      double padding = 4.0;
      Rect rectBg = Rect.fromLTWH(
        offsetPeso.dx - tpPeso.width / 2 - padding,
        offsetPeso.dy - tpPeso.height / 2 - padding,
        tpPeso.width + padding * 2,
        tpPeso.height + padding * 2,
      );
      Paint paintBg = Paint()..color = Colors.white.withOpacity(0.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rectBg, Radius.circular(4)),
        paintBg,
      );

      tpPeso.paint(
        canvas,
        Offset(
          offsetPeso.dx - tpPeso.width / 2,
          offsetPeso.dy - tpPeso.height / 2,
        ),
      );
    }

    double textoFontSize = tam * 0.2;
    TextStyle textStyleCiudad = TextStyle(
      color: Colors.black,
      fontSize: textoFontSize,
    );

    for (int i = 0; i < ciudades.length; i++) {
      var c = ciudades[i];

      Ciudades(
        Offset(c.dx - tam / 2, c.dy - tam / 2),
        tam,
        tam,
        colores[i],
      ).paint(canvas, Size(tam, tam));

      TextSpan spanLabel = TextSpan(text: nombres[i], style: textStyleCiudad);
      TextPainter tpLabel = TextPainter(
        text: spanLabel,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      Offset offsetLabel = Offset(
        c.dx - tpLabel.width / 2,
        c.dy - tam / 2 - tpLabel.height - 4,
      );

      Rect bgLabelRect = Rect.fromLTWH(
        offsetLabel.dx - 2,
        offsetLabel.dy - 2,
        tpLabel.width + 4,
        tpLabel.height + 4,
      );
      Paint paintLabelBg = Paint()..color = Colors.white.withOpacity(0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgLabelRect, Radius.circular(4)),
        paintLabelBg,
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
