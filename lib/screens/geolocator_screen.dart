import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/geolocator_controller.dart';

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
            icon: Icon(Icons.add_location),
            onPressed: () {
              controller.getPostion();
            },
          ),
        ],
      ),
      body: Center(
        child: Obx(
          () => Text(
            'Lat: ${controller.latitude.value} | Lng: ${controller.longitude.value}',
          ),
        ),
      ),
    );
  }
}
