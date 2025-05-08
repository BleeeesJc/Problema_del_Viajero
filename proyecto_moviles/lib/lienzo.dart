import 'package:flutter/material.dart';
import 'package:proyecto_moviles/lienzopainter.dart';

class Lienzo extends StatefulWidget {
  const Lienzo({super.key});

  @override
  State<Lienzo> createState() => _LienzoState();
}

class _LienzoState extends State<Lienzo> {
  List<Offset> ciudades = [];
  List<List<int>> conexiones = [];
  double tamvalue = 10;
  bool agregarCiudad = false;
  bool conectarCiudades = false;
  bool eliminarConexiones = false;
  int? ciudadSeleccionada;

  double toleranciaToque = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (TapDownDetails details) {
          Offset tapPos = details.localPosition;

          if (agregarCiudad) {
            setState(() {
              ciudades.add(tapPos);
            });
          } else if (conectarCiudades) {
            for (int i = 0; i < ciudades.length; i++) {
              if ((ciudades[i] - tapPos).distance <= tamvalue) {
                setState(() {
                  if (ciudadSeleccionada == null) {
                    ciudadSeleccionada = i;
                  } else if (ciudadSeleccionada != i) {
                    List<int> par = [ciudadSeleccionada!, i];
                    List<int> parInvertido = [i, ciudadSeleccionada!];
                    bool existe = conexiones.any(
                      (c) =>
                          (c[0] == par[0] && c[1] == par[1]) ||
                          (c[0] == parInvertido[0] && c[1] == parInvertido[1]),
                    );
                    if (!existe) {
                      conexiones.add(par);
                    }
                    ciudadSeleccionada = null;
                  }
                });
                break;
              }
            }
          } else if (eliminarConexiones) {
            for (int i = 0; i < conexiones.length; i++) {
              Offset p1 = ciudades[conexiones[i][0]];
              Offset p2 = ciudades[conexiones[i][1]];
              if (estaCerca(tapPos, p1, p2)) {
                setState(() {
                  conexiones.removeAt(i);
                });
                break;
              }
            }
          }
        },
        child: Stack(
          children: [
            CustomPaint(
              painter: LienzoPainter(ciudades, tamvalue, conexiones),
              size: Size.infinite,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 60,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Tamaño:"),
                ),
                Container(
                  width: 150,
                  height: 50,
                  child: Slider(
                    min: 1,
                    max: 50,
                    value: tamvalue,
                    label: tamvalue.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        tamvalue = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    agregarCiudad ? Icons.location_on : Icons.location_off,
                    color: agregarCiudad ? Colors.green : Colors.grey,
                  ),
                  tooltip:
                      agregarCiudad
                          ? "Agregar ciudad activo"
                          : "Activar agregar ciudad",
                  onPressed: () {
                    setState(() {
                      agregarCiudad = !agregarCiudad;
                      conectarCiudades = false;
                      eliminarConexiones = false;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    conectarCiudades ? Icons.share : Icons.share_outlined,
                    color: conectarCiudades ? Colors.orange : Colors.grey,
                  ),
                  tooltip:
                      conectarCiudades
                          ? "Conectar ciudades activo"
                          : "Activar conectar ciudades",
                  onPressed: () {
                    setState(() {
                      conectarCiudades = !conectarCiudades;
                      agregarCiudad = false;
                      eliminarConexiones = false;
                      ciudadSeleccionada = null;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    eliminarConexiones
                        ? Icons.highlight_remove
                        : Icons.remove_circle_outline,
                    color: eliminarConexiones ? Colors.red : Colors.grey,
                  ),
                  tooltip:
                      eliminarConexiones
                          ? "Eliminar conexiones activo"
                          : "Activar eliminación de conexiones",
                  onPressed: () {
                    setState(() {
                      eliminarConexiones = !eliminarConexiones;
                      agregarCiudad = false;
                      conectarCiudades = false;
                      ciudadSeleccionada = null;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  tooltip: "Borrar todo",
                  onPressed: () {
                    setState(() {
                      ciudades.clear();
                      conexiones.clear();
                      ciudadSeleccionada = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool estaCerca(Offset punto, Offset a, Offset b) {
    double dx = b.dx - a.dx;
    double dy = b.dy - a.dy;
    if (dx == 0 && dy == 0) return false;
    double longitud = (b - a).distance;
    double t =
        ((punto.dx - a.dx) * dx + (punto.dy - a.dy) * dy) /
        (longitud * longitud);
    t = t.clamp(0.0, 1.0);
    Offset puntoProyectado = Offset(a.dx + t * dx, a.dy + t * dy);
    double distancia = (punto - puntoProyectado).distance;
    return distancia <= toleranciaToque;
  }
}
