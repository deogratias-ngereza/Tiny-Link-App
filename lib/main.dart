import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controllers/theme_controller.dart';
import 'data/hive_service.dart';
import 'routes/app_pages.dart';

/// Entry point for Tiny Link.
/// - Initializes local database (Hive) and registers adapters.
/// - Seeds initial Apps if empty for a good first-run experience.
/// - Boots a GetMaterialApp with reactive theming via ThemeController.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database (Hive) and open boxes
  await HiveService.init();
  // Seed sample Apps if none exist yet
  await HiveService.seedIfEmpty();

  // Initialize ThemeController for reactive theming
  Get.put(ThemeController(), permanent: true);

  runApp(const TinyLinkApp());
}

class TinyLinkApp extends StatelessWidget {
  const TinyLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        return GetMaterialApp(
          title: 'Tiny Link',
          debugShowCheckedModeBanner: false,
          theme: themeCtrl.buildTheme(),
          initialRoute: HiveService.isAccepted() ? Routes.apps : Routes.accept,
          getPages: AppPages.pages,
        );
      },
    );
  }
}
