import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../data/hive_service.dart';

/// ThemeController manages the app's seed color and builds ThemeData reactively.
/// It persists the chosen color in Hive (settings_box).
class ThemeController extends GetxController {
  final RxString _seedHex = HiveService.getThemeColorHex().obs;

  /// Current seed color as a Color.
  Color get seedColor => Color(HiveService.parseColorHex(_seedHex.value));

  /// Update the seed color (hex like #4F46E5) and persist it.
  Future<void> setSeedHex(String hex) async {
    _seedHex.value = hex;
    await HiveService.setThemeColorHex(hex);
    update(); // notify GetBuilder/GetX listeners
  }

  /// Compute a ThemeData based on the current seed color.
  ThemeData buildTheme() {
    final scheme = ColorScheme.fromSeed(seedColor: seedColor);
    // Decide overlay icon brightness based on seed luminance
    final isLight = seedColor.computeLuminance() > 0.5;
    final overlay = SystemUiOverlayStyle(
      statusBarColor: scheme.primary,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: scheme.primary,
      systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlay,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: scheme.surfaceVariant,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}
