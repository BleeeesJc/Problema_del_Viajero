import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:proyecto_moviles/conexion.dart';
import 'package:proyecto_moviles/lienzopainter.dart';

class Lienzo extends StatefulWidget {
  const Lienzo({super.key});

  @override
  State<Lienzo> createState() => _LienzoState();
}

class _LienzoState extends State<Lienzo> {
  List<Offset> ciudades = [];
  List<String> nombresCiudades = [];
  List<Conexion> conexiones = [];
  List<Color> coloresCiudades = [];
  double tamvalue = 10;
  bool modoAgregar = false;
  bool modoConectar = false;
  bool modoEliminar = false;
  bool modoEditar = false;
  bool modoColor = false;
  int? ciudadSeleccionada;
  double toleranciaToque = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de herramientas arriba
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Tamaño:"),
                  ),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: Slider(
                      min: 1,
                      max: 50,
                      value: tamvalue,
                      label: tamvalue.round().toString(),
                      onChanged: (value) => setState(() => tamvalue = value),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      modoAgregar ? Icons.location_on : Icons.location_off,
                      color: modoAgregar ? Colors.green : Colors.grey,
                    ),
                    tooltip: modoAgregar ? "Modo agregar" : "Activar agregar",
                    onPressed:
                        () => setState(() {
                          modoAgregar = !modoAgregar;
                          modoConectar = false;
                          modoEliminar = false;
                          modoEditar = false;
                          ciudadSeleccionada = null;
                        }),
                  ),
                  IconButton(
                    icon: Icon(
                      modoConectar ? Icons.share : Icons.share_outlined,
                      color: modoConectar ? Colors.orange : Colors.grey,
                    ),
                    tooltip:
                        modoConectar ? "Modo conectar" : "Activar conectar",
                    onPressed:
                        () => setState(() {
                          modoConectar = !modoConectar;
                          modoAgregar = false;
                          modoEliminar = false;
                          modoEditar = false;
                          ciudadSeleccionada = null;
                        }),
                  ),
                  IconButton(
                    icon: Icon(
                      modoEliminar
                          ? Icons.remove_circle
                          : Icons.remove_circle_outline,
                      color: modoEliminar ? Colors.red : Colors.grey,
                    ),
                    tooltip:
                        modoEliminar
                            ? "Modo eliminar conexiones"
                            : "Activar eliminar conexiones",
                    onPressed:
                        () => setState(() {
                          modoEliminar = !modoEliminar;
                          modoAgregar = false;
                          modoConectar = false;
                          modoEditar = false;
                          ciudadSeleccionada = null;
                        }),
                  ),
                  IconButton(
                    icon: Icon(
                      modoEditar ? Icons.edit : Icons.edit_outlined,
                      color: modoEditar ? Colors.blue : Colors.grey,
                    ),
                    tooltip:
                        modoEditar
                            ? "Modo editar ciudad/peso"
                            : "Activar editar ciudad/peso",
                    onPressed:
                        () => setState(() {
                          modoEditar = !modoEditar;
                          modoAgregar = false;
                          modoConectar = false;
                          modoEliminar = false;
                          ciudadSeleccionada = null;
                        }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    tooltip: "Borrar todo",
                    onPressed:
                        () => setState(() {
                          ciudades.clear();
                          nombresCiudades.clear();
                          conexiones.clear();
                          ciudadSeleccionada = null;
                        }),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.color_lens,
                      color: modoColor ? Colors.purple : Colors.grey,
                    ),
                    tooltip: modoColor ? "Modo color" : "Activar color",
                    onPressed:
                        () => setState(() {
                          modoColor = !modoColor;
                          modoAgregar =
                              modoConectar = modoEliminar = modoEditar = false;
                          ciudadSeleccionada = null;
                        }),
                  ),
                ],
              ),
            ),
          ),
          // Lienzo debajo
          Expanded(
            child: GestureDetector(
              onPanStart: (DragStartDetails details) {
                Offset pos = details.localPosition;
                if (![
                  modoAgregar,
                  modoConectar,
                  modoEliminar,
                  modoEditar,
                  modoColor,
                ].any((m) => m)) {
                  for (var i = 0; i < ciudades.length; i++) {
                    if ((ciudades[i] - pos).distance <= tamvalue) {
                      ciudadSeleccionada = i;
                      break;
                    }
                  }
                }
              },
              onPanUpdate: (DragUpdateDetails details) {
                if (ciudadSeleccionada != null &&
                    ![
                      modoAgregar,
                      modoConectar,
                      modoEliminar,
                      modoEditar,
                      modoColor,
                    ].any((m) => m)) {
                  setState(() {
                    ciudades[ciudadSeleccionada!] = details.localPosition;
                  });
                }
              },
              onPanEnd: (DragEndDetails details) {
                ciudadSeleccionada = null;
              },
              onTapDown: (TapDownDetails details) {
                Offset tapPos = details.localPosition;

                if (modoAgregar) {
                  setState(() {
                    ciudades.add(tapPos);
                    nombresCiudades.add('Ciudad ${ciudades.length}');
                    coloresCiudades.add(Colors.blue);
                  });
                } else if (modoConectar) {
                  for (int i = 0; i < ciudades.length; i++) {
                    if ((ciudades[i] - tapPos).distance <= tamvalue) {
                      setState(() {
                        if (ciudadSeleccionada == null) {
                          ciudadSeleccionada = i;
                        } else if (ciudadSeleccionada != i) {
                          bool existe = conexiones.any(
                            (c) =>
                                (c.ciudad1 == ciudadSeleccionada &&
                                    c.ciudad2 == i) ||
                                (c.ciudad1 == i &&
                                    c.ciudad2 == ciudadSeleccionada),
                          );
                          if (!existe) {
                            conexiones.add(
                              Conexion(ciudadSeleccionada!, i, 1.0),
                            );
                          }
                          ciudadSeleccionada = null;
                        }
                      });
                      break;
                    }
                  }
                } else if (modoEliminar) {
                  for (int i = 0; i < conexiones.length; i++) {
                    Offset p1 = ciudades[conexiones[i].ciudad1];
                    Offset p2 = ciudades[conexiones[i].ciudad2];
                    if (estaCerca(tapPos, p1, p2)) {
                      setState(() => conexiones.removeAt(i));
                      break;
                    }
                  }
                } else if (modoEditar) {
                  for (int i = 0; i < ciudades.length; i++) {
                    if ((ciudades[i] - tapPos).distance <= tamvalue) {
                      mostrarDialogoNombre(i);
                      return;
                    }
                  }
                  for (int i = 0; i < conexiones.length; i++) {
                    Offset p1 = ciudades[conexiones[i].ciudad1];
                    Offset p2 = ciudades[conexiones[i].ciudad2];
                    if (estaCerca(tapPos, p1, p2)) {
                      mostrarDialogoPeso(i);
                      return;
                    }
                  }
                } else if (modoColor) {
                  for (var i = 0; i < ciudades.length; i++) {
                    if ((ciudades[i] - tapPos).distance <= tamvalue) {
                      mostrarColorPicker(i);
                      return;
                    }
                  }
                }
              },
              child: CustomPaint(
                painter: LienzoPainter(
                  ciudades,
                  nombresCiudades,
                  coloresCiudades,
                  tamvalue,
                  conexiones,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}),
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
    Offset pp = Offset(a.dx + t * dx, a.dy + t * dy);
    double distancia = (punto - pp).distance;
    return distancia <= toleranciaToque;
  }

  void mostrarDialogoPeso(int indexConexion) {
    TextEditingController controller = TextEditingController(
      text: conexiones[indexConexion].peso.toString(),
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Editar peso"),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Peso"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  double? nuevo = double.tryParse(controller.text);
                  if (nuevo != null) {
                    setState(() => conexiones[indexConexion].peso = nuevo);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
    );
  }

  void mostrarDialogoNombre(int indexCiudad) {
    TextEditingController controller = TextEditingController(
      text: nombresCiudades[indexCiudad],
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Editar nombre"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Nombre ciudad"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  setState(
                    () => nombresCiudades[indexCiudad] = controller.text,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
    );
  }

  void mostrarColorPicker(int idx) {
    Color pickerColor = coloresCiudades[idx];
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Color de ${nombresCiudades[idx]}"),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: pickerColor,
                onColorChanged: (c) => pickerColor = c,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  setState(() => coloresCiudades[idx] = pickerColor);
                  Navigator.pop(ctx);
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
    );
  }
}
