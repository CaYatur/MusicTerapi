import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session_record.dart';

class SessionDetailScreen extends StatelessWidget {
  final SessionRecord session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

    return Scaffold(
      appBar: AppBar(title: const Text('Seans Detayı')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    session.mood,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(dateFormat.format(session.timestamp)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StressCircle(
                        label: 'Önce',
                        value: session.stressBefore,
                        color: Colors.red,
                      ),
                      Icon(Icons.arrow_forward,
                          color: theme.colorScheme.onPrimaryContainer),
                      _StressCircle(
                        label: 'Sonra',
                        value: session.stressAfter,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Delta: ${session.deltaStress > 0 ? '+' : ''}${session.deltaStress}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: session.deltaStress > 0
                          ? Colors.green
                          : session.deltaStress < 0
                              ? Colors.red
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details
          _DetailTile('Grup', 'Grup ${session.group}'),
          _DetailTile(
              'Durum', session.completed ? 'Tamamlandı ✓' : 'Yarıda kaldı ⚠'),
          _DetailTile('Planlanan Süre',
              '${session.durationPlannedSeconds ~/ 60} dakika'),
          _DetailTile('Dinlenen Süre',
              _formatDuration(session.durationListenedSeconds)),
          _DetailTile('Parça ID', session.selectedTrackId),

          const SizedBox(height: 16),
          Text('Anket Sonuçları',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _DetailTile('Rahatlama', '${session.surveyRelax} / 5'),
          _DetailTile('İyi Hissetme', '${session.surveyFeelGood} / 5'),
          _DetailTile(
              'Tekrar İster mi?', session.surveyRepeat ? 'Evet' : 'Hayır'),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m dk $s sn';
  }
}

class _StressCircle extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StressCircle({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String title;
  final String value;

  const _DetailTile(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
