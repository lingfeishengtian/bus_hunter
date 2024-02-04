import 'package:bus_hunter/api/bus_api.dart';
import 'package:collection/collection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:bus_hunter/utils.dart';
import 'package:flutter/material.dart';

class AppleMaps extends StatelessWidget {
  final Set<Polyline> currRoute;
  final Color routeColor;
  final Function(AppleMapController) onMapCreated;
  final List<BusRouteVehicleInfo> buses;
  final List<PatternPoint> bPoints;
  final List<List<PatternPoint>> bPointsDisruption;
  final NextDepartureTime? nextDepartureTime;
  final Function(String) onBusStopTap;

  AppleMaps(
    this.bPoints,
    this.bPointsDisruption, {
    required this.routeColor,
    required this.onMapCreated,
    required this.buses,
    required this.onBusStopTap,
    this.nextDepartureTime,
  }) : currRoute = {
          Polyline(
              polylineId: PolylineId("a"),
              color: routeColor,
              width: 5,
              points:
                  bPoints.map((e) => LatLng(e.latitude, e.longitude)).toList())
        } {
    for (final (i, points) in bPointsDisruption.indexed) {
      currRoute.add(Polyline(
          polylineId: PolylineId("disruption$i"),
          color: Colors.red,
          width: 2,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          points: points.map((e) => LatLng(e.latitude, e.longitude)).toList()));
    }
    // print(bPoints);
  }

  @override
  Widget build(BuildContext context) {
    final Set<Annotation> stopMarkers = {};
    for (final point in bPoints) {
      if (point.stop != null) {
        final departInfo = nextDepartureTime?.routeDirectionTimes
            .firstWhereOrNull((element) => element.nextDeparts.isNotEmpty)
            ?.nextDeparts
            .firstOrNull;
        final time = departInfo?.estimatedDepartTimeUtc ??
            departInfo?.scheduledDepartTimeUtc;
        stopMarkers.add(Annotation(
          onTap: () {
            onBusStopTap(point.stop?.stopCode ?? "");
          },
          annotationId: AnnotationId(point.key),
          position: LatLng(point.latitude, point.longitude),
          infoWindow: InfoWindow(
              title: point.stop!.name,
              snippet: nextDepartureTime != null
                  ? time != null
                      ? AppLocalizations.of(context)!.minutesTillArrival(
                          time.difference(DateTime.now()).inMinutes.toString())
                      : AppLocalizations.of(context)!.noService
                  : AppLocalizations.of(context)!.loading),
          anchor: const Offset(0.5, 0.5),
          visible: true,
          icon: img_bus_stop,
        ));
      }
    }
    return AppleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(30.6187, -96.3365),
          zoom: 14,
        ),
        myLocationEnabled: true,
        rotateGesturesEnabled: false,
        polylines: currRoute,
        // circles: stopMarkers,
        annotations: buses
            .map((bus) => Annotation(
                // zIndex: 1000,
                annotationId: AnnotationId(bus.key),
                infoWindow: InfoWindow(
                    title: bus.name,
                    // "${AppLocalizations.of(context)!.nextStop}: ${bus.directionName}",
                    snippet: AppLocalizations.of(context)!.percentFull(
                        "${(bus.passengersOnboard.toDouble() / (bus.passengerCapacity != 0 ? bus.passengerCapacity.toDouble() : 1.0) * 100).round()}%")),
                position: LatLng(bus.location.latitude, bus.location.longitude),
                anchor: const Offset(0.5, 0.5),
                icon: img,
                rotation: bus.location.heading))
            .toSet()
            .union(stopMarkers));
  }
}
