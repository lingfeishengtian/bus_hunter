import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'bus_obj.dart';

const LINK = "https://aggiespirit.ts.tamu.edu/RouteMap/GetBaseData/";

/*
final httpsUri = Uri(
    scheme: 'https',
    host: 'dart.dev',
    path: 'guides/libraries/library-tour',
    fragment: 'numbers');
print(httpsUri); // 
*/

const HOST = "aggiespirit.ts.tamu.edu";

Future<List<BusRoute>> getRoutes() async {
  return await post(Uri(
    scheme: 'https',
    host: HOST,
    path: 'RouteMap/GetBaseData',
  )).then((value) {
    return (jsonDecode(value.body)['routes'] as List<dynamic>)
        .map((e) => BusRoute.fromJson(e))
        .toList();
  });
}

class PatternPathReturn {
  String routeKey;
  List<PatternPath> patternPaths;

  PatternPathReturn({required this.routeKey, required this.patternPaths});

  factory PatternPathReturn.fromJson(Map<String, dynamic> json) {
    return PatternPathReturn(
      routeKey: json['routeKey'],
      patternPaths: json['patternPaths']
          .map<PatternPath>((e) => PatternPath.fromJson(e))
          .toList(),
    );
  }
}

Future<List<PatternPath>> getPatternPaths(List<String> routeKeys) async {
  print({for (var (i, p) in routeKeys.indexed) "count[$i]": p});
  List<PatternPath> paths = [];
  await post(
          Uri(
            scheme: 'https',
            host: HOST,
            path: 'RouteMap/GetPatternPaths',
          ),
          body: {for (var (i, p) in routeKeys.indexed) "routeKeys[$i]": p})
      .then((value) {
    print("called");
    print(value.body);
    paths.addAll((jsonDecode(value.body) as List<dynamic>)
        .map((e) => PatternPathReturn.fromJson(e).patternPaths)
        .expand((element) => element));
  });
  return paths;
}

Future<List<BusRouteVehicle>> getBuses(List<String> routeKeys) async {
  List<BusRouteVehicle> buses = [];
  print("getting buses called");
  await post(
          Uri(
            scheme: 'https',
            host: HOST,
            path: 'RouteMap/GetVehicles',
          ),
          body: {for (var (i, p) in routeKeys.indexed) "routeKeys[$i]": p})
      .then((value) {
    buses.addAll((jsonDecode(value.body) as List<dynamic>)
        .map((e) => BusRouteVehicle.fromJson(e)));
  });
  return buses;
}

Future<NextDepartureTime> getNextDepartureTime(
    String stopCode, String routeKey, List<String> directionKeys) async {
  return await post(
      Uri(
        scheme: 'https',
        host: HOST,
        path: 'RouteMap/GetNextDepartTimes',
      ),
      body: {
        "stopCode": stopCode,
        for (var (i, p) in directionKeys.indexed)
          "routeDirectionKeys[$i][directionKey]": p,
        for (var (i, _) in directionKeys.indexed)
          "routeDirectionKeys[$i][routeKey]": routeKey,
      }).then((value) {
    return NextDepartureTime.fromJson(jsonDecode(value.body));
  });
}
