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

  @override
  int get hashCode => key.hashCode;

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      key: json['key'],
      name: json['name'],
      shortName: json['shortName'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'shortName': shortName,
      'description': description,
    };
  }

  @override
  toString() {
    return 'BusRoute: {key: $key, name: $name, shortName: $shortName, description: $description}';
  }

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
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

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'direction': direction.toJson(),
      'destination': destination,
      'lineDisplayInfo': lineDisplayInfo.toJson(),
      'timePointDisplayInfo': timePointDisplayInfo.toJson(),
      'busStopDisplayInfo': busStopDisplayInfo.toJson(),
      'isDisplay': isDisplay,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'type': type,
      'symbol': symbol,
      'size': size,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
    };
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

class Bus {
  final String key;
  final String name;
  final String vehicleType;
  final BusLocation location;
  final int passengerLoad;
  final int passengerCapacity;
  final String routeKey;
  final String? patternKey;
  final String? tripKey;
  final BusStopDeparture nextStopDeparture;
  final List<dynamic> attributes;
  final List<dynamic> amenities;
  final String routeName;
  final String routeShortName;
  final String patternName;
  final String patternDestination;
  final String patternColor;
  final String directionName;
  final bool isTripper;
  final String? workItemKey;
  final BusRouteStatus? routeStatus;
  final BusOpStatus opStatus;

  Bus({
    required this.key,
    required this.name,
    required this.vehicleType,
    required this.location,
    required this.passengerLoad,
    required this.passengerCapacity,
    required this.routeKey,
    required this.patternKey,
    required this.tripKey,
    required this.nextStopDeparture,
    required this.attributes,
    required this.amenities,
    required this.routeName,
    required this.routeShortName,
    required this.patternName,
    required this.patternDestination,
    required this.patternColor,
    required this.directionName,
    required this.isTripper,
    required this.workItemKey,
    required this.routeStatus,
    required this.opStatus,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      key: json['key'],
      name: json['name'],
      vehicleType: json['vehicleType'],
      location: BusLocation.fromJson(json['location']),
      passengerLoad: json['passengerLoad'],
      passengerCapacity: json['passengerCapacity'],
      routeKey: json['routeKey'],
      patternKey: json['patternKey'],
      tripKey: json['tripKey'],
      nextStopDeparture:
          BusStopDeparture.fromJson(json['nextStopDeparture'] ?? {}),
      attributes: json['attributes'],
      amenities: json['amenities'],
      routeName: json['routeName'],
      routeShortName: json['routeShortName'],
      patternName: json['patternName'],
      patternDestination: json['patternDestination'],
      patternColor: json['patternColor'],
      directionName: json['directionName'],
      isTripper: json['isTripper'],
      workItemKey: json['workItemKey'],
      routeStatus: json['routeStatus'] != null
          ? BusRouteStatus.fromJson(json['routeStatus'])
          : null,
      opStatus: BusOpStatus.fromJson(json['opStatus']),
    );
  }
}

class BusLocation {
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final DateTime lastGpsDate;

  BusLocation({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.lastGpsDate,
  });

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    return BusLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      speed: json['speed'].toDouble(),
      heading: json['heading'].toDouble(),
      lastGpsDate: DateTime.parse(json['lastGpsDate']),
    );
  }
}

class BusStopDeparture {
  final String? stopKey;
  final String stopCode;
  final String? tripPointKey;
  final String? patternPointKey;
  final DateTime? scheduledDeparture;
  final DateTime? estimatedDeparture;
  final bool hasDeparted;
  final String stopName;

  BusStopDeparture({
    required this.stopKey,
    required this.stopCode,
    required this.tripPointKey,
    required this.patternPointKey,
    required this.scheduledDeparture,
    required this.estimatedDeparture,
    required this.hasDeparted,
    required this.stopName,
  });

  factory BusStopDeparture.fromJson(Map<String, dynamic> json) {
    return BusStopDeparture(
      stopKey: json['stopKey'],
      stopCode: json['stopCode'] ?? '',
      tripPointKey: json['tripPointKey'],
      patternPointKey: json['patternPointKey'],
      scheduledDeparture: json['scheduledDeparture'] != null
          ? DateTime.parse(json['scheduledDeparture'])
          : null,
      estimatedDeparture: json['estimatedDeparture'] != null
          ? DateTime.parse(json['estimatedDeparture'])
          : null,
      hasDeparted: json['hasDeparted'] ?? false,
      stopName: json['stopName'] ?? '',
    );
  }
}

class BusRouteStatus {
  final String status;
  final String color;

  BusRouteStatus({
    required this.status,
    required this.color,
  });

  factory BusRouteStatus.fromJson(Map<String, dynamic> json) {
    return BusRouteStatus(
      status: json['status'],
      color: json['color'],
    );
  }
}

class BusOpStatus {
  final String status;
  final String color;

  BusOpStatus({
    required this.status,
    required this.color,
  });

  factory BusOpStatus.fromJson(Map<String, dynamic> json) {
    return BusOpStatus(
      status: json['status'],
      color: json['color'],
    );
  }
}

class BusTimeTable {
  final String destination;
  final String html;

  BusTimeTable({
    required this.destination,
    required this.html,
  });

  factory BusTimeTable.fromJson(Map<String, dynamic> json) {
    return BusTimeTable(
      destination: json['destination'],
      html: json['html'],
    );
  }
}
