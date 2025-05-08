import 'package:flutter/material.dart';
import 'package:proyecto_moviles/lienzopainter.dart';

class Lienzo extends StatefulWidget {
  const Lienzo({super.key});

  @override
  State<Lienzo> createState() => _LienzoState();
}

class _LienzoState extends State<Lienzo> {
  final List<Offset> ciudades = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        setState(() {
          ciudades.add(details.localPosition);
        });
      },
      child: CustomPaint(size: Size.infinite, painter: LienzoPainter(ciudades)),
    );
  }
}
