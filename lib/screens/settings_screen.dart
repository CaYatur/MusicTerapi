import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../providers/settings_provider.dart';
import '../providers/sessions_provider.dart';
import 'admin_panel_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Grup bilgisi & değiştirme
          Card(
            child: ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Grubum'),
              subtitle: Text(
                settings.assignedGroup == 1
                    ? 'Grup 1 (Deney)'
                    : 'Grup 2 (Kontrol)',
              ),
              trailing: DropdownButton<int>(
                value: settings.assignedGroup,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                      value: 1, child: Text('Grup 1 (Deney)')),
                  DropdownMenuItem(
                      value: 2, child: Text('Grup 2 (Kontrol)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setGroup(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Seans süresi
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Seans Süresi'),
              subtitle: Text('${settings.sessionDurationMinutes} dakika'),
              trailing: DropdownButton<int>(
                value: settings.sessionDurationMinutes,
                underline: const SizedBox(),
                items: kSessionDurations.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text('$d dk'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .setSessionDuration(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Admin Panel
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: ListTile(
              leading: Icon(Icons.admin_panel_settings,
                  color: theme.colorScheme.onSecondaryContainer),
              title: Text(
                'Admin Panel',
                style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Ses kütüphanesi ve içerik yönetimi',
                style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer
                        .withOpacity(0.7)),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: theme.colorScheme.onSecondaryContainer),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminPanelScreen()),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Verileri sıfırla
          OutlinedButton.icon(
            onPressed: () => _showResetDialog(context, ref),
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text('Verileri Sıfırla',
                style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning, color: Colors.red, size: 48),
        title: const Text('Verileri Sıfırla'),
        content: const Text(
          'Tüm seans kayıtları silinecektir.\n'
          'Bu işlem geri alınamaz!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(sessionsProvider.notifier).clearAll();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tüm seans verileri silindi.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
