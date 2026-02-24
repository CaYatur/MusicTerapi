import 'package:hive/hive.dart';

class SessionRecord extends HiveObject {
  String id;
  DateTime timestamp;
  int group;
  String mood;
  String selectedTrackId;
  int durationPlannedSeconds;
  int durationListenedSeconds;
  bool completed;
  int stressBefore;
  int stressAfter;
  int deltaStress;
  int surveyRelax;
  int surveyFeelGood;
  bool surveyRepeat;

  SessionRecord({
    required this.id,
    required this.timestamp,
    required this.group,
    required this.mood,
    required this.selectedTrackId,
    required this.durationPlannedSeconds,
    required this.durationListenedSeconds,
    required this.completed,
    required this.stressBefore,
    required this.stressAfter,
    required this.deltaStress,
    required this.surveyRelax,
    required this.surveyFeelGood,
    required this.surveyRepeat,
  });
}

class SessionRecordAdapter extends TypeAdapter<SessionRecord> {
  @override
  final int typeId = 1;

  @override
  SessionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SessionRecord(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      group: fields[2] as int,
      mood: fields[3] as String,
      selectedTrackId: fields[4] as String,
      durationPlannedSeconds: fields[5] as int,
      durationListenedSeconds: fields[6] as int,
      completed: fields[7] as bool,
      stressBefore: fields[8] as int,
      stressAfter: fields[9] as int,
      deltaStress: fields[10] as int,
      surveyRelax: fields[11] as int,
      surveyFeelGood: fields[12] as int,
      surveyRepeat: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SessionRecord obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.group)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.selectedTrackId)
      ..writeByte(5)
      ..write(obj.durationPlannedSeconds)
      ..writeByte(6)
      ..write(obj.durationListenedSeconds)
      ..writeByte(7)
      ..write(obj.completed)
      ..writeByte(8)
      ..write(obj.stressBefore)
      ..writeByte(9)
      ..write(obj.stressAfter)
      ..writeByte(10)
      ..write(obj.deltaStress)
      ..writeByte(11)
      ..write(obj.surveyRelax)
      ..writeByte(12)
      ..write(obj.surveyFeelGood)
      ..writeByte(13)
      ..write(obj.surveyRepeat);
  }
}
