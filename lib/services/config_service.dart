import 'dart:convert';

import 'package:hive/hive.dart';

import '../data/hive_service.dart';
import '../models/app_model.dart';
import '../models/link_model.dart';
import '../models/webview_config.dart';

/// Configuration export/import service.
/// Exports the full configuration (apps, links, settings) to JSON and imports it back.
class ConfigService {
  static const _schemaVersion = 1;

  /// Export current configuration to a JSON string.
  /// Contains:
  /// - version
  /// - settings: { themeColorHex }
  /// - apps: [{ id, name, colorHex }]
  /// - links: [ full LinkModel including WebViewConfig ]
  static String exportToJsonString() {
    final apps = HiveService.appsBox.values.map((a) => {
          'id': a.id,
          'name': a.name,
          'colorHex': a.colorHex,
        });

    final links = HiveService.linksBox.values.map((l) => {
          'id': l.id,
          'appId': l.appId,
          'title': l.title,
          'url': l.url,
          'colorHex': l.colorHex,
          'lastUrl': l.lastUrl,
          'config': {
            'javascriptEnabled': l.config.javascriptEnabled,
            'zoomEnabled': l.config.zoomEnabled,
            'localStorageEnabled': l.config.localStorageEnabled,
            'initialZoom': l.config.initialZoom,
            'startFullscreen': l.config.startFullscreen,
            'homeIconPosition': l.config.homeIconPosition,
          },
          'createdAt': l.createdAt.toIso8601String(),
          'updatedAt': l.updatedAt.toIso8601String(),
        });

    final settings = {
      'themeColorHex': HiveService.getThemeColorHex(),
    };

    final bundle = {
      'version': _schemaVersion,
      'settings': settings,
      'apps': apps.toList(),
      'links': links.toList(),
    };

    // Pretty-print JSON
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(bundle);
  }

  /// Import configuration from a JSON string.
  /// By default replaces all existing apps/links/settings.
  /// Throws [FormatException] if JSON schema is invalid.
  static Future<void> importFromJsonString(String jsonString,
      {bool replaceExisting = true}) async {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON format: expected an object');
    }

    final int version = decoded['version'] is int ? decoded['version'] as int : 0;
    if (version != _schemaVersion) {
      // For now we require exact version match; later we can migrate or relax
      throw FormatException('Unsupported config version: $version (expected $_schemaVersion)');
    }

    final settings = decoded['settings'] as Map<String, dynamic>? ?? {};
    final apps = decoded['apps'] as List<dynamic>? ?? [];
    final links = decoded['links'] as List<dynamic>? ?? [];

    // Optionally clear existing data
    if (replaceExisting) {
      await HiveService.appsBox.clear();
      await HiveService.linksBox.clear();
    }

    // Import apps
    for (final a in apps) {
      if (a is! Map<String, dynamic>) continue;
      final app = AppModel(
        id: (a['id'] as String?) ?? '',
        name: (a['name'] as String?) ?? '',
        colorHex: (a['colorHex'] as String?) ?? '#4F46E5',
      );
      if (app.id.isEmpty || app.name.isEmpty) continue;
      await HiveService.appsBox.put(app.id, app);
    }

    // Import links
    for (final l in links) {
      if (l is! Map<String, dynamic>) continue;
      final cfg = (l['config'] as Map<String, dynamic>?);
      final config = WebViewConfig(
        javascriptEnabled: (cfg?['javascriptEnabled'] as bool?) ?? true,
        zoomEnabled: (cfg?['zoomEnabled'] as bool?) ?? true,
        localStorageEnabled: (cfg?['localStorageEnabled'] as bool?) ?? true,
        initialZoom: (cfg?['initialZoom'] as num?)?.toDouble() ?? 1.0,
        startFullscreen: (cfg?['startFullscreen'] as bool?) ?? false,
        homeIconPosition: (cfg?['homeIconPosition'] as String?) ?? 'topLeft',
      );
      final createdAtStr = l['createdAt'] as String?;
      final updatedAtStr = l['updatedAt'] as String?;
      final link = LinkModel(
        id: (l['id'] as String?) ?? '',
        appId: (l['appId'] as String?) ?? '',
        title: (l['title'] as String?) ?? '',
        url: (l['url'] as String?) ?? '',
        colorHex: (l['colorHex'] as String?) ?? '#4F46E5',
        config: config,
        lastUrl: l['lastUrl'] as String?,
        createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
        updatedAt: updatedAtStr != null ? DateTime.tryParse(updatedAtStr) : null,
      );
      if (link.id.isEmpty || link.appId.isEmpty || link.title.isEmpty || link.url.isEmpty) {
        continue;
      }
      await HiveService.linksBox.put(link.id, link);
    }

    // Import settings (theme color)
    final themeHex = (settings['themeColorHex'] as String?) ?? '#4F46E5';
    await HiveService.setThemeColorHex(themeHex);
  }
}
