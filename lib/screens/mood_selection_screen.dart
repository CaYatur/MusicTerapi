import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../models/track.dart';
import '../providers/tracks_provider.dart';
import '../providers/settings_provider.dart';
import 'stress_before_screen.dart';

class MoodSelectionScreen extends ConsumerWidget {
  const MoodSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final tracksNotifier = ref.read(tracksProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Nasıl Hissediyorsunuz?')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Şu anki duygu durumunuzu seçin',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: kMoods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final mood = kMoods[index];
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      leading: Text(mood.emoji,
                          style: const TextStyle(fontSize: 36)),
                      title: Text(
                        mood.name,
                        style: theme.textTheme.titleLarge,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: theme.colorScheme.primary),
                      onTap: () {
                        // Determine track pool
                        List<Track> candidates;

                        if (settings.assignedGroup == 1) {
                          // Deney grubu: duyguya göre
                          candidates =
                              tracksNotifier.getActiveTracksForMood(mood.name);
                        } else {
                          // Kontrol grubu: tüm aktiflerden
                          candidates =
                              tracksNotifier.getActiveTracks();
                        }

                        if (candidates.isEmpty) {
                          _showNoTrackDialog(context);
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StressBeforeScreen(
                              mood: mood.name,
                              trackPool: candidates,
                              durationSeconds:
                                  settings.sessionDurationMinutes * 60,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoTrackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48),
        title: const Text('İçerik Bulunamadı'),
        content: const Text(
          'Bu duygu için uygun ses içeriği yok.\n'
          'Lütfen Admin Panel\'den ses ekleyin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
