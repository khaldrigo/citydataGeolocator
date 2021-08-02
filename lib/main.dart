import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './screens/geolocator_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Citydata Geolocator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        accentColor: Colors.blueGrey,
      ),
      home: GeolocatorScreen(),
    );
  }
}
