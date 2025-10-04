import 'package:hive/hive.dart';
import 'webview_config.dart';

/// Represents a single link under a specific App (appId).
/// Includes title, url, display color, and per-link webview configuration.
@HiveType(typeId: 1)
class LinkModel {
  @HiveField(0)
  final String id; // uuid

  @HiveField(1)
  final String appId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String url;

  /// Hex color string for display (e.g., #2196F3).
  @HiveField(4)
  final String colorHex;

  /// Last loaded url in the webview for this link (to resume where user left).
  @HiveField(5)
  final String? lastUrl;

  /// Per-link webview configuration (JS/Zoom/LocalStorage settings).
  @HiveField(6)
  final WebViewConfig config;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  LinkModel({
    required this.id,
    required this.appId,
    required this.title,
    required this.url,
    required this.colorHex,
    required this.config,
    this.lastUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  LinkModel copyWith({
    String? id,
    String? appId,
    String? title,
    String? url,
    String? colorHex,
    String? lastUrl,
    WebViewConfig? config,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LinkModel(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      title: title ?? this.title,
      url: url ?? this.url,
      colorHex: colorHex ?? this.colorHex,
      lastUrl: lastUrl ?? this.lastUrl,
      config: config ?? this.config,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Manual Hive TypeAdapter for LinkModel (no code generation needed).
class LinkModelAdapter extends TypeAdapter<LinkModel> {
  @override
  final int typeId = 1;

  @override
  LinkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return LinkModel(
      id: fields[0] as String,
      appId: fields[1] as String,
      title: fields[2] as String,
      url: fields[3] as String,
      colorHex: fields[4] as String,
      lastUrl: fields[5] as String?,
      config: fields[6] as WebViewConfig,
      createdAt: fields[7] as DateTime? ?? DateTime.now(),
      updatedAt: fields[8] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, LinkModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.appId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.colorHex)
      ..writeByte(5)
      ..write(obj.lastUrl)
      ..writeByte(6)
      ..write(obj.config)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }
}
