import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.music_note_rounded,
                size: 100,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'PsychoSound',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Duygu durumunuza göre kişiselleştirilmiş müzik terapi seansları ile stresinizi azaltın.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.secondary),
                      const SizedBox(height: 8),
                      Text(
                        'Size rastgele bir deney grubu atandı. '
                        'Ayarlar ekranından grubunuzu görebilirsiniz.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(settingsProvider.notifier)
                      .setOnboardingCompleted();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const HomeScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Başla'),
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
}
