// import 'dart:html';

import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:workmanager/workmanager.dart';

class GeolocatorController extends GetxController {
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final speed = 0.0.obs;
  late StreamSubscription<Position> positionStream;
  LatLng _position = LatLng(-2.4254, -54.7107);
  late GoogleMapController _mapsController;
  Set<Marker> markers = Set();
  int _markerIdCounter = 1;
  Timer? timer;
  static const MAP_STYLE =
      "[{\"featureType\":\"all\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"weight\":\"2.00\"}]},{\"featureType\":\"all\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#9c9c9c\"}]},{\"featureType\":\"all\",\"elementType\":\"labels.text\",\"stylers\":[{\"visibility\":\"on\"}]},{\"featureType\":\"landscape\",\"elementType\":\"all\",\"stylers\":[{\"color\":\"#f2f2f2\"}]},{\"featureType\":\"landscape\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#ffffff\"}]},{\"featureType\":\"landscape.man_made\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#ffffff\"}]},{\"featureType\":\"poi\",\"elementType\":\"all\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"road\",\"elementType\":\"all\",\"stylers\":[{\"saturation\":-100},{\"lightness\":45}]},{\"featureType\":\"road\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#eeeeee\"}]},{\"featureType\":\"road\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#7b7b7b\"}]},{\"featureType\":\"road\",\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#ffffff\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"all\",\"stylers\":[{\"visibility\":\"simplified\"}]},{\"featureType\":\"road.arterial\",\"elementType\":\"labels.icon\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"transit\",\"elementType\":\"all\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"water\",\"elementType\":\"all\",\"stylers\":[{\"color\":\"#46bcec\"},{\"visibility\":\"on\"}]},{\"featureType\":\"water\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#c8d7d4\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#070707\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#ffffff\"}]}]";

  static GeolocatorController get to => Get.find<GeolocatorController>();

  get mapsController => _mapsController;
  get position => _position;

  onMapCreated(GoogleMapController gMapController) async {
    _mapsController = gMapController;
    _mapsController.setMapStyle(MAP_STYLE);

    getPosition();
  }

  watchPosition() async {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      latitude.value = position.latitude;
      longitude.value = position.longitude;
    });
  }

  activityType() {
    final speedWithPrecision = num.parse(speed.toStringAsPrecision(1));
    if (speedWithPrecision <= 1.8) {
      print('andando');
      return 'walking';
    } else if (speedWithPrecision > 1.8 && speedWithPrecision <= 2.3) {
      print('correndo');
      return 'running';
    } else if (speedWithPrecision > 2.3 && speedWithPrecision <= 8.3) {
      print('bicicleta');
      return 'by bike';
    }
    print('carro');
    return 'by car';
  }

  addMarker() {
    final int markerCount = markers.length;
    String atividade = activityType();

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    Marker currentPosition = Marker(
      markerId: markerId,
      position: LatLng(latitude.value, longitude.value),
      infoWindow: InfoWindow(title: atividade),
      draggable: true,
    );

    markers.add(currentPosition);
    print(markerCount);
    update();
  }

  clearMarkers() {
    markers.clear();
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
      var currentTime = DateTime.now();
      timer = Timer.periodic(Duration(seconds: 10), (timer) async {
        final position = await _actualPosition();
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        speed.value = position.speed;

        _mapsController.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(latitude.value, longitude.value),
          ),
        );

        var fiveMinutesLater = DateTime.now();
        print(fiveMinutesLater);
        print(currentTime);
        print(position.speed);
        var difference = fiveMinutesLater.difference(currentTime);
        if (difference.inSeconds <= 300) {
          addMarker();
          print(watchPosition().toString());
          print(_actualPosition().toString());
        } else {
          print('cabo o tempo!');

          timer.cancel();
        }
      });
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
