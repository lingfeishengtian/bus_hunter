import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:bus_hunter/utils.dart';
import 'package:flutter/material.dart';

class AppleMaps extends StatelessWidget {
  final Set<Polyline> currRoute;
  final Set<Circle> stopMarkers = {};
  final Color routeColor;
  final Function(AppleMapController) onMapCreated;
  final List<Bus> buses;

  AppleMaps(List<BusPoint> bPoints,
      {super.key,
      required this.routeColor,
      required this.onMapCreated,
      required this.buses})
      : currRoute = {
          Polyline(
              polylineId: PolylineId("a"),
              color: routeColor,
              width: 5,
              points:
                  bPoints.map((e) => LatLng(e.latitude, e.longitude)).toList())
        } {
    for (final point in bPoints) {
      if (point.isStop) {
        stopMarkers.add(Circle(
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
        myLocationEnabled: true,
        rotateGesturesEnabled: false,
        polylines: currRoute,
        circles: stopMarkers,
        annotations: buses
            .map((bus) => Annotation(
                annotationId: AnnotationId(bus.key),
                infoWindow: InfoWindow(
                    title:
                        "${AppLocalizations.of(context)!.nextStop}: ${bus.nextStopDeparture.stopName}",
                    snippet: AppLocalizations.of(context)!.percentFull(
                        "${(bus.passengerLoad.toDouble() / (bus.passengerCapacity != 0 ? bus.passengerCapacity.toDouble() : 1.0) * 100).round()}%")),
                position: LatLng(bus.location.latitude, bus.location.longitude),
                anchor: const Offset(0.5, 0.5),
                icon: img,
                rotation: bus.location.heading))
            .toSet());
  }
}
