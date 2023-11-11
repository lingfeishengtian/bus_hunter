import 'package:signalr_core/signalr_core.dart';
import 'package:logger/logger.dart';
import 'bus_obj.dart';

final _signalRLogger = Logger(
    printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true),
    output: ConsoleOutput());

final _connectionOptions = HttpConnectionOptions(logging: (level, message) {
  switch (level) {
    case LogLevel.critical:
    case LogLevel.error:
      _signalRLogger.e(message);
      break;
    case LogLevel.warning:
      _signalRLogger.w(message);
      break;
    case LogLevel.information:
      _signalRLogger.i(message);
      break;
    case LogLevel.debug:
      _signalRLogger.d(message);
    case LogLevel.trace:
      _signalRLogger.t(message);
      break;
    case LogLevel.none:
      _signalRLogger.i(message);
  }
});

HubConnection _buildHubConnection() => HubConnectionBuilder()
    .withAutomaticReconnect()
    .withUrl(
        'https://transport.tamu.edu/busroutes.web/mapHub', _connectionOptions)
    .build();
HubConnection _connection = _buildHubConnection();

Future<void> _startServerConnection() async {
  if (_connection.state == HubConnectionState.disconnected) {
    _connection = _buildHubConnection();
    try {
      await _connection.start();
    } catch (e) {
      _signalRLogger.e(e);
      _signalRLogger.e('Failed to connect to SignalR server, trying again...');

      await Future.delayed(const Duration(seconds: 1), () {});
      await _startServerConnection();
    }
  }
}

Future<dynamic> _invokeMethod(String method, List<Object?> args) async {
  await _startServerConnection();
  return _connection.invoke(method, args: args);
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

Future<List<BusRoute>> getRoutes() async {
  final List<dynamic> routes =
      await _invokeMethod('GetRoutesByGroup', ["OnCampus"]);
  return routes.map((e) => BusRoute.fromJson(e)).toList();
}
