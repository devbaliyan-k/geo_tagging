import 'package:flutter/material.dart';
import 'package:geo_tagging_project/screens/home_screen.dart';

void main() {
  runApp(const GeoTaggingApp());
}

class GeoTaggingApp extends StatelessWidget {
  const GeoTaggingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GeoTaggingHome(),
    );
  }
}
