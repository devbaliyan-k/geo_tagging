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
      appBar: AppBar(
        backgroundColor: AppColor.blueColor,
        title: const TextWidget(
          text: "Geo Tagging",
          fontSize: 25,
          color: AppColor.appBarTextColor,
          fontStyle: FontStyle.italic,
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Material(
            color: Colors.grey,
            child: TabBar(
              controller: geotaggingTabController,
              labelColor: AppColor.blackColor,
              unselectedLabelColor: AppColor.blackColor,
              tabs: [
                Tab(text: "Watermark Type"),
                Tab(text: "Meta Data Type"),
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
