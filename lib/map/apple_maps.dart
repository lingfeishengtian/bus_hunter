import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:flutter/material.dart';

class AppleMaps extends StatelessWidget {
  final Set<Polyline> currRoute;
  late final AppleMapController mapController;

  // Set<Polyline> polylines = {};

  AppleMaps(List<BusPoint> bPoints, {super.key})
      : currRoute = {
          Polyline(
              polylineId: PolylineId("a"),
              points:
                  bPoints.map((e) => LatLng(e.latitude, e.longitude)).toList())
        };

  void _onMapCreated(AppleMapController controller) {
    mapController = controller;
  }

  // void getMapDetails() async {
  //   List<BusRoute> routes = await getRoutes();
  //   for (BusRoute route in routes) {
  //     if (route.shortName == "04") {
  //       currRoute = route;
  //     }
  //   }

  //   List<LatLng> points = [];
  //   List<BusRoutePattern> patternPoints = await getRoutePatterns(currRoute.key);
  //   for (BusRoutePattern pattern in patternPoints) {
  //     List<BusPoint> a = await getPatternPoints(pattern.key);
  //     for (BusPoint point in a) {
  //       points.add(LatLng(point.latitude, point.longitude));
  //     }
  //   }

  //   setState(() {
  //     polylines = {Polyline(polylineId: PolylineId("04"), points: points)};
  //     mapController.moveCamera(
  //         CameraUpdate.newLatLngZoom(polylines.first.points.first, 15));
  //   });
  // }

  // AppleMaps({super.key}) {
  //   // getMapDetails();
  // }

  @override
  Widget build(BuildContext context) {
    return AppleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: LatLng(0.0, 0.0),
      ),
      polylines: currRoute,
    );
  }
}
