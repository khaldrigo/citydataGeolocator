import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/geolocator_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class GeolocatorScreen extends StatelessWidget {
  const GeolocatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GeolocatorController());
    // OneSignal.shared.init('4659e3fe-f729-4c52-a4c7-49ee04f869d1');
    return Scaffold(
        appBar: AppBar(
          title: Text('Citydata Geolocator'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                controller.clearMarkers();
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
              zoom: 15,
            ),
            markers: controller.markers,
            onMapCreated: controller.onMapCreated,
            myLocationEnabled: true,
          ),
        ));
  }
}
