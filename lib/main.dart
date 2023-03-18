import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps/network.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const GoogleMapWithFlutter());

class GoogleMapWithFlutter extends StatefulWidget {
  const GoogleMapWithFlutter({super.key});

  @override
  State<GoogleMapWithFlutter> createState() => _GoogleMapWithFlutterState();
}

class _GoogleMapWithFlutterState extends State<GoogleMapWithFlutter> {
  final mapMarkers = HashSet<Marker>();
  final myLocationMarkerId = const MarkerId('MyLocation');
  late BitmapDescriptor customMarker;

  @override
  void initState() {
    setMarker();
    super.initState();
  }

  Future<void> setMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, 'assets/images/pin.png');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Google Maps',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: FutureBuilder(
          future: determinePosition(),
          builder: (context, snapshot) => snapshot.hasData
              ? GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      mapMarkers.add(
                        Marker(
                          icon: customMarker,
                          markerId: myLocationMarkerId,
                          position: snapshot.data!,
                          infoWindow: InfoWindow(
                            title: 'My location',
                            snippet: 'Thanks to code2start',
                            onTap: () async {
                              if (await controller.isMarkerInfoWindowShown(
                                myLocationMarkerId,
                              )) {
                                setState(() {
                                  controller
                                      .hideMarkerInfoWindow(myLocationMarkerId);
                                });
                              }
                            },
                          ),
                        ),
                      );
                    });
                  },
                  markers: mapMarkers,
                  initialCameraPosition: CameraPosition(
                    zoom: 15,
                    target: snapshot.data!,
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
