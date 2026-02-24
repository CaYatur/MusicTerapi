import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/track.dart';

class TracksNotifier extends StateNotifier<List<Track>> {
  TracksNotifier() : super([]) {
    _load();
  }

  final Box<Track> _box = Hive.box<Track>('tracks');

  void _load() {
    state = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addTrack(Track track) async {
    await _box.put(track.id, track);
    _load();
  }

  Future<void> updateTrack(Track track) async {
    await _box.put(track.id, track);
    _load();
  }

  Future<void> deleteTrack(String id) async {
    await _box.delete(id);
    _load();
  }

  List<Track> getActiveTracks() {
    return state.where((t) => t.enabled).toList();
  }

  List<Track> getActiveTracksForMood(String mood) {
    return state.where((t) => t.enabled && t.moods.contains(mood)).toList();
  }

  void refresh() => _load();
}

final tracksProvider =
    StateNotifierProvider<TracksNotifier, List<Track>>((ref) {
  return TracksNotifier();
});
