import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/track.dart';
import 'models/session_record.dart';
import 'models/app_settings.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch unhandled async errors (e.g. audio plugin init failures)
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled platform error: $error');
    return true; // Prevent crash
  };

  await Hive.initFlutter();

  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(SessionRecordAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  await Hive.openBox<Track>('tracks');
  await Hive.openBox<SessionRecord>('sessions');
  await Hive.openBox<AppSettings>('settings');

  // Initialize settings on first run
  final settingsBox = Hive.box<AppSettings>('settings');
  if (settingsBox.get('main') == null) {
    final group = Random().nextInt(2) + 1;
    await settingsBox.put(
      'main',
      AppSettings(
        assignedGroup: group,
        sessionDurationMinutes: 10,
        onboardingCompleted: false,
      ),
    );
  }

  runApp(const ProviderScope(child: PsychoSoundApp()));
}

class PsychoSoundApp extends StatelessWidget {
  const PsychoSoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Hive.box<AppSettings>('settings').get('main')!;

    return MaterialApp(
      title: 'PsychoSound',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: settings.onboardingCompleted
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}
