import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/story.dart';
import 'package:geocoding/geocoding.dart';

class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen>
    with SingleTickerProviderStateMixin {
  String? _address;

  late GoogleMapController _mapController;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  bool _cardVisible = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _cardVisible = true;
      });
      _animationController.forward();
    });

    // Get address
    if (widget.story.lat != null && widget.story.lon != null) {
      _getAddressFromLatLng(widget.story.lat!, widget.story.lon!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromLatLng(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Gagal mendapatkan alamat: $e');
      }
    }
  }

  void _focusOnMarker() {
    final LatLng target = LatLng(widget.story.lat!, widget.story.lon!);
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 17)),
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng? storyLocation;
    if (widget.story.lat != null && widget.story.lon != null) {
      storyLocation = LatLng(widget.story.lat!, widget.story.lon!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Maps')),
      body: Stack(
        children: [
          if (storyLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: storyLocation,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('storyLocation'),
                  position: storyLocation,
                  infoWindow: InfoWindow(
                    title: _address ?? 'Mencari alamat...',
                  ),
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            )
          else
            const Center(
              child: Text('Lokasi tidak tersedia untuk cerita ini.'),
            ),

          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            bottom: 30,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _cardVisible ? 1.0 : 0.0,
              child: SlideTransition(
                position: _offsetAnimation,
                child: GestureDetector(
                  onTap: _focusOnMarker,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.story.photoUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.story.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.story.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
