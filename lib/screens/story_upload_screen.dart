import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intermediete_1/main_common.dart';
import 'package:intermediete_1/services/story_service.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class UploadStoryScreen extends StatefulWidget {
  const UploadStoryScreen({super.key});

  @override
  State<UploadStoryScreen> createState() => _UploadStoryScreenState();
}

LatLng? _selectedLocation;

class _UploadStoryScreenState extends State<UploadStoryScreen> {
  final TextEditingController _descController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickLocation() async {
    final location = Location();
    final currentLocation = await location.getLocation();

    final initialLatLang = LatLng(
      currentLocation.latitude!,
      currentLocation.longitude!,
    );

    final picked = await context.push<LatLng>(
      '/map-picker',
      extra: initialLatLang,
    );

    if (picked != null) {
      setState(() {
        _selectedLocation = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Kamera'),
                  onTap: () => context.pop(ImageSource.camera),
                ),

                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () => context.pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_imageFile == null || _descController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi semua data!")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await StoryService.uploadStory(
      description: _descController.text,
      imageFile: _imageFile!,
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cerita berhasil diunggah!")),
      );
      _selectedLocation = null;
      context.pop(true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengunggah cerita.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Cerita")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : const Text("Belum ada gambar"),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo),
              label: const Text("Pilih Gambar"),
            ),
            TextButton.icon(
              onPressed: isPaidGlobal ? _pickLocation : null,
              icon: const Icon(Icons.location_pin),
              label: Text(
                _selectedLocation != null
                    ? "Lokasi: ${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}"
                    : (isPaidGlobal ? "Pilih Lokasi" : "Fitur premium"),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleUpload,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Upload Cerita"),
            ),
          ],
        ),
      ),
    );
  }
}
