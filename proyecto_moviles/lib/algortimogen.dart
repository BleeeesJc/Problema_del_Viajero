import 'dart:math';

class Viajero {
  List<int> ruta;
  double fitness;

  Viajero(this.ruta, this.fitness);
}

class AlgoritmoGenetico {
  final List<List<double>> distancias;
  int poblacion;
  int generaciones;
  double probMutacion;

  AlgoritmoGenetico({
    required this.distancias,
    this.poblacion = 100,
    this.generaciones = 300,
    this.probMutacion = 0.05,
  });

  final _rand = Random();

  List<int> resolver() {
    var poblacionActual = poblacionInical();

    for (int gen = 0; gen < generaciones; gen++) {
      List<Viajero> nuevaP = [];
      for (int i = 0; i < poblacion; i++) {
        var padre1 = seleccion(poblacionActual);
        var padre2 = seleccion(poblacionActual);
        var hijo = crossover(padre1, padre2);
        mutar(hijo);
        hijo.fitness = fitness(hijo.ruta);
        nuevaP.add(hijo);
      }
      poblacionActual = nuevaP;
    }

    poblacionActual.sort((a, b) => b.fitness.compareTo(a.fitness));
    return poblacionActual.first.ruta;
  }

  List<Viajero> poblacionInical() {
    var lista = <Viajero>[];
    var base = List.generate(distancias.length, (i) => i);
    for (int i = 0; i < poblacion; i++) {
      var ruta = List<int>.from(base)..shuffle(_rand);
      lista.add(Viajero(ruta, fitness(ruta)));
    }
    return lista;
  }

  double fitness(List<int> ruta) {
    double total = 0;
    for (int i = 0; i < ruta.length - 1; i++) {
      total += distancias[ruta[i]][ruta[i + 1]];
    }
    total += distancias[ruta.last][ruta.first];
    return 1 / total;
  }

  Viajero seleccion(List<Viajero> pop) {
    var torneo = List.generate(5, (_) => pop[_rand.nextInt(pop.length)]);
    torneo.sort((a, b) => b.fitness.compareTo(a.fitness));
    return torneo.first;
  }

  Viajero crossover(Viajero p1, Viajero p2) {
    int start = _rand.nextInt(p1.ruta.length);
    int end = _rand.nextInt(p1.ruta.length);
    if (start > end) {
      var t = start;
      start = end;
      end = t;
    }
    var hijoRuta = List<int?>.filled(p1.ruta.length, null);
    for (int i = start; i <= end; i++) {
      hijoRuta[i] = p1.ruta[i];
    }
    int idx = 0;
    for (var ciudad in p2.ruta) {
      if (!hijoRuta.contains(ciudad)) {
        while (hijoRuta[idx] != null) idx++;
        hijoRuta[idx] = ciudad;
      }
    }
    return Viajero(hijoRuta.cast<int>(), 0);
  }

  void mutar(Viajero ind) {
    if (_rand.nextDouble() < probMutacion) {
      int i = _rand.nextInt(ind.ruta.length);
      int j = _rand.nextInt(ind.ruta.length);
      var tmp = ind.ruta[i];
      ind.ruta[i] = ind.ruta[j];
      ind.ruta[j] = tmp;
    }
  }
}
