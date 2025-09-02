import 'package:geo_tagging_project/utils/widgets/text_widget.dart';
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _capturedTime = DateFormat(
          "yyyy-MM-dd HH:mm:ss",
        ).format(DateTime.now());
      });

      await _getLocation();
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(text: "Location services are disabled"),
        ),
      );
      return;
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextWidget(text: "Location permission denied"),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            text: "Location permissions are permanently denied",
          ),
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
    List<Placemark> placeMarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placeMarks.isNotEmpty) {
      Placemark place = placeMarks.first;
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
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const TextWidget(
            text: "Image Metadata",
            color: AppColor.blueColor,
            fontSize: 25,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: "📍 Address: ${_address ?? 'Fetching...'}",
                color: AppColor.whiteColor,
              ),
              const SizedBox(height: 8),
              TextWidget(
                text: "🕒 Captured: $_capturedTime",
                color: AppColor.whiteColor,
              ),
              const SizedBox(height: 8),
              TextWidget(
                text: "🌐 Latitude: ${_latitude ?? '--'}",
                color: AppColor.whiteColor,
              ),
              TextWidget(
                text: "🌐 Longitude: ${_longitude ?? '--'}",
                color: AppColor.whiteColor,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const TextWidget(text: "Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _imageFile == null
            ? const TextWidget(
                text: "Click the camera button to capture an image",
              )
            : Stack(
                children: [
                  /// Display Captured Image
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    height: MediaQuery.sizeOf(context).height * 0.6,
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

      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
