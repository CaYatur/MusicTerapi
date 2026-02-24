import 'package:hive/hive.dart';

class Track extends HiveObject {
  String id;
  String title;
  String filePath;
  String fileExt;
  List<String> moods;
  bool enabled;
  DateTime createdAt;

  Track({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileExt,
    required this.moods,
    this.enabled = true,
    required this.createdAt,
  });
}

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 0;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Track(
      id: fields[0] as String,
      title: fields[1] as String,
      filePath: fields[2] as String,
      fileExt: fields[3] as String,
      moods: (fields[4] as List).cast<String>(),
      enabled: fields[5] as bool,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.fileExt)
      ..writeByte(4)
      ..write(obj.moods)
      ..writeByte(5)
      ..write(obj.enabled)
      ..writeByte(6)
      ..write(obj.createdAt);
  }
}
