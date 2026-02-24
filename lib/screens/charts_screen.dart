import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sessions_provider.dart';
import '../models/session_record.dart';

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final theme = Theme.of(context);

    // Filter last 14 days
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final recentSessions = sessions
        .where((s) => s.timestamp.isAfter(twoWeeksAgo))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate statistics
    final completed = recentSessions.where((s) => s.completed).length;
    final avgStressBefore = recentSessions.isEmpty
        ? 0.0
        : recentSessions.map((s) => s.stressBefore).reduce((a, b) => a + b) /
            recentSessions.length;
    final avgStressAfter = recentSessions.isEmpty
        ? 0.0
        : recentSessions.map((s) => s.stressAfter).reduce((a, b) => a + b) /
            recentSessions.length;
    final avgDelta = recentSessions.isEmpty
        ? 0.0
        : recentSessions.map((s) => s.deltaStress).reduce((a, b) => a + b) /
            recentSessions.length;
    final totalRelax = recentSessions.isEmpty
        ? 0
        : recentSessions.map((s) => s.surveyRelax).reduce((a, b) => a + b);
    final repeatYes =
        recentSessions.where((s) => s.surveyRepeat).length;

    // Group by mood
    final moodStats = <String, List<SessionRecord>>{};
    for (final s in recentSessions) {
      moodStats.putIfAbsent(s.mood, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Grafikler')),
      body: recentSessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart,
                      size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('Son 14 günde veri yok.',
                      style: theme.textTheme.bodyLarge),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall summary
                  Text('Son 14 Gün Özeti',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Toplam Seans',
                    value: '${recentSessions.length}',
                    subtitle:
                        '$completed tamamlandı, ${recentSessions.length - completed} yarıda kaldı',
                  ),
                  const SizedBox(height: 8),
                  _SummaryCard(
                    title: 'Ort. Stres Önce',
                    value: avgStressBefore.toStringAsFixed(1),
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _SummaryCard(
                    title: 'Ort. Stres Sonra',
                    value: avgStressAfter.toStringAsFixed(1),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _SummaryCard(
                    title: 'Ort. Δ Stres',
                    value: '${avgDelta > 0 ? '+' : ''}${avgDelta.toStringAsFixed(1)}',
                    color: avgDelta > 0 ? Colors.green : Colors.red,
                    subtitle: avgDelta > 0
                        ? 'Stres azaldı ✓'
                        : avgDelta < 0
                            ? 'Stres arttı'
                            : 'Değişim yok',
                  ),
                  const SizedBox(height: 24),

                  // Anket sonuçları
                  Text('Anket Sonuçları',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Toplam Rahatlama Puanı',
                    value: '$totalRelax',
                  ),
                  _DetailRow(
                    label: 'Tekrar İsteyenler',
                    value: '$repeatYes (${recentSessions.isEmpty ? 0 : (repeatYes * 100 / recentSessions.length).toStringAsFixed(0)}%)',
                  ),
                  const SizedBox(height: 24),

                  // Duygu dağılımı
                  if (moodStats.isNotEmpty) ...[
                    Text('Duygu Dağılımı',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: moodStats.entries.length,
                      itemBuilder: (context, index) {
                        final entry = moodStats.entries.elementAt(index);
                        final count = entry.value.length;
                        final percentage = (count * 100 / recentSessions.length)
                            .toStringAsFixed(0);
                        final avgDeltaMood =
                            entry.value.map((s) => s.deltaStress).reduce((a, b) => a + b) /
                                entry.value.length;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.key,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.bold)),
                                    Text('$count seans ($percentage%)',
                                        style:
                                            theme.textTheme.bodySmall),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Δ: ${avgDeltaMood > 0 ? '+' : ''}${avgDeltaMood.toStringAsFixed(1)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: avgDeltaMood > 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal)),
        ],
      ),
    );
  }
}
