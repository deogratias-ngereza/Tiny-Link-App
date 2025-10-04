import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/app_model.dart';
import '../models/link_model.dart';
import '../models/webview_config.dart';

/// Centralized Hive initialization and box access.
/// - Registers all adapters (manual adapters implemented in models)
/// - Opens boxes for apps and links
/// - Optionally seeds initial data
class HiveService {
  static const String appsBoxName = 'apps_box';
  static const String linksBoxName = 'links_box';
  static const String settingsBoxName = 'settings_box';

  static bool _registered = false;

  /// Initialize Hive, register adapters, and open boxes.
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters once
    if (!_registered) {
      Hive.registerAdapter(AppModelAdapter());
      Hive.registerAdapter(LinkModelAdapter());
      Hive.registerAdapter(WebViewConfigAdapter());
      _registered = true;
    }

    // Open boxes
    await Future.wait([
      Hive.openBox<AppModel>(appsBoxName),
      Hive.openBox<LinkModel>(linksBoxName),
      Hive.openBox(settingsBoxName),
    ]);
  }

  static Box<AppModel> get appsBox => Hive.box<AppModel>(appsBoxName);
  static Box<LinkModel> get linksBox => Hive.box<LinkModel>(linksBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);

  /// Seed example apps if empty so the UI has something to display.
  static Future<void> seedIfEmpty() async {
    if (appsBox.isEmpty) {
      final uuid = const Uuid();
      final samples = <AppModel>[
        AppModel(id: uuid.v4(), name: 'YouTube', colorHex: '#FF0000'),
        AppModel(id: uuid.v4(), name: 'Gmail', colorHex: '#D93025'),
        AppModel(id: uuid.v4(), name: 'Docs', colorHex: '#1A73E8'),
      ];
      for (final a in samples) {
        await appsBox.put(a.id, a);
      }
    }
  }

  /// Helper to parse a hex color string (#RRGGBB or #AARRGGBB) to int ARGB.
  /// Defaults to opaque if alpha missing.
  static int parseColorHex(String hex) {
    var value = hex.replaceAll('#', '').toUpperCase();
    if (value.length == 6) {
      value = 'FF$value'; // add opaque alpha
    }
    return int.parse(value, radix: 16);
  }

  /// Terms/consent acceptance helpers
  static bool isAccepted() {
    return (settingsBox.get('accepted', defaultValue: false) as bool);
  }

  static Future<void> setAccepted(bool accepted) async {
    await settingsBox.put('accepted', accepted);
  }

  // Theme color helpers (seed color for the app)
  static String getThemeColorHex() {
    return (settingsBox.get('themeColor', defaultValue: '#4F46E5') as String);
  }

  static Future<void> setThemeColorHex(String hex) async {
    await settingsBox.put('themeColor', hex);
  }
}
