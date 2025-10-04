import 'package:hive/hive.dart';

/// Represents an App grouping (e.g., "YouTube", "Gmail", "Docs").
/// Each app contains multiple links managed separately.
@HiveType(typeId: 0)
class AppModel {
  @HiveField(0)
  final String id; // uuid

  @HiveField(1)
  final String name;

  /// Hex color string for display (e.g., #FF5722).
  @HiveField(2)
  final String colorHex;

  const AppModel({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  AppModel copyWith({
    String? id,
    String? name,
    String? colorHex,
  }) {
    return AppModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}

/// Manual Hive TypeAdapter for AppModel.
class AppModelAdapter extends TypeAdapter<AppModel> {
  @override
  final int typeId = 0;

  @override
  AppModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppModel(
      id: fields[0] as String,
      name: fields[1] as String,
      colorHex: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorHex);
  }
}
