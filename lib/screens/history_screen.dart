import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sessions_provider.dart';
import 'session_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Seans Geçmişi')),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history,
                      size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('Henüz seans kaydı yok.',
                      style: theme.textTheme.bodyLarge),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final s = sessions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: s.deltaStress > 0
                          ? Colors.green.shade100
                          : s.deltaStress < 0
                              ? Colors.red.shade100
                              : Colors.grey.shade200,
                      child: Text(
                        s.deltaStress > 0
                            ? '-${s.deltaStress}'
                            : '${s.deltaStress}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: s.deltaStress > 0
                              ? Colors.green.shade800
                              : s.deltaStress < 0
                                  ? Colors.red.shade800
                                  : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    title: Text(s.mood),
                    subtitle: Text(
                      '${dateFormat.format(s.timestamp)} • '
                      'Stres: ${s.stressBefore}→${s.stressAfter} • '
                      'Grup ${s.group}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!s.completed)
                          const Icon(Icons.warning_amber,
                              size: 18, color: Colors.orange),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionDetailScreen(session: s),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
