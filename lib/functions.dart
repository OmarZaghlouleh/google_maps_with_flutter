import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'network.dart';

class Functions {
  LatLng latLng = const LatLng(0, 0);
  final myLocationMarkerId = const MarkerId('MyLocation');
  double distance = 0;

  Functions();

  Future<void> setLatLng() async {
    latLng = await determinePosition();
  }

  Future<BitmapDescriptor> setMarker() async {
    return await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, 'assets/images/pin.png');
  }

  Set<Polygon> setPolygon() {
    List<LatLng> polygonCoords = [];

    double value = 0.001;
    polygonCoords.addAll([
      LatLng(latLng.latitude + value, latLng.longitude + value),
      LatLng(latLng.latitude - value, latLng.longitude + value),
      LatLng(latLng.latitude + value, latLng.longitude - value),
    ]);

    Set<Polygon> polygonSet = {};
    polygonSet.add(
      Polygon(
        polygonId: const PolygonId('test'),
        points: polygonCoords,
        strokeWidth: 1,
        fillColor: Colors.black.withOpacity(0.4),
        strokeColor: Colors.amber,
      ),
    );

    return polygonSet;
  }

  Set<Circle> setCircle() {
    return {
      Circle(
        circleId: const CircleId('MyLocation'),
        center: latLng,
        radius: 500,
        strokeColor: Colors.amber,
        strokeWidth: 1,
        fillColor: Colors.black.withOpacity(0.4),
      ),
    };
  }

  Set<Polyline> setPolyline({required List<LatLng> points}) {
    double value = 0.001;
    return {
      Polyline(
        polylineId: const PolylineId('MyLocation'),
        color: Colors.amber,
        startCap: Cap.roundCap,
        endCap: Cap.squareCap,
        width: 3,
        points: [
          LatLng(latLng.latitude + value, latLng.longitude + value),
          LatLng(latLng.latitude - value, latLng.longitude + value),
          LatLng(latLng.latitude + value, latLng.longitude - value),
        ],
        patterns: [PatternItem.dash(10), PatternItem.gap(10)],
      ),
    };
  }

  Future<Set<Marker>> setMapMarkers(
      {required LatLng latLng, required GoogleMapController controller}) async {
    BitmapDescriptor customMarker = await setMarker();
    return {
      Marker(
        icon: customMarker,
        markerId: myLocationMarkerId,
        position: latLng,
        infoWindow: InfoWindow(
          title: 'My location',
          snippet: 'Thanks to code2start',
          onTap: () async {
            await controller.animateCamera(CameraUpdate.zoomTo(15));
          },
        ),
      ),
    };
  }

  String calculateDistance(
      {required double lat1,
      required double lon1,
      required double lat2,
      required double lon2}) {
    const R = 6371e3; // metres
    final alpha1 = lat1 * pi / 180; // φ, λ in radians
    final alpha2 = lat2 * pi / 180;
    final deltaAlpha = (lat2 - lat1) * pi / 180;
    final deltaGamma = (lon2 - lon1) * pi / 180;

    final a = sin(deltaAlpha / 2) * sin(deltaAlpha / 2) +
        cos(alpha1) * cos(alpha2) * sin(deltaGamma / 2) * sin(deltaGamma / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final d = R * c; // in metres
    return 'Distance: ${d.toStringAsFixed(1)} Meters';
  }
}
