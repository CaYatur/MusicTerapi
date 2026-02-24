import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sessions_provider.dart';
import '../services/csv_export_service.dart';
import 'mood_selection_screen.dart';
import 'history_screen.dart';
import 'charts_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessions = ref.watch(sessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PsychoSound'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Stats summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.headphones,
                      label: 'Toplam Seans',
                      value: '${sessions.length}',
                    ),
                    _StatItem(
                      icon: Icons.trending_down,
                      label: 'Ort. Δ Stres',
                      value: sessions.isEmpty
                          ? '-'
                          : (sessions
                                      .map((s) => s.deltaStress)
                                      .reduce((a, b) => a + b) /
                                  sessions.length)
                              .toStringAsFixed(1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Main action buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _HomeCard(
                    icon: Icons.play_circle_filled,
                    label: 'Seans Başlat',
                    color: theme.colorScheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MoodSelectionScreen()),
                    ),
                  ),
                  _HomeCard(
                    icon: Icons.history,
                    label: 'Geçmiş',
                    color: theme.colorScheme.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistoryScreen()),
                    ),
                  ),
                  _HomeCard(
                    icon: Icons.bar_chart,
                    label: 'Grafikler',
                    color: theme.colorScheme.tertiary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChartsScreen()),
                    ),
                  ),
                  _HomeCard(
                    icon: Icons.file_download,
                    label: 'Dışa Aktar',
                    color: Colors.orange,
                    onTap: () {
                      CsvExportService.showExportDialog(context, sessions);
                    },
                  ),
                  _HomeCard(
                    icon: Icons.settings,
                    label: 'Ayarlar',
                    color: Colors.blueGrey,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(value,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
