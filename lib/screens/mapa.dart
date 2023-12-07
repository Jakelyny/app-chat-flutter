import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding_resolver/geocoding_resolver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapSample extends StatefulWidget {
  final String? idLocal;

  const MapSample({Key? key, this.idLocal}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}


class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  final CollectionReference _locais =
  FirebaseFirestore.instance.collection("locais");

  GeoCoder geoCoder = GeoCoder();
  Set<Marker> _marcadores = {};

  static CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 15,
  );


  TextEditingController _nomeController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _posicaoCamera,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          getLocation();
        },
        markers: _marcadores,
        onLongPress: _addMarcador,
        onTap: (_) {
          _limparCampos();
        },
      ),
    );
  }


  _movimentarCamera() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
        CameraUpdate.newCameraPosition(_posicaoCamera));
  }


  getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    print("permissão: " + permission.toString());
    if (permission == LocationPermission.denied) {
      print("pedindo permissão");
      await Geolocator.requestPermission();
      permission = await Geolocator.checkPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      print("abrindo config");
      await Geolocator.openLocationSettings();
      permission = await Geolocator.checkPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      print("entrou " );
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("posição: " + position.latitude.toString());
      _posicaoCamera = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      );
      _movimentarCamera();
    }
  }


  @override
  void initState() {
    super.initState();
    if (widget.idLocal != null){
      mostrarLocal(widget.idLocal);
    }else {
      _carregarMarcadores();
    }
  }


  _addMarcador(LatLng latLng) async {
    Address address = await geoCoder.getAddressFromLatLng(
        latitude: latLng.latitude, longitude: latLng.longitude);
    String rua = address.addressDetails.road;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Adicionar Marcador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome do local'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _registrarMarcador(
                LatLng(latLng.latitude, latLng.longitude),
                _nomeController.text,
                _descricaoController.text,
              );
              Navigator.of(context).pop();
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }


  _carregarMarcadores() async {
    QuerySnapshot querySnapshot = await _locais.get();
    querySnapshot.docs.forEach((doc) {
      double latitude = doc.get('latitude');
      double longitude = doc.get('longitude');
      String titulo = doc.get('titulo');
      String descricao = doc.get('descricao');

      LatLng latLng = LatLng(latitude, longitude);
      Marker marcador = Marker(
        markerId: MarkerId("marcador-$latitude-$longitude"),
        position: latLng,
        infoWindow: InfoWindow(
          title: titulo,
          snippet: descricao,
        ),
      );
      setState(() {
        _marcadores.add(marcador);
      });
    });
  }


  _limparCampos() {
    _nomeController.clear();
    _descricaoController.clear();
  }


  _registrarMarcador(
      LatLng latLng, String nomeLocal, String descricaoLocal) async {
    Marker marcador = Marker(
      markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
      position: latLng,
      infoWindow: InfoWindow(
        title: nomeLocal,
        snippet: descricaoLocal,
      ),
    );
    setState(() {
      _marcadores.add(marcador);
    });

    // Gravar no Firestore
    Map<String, dynamic> local = Map();
    local['titulo'] = nomeLocal;
    local['descricao'] = descricaoLocal;
    local['latitude'] = latLng.latitude;
    local['longitude'] = latLng.longitude;
    _locais.add(local);
  }


  mostrarLocal(String? idLocal) async {
    DocumentSnapshot local = await _locais.doc(idLocal).get();
    String titulo = local.get("titulo");
    String descricao = local.get("descricao");
    LatLng latLng = LatLng(local.get('latitude'), local.get('longitude'));

    // Mover a câmera para o marcador selecionado
    CameraPosition newPosition = CameraPosition(target: latLng, zoom: 15);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));

    // Adicionar todos os marcadores à lista
    _carregarMarcadores();
  }
}
