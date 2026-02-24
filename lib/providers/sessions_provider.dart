import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/session_record.dart';

class SessionsNotifier extends StateNotifier<List<SessionRecord>> {
  SessionsNotifier() : super([]) {
    _load();
  }

  final Box<SessionRecord> _box = Hive.box<SessionRecord>('sessions');

  void _load() {
    state = _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addSession(SessionRecord session) async {
    await _box.put(session.id, session);
    _load();
  }

  Future<void> clearAll() async {
    await _box.clear();
    _load();
  }

  void refresh() => _load();
}

final sessionsProvider =
    StateNotifierProvider<SessionsNotifier, List<SessionRecord>>((ref) {
  return SessionsNotifier();
});
