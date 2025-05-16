import 'dart:math';
import 'dart:ui';
import 'conexion.dart';

class AlgoritmoGenetico {
  int startCity = 0;
  List<Offset> ciudades = [];
  List<Conexion> conexiones = [];
  int populationSize = 200;
  int generations = 300;
  double mutationRate = 0.1;

  AlgoritmoGenetico({
    int? startCity,
    List<Offset>? ciudades,
    List<Conexion>? conexiones,
    int? populationSize,
    int? generations,
    double? mutationRate,
  }) {
    this.startCity = startCity ?? 0;
    this.ciudades = ciudades ?? [];
    this.conexiones = conexiones ?? [];
    this.populationSize = populationSize ?? 100;
    this.generations = generations ?? 200;
    this.mutationRate = mutationRate ?? 0.05;
  }

  List<int> resolver() {
    List<int> allCities = List.generate(ciudades.length, (i) => i);

    List<List<int>> population = List.generate(populationSize, (_) {
      List<int> route = List.from(allCities);
      route.remove(startCity);
      route.shuffle();
      route.insert(0, startCity);
      route.add(startCity);
      return route;
    });

    List<int> bestRoute = population.first;
    double bestDistance = calcularDistancia(bestRoute);

    for (int gen = 0; gen < generations; gen++) {
      population.sort(
        (a, b) => calcularDistancia(a).compareTo(calcularDistancia(b)),
      );

      if (calcularDistancia(population.first) < bestDistance) {
        bestRoute = population.first;
        bestDistance = calcularDistancia(bestRoute);
      }

      List<List<int>> newPopulation = [];
      for (int i = 0; i < populationSize ~/ 2; i++) {
        List<int> p1 = population[i];
        List<int> p2 = population[populationSize - i - 1];
        List<int> child = crossover(p1, p2);
        if (Random().nextDouble() < mutationRate) {
          child = mutarRuta(child);
        }
        newPopulation.add(child);
      }

      population = [...population.take(populationSize ~/ 2), ...newPopulation];
    }

    return bestRoute;
  }

  double calcularDistancia(List<int> ruta) {
    double distancia = 0.0;
    for (int i = 0; i < ruta.length - 1; i++) {
      distancia += obtenerPeso(ruta[i], ruta[i + 1]);
    }
    return distancia;
  }

  double obtenerPeso(int a, int b) {
    for (var c in conexiones) {
      if ((c.ciudad1 == a && c.ciudad2 == b) ||
          (c.ciudad1 == b && c.ciudad2 == a)) {
        return c.peso;
      }
    }
    return 1e6;
  }

  List<int> crossover(List<int> p1, List<int> p2) {
    int size = p1.length - 2;
    int startIndex = 1 + Random().nextInt(size);
    int endIndex = startIndex + Random().nextInt(size - startIndex + 1);

    List<int> childMiddle = p1.sublist(startIndex, endIndex);
    List<int> rest =
        p2.where((c) => c != startCity && !childMiddle.contains(c)).toList();

    List<int> child = [
      startCity,
      ...rest.sublist(0, startIndex - 1),
      ...childMiddle,
      ...rest.sublist(startIndex - 1),
    ];
    child.add(startCity);
    return child;
  }

  List<int> mutarRuta(List<int> ruta) {
    int i = 1 + Random().nextInt(ruta.length - 3);
    int j = 1 + Random().nextInt(ruta.length - 3);
    if (i > j) {
      var temp = i;
      i = j;
      j = temp;
    }
    var nueva = List<int>.from(ruta);
    var sub = nueva.sublist(i, j + 1).reversed.toList();
    nueva.replaceRange(i, j + 1, sub);
    return nueva;
  }
}