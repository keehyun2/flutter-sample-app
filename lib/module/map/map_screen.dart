import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  bool isReady = false;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isReady = true;
                });
              },
              style: ElevatedButton.styleFrom(
                  primary: isReady ? Colors.blue : Colors.red),
              child: isReady ? const Text('대기중...') : const Text('시작')),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: FloatingActionButton(
              backgroundColor: Colors.amber,
              onPressed: isReady
                  ? () {
                      setState(() {
                        isReady = false;
                      });
                    }
                  : () {
                      Navigator.of(context, rootNavigator: true).pop(context);
                    },
              elevation: 0.0,
              child: isReady
                  ? const Icon(Icons.stop)
                  : const Icon(Icons.exit_to_app)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop);
  }
}
