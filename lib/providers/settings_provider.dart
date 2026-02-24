import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier()
      : super(Hive.box<AppSettings>('settings').get('main') ??
            AppSettings(
              assignedGroup: 1,
              sessionDurationMinutes: 10,
              onboardingCompleted: false,
            ));

  final Box<AppSettings> _box = Hive.box<AppSettings>('settings');

  Future<void> _save() async {
    await _box.put('main', state);
  }

  Future<void> setOnboardingCompleted() async {
    state = AppSettings(
      assignedGroup: state.assignedGroup,
      sessionDurationMinutes: state.sessionDurationMinutes,
      onboardingCompleted: true,
    );
    await _save();
  }

  Future<void> setSessionDuration(int minutes) async {
    state = AppSettings(
      assignedGroup: state.assignedGroup,
      sessionDurationMinutes: minutes,
      onboardingCompleted: state.onboardingCompleted,
    );
    await _save();
  }

  Future<void> setGroup(int group) async {
    state = AppSettings(
      assignedGroup: group,
      sessionDurationMinutes: state.sessionDurationMinutes,
      onboardingCompleted: state.onboardingCompleted,
    );
    await _save();
  }

  Future<void> resetAll() async {
    state = AppSettings(
      assignedGroup: state.assignedGroup,
      sessionDurationMinutes: 10,
      onboardingCompleted: state.onboardingCompleted,
    );
    await _save();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
