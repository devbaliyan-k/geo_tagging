import 'package:geo_tagging_project/utils/app_imports/app_imports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController geotaggingTabController;

  @override
  void initState() {
    super.initState();
    geotaggingTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    geotaggingTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geo Tagging"), centerTitle: true),

      body: Column(
        children: [
          Material(
            color: Colors.green,
            child: TabBar(
              controller: geotaggingTabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: "Watermark Form"),
                Tab(text: "Meta Data Form"),
              ],
            ),
          ),

          /// Expanded TabBarViews
          Expanded(
            child: TabBarView(
              controller: geotaggingTabController,
              children: [WatermarkGeoTagging(), MetaGeoTagging()],
            ),
          ),
        ],
      ),
    );
  }
}
