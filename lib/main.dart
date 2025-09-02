import 'package:geo_tagging_project/utils/app_imports/app_imports.dart';

void main() {
  runApp(const GeoTaggingApp());
}

class GeoTaggingApp extends StatelessWidget {
  const GeoTaggingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
