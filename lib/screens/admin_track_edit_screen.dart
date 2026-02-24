import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';
import '../constants.dart';
import '../providers/tracks_provider.dart';

class AdminTrackEditScreen extends ConsumerStatefulWidget {
  final Track track;

  const AdminTrackEditScreen({super.key, required this.track});

  @override
  ConsumerState<AdminTrackEditScreen> createState() =>
      _AdminTrackEditScreenState();
}

class _AdminTrackEditScreenState extends ConsumerState<AdminTrackEditScreen> {
  late TextEditingController _titleController;
  late List<String> _selectedMoods;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.track.title);
    _selectedMoods = List.from(widget.track.moods);
    _enabled = widget.track.enabled;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık boş olamaz.')),
      );
      return;
    }

    final updated = Track(
      id: widget.track.id,
      title: title,
      filePath: widget.track.filePath,
      fileExt: widget.track.fileExt,
      moods: _selectedMoods,
      enabled: _enabled,
      createdAt: widget.track.createdAt,
    );

    await ref.read(tracksProvider.notifier).updateTrack(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ses güncellendi!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ses Düzenle'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Kaydet'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 24),

          // File info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.audiotrack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dosya: ${widget.track.filePath}',
                            style: theme.textTheme.bodySmall),
                        Text('Format: ${widget.track.fileExt.toUpperCase()}',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mood tags
          Text('Duygu Etiketleri',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Bu ses hangi duygu durumları için uygun?',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kMoods.map((mood) {
              final isSelected = _selectedMoods.contains(mood.name);
              return FilterChip(
                label: Text('${mood.emoji} ${mood.name}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedMoods.add(mood.name);
                    } else {
                      _selectedMoods.remove(mood.name);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Active toggle
          SwitchListTile(
            title: const Text('Aktif'),
            subtitle: Text(_enabled
                ? 'Bu ses seanslarda kullanılabilir'
                : 'Bu ses seanslarda kullanılmaz'),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          const SizedBox(height: 32),

          // Save button
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Değişiklikleri Kaydet'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        ],
      ),
    );
  }
}
