import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaDialog extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapaDialog({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _MapaDialogState createState() => _MapaDialogState();
}

class _MapaDialogState extends State<MapaDialog> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 15, // Zoom na localização
        ),
        markers: {
          Marker(
            markerId: MarkerId('localizacao'),
            position: LatLng(widget.latitude, widget.longitude),
            infoWindow: InfoWindow(title: 'Localização'),
          ),
        },
      ),
      
    );
  }
}
