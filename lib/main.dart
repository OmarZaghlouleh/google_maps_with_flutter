import 'package:flutter/material.dart';
import 'package:google_maps/network.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const GoogleMapWithFlutter());

class GoogleMapWithFlutter extends StatelessWidget {
  const GoogleMapWithFlutter({super.key});

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
            style: TextStyle(color: Colors.blue),
          ),
        ),
        body: FutureBuilder(
          future: determinePosition(),
          builder: (context, snapshot) => snapshot.hasData
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    zoom: 15,
                    target: LatLng(
                        snapshot.data!.latitude, snapshot.data!.longitude),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
        ),
      ),
    );
  }
}
