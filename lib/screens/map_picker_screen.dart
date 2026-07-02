import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng initialLocation;
  const MapPickerScreen({super.key, required this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final currentLocation = await location.getLocation();
    final newLocation = LatLng(
      currentLocation.latitude!,
      currentLocation.longitude!,
    );

    setState(() {
      _pickedLocation = newLocation;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Lokasi')),
      body:
          _pickedLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _pickedLocation!,
                      zoom: 15,
                    ),
                    onTap: (position) {
                      setState(() {
                        _pickedLocation = position;
                      });
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _pickedLocation!,
                      ),
                    },
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
                  Positioned(
                    bottom: 50,
                    left: 20,

                    child: FloatingActionButton(
                      onPressed: _getCurrentLocation,
                      tooltip: 'Lokasi Saya',
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pop(_pickedLocation);
        },
        label: const Text("Pilih Lokasi"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
