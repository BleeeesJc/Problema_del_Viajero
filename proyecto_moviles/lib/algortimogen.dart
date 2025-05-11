// tsp_solver.dart
import 'dart:math';
import 'dart:ui';
import 'conexion.dart';

class AlgoritmoGenetico {
  static List<int> resolver({
    int? startCity,
    List<Offset>? ciudades,
    List<Conexion>? conexiones,
    int? populationSize,
    int? generations,
    double? mutationRate,
  }) {
    startCity ??= 0;
    ciudades ??= [];
    conexiones ??= [];
    populationSize ??= 100;
    generations ??= 200;
    mutationRate ??= 0.05;

    List<int> allCities = List.generate(ciudades.length, (i) => i);
    List<List<int>> population = List.generate(populationSize, (_) {
      List<int> route = List.from(allCities);
      route.remove(startCity);
      route.shuffle();
      route.insert(0, startCity!);
      route.add(startCity);
      return route;
    });

    List<int> bestRoute = population.first;
    double bestDistance = calcularDistancia(bestRoute, conexiones);

    for (int gen = 0; gen < generations; gen++) {
      population.sort(
        (a, b) => calcularDistancia(
          a,
          conexiones!,
        ).compareTo(calcularDistancia(b, conexiones)),
      );

      if (calcularDistancia(population.first, conexiones) < bestDistance) {
        bestRoute = population.first;
        bestDistance = calcularDistancia(bestRoute, conexiones);
      }

      List<List<int>> newPopulation = [];
      for (int i = 0; i < populationSize ~/ 2; i++) {
        List<int> p1 = population[i];
        List<int> p2 = population[populationSize - i - 1];
        List<int> child = crossover(p1, p2, startCity);
        if (Random().nextDouble() < mutationRate) {
          child = mutarRuta(child);
        }
        newPopulation.add(child);
      }

      population = [...population.take(populationSize ~/ 2), ...newPopulation];
    }

    return bestRoute;
  }

  static double calcularDistancia(List<int> ruta, List<Conexion> conexiones) {
    double distancia = 0.0;
    for (int i = 0; i < ruta.length - 1; i++) {
      distancia += obtenerPeso(ruta[i], ruta[i + 1], conexiones);
    }
    return distancia;
  }

  static double obtenerPeso(int a, int b, List<Conexion> conexiones) {
    for (var c in conexiones) {
      if ((c.ciudad1 == a && c.ciudad2 == b) ||
          (c.ciudad1 == b && c.ciudad2 == a)) {
        return c.peso;
      }
    }
    return double.infinity;
  }

  static List<int> crossover(List<int> p1, List<int> p2, int start) {
    int size = p1.length - 2;
    int startIndex = 1 + Random().nextInt(size);
    int endIndex = startIndex + Random().nextInt(size - startIndex + 1);

    List<int> childMiddle = p1.sublist(startIndex, endIndex);
    List<int> rest =
        p2.where((c) => c != start && !childMiddle.contains(c)).toList();

    List<int> child = [
      start,
      ...rest.sublist(0, startIndex - 1),
      ...childMiddle,
      ...rest.sublist(startIndex - 1),
    ];
    child.add(start);
    return child;
  }

  static List<int> mutarRuta(List<int> ruta) {
    int i = 1 + Random().nextInt(ruta.length - 3);
    int j = 1 + Random().nextInt(ruta.length - 3);
    var nueva = List<int>.from(ruta);
    var temp = nueva[i];
    nueva[i] = nueva[j];
    nueva[j] = temp;
    return nueva;
  }
}
