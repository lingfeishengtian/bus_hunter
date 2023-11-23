import 'dart:async';
import 'dart:collection';
import 'package:bus_hunter/api/bus_api.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:bus_hunter/main.dart';
import 'package:bus_hunter/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class MappedBusData {
  HashMap<BusRoute, BusRouteData> data;
  MappedBusData() : data = HashMap();

  void _addEntry(BusRoute route, List<BusRoutePattern> patterns) {
    data.addEntries([MapEntry(route, (patterns, []))]);
  }

  void removeEntry(String routeKey) {
    data.remove(routeKey);
  }

  // Will throw an error if pattern is empty for this route. In addition it will not add the route
  Future<void> addRouteAndRetrieveData(BusRoute route) async {
    List<BusRoutePattern> patterns = await getRoutePatterns(route.key);
    List<BusPoint> points = [];
    if (patterns.isEmpty) {
      throw Exception('Empty patterns for route ${route.name}');
    }
    if (routes.any((element) => element.key == route.key)) {
      data[route] = (patterns, points);
    } else {
      _addEntry(route, patterns);
    }
    logger.t('Added route ${route.name} with ${patterns.length} patterns and '
        '${points.length} points');
  }

  BusRoute? route(String key) {
    return data.keys.firstWhereOrNull((element) => element.key == key);
  }

  List<BusRoutePattern>? patterns(String key) {
    return data[route(key)]?.$1;
  }

  Future<List<BusPoint>?> points(String key) async {
    if (data[route(key)]?.$2.isEmpty ?? false) {
      List<Future<void>> futures = [];
      for (BusRoutePattern pattern in patterns(key) ?? []) {
        futures.add(getPatternPoints(pattern.key).then((p) {
          if (p.isEmpty) {
            logger.e('Empty points for pattern ${pattern.name}');
          }
          logger.t('Adding ${p.length} points for pattern ${pattern.name}');
          data[route(key)]?.$2.addAll(p);
        }));
      }
      await Future.wait(futures);
    }
    return data[route(key)]?.$2;
  }

  List<BusPoint>? forceGetPoints(String key) {
    return data[route(key)]?.$2;
  }

  List<BusRoute> get routes {
    return data.keys.toList().sortedBy((element) => element.shortName);
  }

  Color getRouteColor(String key) {
    if (patterns(key)?.isEmpty ?? false) return Colors.black;
    return hexToColor(patterns(key)?.first.lineDisplayInfo.color ?? "#000000");
  }

  bool emptyRouteData() {
    if (routes.isEmpty) return true;
    for (var element in data.values) {
      if (element.$1.isEmpty) {
        return true;
      }
    }
    return false;
  }
}
