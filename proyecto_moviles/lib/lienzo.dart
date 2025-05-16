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
  double tamvalue = 20;
  bool modoAgregar = false;
  bool modoConectar = false;
  bool modoEliminar = false;
  bool modoEditar = false;
  bool modoColor = false;
  int? ciudadSeleccionada;
  double? pesoTotal;
  double toleranciaToque = 60.0;
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
    var scale = ancho / 400;
    var tamAbs = tamvalue * scale;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Tamaño:"),
                      ),
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: Slider(
                          min: 20,
                          max: 100,
                          value: tamvalue,
                          label: tamvalue.round().toString(),
                          onChanged:
                              (value) => setState(() => tamvalue = value),
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
                          tooltip:
                              modoAgregar ? "Modo agregar" : "Activar agregar",
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
                              modoConectar
                                  ? "Modo conectar"
                                  : "Activar conectar",
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
                                ruta = null;
                                posViajero = null;
                                velocidadAnimacion = 1.0;
                                animacionPausada = false;
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
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onPanStart: (DragStartDetails details) {
                      Offset pos = details.localPosition;
                      if (controller != null) return;
                      if (![
                        modoAgregar,
                        modoConectar,
                        modoEliminar,
                        modoEditar,
                        modoColor,
                      ].any((m) => m)) {
                        for (var i = 0; i < ciudades.length; i++) {
                          if ((ciudades[i] - pos).distance <= toleranciaToque) {
                            ciudadSeleccionada = i;
                            break;
                          }
                        }
                      }
                    },
                    onPanUpdate: (DragUpdateDetails details) {
                      if (controller != null) return;
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
                          if ((ciudades[i] - tapPos).distance <=
                              toleranciaToque) {
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
                          if ((ciudades[i] - tapPos).distance <= tamAbs) {
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
                  const SizedBox(width: 5),
                  if (pesoTotal != null)
                    Text(
                      "Distancia total: ${pesoTotal!.toStringAsFixed(1)}",
                      style: TextStyle(
                        fontSize: 5 * (MediaQuery.of(context).size.width / 400),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          resolverTSP();
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.route),
        label: const Text('Resolver'),
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
              decoration: const InputDecoration(
                labelText: "Peso (mayor que 0)",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  double? nuevo = double.tryParse(controller.text);
                  if (nuevo == null || nuevo <= 0) {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text("Peso inválido"),
                            content: const Text(
                              "El peso debe ser un número mayor que cero.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                    );
                    return;
                  }
                  setState(() => conexiones[indexConexion].peso = nuevo);
                  Navigator.pop(context);
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

  void resolverTSP() {
    var conexInvalidas = conexiones.where((c) => c.peso <= 0).toList();
    if (conexInvalidas.isNotEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Error en conexiones"),
              content: Text(
                "Hay ${conexInvalidas.length} conexión(es) con peso 0 o negativo.\n"
                "Por favor, corrige todos los pesos antes de continuar.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Entendido"),
                ),
              ],
            ),
      );
      return;
    }
    final int n = ciudades.length;
    List<List<double>> matriz = List.generate(
      n,
      (_) => List<double>.filled(n, double.infinity),
    );
    for (var c in conexiones) {
      matriz[c.ciudad1][c.ciudad2] = c.peso;
      matriz[c.ciudad2][c.ciudad1] = c.peso;
    }

    AlgoritmoGenetico gen = AlgoritmoGenetico(distancias: matriz);
    List<int> mejorRuta = gen.resolver();
    int idx0 = mejorRuta.indexOf(0);
    if (idx0 > 0) {
      mejorRuta = [...mejorRuta.sublist(idx0), ...mejorRuta.sublist(0, idx0)];
    }
    setState(() {
      ruta = mejorRuta;
      pesoTotal = 0.0;
      for (int i = 0; i < ruta!.length - 1; i++) {
        pesoTotal = (pesoTotal ?? 0) + matriz[ruta![i]][ruta![i + 1]];
      }
      pesoTotal = (pesoTotal ?? 0) + matriz[ruta!.last][ruta!.first];
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
    Offset inicio = ciudades[ruta!.first];
    double dRetorno = (inicio - ciudades[ruta!.last]).distance;
    distSegmentos.add(dRetorno);
    totalDist += dRetorno;
    controller?.dispose();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (totalDist * 10).toInt()),
    );
    baseDuration = controller!.duration!;

    animation = Tween<double>(
      begin: 0,
      end: totalDist,
    ).animate(controller!)..addListener(() {
      double recorrido = animation!.value;
      double acumulado = 0;

      for (int i = 0; i < distSegmentos.length; i++) {
        if (recorrido <= acumulado + distSegmentos[i]) {
          double t = (recorrido - acumulado) / distSegmentos[i];
          Offset p0 = puntosRuta[i];
          Offset p1 = (i < ruta!.length - 1) ? ciudades[ruta![i + 1]] : inicio;
          posViajero = Offset.lerp(p0, p1, t);
          break;
        }
        acumulado += distSegmentos[i];
      }

      setState(() {});
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
