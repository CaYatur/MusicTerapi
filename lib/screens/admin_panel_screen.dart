import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/track.dart';
import '../providers/tracks_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sessions_provider.dart';
import '../constants.dart';
import '../services/file_service.dart';
import '../services/safe_audio_player.dart';
import 'admin_track_edit_screen.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SafeAudioPlayer? _previewPlayer;
  String? _previewingTrackId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _previewPlayer?.dispose();
    super.dispose();
  }

  Future<void> _previewTrack(Track track) async {
    // Stop any current preview
    await _stopPreviewQuietly();

    final exists = await FileService.audioFileExists(track.filePath);
    if (!exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosya bulunamadı!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final player = SafeAudioPlayer();
    final inited = await player.init();
    bool loaded = false;
    bool playing = false;

    if (inited) {
      loaded = await player.loadTrack(track.filePath);
      if (loaded) {
        playing = await player.play();
      }
    }

    _previewPlayer = player;
    setState(() => _previewingTrackId = track.id);

    if (inited && loaded && playing) {
      // Listen for completion
      player.onComplete(() {
        if (mounted) setState(() => _previewingTrackId = null);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu cihazda ses önizleme desteklenmiyor.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      // Simulate short preview
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _previewingTrackId = null);
      });
    }
  }

  Future<void> _stopPreviewQuietly() async {
    await _previewPlayer?.stop();
    _previewPlayer?.dispose();
    _previewPlayer = null;
  }

  Future<void> _stopPreview() async {
    await _stopPreviewQuietly();
    if (mounted) {
      setState(() => _previewingTrackId = null);
    }
  }

  Future<void> _importAudio() async {
    final result = await FileService.pickAndCopyAudio();
    if (result == null) return;

    final track = Track(
      id: const Uuid().v4(),
      title: result['originalName']!.replaceAll(RegExp(r'\.[^.]+$'), ''),
      filePath: result['filePath']!,
      fileExt: result['fileExt']!,
      moods: [],
      enabled: true,
      createdAt: DateTime.now(),
    );

    await ref.read(tracksProvider.notifier).addTrack(track);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ses dosyası başarıyla eklendi!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteTrack(Track track) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ses Sil'),
        content: Text('"${track.title}" silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FileService.deleteAudioFile(track.filePath);
      await ref.read(tracksProvider.notifier).deleteTrack(track.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ses silindi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.library_music), text: 'Ses Kütüphanesi'),
            Tab(icon: Icon(Icons.settings), text: 'Ayarlar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLibraryTab(theme),
          _buildSettingsTab(theme),
        ],
      ),
    );
  }

  Widget _buildLibraryTab(ThemeData theme) {
    final tracks = ref.watch(tracksProvider);
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Column(
      children: [
        // Import button
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _importAudio,
            icon: const Icon(Icons.add),
            label: const Text('Ses Ekle (Import)'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        // Track count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Toplam: ${tracks.length} ses',
                  style: theme.textTheme.bodySmall),
              const Spacer(),
              Text(
                  'Aktif: ${tracks.where((t) => t.enabled).length}',
                  style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const Divider(),
        // Track list
        Expanded(
          child: tracks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_off,
                          size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text('Henüz ses eklenmemiş.',
                          style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Yukarıdaki butonu kullanarak ses ekleyin.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    final isPreviewing =
                        _previewingTrackId == track.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ExpansionTile(
                        leading: IconButton(
                          icon: Icon(
                            isPreviewing
                                ? Icons.stop_circle
                                : Icons.play_circle_outline,
                            color: isPreviewing
                                ? Colors.red
                                : theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            if (isPreviewing) {
                              _stopPreview();
                            } else {
                              _previewTrack(track);
                            }
                          },
                        ),
                        title: Text(
                          track.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: track.enabled
                                ? null
                                : TextDecoration.lineThrough,
                            color: track.enabled ? null : Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                          '${track.fileExt.toUpperCase()} • '
                          '${dateFormat.format(track.createdAt)} • '
                          '${track.enabled ? "Aktif" : "Pasif"}',
                          style: theme.textTheme.bodySmall,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16, 0, 16, 12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Mood tags
                                if (track.moods.isNotEmpty)
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: track.moods
                                        .map((m) => Chip(
                                              label: Text(m,
                                                  style:
                                                      const TextStyle(
                                                          fontSize:
                                                              12)),
                                              visualDensity:
                                                  VisualDensity
                                                      .compact,
                                            ))
                                        .toList(),
                                  )
                                else
                                  Text(
                                    'Duygu etiketi atanmamış',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                            color: Colors.orange),
                                  ),
                                const SizedBox(height: 12),
                                // Action buttons
                                Row(
                                  children: [
                                    // Toggle active
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        final updated = Track(
                                          id: track.id,
                                          title: track.title,
                                          filePath: track.filePath,
                                          fileExt: track.fileExt,
                                          moods:
                                              List.from(track.moods),
                                          enabled: !track.enabled,
                                          createdAt: track.createdAt,
                                        );
                                        ref
                                            .read(tracksProvider
                                                .notifier)
                                            .updateTrack(updated);
                                      },
                                      icon: Icon(
                                        track.enabled
                                            ? Icons
                                                .visibility_off
                                            : Icons.visibility,
                                        size: 18,
                                      ),
                                      label: Text(track.enabled
                                          ? 'Pasif Yap'
                                          : 'Aktif Yap'),
                                    ),
                                    const SizedBox(width: 8),
                                    // Edit
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AdminTrackEditScreen(
                                                    track: track),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit,
                                          size: 18),
                                      label: const Text('Düzenle'),
                                    ),
                                    const SizedBox(width: 8),
                                    // Delete
                                    IconButton(
                                      onPressed: () =>
                                          _deleteTrack(track),
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab(ThemeData theme) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Session duration
        Card(
          child: ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Seans Süresi'),
            trailing: DropdownButton<int>(
              value: settings.sessionDurationMinutes,
              underline: const SizedBox(),
              items: kSessionDurations.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text('$d dakika'),
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

        // Group change
        Card(
          child: ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Grup Değiştir'),
            subtitle: Text(
              'Mevcut: Grup ${settings.assignedGroup}',
            ),
            trailing: DropdownButton<int>(
              value: settings.assignedGroup,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Grup 1 (Deney)')),
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
        const SizedBox(height: 24),

        // Reset data
        OutlinedButton.icon(
          onPressed: () => _showResetDialog(),
          icon: const Icon(Icons.delete_forever, color: Colors.red),
          label: const Text('Tüm Verileri Sıfırla',
              style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning, color: Colors.red, size: 48),
        title: const Text('Tüm Verileri Sıfırla'),
        content: const Text(
          'Tüm seans kayıtları silinecektir.\n'
          'Ses dosyaları korunacaktır.\n'
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
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veriler sıfırlandı.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }
}
