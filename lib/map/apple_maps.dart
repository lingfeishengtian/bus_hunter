import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:flutter/material.dart';

class AppleMaps extends StatelessWidget {
  final Set<Polyline> currRoute;
  final Set<Circle> currBusMarkers;
  final Color routeColor;
  final Function(AppleMapController) onMapCreated;

  AppleMaps(List<BusPoint> bPoints, List<Bus> buses,
      {super.key, required this.routeColor, required this.onMapCreated})
      : currRoute = {
          Polyline(
              polylineId: PolylineId("a"),
              color: routeColor,
              width: 5,
              points:
                  bPoints.map((e) => LatLng(e.latitude, e.longitude)).toList())
        },
        currBusMarkers = {
          for (final bus in buses)
            Circle(
                circleId: CircleId(bus.key),
                center: LatLng(bus.location.latitude, bus.location.longitude),
                radius: 20,
                fillColor: const Color.fromARGB(255, 0, 0, 255),
                strokeColor: const Color.fromARGB(255, 0, 0, 255))
        } {
    for (final point in bPoints) {
      if (point.isStop) {
        currBusMarkers.add(Circle(
            circleId: CircleId(point.key),
            center: LatLng(point.latitude, point.longitude),
            radius: 10,
            fillColor: Colors.white,
            strokeColor: Colors.white));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: LatLng(30.6187, -96.3365),
        zoom: 14,
      ),
      polylines: currRoute,
      circles: currBusMarkers,
    );
  }
}
