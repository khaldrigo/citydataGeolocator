// import 'dart:html';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeolocatorController extends GetxController {
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  late StreamSubscription<Position> positionStream;
  LatLng _position = LatLng(-2.4254, -54.7107);
  late GoogleMapController _mapsController;
  Set<Marker> markers = Set();
  late Timer _timer;

  static GeolocatorController get to => Get.find<GeolocatorController>();

  get mapsController => _mapsController;
  get position => _position;

  onMapCreated(GoogleMapController gMapController) async {
    _mapsController = gMapController;
    getPosition();
  }

  watchPosition() async {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      latitude.value = position.latitude;
      longitude.value = position.longitude;
    });
  }

  addMarker() {
    markers.add(
      Marker(
        markerId: MarkerId('1'),
        position: LatLng(latitude.value, longitude.value),
        infoWindow: InfoWindow(title: 'teste'),
        onTap: () {},
      ),
    );

    update();
  }

  addMarker2() {
    markers.add(
      Marker(
        markerId: MarkerId('2'),
        position: LatLng(-2.4401, -54.7322),
        infoWindow: InfoWindow(title: 'teste'),
        onTap: () {},
      ),
    );

    update();
  }

  @override
  void onClose() {
    positionStream.cancel();
    super.onClose();
  }

  Future<Position> _actualPosition() async {
    LocationPermission permission;
    bool activated = await Geolocator.isLocationServiceEnabled();

    if (!activated) {
      return Future.error('Please, activate GPS.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('You need to authorize access to GPS.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'You need to authorize permissions in your smartphone settings.');
    }

    return await Geolocator.getCurrentPosition();
  }

  getPosition() async {
    try {
      final position = await _actualPosition();
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      _mapsController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(latitude.value, longitude.value),
        ),
      );
      addMarker();
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      _timer = Timer.periodic(Duration(seconds: 10), (timer) {
        _mapsController.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(latitude.value, longitude.value),
          ),
        );
      });
      addMarker2();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.grey[900],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
