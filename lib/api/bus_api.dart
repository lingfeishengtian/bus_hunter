import 'package:bus_hunter/main.dart';
import 'package:signalr_core/signalr_core.dart';
import 'bus_obj.dart';

final _signalRLogger = logger;

final httpConnectionOptions = HttpConnectionOptions(
  logging: (level, message) => _signalRLogger.i(message),
  skipNegotiation: false,
  transport: HttpTransportType.longPolling,
);
final _builder = HubConnectionBuilder()
    .withHubProtocol(JsonHubProtocol())
    .withUrl("https://transport.tamu.edu/busroutes.web/mapHub")
    .withAutomaticReconnect([0, 1000, 2000]);
var _connection = _builder.build();

Future<void> _startServerConnection() async {
  try {
    await _connection.start();
    _signalRLogger.i('Connected to SignalR server');
  } catch (e) {
    _signalRLogger.e(e);
    _signalRLogger.e('Failed to connect to SignalR server, trying again...');

    await Future.delayed(const Duration(milliseconds: 1000), () {});
    return await _startServerConnection();
  }
}

Future<void> startServerConnection() async {
  await _startServerConnection();
}

Future<dynamic> _invokeMethod(String method, List<String> args) async {
  dynamic val;
  while (val == null) {
    try {
      _signalRLogger.i('Invoking $method with args $args');
      val = _connection.invoke(method, args: args);
      val = val as List<dynamic>;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1), () {});
    }
  }
  return val;
}

// Pass in a pattern key to get the pattern points
Future<List<BusPoint>> getPatternPoints(String arg) async {
  final List<dynamic> patterns = await _invokeMethod('GetPatternPoints', [arg]);
  return patterns.map((e) => BusPoint.fromJson(e)).toList();
}

// Pass in a route key to get the route patterns
Future<List<BusRoutePattern>> getRoutePatterns(String arg) async {
  final List<dynamic> patterns = await _invokeMethod('GetRoutePatterns', [arg]);
  return patterns.map((e) => BusRoutePattern.fromJson(e)).toList();
}

enum RouteGroups { onCampus, offCampus, gameday }

extension RouteGroupsExtension on RouteGroups {
  String get name {
    switch (this) {
      case RouteGroups.onCampus:
        return 'On Campus';
      case RouteGroups.offCampus:
        return 'Off Campus';
      case RouteGroups.gameday:
        return 'Gameday';
    }
  }

  String get key {
    switch (this) {
      case RouteGroups.onCampus:
        return 'OnCampus';
      case RouteGroups.offCampus:
        return 'OffCampus';
      case RouteGroups.gameday:
        return 'Gameday';
    }
  }
}

Future<List<BusRoute>> getRouteByGroup(RouteGroups g) async {
  final List<dynamic> routes = await _invokeMethod('GetRoutesByGroup', [g.key]);
  return routes.map((e) => BusRoute.fromJson(e)).toList();
}

Future<List<Bus>> getBuses(String arg) async {
  final List<dynamic> buses = await _invokeMethod('GetBuses', [arg]);
  return buses.map((e) => Bus.fromJson(e)).toList();
}
