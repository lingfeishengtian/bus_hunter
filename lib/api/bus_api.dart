import 'package:bus_hunter/main.dart';
import 'package:signalr_core/signalr_core.dart';
import 'bus_obj.dart';

final _signalRLogger = logger;

final httpConnectionOptions = HttpConnectionOptions(
  logging: (level, message) => _signalRLogger.t(message),
  skipNegotiation: false,
  transport: HttpTransportType.longPolling,
);
final _builder = HubConnectionBuilder()
    .withHubProtocol(JsonHubProtocol())
    .withUrl("https://transport.tamu.edu/busroutes.web/mapHub")
    .withAutomaticReconnect([0, 1000, 2000]);
var _connection = _builder.build();

Future<void> rebuildConnection() async {
  _connection = _builder.build();
  await _startServerConnection();
}

Future<void> _startServerConnection() async {
  if (_connection.state == HubConnectionState.disconnected) {
    try {
      await _connection.start()?.timeout(const Duration(seconds: 10),
          onTimeout: () async {
        _signalRLogger.e('Timeouot on connection');
      });
      if (_connection.state == HubConnectionState.connected) {
        _signalRLogger.d('Connected to SignalR server');
      } else {
        _signalRLogger
            .e('Failed to connect to SignalR server, trying again...');
        await Future.delayed(const Duration(milliseconds: 1000), () {});
        return await rebuildConnection();
      }
    } catch (e) {
      _signalRLogger.e(e);
      _signalRLogger.e('Failed to connect to SignalR server, trying again...');

      await Future.delayed(const Duration(milliseconds: 1000), () {});
      return await _startServerConnection();
    }
  }
}

Future<void> startServerConnection() async {
  await _startServerConnection();
}

int instances = 0;
Future<dynamic> _invokeMethod(String method, List<String> args) async {
  while (instances > 4) {
    await Future.delayed(const Duration(milliseconds: 100), () {});
  }
  instances++;
  dynamic val;
  while (val == null) {
    try {
      _signalRLogger.t('Invoking $method with args $args');
      await startServerConnection();
      val = _connection.invoke(method, args: args);
      val = val as List<dynamic>;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1), () {});
    }
  }
  instances--;
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
