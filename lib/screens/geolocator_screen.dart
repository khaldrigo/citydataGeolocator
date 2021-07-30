import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/geolocator_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeolocatorScreen extends StatelessWidget {
  const GeolocatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GeolocatorController());
    return Scaffold(
        appBar: AppBar(
          title: Text('Citydata Geolocator'),
          actions: [
            IconButton(
              icon: Icon(Icons.location_history),
              onPressed: () {
                controller.watchPosition();
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                controller.addMarker();
              },
            ),
          ],
        ),
        body: GetBuilder<GeolocatorController>(
          init: controller,
          builder: (value) => GoogleMap(
            mapType: MapType.normal,
            zoomControlsEnabled: true,
            initialCameraPosition: CameraPosition(
              target: controller.position,
              zoom: 16,
            ),
            markers: controller.markers,
            onMapCreated: controller.onMapCreated,
            myLocationEnabled: true,
          ),
        ));
  }
}
