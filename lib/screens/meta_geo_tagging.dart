import 'package:intl/intl.dart';
import 'package:geo_tagging_project/utils/app_imports/app_imports.dart';

class MetaGeoTagging extends StatefulWidget {
  const MetaGeoTagging({super.key});

  @override
  State<MetaGeoTagging> createState() => _MetaGeoTaggingState();
}

class _MetaGeoTaggingState extends State<MetaGeoTagging> {
  File? _imageFile;
  String? _capturedTime;
  String? _latitude;
  String? _longitude;
  String? _address;

  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _capturedTime = DateFormat(
          "yyyy-MM-dd HH:mm:ss",
        ).format(DateTime.now());
      });

      /// Get location after capturing image
      await _getLocation();
    }
  }

  /// Get current GPS location and address
  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled")),
      );
      return;
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permissions are permanently denied"),
        ),
      );
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _latitude = position.latitude.toStringAsFixed(6);
      _longitude = position.longitude.toStringAsFixed(6);
    });

    // Reverse geocoding to get human-readable address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        _address =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
    }
  }

  /// Show metadata dialog
  void _showMetaData() {
    if (_imageFile == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Image Metadata"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📍 Address: ${_address ?? 'Fetching...'}"),
              const SizedBox(height: 8),
              Text("🕒 Captured: $_capturedTime"),
              const SizedBox(height: 8),
              Text("🌐 Latitude: ${_latitude ?? '--'}"),
              Text("🌐 Longitude: ${_longitude ?? '--'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geo Tagging Example")),

      body: Center(
        child: _imageFile == null
            ? const Text("Click the camera button to capture an image")
            : Stack(
                children: [
                  /// Display Captured Image
                  Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  /// Info Icon Overlay
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _showMetaData,
                    ),
                  ),
                ],
              ),
      ),

      /// FloatingActionButton to capture image
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
