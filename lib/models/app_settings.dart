import 'package:hive/hive.dart';

class AppSettings extends HiveObject {
  int assignedGroup;
  int sessionDurationMinutes;
  bool onboardingCompleted;

  AppSettings({
    required this.assignedGroup,
    required this.sessionDurationMinutes,
    this.onboardingCompleted = false,
  });
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 2;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AppSettings(
      assignedGroup: fields[0] as int,
      sessionDurationMinutes: fields[1] as int,
      onboardingCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.assignedGroup)
      ..writeByte(1)
      ..write(obj.sessionDurationMinutes)
      ..writeByte(2)
      ..write(obj.onboardingCompleted);
  }
}
