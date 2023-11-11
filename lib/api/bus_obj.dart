class BusRoute {
  final String key;
  final String name;
  final String shortName;
  final String? description;

  BusRoute({
    required this.key,
    required this.name,
    required this.shortName,
    this.description,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      key: json['key'],
      name: json['name'],
      shortName: json['shortName'],
      description: json['description'],
    );
  }

  @override
  toString() {
    return 'BusRoute: {key: $key, name: $name, shortName: $shortName, description: $description}';
  }
}

class BusRoutePattern {
  final String key;
  final String name;
  final BusRouteDirection direction;
  final String destination;
  final BusDisplayInfo lineDisplayInfo;
  final BusDisplayInfo timePointDisplayInfo;
  final BusDisplayInfo busStopDisplayInfo;
  final bool isDisplay;

  BusRoutePattern({
    required this.key,
    required this.name,
    required this.direction,
    required this.destination,
    required this.lineDisplayInfo,
    required this.timePointDisplayInfo,
    required this.busStopDisplayInfo,
    required this.isDisplay,
  });

  factory BusRoutePattern.fromJson(Map<String, dynamic> json) {
    return BusRoutePattern(
      key: json['key'],
      name: json['name'],
      direction: BusRouteDirection.fromJson(json['direction']),
      destination: json['destination'],
      lineDisplayInfo: BusDisplayInfo.fromJson(json['lineDisplayInfo']),
      timePointDisplayInfo:
          BusDisplayInfo.fromJson(json['timePointDisplayInfo']),
      busStopDisplayInfo: BusDisplayInfo.fromJson(json['busStopDisplayInfo']),
      isDisplay: json['isDisplay'],
    );
  }

  @override
  toString() {
    return 'BusRoutePattern {key: $key, name: $name, direction: $direction, destination: $destination, lineDisplayInfo: $lineDisplayInfo, timePointDisplayInfo: $timePointDisplayInfo, busStopDisplayInfo: $busStopDisplayInfo, isDisplay: $isDisplay}';
  }
}

class BusDisplayInfo {
  final String color;
  final int type;
  final int symbol;
  final int size;

  BusDisplayInfo({
    required this.color,
    required this.type,
    required this.symbol,
    required this.size,
  });

  factory BusDisplayInfo.fromJson(Map<String, dynamic> json) {
    return BusDisplayInfo(
      color: json['color'],
      type: json['type'],
      symbol: json['symbol'],
      size: json['size'],
    );
  }

  @override
  toString() {
    return '{color: $color, type: $type, symbol: $symbol, size: $size}';
  }
}

class BusRouteDirection {
  final String key;
  final String name;

  BusRouteDirection({
    required this.key,
    required this.name,
  });

  factory BusRouteDirection.fromJson(Map<String, dynamic> json) {
    return BusRouteDirection(
      key: json['key'],
      name: json['name'],
    );
  }

  @override
  toString() {
    return '{key: $key, name: $name}';
  }
}

class BusPoint {
  final String key;
  final String name;
  final String description;
  final int rank;
  final double longitude;
  final double latitude;
  final bool isStop;
  final bool isTimePoint;
  final BusStop? stop;
  final int routeHeaderRank;
  final double distanceToPreviousPoint;

  BusPoint({
    required this.key,
    required this.name,
    required this.description,
    required this.rank,
    required this.longitude,
    required this.latitude,
    required this.isStop,
    required this.isTimePoint,
    required this.stop,
    required this.routeHeaderRank,
    required this.distanceToPreviousPoint,
  });

  factory BusPoint.fromJson(Map<String, dynamic> json) {
    return BusPoint(
      key: json['key'],
      name: json['name'],
      description: json['description'],
      rank: json['rank'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      isStop: json['isStop'],
      isTimePoint: json['isTimePoint'],
      stop: json['stop'] != null ? BusStop.fromJson(json['stop']) : null,
      routeHeaderRank: json['routeHeaderRank'],
      distanceToPreviousPoint: json['distanceToPreviousPoint'].toDouble(),
    );
  }

  @override
  toString() {
    return 'BusPoint {key: $key, name: $name, description: $description, rank: $rank, longitude: $longitude, latitude: $latitude, isStop: $isStop, isTimePoint: $isTimePoint, stop: $stop, routeHeaderRank: $routeHeaderRank, distanceToPreviousPoint: $distanceToPreviousPoint}';
  }
}

class BusStop {
  final String key;
  final String name;
  final String stopCode;
  final bool isTemporary;
  final List<dynamic> attributes;

  BusStop({
    required this.key,
    required this.name,
    required this.stopCode,
    required this.isTemporary,
    required this.attributes,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      key: json['key'],
      name: json['name'],
      stopCode: json['stopCode'],
      isTemporary: json['isTemporary'],
      attributes: json['attributes'],
    );
  }

  @override
  toString() {
    return 'BusStop {key: $key, name: $name, stopCode: $stopCode, isTemporary: $isTemporary, attributes: $attributes}';
  }
}
