import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import '../services/safe_audio_player.dart';
import '../services/file_service.dart';
import 'stress_after_screen.dart';

class ListeningScreen extends ConsumerStatefulWidget {
  final String mood;
  final int stressBefore;
  final List<Track> trackPool; // all candidate tracks for this mood/group
  final int durationSeconds;

  const ListeningScreen({
    super.key,
    required this.mood,
    required this.stressBefore,
    required this.trackPool,
    required this.durationSeconds,
  });

  @override
  ConsumerState<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends ConsumerState<ListeningScreen> {
  final SafeAudioPlayer _player = SafeAudioPlayer();
  final Random _random = Random();
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _audioWorking = true;
  String? _errorMessage;

  late Track _currentTrack;
  late List<Track> _remainingPool;

  @override
  void initState() {
    super.initState();
    _remainingPool = List.from(widget.trackPool);
    _currentTrack = _pickRandomTrack();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAudio());
  }

  /// Pick a random track from the pool. Reshuffles when pool is exhausted.
  Track _pickRandomTrack() {
    if (_remainingPool.isEmpty) {
      _remainingPool = List.from(widget.trackPool);
    }
    final index = _random.nextInt(_remainingPool.length);
    return _remainingPool.removeAt(index);
  }

  Future<void> _initAudio() async {
    final exists = await FileService.audioFileExists(_currentTrack.filePath);
    if (!exists) {
      if (mounted) setState(() => _errorMessage = 'Ses dosyası bulunamadı.');
      return;
    }

    await _player.configureSession();
    final inited = await _player.init();
    bool loaded = false;
    bool playing = false;

    if (inited) {
      loaded = await _player.loadTrack(_currentTrack.filePath);
      if (loaded) {
        // Don't loop single track — we'll advance to next random track
        await _player.setLoopMode(LoopMode.off);
        playing = await _player.play();
      }
    }

    _audioWorking = inited && loaded && playing;

    if (mounted) {
      setState(() {
        _isPlaying = true;
        _isInitialized = true;
      });

      if (!_audioWorking) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ses çalma başlatılamadı. Zamanlayıcı çalışıyor.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    // Listen for track completion → play next random track
    if (_audioWorking) {
      _player.onComplete(() {
        if (mounted && _isPlaying) {
          _playNextRandomTrack();
        }
      });
    }

    _startTimer();
  }

  /// Load and play the next random track
  Future<void> _playNextRandomTrack() async {
    if (widget.trackPool.length <= 1) {
      // Only one track available, replay it
      await _player.loadTrack(_currentTrack.filePath);
      await _player.play();
      // Re-register completion listener
      _player.onComplete(() {
        if (mounted && _isPlaying) _playNextRandomTrack();
      });
      return;
    }

    final nextTrack = _pickRandomTrack();
    final loaded = await _player.loadTrack(nextTrack.filePath);
    if (loaded) {
      await _player.play();
      if (mounted) setState(() => _currentTrack = nextTrack);
      // Re-register completion listener
      _player.onComplete(() {
        if (mounted && _isPlaying) _playNextRandomTrack();
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= widget.durationSeconds) {
          _finishSession(completed: true);
        }
      });
    });
  }

  void _finishSession({required bool completed}) {
    _timer?.cancel();
    _player.stop();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StressAfterScreen(
          mood: widget.mood,
          stressBefore: widget.stressBefore,
          selectedTrack: _currentTrack,
          durationPlannedSeconds: widget.durationSeconds,
          durationListenedSeconds: _elapsedSeconds,
          completed: completed,
        ),
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
      _timer?.cancel();
    } else {
      if (_audioWorking) await _player.play();
      _startTimer();
    }
    if (mounted) setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _showEndSessionDialog() async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seansı Bitir'),
        content:
            const Text('Seansı erken bitirmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hayır'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );
    if (shouldEnd == true) {
      _finishSession(completed: false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = widget.durationSeconds - _elapsedSeconds;
    final progress = widget.durationSeconds > 0
        ? _elapsedSeconds / widget.durationSeconds
        : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showEndSessionDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dinleme Seansı'),
          automaticallyImplyLeading: false,
        ),
        body: _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Geri Dön'),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Current track info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.music_note,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentTrack.title,
                                    style: theme.textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.trackPool.length > 1)
                                    Text(
                                      'Rastgele çalınıyor',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: theme.colorScheme.outline),
                                    ),
                                ],
                              ),
                            ),
                            if (!_audioWorking && _isInitialized)
                              const Tooltip(
                                message: 'Ses çalınamıyor',
                                child: Icon(Icons.volume_off,
                                    color: Colors.orange, size: 20),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Circular progress
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatTime(remaining > 0 ? remaining : 0),
                                style:
                                    theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('kalan',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Play/Pause
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed:
                              _isInitialized ? _togglePlayPause : null,
                          icon: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 48,
                          ),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(80, 80),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isPlaying ? 'Çalıyor...' : 'Duraklatıldı',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Spacer(),

                    // End session button
                    OutlinedButton.icon(
                      onPressed: () => _showEndSessionDialog(),
                      icon: const Icon(Icons.stop),
                      label: const Text('Seansı Bitir'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
