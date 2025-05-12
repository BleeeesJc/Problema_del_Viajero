import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:proyecto_moviles/algortimogen.dart';
import 'package:proyecto_moviles/conexion.dart';
import 'package:proyecto_moviles/lienzopainter.dart';

class Lienzo extends StatefulWidget {
  const Lienzo({super.key});

  @override
  State<Lienzo> createState() => _LienzoState();
}

class _LienzoState extends State<Lienzo> with TickerProviderStateMixin {
  List<Offset> ciudades = [];
  List<String> nombresCiudades = [];
  List<Conexion> conexiones = [];
  List<Color> coloresCiudades = [];
  List<int>? ruta;
  double tamvalue = 50;
  bool modoAgregar = false;
  bool modoConectar = false;
  bool modoEliminar = false;
  bool modoEditar = false;
  bool modoColor = false;
  int? ciudadSeleccionada;
  double toleranciaToque = 10.0;
  double velocidadAnimacion = 1.0;
  bool animacionPausada = false;
  Duration? baseDuration;

  AnimationController? controller;
  Animation<double>? animation;
  Offset? posViajero;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ancho = MediaQuery.of(context).size.width;
    var alto =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var base = 400.0;
    var scale = ancho / base;
    var tamAbs = tamvalue * scale;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Tamaño:"),
                  ),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: Slider(
                      min: 25,
                      max: 100,
                      value: tamvalue,
                      label: tamvalue.round().toString(),
                      onChanged: (value) => setState(() => tamvalue = value),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: IconButton(
                      iconSize: 32.0,
                      icon: Icon(
                        modoAgregar ? Icons.add : Icons.add_outlined,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: IconButton(
                      iconSize: 32.0,
                      icon: Icon(
                        modoConectar ? Icons.link : Icons.link_off,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: IconButton(
                      iconSize: 28.0,
                      icon: Icon(
                        modoEliminar
                            ? Icons.remove_circle
                            : Icons.remove_circle_outline,
                        color: modoEliminar ? Colors.red : Colors.grey,
                      ),
                      tooltip:
                          modoEliminar
                              ? "Modo eliminar conexiones/ciudad"
                              : "Activar eliminar conexiones/ciudad",
                      onPressed:
                          () => setState(() {
                            modoEliminar = !modoEliminar;
                            modoAgregar = false;
                            modoConectar = false;
                            modoEditar = false;
                            ciudadSeleccionada = null;
                          }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: IconButton(
                      iconSize: 28.0,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: IconButton(
                      iconSize: 28.0,
                      icon: const Icon(Icons.delete_forever),
                      tooltip: "Borrar todo",
                      onPressed:
                          () => setState(() {
                            controller?.stop();
                            controller?.dispose();
                            controller = null;
                            ciudades.clear();
                            nombresCiudades.clear();
                            conexiones.clear();
                            ciudadSeleccionada = null;
                            posViajero = null;
                          }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: IconButton(
                      iconSize: 28.0,
                      icon: Icon(
                        Icons.color_lens,
                        color: modoColor ? Colors.purple : Colors.grey,
                      ),
                      tooltip: modoColor ? "Modo color" : "Activar color",
                      onPressed:
                          () => setState(() {
                            modoColor = !modoColor;
                            modoAgregar =
                                modoConectar =
                                    modoEliminar = modoEditar = false;
                            ciudadSeleccionada = null;
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                  for (int i = 0; i < ciudades.length; i++) {
                    if ((ciudades[i] - tapPos).distance <= tamvalue) {
                      setState(() {
                        ciudades.removeAt(i);
                        nombresCiudades.removeAt(i);
                        coloresCiudades.removeAt(i);
                        conexiones.removeWhere(
                          (c) => c.ciudad1 == i || c.ciudad2 == i,
                        );
                        for (var c in conexiones) {
                          if (c.ciudad1 > i) c.ciudad1--;
                          if (c.ciudad2 > i) c.ciudad2--;
                        }
                      });
                      return;
                    }
                  }
                  for (int j = 0; j < conexiones.length; j++) {
                    Offset p1 = ciudades[conexiones[j].ciudad1];
                    Offset p2 = ciudades[conexiones[j].ciudad2];
                    if (estaCerca(tapPos, p1, p2)) {
                      setState(() {
                        conexiones.removeAt(j);
                      });
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
                size: Size(ancho, alto),
                painter: LienzoPainter(
                  ciudades,
                  nombresCiudades,
                  coloresCiudades,
                  tamAbs,
                  conexiones,
                  ruta,
                  posViajero,
                  tamAbs * 1.5,
                ),
              ),
            ),
          ),
          if (ruta != null)
            Positioned(
              bottom: 20,
              left: 20,
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: Slider(
                      min: 0.1,
                      max: 3.0,
                      divisions: 29,
                      label: "${velocidadAnimacion.toStringAsFixed(1)}×",
                      value: velocidadAnimacion,
                      onChanged: velocidad,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      animacionPausada ? Icons.play_arrow : Icons.pause,
                      size: 32,
                    ),
                    onPressed: pausa,
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (ciudadSeleccionada == null) {
            setState(() {
              modoAgregar = false;
              modoConectar = false;
              modoEliminar = false;
              modoEditar = false;
              modoColor = false;
            });
            mostrarSeleccionCiudadInicio();
          } else {
            resolverTSP();
          }
        },
        tooltip:
            ciudadSeleccionada == null
                ? "Seleccionar ciudad de inicio"
                : "Resolver TSP",
        child: const Icon(Icons.route),
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

  void mostrarSeleccionCiudadInicio() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Seleccionar ciudad de inicio"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(ciudades.length, (index) {
                return ListTile(
                  title: Text(nombresCiudades[index]),
                  onTap: () {
                    setState(() {
                      ciudadSeleccionada = index;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
            ],
          ),
    );
  }

  void resolverTSP() {
    if (ciudades.length < 2 || conexiones.isEmpty) return;
    int startCity = ciudadSeleccionada ?? 0;

    List<int> nuevaRuta = AlgoritmoGenetico.resolver(
      startCity: startCity,
      ciudades: ciudades,
      conexiones: conexiones,
      populationSize: 100,
      generations: 200,
      mutationRate: 0.05,
    );
    int idx = nuevaRuta.indexOf(startCity);
    if (idx > 0) {
      List<int> rota = [
        ...nuevaRuta.sublist(idx),
        ...nuevaRuta.sublist(0, idx),
      ];
      nuevaRuta = rota;
    }

    setState(() {
      ruta = nuevaRuta;
    });
    animacion();
  }

  void animacion() {
    if (ruta == null || ruta!.length < 2) return;
    List<Offset> puntosRuta = [];
    List<double> distSegmentos = [];
    double totalDist = 0;

    for (int i = 0; i < ruta!.length - 1; i++) {
      Offset a = ciudades[ruta![i]];
      Offset b = ciudades[ruta![i + 1]];
      puntosRuta.add(a);
      double d = (b - a).distance;
      distSegmentos.add(d);
      totalDist += d;
    }
    puntosRuta.add(ciudades[ruta!.last]);
    controller?.dispose();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (totalDist * 10).toInt()),
    );
    baseDuration = controller!.duration!;

    animation =
        Tween<double>(begin: 0, end: totalDist).animate(controller!)
          ..addListener(() {
            double recorrido = animation!.value;
            double acumulado = 0;
            for (int i = 0; i < distSegmentos.length; i++) {
              if (recorrido <= acumulado + distSegmentos[i]) {
                double t = (recorrido - acumulado) / distSegmentos[i];
                Offset p0 = puntosRuta[i];
                Offset p1 = puntosRuta[i + 1];
                posViajero = Offset.lerp(p0, p1, t);
                break;
              }
              acumulado += distSegmentos[i];
            }
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {}
          });

    controller!.forward(from: 0);
  }

  void velocidad(double value) {
    setState(() {
      velocidadAnimacion = value;
      if (controller != null && baseDuration != null) {
        final newMillis =
            (baseDuration!.inMilliseconds / velocidadAnimacion).round();
        controller!.duration = Duration(milliseconds: newMillis);
        if (!animacionPausada) {
          controller!.forward(from: controller!.value);
        }
      }
    });
  }

  void pausa() {
    setState(() {
      if (controller == null) return;
      if (animacionPausada) {
        controller!.forward(from: controller!.value);
      } else {
        controller!.stop();
      }
      animacionPausada = !animacionPausada;
    });
  }
}
