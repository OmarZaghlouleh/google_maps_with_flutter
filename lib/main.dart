import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps/enums.dart';
import 'package:google_maps/functions.dart';
import 'package:google_maps/network.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const GoogleMapWithFlutter());

class GoogleMapWithFlutter extends StatelessWidget {
  const GoogleMapWithFlutter({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyScaffold(),
    );
  }
}

class MyScaffold extends StatefulWidget {
  const MyScaffold({super.key});

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  late BitmapDescriptor customMarker;
  Set<Marker> mapMarkers = {};
  Set<Polygon> mapPolygons = {};
  Set<Circle> mapCircles = {};
  Set<Polyline> mapPolylines = {};
  MapType mapType = MapType.normal;
  Shape shape = Shape.none;
  Functions functions = Functions();
  double mapZoom = 16;
  LatLng? destination;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    await functions.setLatLng();
    customMarker = await functions.setMarker();
    mapPolygons = functions.setPolygon();
    mapCircles = functions.setCircle();
    mapPolylines = functions.setPolyline(points: []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: destination != null
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.withOpacity(0.95),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  functions.calculateDistance(
                      lat1: functions.latLng.latitude,
                      lon1: functions.latLng.longitude,
                      lat2: destination!.latitude,
                      lon2: destination!.longitude),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                elevation: 5,
                context: context,
                builder: (BuildContext ctx) => SizedBox(
                  height: 150,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Center(
                              child: Text(
                                'Map type:',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 15),
                              ),
                            ),
                            DropdownButton<MapType>(
                                elevation: 0,
                                alignment: Alignment.center,
                                value: mapType,
                                items: MapType.values
                                    .map(
                                      (type) => DropdownMenuItem<MapType>(
                                        value: type,
                                        child: Text(
                                          type.name,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  Navigator.pop(ctx);
                                  if (value != null) {
                                    setState(() {
                                      mapType = value;
                                    });
                                  }
                                })
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Center(
                              child: Text(
                                'Shape',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 15),
                              ),
                            ),
                            const SizedBox(width: 5),
                            DropdownButton<Shape>(
                                elevation: 0,
                                alignment: Alignment.center,
                                value: shape,
                                items: Shape.values
                                    .map(
                                      (type) => DropdownMenuItem<Shape>(
                                        value: type,
                                        child: Text(
                                          type.name,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  Navigator.pop(ctx);
                                  if (value != null) {
                                    setState(() {
                                      shape = value;
                                    });
                                  }
                                }),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            child: const Text('Options'),
          )
        ],
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
                onTap: (position) {
                  Marker newMarker = Marker(
                      markerId: const MarkerId('Destination'),
                      position: position);
                  setState(() {
                    destination = position;
                    if (mapMarkers.length > 1) {
                      mapMarkers.remove(mapMarkers.last);
                    }
                    mapMarkers.add(newMarker);
                  });
                  log(mapMarkers.length.toString());
                },
                onMapCreated: (controller) async {
                  Set<Marker> newMarkers = await functions.setMapMarkers(
                      latLng: snapshot.data!, controller: controller);
                  setState(() {
                    mapMarkers = newMarkers;
                  });
                },
                mapType: mapType,
                markers: mapMarkers,
                polygons: shape == Shape.polygon ? mapPolygons : {},
                circles: shape == Shape.circle ? mapCircles : {},
                polylines: shape == Shape.polyline ? mapPolylines : {},
                initialCameraPosition: CameraPosition(
                  zoom: mapZoom,
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
    );
  }
}
