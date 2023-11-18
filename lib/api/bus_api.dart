import 'package:bus_hunter/main.dart';
import 'package:signalr_core/signalr_core.dart';
import 'bus_obj.dart';

final _signalRLogger = logger;

final httpConnectionOptions = HttpConnectionOptions(
  logging: (level, message) => _signalRLogger.t(message),
  skipNegotiation: false,
  transport: HttpTransportType.serverSentEvents,
);
final _builderMapHub = HubConnectionBuilder()
    .withHubProtocol(JsonHubProtocol())
    .withUrl("https://transport.tamu.edu/busroutes.web/mapHub",
        httpConnectionOptions)
    .withAutomaticReconnect([0, 1000, 2000]);
final _builderTimeHub = HubConnectionBuilder()
    .withHubProtocol(JsonHubProtocol())
    .withUrl("https://transport.tamu.edu/busroutes.web/timeHub",
        httpConnectionOptions)
    .withAutomaticReconnect([0, 1000, 2000]);
var _connectionMapHub = _builderMapHub.build();
var _connectionTimeHub = _builderTimeHub.build();

enum Hub { map, time }

Future<void> rebuildConnection({Hub hub = Hub.map}) async {
  if (hub == Hub.map) {
    if (_connectionMapHub.state == HubConnectionState.disconnected ||
        _connectionMapHub.state == HubConnectionState.disconnecting) {
      _connectionMapHub = _builderMapHub.build();
      await _startServerConnection(hub);
    }
  } else {
    if (_connectionTimeHub.state == HubConnectionState.disconnected ||
        _connectionTimeHub.state == HubConnectionState.disconnecting) {
      _connectionTimeHub = _builderTimeHub.build();
      await _startServerConnection(hub);
    }
  }
}

Future<void> _startServerConnection(Hub hub) async {
  final connection = hub == Hub.map ? _connectionMapHub : _connectionTimeHub;
  if (connection.state == HubConnectionState.disconnected) {
    try {
      bool timeout = false;
      await connection.start()?.timeout(const Duration(seconds: 10),
          onTimeout: () {
        _signalRLogger.e('Timeout on connection');
        timeout = true;
      });
      if (timeout) {
        _signalRLogger
            .e('Failed to connect to SignalR server, trying again...');
        return await startServerConnection(hub: hub);
      }
      // if (connection.state == HubConnectionState.connected) {
      //   _signalRLogger.d('Connected to SignalR server');
      // } else {
      //   _signalRLogger
      //       .e('Failed to connect to SignalR server, trying again...');
      //   await Future.delayed(const Duration(milliseconds: 1000), () {});
      //   return await rebuildConnection(hub: hub);
      // }
    } catch (e) {
      _signalRLogger.e(e);
      _signalRLogger.e('Failed to connect to SignalR server, trying again...');

      await Future.delayed(const Duration(milliseconds: 1000), () {});
      return await startServerConnection(hub: hub);
    }
  }
}

Future<void> startServerConnection({Hub hub = Hub.map}) async {
  if (hub == Hub.map) {
    await _startServerConnection(hub);
  } else {
    await _startServerConnection(hub);
  }
}

int instances = 0;
Future<dynamic> _invokeMethod(String method, List<String> args,
    [Hub h = Hub.map]) async {
  while (instances > 4) {
    await Future.delayed(const Duration(milliseconds: 100), () {});
  }
  instances++;
  dynamic val;
  while (val == null) {
    try {
      _signalRLogger.t('Invoking $method with args $args');
      await startServerConnection(hub: h);
      if (h == Hub.map) {
        val = _connectionMapHub.invoke(method, args: args);
      } else {
        val = _connectionTimeHub.invoke(method, args: args);
      }
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

// Date is in the format YYYY-MM-DD
Future<List<BusTimeTable>> getTimeTable(
    String routeShortName, String date) async {
  List<dynamic> ret =
      (await _invokeMethod('GetTimeTable', [routeShortName, date], Hub.time)
          as Map<String, dynamic>)['jsonTimeTableList'] as List<dynamic>;
  return ret.map((e) => BusTimeTable.fromJson(e)).toList();
}
