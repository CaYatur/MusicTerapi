import 'package:flutter/material.dart';
import '../models/track.dart';
import 'listening_screen.dart';

class StressBeforeScreen extends StatefulWidget {
  final String mood;
  final List<Track> trackPool;
  final int durationSeconds;

  const StressBeforeScreen({
    super.key,
    required this.mood,
    required this.trackPool,
    required this.durationSeconds,
  });

  @override
  State<StressBeforeScreen> createState() => _StressBeforeScreenState();
}

class _StressBeforeScreenState extends State<StressBeforeScreen> {
  double _stressLevel = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Seans Öncesi Stres')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Şu anki stres seviyenizi değerlendirin',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Text(
              '${_stressLevel.round()}',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getStressColor(_stressLevel.round()),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1\nÇok düşük',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center),
                Text('10\nÇok yüksek',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center),
              ],
            ),
            Slider(
              value: _stressLevel,
              min: 1,
              max: 10,
              divisions: 9,
              label: '${_stressLevel.round()}',
              onChanged: (v) => setState(() => _stressLevel = v),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListeningScreen(
                      mood: widget.mood,
                      stressBefore: _stressLevel.round(),
                      trackPool: widget.trackPool,
                      durationSeconds: widget.durationSeconds,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.headphones),
              label: const Text('Dinlemeye Başla'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStressColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }
}
