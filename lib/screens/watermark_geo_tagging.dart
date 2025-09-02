import 'package:intl/intl.dart';
import 'package:geo_tagging_project/utils/app_imports/app_imports.dart';

class WatermarkGeoTagging extends StatefulWidget {
  const WatermarkGeoTagging({super.key});

  @override
  State<WatermarkGeoTagging> createState() => WatermarkGeoTaggingState();
}

class WatermarkGeoTaggingState extends State<WatermarkGeoTagging> {
  File? _image;
  String? _address;
  String? _dateTime;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
        _address = null;
        _dateTime = null;
      });

      // Location checks
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextWidget(text: 'Location services are disabled.'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: TextWidget(text: 'Location permission denied.'),
            ),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextWidget(
              text:
                  'Location permissions are permanently denied. Please enable from settings.',
            ),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String formattedAddress = 'Unknown location';
      try {
        final placeMarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placeMarks.isNotEmpty) {
          final p = placeMarks.first;
          formattedAddress =
              "${p.name ?? ''} ${p.locality ?? ''}, ${p.subAdministrativeArea ?? ''}, ${p.administrativeArea ?? ''}, ${p.country ?? ''}"
                  .trim()
                  .replaceAll(RegExp(r'\s+,'), ',');
        }
      } catch (e) {
        debugPrint('Reverse geocoding failed: $e');
      }

      final formattedDateTime = DateFormat(
        'yyyy-MM-dd – HH:mm',
      ).format(DateTime.now());

      setState(() {
        _address = formattedAddress;
        _dateTime = formattedDateTime;
      });
    } catch (e) {
      debugPrint("Error in _pickImage: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: TextWidget(text: 'Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _image == null
            ? const TextWidget(text: "No image captured yet")
            : Stack(
                alignment:
                    Alignment.bottomCenter, // 👈 bottom align the overlay
                children: [
                  /// Image in center
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    height: MediaQuery.sizeOf(context).height * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  /// Bottom overlay with geotagging info
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_address != null)
                            TextWidget(
                              text: "📍 $_address",
                              fontSize: 16,
                              color: AppColor.whiteColor,
                            ),
                          if (_dateTime != null)
                            TextWidget(
                              text: "🕒 $_dateTime",
                              fontSize: 16,
                              color: AppColor.whiteColor,
                            ),
                        ],
                      ),
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
