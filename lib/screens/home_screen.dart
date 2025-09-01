import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart'; // <<-- required for DateFormat

class GeoTaggingHome extends StatefulWidget {
  const GeoTaggingHome({super.key});

  @override
  State<GeoTaggingHome> createState() => _GeoTaggingHomeState();
}

class _GeoTaggingHomeState extends State<GeoTaggingHome> {
  File? _image;
  String? _address;
  String? _dateTime;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      // Open camera
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
        _address = null;
        _dateTime = null;
      });

      // --- Location checks ---
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location permissions are permanently denied. Please enable from settings.')),
        );
        return;
      }

      // --- Get current position ---
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // --- Reverse geocode to get address ---
      String formattedAddress = 'Unknown location';
      try {
        final placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          formattedAddress =
              "${p.name ?? ''} ${p.locality ?? ''}, ${p.subAdministrativeArea ?? ''}, ${p.administrativeArea ?? ''}, ${p.country ?? ''}"
                  .trim()
                  .replaceAll(RegExp(r'\s+,'), ',');
        }
      } catch (e) {
        debugPrint('Reverse geocoding failed: $e');
      }

      // --- Date & time ---
      final formattedDateTime =
      DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.now());

      setState(() {
        _address = formattedAddress;
        _dateTime = formattedDateTime;
      });
    } catch (e) {
      debugPrint("Error in _pickImage: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geo Tagging"),centerTitle: true,),
      body: Center(
        child: _image == null
            ? const Text(
          "No image captured yet",
          style: TextStyle(fontSize: 18),
        )
            : Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // Image container
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(_image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Overlay for text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.black54,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_address != null)
                    Text(
                      "📍 $_address",
                      style: const TextStyle(
                          color: Colors.black, fontSize: 14),
                    ),
                  if (_dateTime != null)
                    Text(
                      "🕒 $_dateTime",
                      style: const TextStyle(
                          color: Colors.black, fontSize: 14),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
