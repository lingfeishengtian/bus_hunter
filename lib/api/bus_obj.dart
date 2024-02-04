class BusRoute {
  String key;
  String name;
  String shortName;
  List<BusRouteDirection> directionList;

  BusRoute({
    required this.key,
    required this.name,
    required this.shortName,
    required this.directionList,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      key: json['key'],
      name: json['name'],
      shortName: json['shortName'],
      directionList: List<BusRouteDirection>.from(
        json['directionList'].map(
          (x) => BusRouteDirection.fromJson(x),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'shortName': shortName,
      'directionList': directionList.map((e) => e.toJson()).toList(),
    };
  }
}

class BusRouteDirection {
  BusRouteDirection({
    required this.direction,
    required this.destination,
    required this.lineColor,
    required this.textColor,
    required this.patternList,
    required this.serviceInterruptionKeys,
  });

  BusDirection direction;
  String destination;
  String lineColor;
  String textColor;
  List<BusRoutePattern> patternList;
  List<dynamic> serviceInterruptionKeys;

  factory BusRouteDirection.fromJson(Map<String, dynamic> json) {
    return BusRouteDirection(
      direction: BusDirection.fromJson(json['direction']),
      destination: json['destination'],
      lineColor: json['lineColor'],
      textColor: json['textColor'],
      patternList: List<BusRoutePattern>.from(
        json['patternList'].map(
          (x) => BusRoutePattern.fromJson(x),
        ),
      ),
      serviceInterruptionKeys: List<dynamic>.from(
        json['serviceInterruptionKeys'].map(
          (x) => x,
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction.toJson(),
      'destination': destination,
      'lineColor': lineColor,
      'textColor': textColor,
      'patternList': patternList.map((e) => e.toJson()).toList(),
      'serviceInterruptionKeys': serviceInterruptionKeys,
    };
  }
}

class BusDirection {
  BusDirection({
    required this.key,
    required this.name,
  });

  String key;
  String name;

  factory BusDirection.fromJson(Map<String, dynamic> json) {
    return BusDirection(
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
}

class BusRoutePattern {
  BusRoutePattern({
    required this.key,
    required this.isDisplay,
  });

  String key;
  bool isDisplay;

  factory BusRoutePattern.fromJson(Map<String, dynamic> json) {
    return BusRoutePattern(
      key: json['key'],
      isDisplay: json['isDisplay'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'isDisplay': isDisplay,
    };
  }
}

class PatternPath {
  String patternKey;
  String directionKey;
  List<PatternPoint> patternPoints;
  List<SegmentPath> segmentPaths;

  PatternPath(
      {required this.patternKey,
      required this.directionKey,
      required this.patternPoints,
      required this.segmentPaths});

  factory PatternPath.fromJson(Map<String, dynamic> json) {
    return PatternPath(
      patternKey: json['patternKey'],
      directionKey: json['directionKey'],
      patternPoints: json['patternPoints']
          .map<PatternPoint>((json) => PatternPoint.fromJson(json))
          .toList(),
      segmentPaths: json['segmentPaths']
          .map<SegmentPath>((json) => SegmentPath.fromJson(json))
          .toList(),
    );
  }
}

class PatternPoint {
  String key;
  double latitude;
  double longitude;
  Stop? stop;

  PatternPoint(
      {required this.key,
      required this.latitude,
      required this.longitude,
      required this.stop});

  factory PatternPoint.fromJson(Map<String, dynamic> json) {
    return PatternPoint(
      key: json['key'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      stop: json['stop'] != null ? Stop.fromJson(json['stop']) : null,
    );
  }
}

class Stop {
  String name;
  String stopCode;
  int stopType;

  Stop({required this.name, required this.stopCode, required this.stopType});

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      name: json['name'],
      stopCode: json['stopCode'],
      stopType: json['stopType'],
    );
  }
}

class SegmentPath {
  String serviceInterruptionKey;
  String patternKey;
  List<PatternPoint> patternPoints;

  SegmentPath(
      {required this.serviceInterruptionKey,
      required this.patternKey,
      required this.patternPoints});

  factory SegmentPath.fromJson(Map<String, dynamic> json) {
    return SegmentPath(
      serviceInterruptionKey: json['serviceInterruptionKey'],
      patternKey: json['patternKey'],
      patternPoints: json['patternPoints']
          .map<PatternPoint>((json) => PatternPoint.fromJson(json))
          .toList(),
    );
  }
}

/*
 [{
    "routeKey": "10130313-2264-4211-9923-43d90e437cff",
    "vehiclesByDirections": [{
        "directionKey": "587389e2-3a18-4888-b9d1-a5b55877dd19",
        "vehicles": [{
            "key": "d5e6d64c-5177-44d0-8150-c4d4ca6b585e",
            "name": "B0620",
            "location": {
                "lastGpsDate": "2024-01-17T09:38:40",
                "latitude": 30.618002,
                "longitude": -96.340834166666653,
                "speed": 0.0,
                "heading": 262.6400146484375
            },
            "directionKey": "587389e2-3a18-4888-b9d1-a5b55877dd19",
            "directionName": "Asbury Water Tower",
            "routeKey": "10130313-2264-4211-9923-43d90e437cff",
            "passengerCapacity": 80,
            "passengersOnboard": 26,
            "amenities": [{
                "name": "Air Conditioning",
                "iconName": "snowflake"
            }, {
                "name": "Wheelchair Lift",
                "iconName": "wheelchair"
            }],
            "isExtraTrip": false
        }]
    }, {
        "directionKey": "46a44363-0622-45cc-a95e-f46de270a400",
        "vehicles": [{
            "key": "8c3a9a4f-1636-4a4b-8600-37299188b64d",
            "name": "B2014",
            "location": {
                "lastGpsDate": "2024-01-17T09:38:42",
                "latitude": 30.619685666666669,
                "longitude": -96.338315666666674,
                "speed": 1.685305379086137,
                "heading": 49.639999389648438
            },
            "directionKey": "46a44363-0622-45cc-a95e-f46de270a400",
            "directionName": "Becky Gates Center",
            "routeKey": "10130313-2264-4211-9923-43d90e437cff",
            "passengerCapacity": 85,
            "passengersOnboard": 11,
            "amenities": [{
                "name": "Air Conditioning",
                "iconName": "snowflake"
            }, {
                "name": "Wheelchair Lift",
                "iconName": "wheelchair"
            }],
            "isExtraTrip": false
        }]
    }]
}]
 */

class BusRouteVehicle {
  String routeKey;
  List<BusRouteVehicleDirection> vehiclesByDirections;

  BusRouteVehicle({required this.routeKey, required this.vehiclesByDirections});

  factory BusRouteVehicle.fromJson(Map<String, dynamic> json) {
    return BusRouteVehicle(
      routeKey: json['routeKey'],
      vehiclesByDirections: json['vehiclesByDirections']
          .map<BusRouteVehicleDirection>(
              (json) => BusRouteVehicleDirection.fromJson(json))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeKey': routeKey,
      'vehiclesByDirections':
          vehiclesByDirections.map((e) => e.toJson()).toList(),
    };
  }
}

class BusRouteVehicleDirection {
  String directionKey;
  List<BusRouteVehicleInfo> vehicles;

  BusRouteVehicleDirection(
      {required this.directionKey, required this.vehicles});

  factory BusRouteVehicleDirection.fromJson(Map<String, dynamic> json) {
    return BusRouteVehicleDirection(
      directionKey: json['directionKey'],
      vehicles: json['vehicles']
          .map<BusRouteVehicleInfo>(
              (json) => BusRouteVehicleInfo.fromJson(json))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'directionKey': directionKey,
      'vehicles': vehicles.map((e) => e.toJson()).toList(),
    };
  }
}

class BusRouteVehicleInfo {
  String key;
  String name;
  BusLocation location;
  String directionKey;
  String directionName;
  String routeKey;
  int passengerCapacity;
  int passengersOnboard;
  List<BusAmenity> amenities;
  bool isExtraTrip;

  BusRouteVehicleInfo(
      {required this.key,
      required this.name,
      required this.location,
      required this.directionKey,
      required this.directionName,
      required this.routeKey,
      required this.passengerCapacity,
      required this.passengersOnboard,
      required this.amenities,
      required this.isExtraTrip});

  factory BusRouteVehicleInfo.fromJson(Map<String, dynamic> json) {
    return BusRouteVehicleInfo(
      key: json['key'],
      name: json['name'],
      location: BusLocation.fromJson(json['location']),
      directionKey: json['directionKey'],
      directionName: json['directionName'],
      routeKey: json['routeKey'],
      passengerCapacity: json['passengerCapacity'],
      passengersOnboard: json['passengersOnboard'],
      amenities: json['amenities']
          .map<BusAmenity>((json) => BusAmenity.fromJson(json))
          .toList(),
      isExtraTrip: json['isExtraTrip'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'location': location.toJson(),
      'directionKey': directionKey,
      'directionName': directionName,
      'routeKey': routeKey,
      'passengerCapacity': passengerCapacity,
      'passengersOnboard': passengersOnboard,
      'amenities': amenities.map((e) => e.toJson()).toList(),
      'isExtraTrip': isExtraTrip,
    };
  }
}

class BusLocation {
  DateTime lastGpsDate;
  double latitude;
  double longitude;
  double speed;
  double heading;

  BusLocation(
      {required this.lastGpsDate,
      required this.latitude,
      required this.longitude,
      required this.speed,
      required this.heading});

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    return BusLocation(
      lastGpsDate: DateTime.parse(json['lastGpsDate']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      speed: json['speed'],
      heading: json['heading'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastGpsDate': lastGpsDate.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
    };
  }
}

class BusAmenity {
  String name;
  String iconName;

  BusAmenity({required this.name, required this.iconName});

  factory BusAmenity.fromJson(Map<String, dynamic> json) {
    return BusAmenity(
      name: json['name'],
      iconName: json['iconName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconName': iconName,
    };
  }
}

/*
{
    "stopCode": "0016",
    "routeDirectionTimes": [
        {
            "routeKey": "c4b8bcfe-e378-4335-9839-801b3296f80d",
            "directionKey": "56f01e6b-3c9d-45f0-8e31-5df18c901332",
            "nextDeparts": [
                {
                    "estimatedDepartTimeUtc": "2024-02-01T20:53:00Z",
                    "scheduledDepartTimeUtc": "2024-02-01T20:58:00Z",
                    "isOffRoute": false
                },
                {
                    "estimatedDepartTimeUtc": "2024-02-01T21:07:00Z",
                    "scheduledDepartTimeUtc": "2024-02-01T21:13:00Z",
                    "isOffRoute": false
                },
                {
                    "estimatedDepartTimeUtc": "2024-02-01T21:28:00Z",
                    "scheduledDepartTimeUtc": "2024-02-01T21:28:00Z",
                    "isOffRoute": false
                }
            ],
            "frequencyInfo": null
        }
    ],
    "amenities": [
        {
            "name": "Bicycle Rack",
            "iconName": "bicycle"
        },
        {
            "name": "Wheelchair Accessible",
            "iconName": "wheelchair"
        }
    ]
}
*/

class NextDepartureTime {
  String stopCode;
  List<RouteDirectionTime> routeDirectionTimes;
  List<BusAmenity> amenities;

  NextDepartureTime(
      {required this.stopCode,
      required this.routeDirectionTimes,
      required this.amenities});

  factory NextDepartureTime.fromJson(Map<String, dynamic> json) {
    return NextDepartureTime(
      stopCode: json['stopCode'],
      routeDirectionTimes: json['routeDirectionTimes']
          .map<RouteDirectionTime>((json) => RouteDirectionTime.fromJson(json))
          .toList(),
      amenities: json['amenities']
          .map<BusAmenity>((json) => BusAmenity.fromJson(json))
          .toList(),
    );
  }
}

class RouteDirectionTime {
  String routeKey;
  String directionKey;
  List<NextDepart> nextDeparts;
  dynamic frequencyInfo;

  RouteDirectionTime(
      {required this.routeKey,
      required this.directionKey,
      required this.nextDeparts,
      required this.frequencyInfo});

  factory RouteDirectionTime.fromJson(Map<String, dynamic> json) {
    return RouteDirectionTime(
      routeKey: json['routeKey'],
      directionKey: json['directionKey'],
      nextDeparts: json['nextDeparts']
          .map<NextDepart>((json) => NextDepart.fromJson(json))
          .toList(),
      frequencyInfo: json['frequencyInfo'],
    );
  }
}

class NextDepart {
  DateTime? estimatedDepartTimeUtc;
  DateTime? scheduledDepartTimeUtc;
  bool isOffRoute;

  NextDepart(
      {required this.estimatedDepartTimeUtc,
      required this.scheduledDepartTimeUtc,
      required this.isOffRoute});

  factory NextDepart.fromJson(Map<String, dynamic> json) {
    return NextDepart(
      estimatedDepartTimeUtc:
          DateTime.tryParse(json['estimatedDepartTimeUtc'] ?? ""),
      scheduledDepartTimeUtc:
          DateTime.tryParse(json['scheduledDepartTimeUtc'] ?? ""),
      isOffRoute: json['isOffRoute'],
    );
  }
}
