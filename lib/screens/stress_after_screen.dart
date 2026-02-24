import 'package:flutter/material.dart';
import '../models/track.dart';
import 'survey_screen.dart';

class StressAfterScreen extends StatefulWidget {
  final String mood;
  final int stressBefore;
  final Track selectedTrack;
  final int durationPlannedSeconds;
  final int durationListenedSeconds;
  final bool completed;

  const StressAfterScreen({
    super.key,
    required this.mood,
    required this.stressBefore,
    required this.selectedTrack,
    required this.durationPlannedSeconds,
    required this.durationListenedSeconds,
    required this.completed,
  });

  @override
  State<StressAfterScreen> createState() => _StressAfterScreenState();
}

class _StressAfterScreenState extends State<StressAfterScreen> {
  double _stressLevel = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seans Sonrası Stres'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.completed
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                size: 64,
                color: widget.completed ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                widget.completed
                    ? 'Seans tamamlandı!'
                    : 'Seans erken sonlandırıldı',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'Şu anki stres seviyenizi değerlendirin',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
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
                      builder: (_) => SurveyScreen(
                        mood: widget.mood,
                        stressBefore: widget.stressBefore,
                        stressAfter: _stressLevel.round(),
                        selectedTrack: widget.selectedTrack,
                        durationPlannedSeconds: widget.durationPlannedSeconds,
                        durationListenedSeconds:
                            widget.durationListenedSeconds,
                        completed: widget.completed,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Devam'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
          ),
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
