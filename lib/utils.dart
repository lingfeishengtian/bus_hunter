import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences prefs;

Color hexToColor(String hexString) {
  var hexColor = hexString.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
  return const Color.fromARGB(0, 0, 0, 0);
}

LatLngBounds calculateLatLngFromBusPoints(List<PatternPoint> bPoints) {
  double minLat = 90;
  double maxLat = -90;
  double minLng = 180;
  double maxLng = -180;

  for (final point in bPoints) {
    if (point.latitude < minLat) {
      minLat = point.latitude;
    }
    if (point.latitude > maxLat) {
      maxLat = point.latitude;
    }
    if (point.longitude < minLng) {
      minLng = point.longitude;
    }
    if (point.longitude > maxLng) {
      maxLng = point.longitude;
    }
  }

  return LatLngBounds(
      southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
}

BitmapDescriptor img = BitmapDescriptor.defaultAnnotation;
Future<void> initBusDirectionIcon() async {
  img = BitmapDescriptor.fromBytes(
      (await rootBundle.load("assets/icons/arrow_bus.png"))
          .buffer
          .asUint8List());
}
