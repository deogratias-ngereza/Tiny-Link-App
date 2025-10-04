import 'package:hive/hive.dart';

/// WebViewConfig holds per-link webview settings and appearance.
/// - javascriptEnabled: allow JS execution
/// - zoomEnabled: allow pinch/gesture zoom (platform dependent)
/// - localStorageEnabled: allow webview local storage (approximated when disabled)
/// - initialZoom: initial zoom factor (1.0 = 100%); applied via JS/CSS best-effort
/// - startFullscreen: start browser in fullscreen (no app bar/bottom bar)
@HiveType(typeId: 3)
class WebViewConfig {
  @HiveField(0)
  final bool javascriptEnabled;

  @HiveField(1)
  final bool zoomEnabled;

  @HiveField(2)
  final bool localStorageEnabled;

  /// Initial zoom factor (1.0 = 100%). Best-effort via JS/CSS on page load.
  @HiveField(3)
  final double initialZoom;

  /// Start the browser in fullscreen (no app bar/bottom controls).
  @HiveField(4)
  final bool startFullscreen;

  /// Fullscreen Home button position: topLeft, topRight, bottomLeft, bottomCenter
  @HiveField(5)
  final String homeIconPosition;

  const WebViewConfig({
    this.javascriptEnabled = true,
    this.zoomEnabled = true,
    this.localStorageEnabled = true,
    this.initialZoom = 1.0,
    this.startFullscreen = false,
    this.homeIconPosition = 'topLeft',
  });

  WebViewConfig copyWith({
    bool? javascriptEnabled,
    bool? zoomEnabled,
    bool? localStorageEnabled,
    double? initialZoom,
    bool? startFullscreen,
    String? homeIconPosition,
  }) {
    return WebViewConfig(
      javascriptEnabled: javascriptEnabled ?? this.javascriptEnabled,
      zoomEnabled: zoomEnabled ?? this.zoomEnabled,
      localStorageEnabled: localStorageEnabled ?? this.localStorageEnabled,
      initialZoom: initialZoom ?? this.initialZoom,
      startFullscreen: startFullscreen ?? this.startFullscreen,
      homeIconPosition: homeIconPosition ?? this.homeIconPosition,
    );
  }
}

/// Manual Hive TypeAdapter (no code generation needed)
class WebViewConfigAdapter extends TypeAdapter<WebViewConfig> {
  @override
  final int typeId = 3;

  @override
  WebViewConfig read(BinaryReader reader) {
    // Standard Hive pattern: read number of fields then each field index/value
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WebViewConfig(
      javascriptEnabled: (fields[0] as bool?) ?? true,
      zoomEnabled: (fields[1] as bool?) ?? true,
      localStorageEnabled: (fields[2] as bool?) ?? true,
      initialZoom: (fields[3] as double?) ?? 1.0,
      startFullscreen: (fields[4] as bool?) ?? false,
      homeIconPosition: (fields[5] as String?) ?? 'topLeft',
    );
  }

  @override
  void write(BinaryWriter writer, WebViewConfig obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.javascriptEnabled)
      ..writeByte(1)
      ..write(obj.zoomEnabled)
      ..writeByte(2)
      ..write(obj.localStorageEnabled)
      ..writeByte(3)
      ..write(obj.initialZoom)
      ..writeByte(4)
      ..write(obj.startFullscreen)
      ..writeByte(5)
      ..write(obj.homeIconPosition);
  }
}
