import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/track.dart';
import '../models/session_record.dart';
import '../providers/sessions_provider.dart';
import '../providers/settings_provider.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  final String mood;
  final int stressBefore;
  final int stressAfter;
  final Track selectedTrack;
  final int durationPlannedSeconds;
  final int durationListenedSeconds;
  final bool completed;

  const SurveyScreen({
    super.key,
    required this.mood,
    required this.stressBefore,
    required this.stressAfter,
    required this.selectedTrack,
    required this.durationPlannedSeconds,
    required this.durationListenedSeconds,
    required this.completed,
  });

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  double _relax = 3;
  double _feelGood = 3;
  bool _repeat = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mini Anket'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rahatlama
              Text('Rahatlama dereceniz',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('1 - Hiç'),
                  const Text('5 - Çok fazla'),
                ],
              ),
              Slider(
                value: _relax,
                min: 1,
                max: 5,
                divisions: 4,
                label: '${_relax.round()}',
                onChanged: (v) => setState(() => _relax = v),
              ),
              Center(
                child: Text(
                  '${_relax.round()} / 5',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Divider(height: 40),

              // İyi hissetme
              Text('İyi hissetme dereceniz',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('1 - Hiç'),
                  const Text('5 - Çok fazla'),
                ],
              ),
              Slider(
                value: _feelGood,
                min: 1,
                max: 5,
                divisions: 4,
                label: '${_feelGood.round()}',
                onChanged: (v) => setState(() => _feelGood = v),
              ),
              Center(
                child: Text(
                  '${_feelGood.round()} / 5',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Divider(height: 40),

              // Tekrar ister misiniz?
              Text('Tekrar ister misiniz?',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Evet'),
                      selected: _repeat,
                      onSelected: (_) => setState(() => _repeat = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Hayır'),
                      selected: !_repeat,
                      onSelected: (_) => setState(() => _repeat = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Tamamla
              FilledButton.icon(
                onPressed: _saveAndFinish,
                icon: const Icon(Icons.check),
                label: const Text('Tamamla'),
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

  Future<void> _saveAndFinish() async {
    final settings = ref.read(settingsProvider);
    final delta = widget.stressBefore - widget.stressAfter;

    final record = SessionRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      group: settings.assignedGroup,
      mood: widget.mood,
      selectedTrackId: widget.selectedTrack.id,
      durationPlannedSeconds: widget.durationPlannedSeconds,
      durationListenedSeconds: widget.durationListenedSeconds,
      completed: widget.completed,
      stressBefore: widget.stressBefore,
      stressAfter: widget.stressAfter,
      deltaStress: delta,
      surveyRelax: _relax.round(),
      surveyFeelGood: _feelGood.round(),
      surveyRepeat: _repeat,
    );

    await ref.read(sessionsProvider.notifier).addSession(record);

    if (mounted) {
      // Show success then go home
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Seans kaydedildi! Stres farkı: $delta',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
