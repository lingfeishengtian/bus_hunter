import 'dart:async';
import 'dart:convert';
import 'package:bus_hunter/api/bus_api.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:bus_hunter/main.dart';
import 'package:bus_hunter/mapped_bus_data.dart';
import 'package:bus_hunter/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RouteStateManagerLoadingStat {
  loading,
  loadingMore,
  done,
}

class RouteStateManager {
  static const int favoritesIndex = 3;
  String? _currRouteKey;
  int _currRouteGroup = 0;
  List<Bus>? buses = [];

  final _routeData = [
    MappedBusData(),
    MappedBusData(),
    MappedBusData(),
    MappedBusData(),
  ];

  MappedBusData get busData {
    if (_currRouteGroup < 0) {
      throw Exception('Invalid index, you forgot to change from -1');
    }
    if (_currRouteGroup <= RouteGroups.values.length) {
      return _routeData[_currRouteGroup];
    } else {
      return _routeData[favoritesIndex];
    }
  }

  bool get routeSelected => _currRouteKey != null;

  bool get _isCurrGroupFavorite {
    return _currRouteGroup == favoritesIndex;
  }

  int get currRouteGroup {
    return _currRouteGroup;
  }

  List<BusPoint> get points {
    return busData.forceGetPoints(_currRouteKey ?? "") ?? [];
  }

  Future<List<BusPoint>> retrievePoints() async {
    return await busData.points(_currRouteKey!) ?? [];
  }

  Color get routeColor {
    return busData.getRouteColor(_currRouteKey ?? "");
  }

  void changeRoute(String routeKey) {
    _currRouteKey = routeKey;
  }

  List<int> get groupIndices {
    List<int> rg = List.generate(RouteGroups.values.length, (index) => index);
    if (_routeData[favoritesIndex].data.isNotEmpty) {
      rg.insert(0, favoritesIndex);
    }
    return rg;
  }

  void changeRouteGroup(
      dynamic route, Function(RouteStateManagerLoadingStat) setState) async {
    if (route is RouteGroups) {
      _currRouteGroup = route.index;
    } else if (route is int) {
      _currRouteGroup = route;
    } else {
      throw Exception('Invalid route type');
    }

    _currRouteKey = null;
    buses = [];

    if (!busData.emptyRouteData()) {
      setState(RouteStateManagerLoadingStat.done);
      return;
    }

    setState(RouteStateManagerLoadingStat.loading);

    List<Future<void>> futures = [];

    List<BusRoute> routes = _isCurrGroupFavorite
        ? busData.routes
        : await getRouteByGroup(RouteGroups.values[_currRouteGroup]);

    for (BusRoute route in routes) {
      futures.add(busData.addRouteAndRetrieveData(route).then((_) {
        if (!_isCurrGroupFavorite) {
          setState(RouteStateManagerLoadingStat.loadingMore);
        }
      }).onError((error, stackTrace) {
        logger.e(
            'Error adding route ${route.name}, failed with "$error", removing favorite if it exists');
        if (_isCurrGroupFavorite) {
          busData.routes.remove(route);
          saveFavorites();
        }
      }));
    }

    await Future.wait(futures);
    setState(RouteStateManagerLoadingStat.done);
  }

  void addFavorites(List<BusRoute> routes) {
    _routeData[favoritesIndex]
        .data
        .addEntries(routes.map((e) => MapEntry(e, ([], []))));
    saveFavorites();
  }

  void removeFavorites(List<BusRoute> routes) {
    _routeData[favoritesIndex].data.removeWhere((key, value) {
      return routes.contains(key);
    });
    saveFavorites();
  }

  bool isCurrentRouteFavorite() {
    return _routeData[favoritesIndex]
        .routes
        .any((element) => element.key == _currRouteKey);
  }

  void unFavorite(Function(RouteStateManagerLoadingStat) stateChange) {
    removeFavorites([busData.route(_currRouteKey ?? "")!]);

    if (currRouteGroup == favoritesIndex && busData.routes.isEmpty) {
      changeRouteGroup(RouteGroups.values.first, (p0) => stateChange);
    }
  }

  void favorite() {
    addFavorites([busData.route(_currRouteKey ?? "")!]);
  }

  Future<void> loadFavorites() async {
    prefs = await SharedPreferences.getInstance();
    final List<BusRoute> favorites = (prefs.getStringList('favorites') ?? [])
        .map((e) => BusRoute.fromJson(jsonDecode(e)))
        .toList();
    if (favorites.isNotEmpty) {
      addFavorites(favorites);
      _currRouteGroup = favoritesIndex;
    }
  }

  void saveFavorites() {
    prefs.setStringList('favorites',
        _routeData[favoritesIndex].routes.map((e) => jsonEncode(e)).toList());
  }

  bool hasFavorites() => _routeData[favoritesIndex].data.isNotEmpty;

  BusRoute get currBusRoute {
    return busData.route(_currRouteKey!)!;
  }

  Future<List<Bus>> retrieveBuses() async {
    if (_currRouteKey == null) {
      throw Exception('currRouteKey is null');
    }
    buses = await getBuses(busData.route(_currRouteKey!)!.shortName);
    return buses!;
  }
}
