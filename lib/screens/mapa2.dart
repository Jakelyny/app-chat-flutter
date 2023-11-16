import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  double _lat = 20.5937;
  double _lng = 78.9629;
  Set<Marker> _marcadores = {};

  static CameraPosition _posicaoCamera = CameraPosition(
      target: LatLng(20.5937, 78.9629), zoom: 15);

  _movimentarCamera() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(_posicaoCamera));
  }

  getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      return;
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      return;
    } else {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );
      _posicaoCamera = CameraPosition(target:
      LatLng(position.latitude, position.longitude), zoom: 15);
      _movimentarCamera();
      print("latitude = ${position.latitude}");
      print("longitude = ${position.longitude}");
      _addMarcador(LatLng(position.latitude, position.longitude));
    }
  }

  _addMarcador(LatLng latLng) async {
    // criar marcador
    Marker marcador = Marker(
        markerId: MarkerId("marcador-${latLng.latitude}=${latLng.longitude}"),
        position: latLng
    );
    setState(() {
      _marcadores.add(marcador);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _posicaoCamera,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _marcadores,
        myLocationEnabled: true,
        onLongPress: _addMarcador,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
      getLocation();
  }

}