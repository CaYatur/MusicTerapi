import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'file_service.dart';

/// A safe wrapper around [AudioPlayer] that catches all platform exceptions.
/// Ensures the app never crashes even if audio isn't available on the platform.
class SafeAudioPlayer {
  AudioPlayer? _player;
  bool _audioAvailable = true;
  bool _isPlaying = false;

  bool get audioAvailable => _audioAvailable;
  bool get isPlaying => _isPlaying;

  /// Try to create the underlying player. Returns false if not available.
  Future<bool> init() async {
    try {
      _player = AudioPlayer();
      _audioAvailable = true;
      return true;
    } catch (e) {
      debugPrint('SafeAudioPlayer.init failed: $e');
      _audioAvailable = false;
      _player = null;
      return false;
    }
  }

  /// Configure audio session (mobile only, safe on desktop).
  Future<void> configureSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint('AudioSession configure failed: $e');
    }
  }

  /// Load a track by its relative file path. Returns true on success.
  Future<bool> loadTrack(String relativeFilePath) async {
    if (_player == null) return false;
    try {
      final fullPath = await FileService.getFullPath(relativeFilePath);
      if (!await File(fullPath).exists()) return false;
      await _player!.setFilePath(fullPath);
      return true;
    } catch (e) {
      debugPrint('SafeAudioPlayer.loadTrack failed: $e');
      return false;
    }
  }

  /// Set loop mode. Silently fails if not available.
  Future<void> setLoopMode(LoopMode mode) async {
    try {
      await _player?.setLoopMode(mode);
    } catch (e) {
      debugPrint('SafeAudioPlayer.setLoopMode failed: $e');
    }
  }

  /// Start playback. Returns true if actually playing.
  Future<bool> play() async {
    if (_player == null) {
      _isPlaying = false;
      return false;
    }
    try {
      await _player!.play();
      _isPlaying = true;
      return true;
    } catch (e) {
      debugPrint('SafeAudioPlayer.play failed: $e');
      _isPlaying = false;
      return false;
    }
  }

  /// Pause playback.
  Future<void> pause() async {
    try {
      await _player?.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('SafeAudioPlayer.pause failed: $e');
      _isPlaying = false;
    }
  }

  /// Stop playback.
  Future<void> stop() async {
    try {
      await _player?.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('SafeAudioPlayer.stop failed: $e');
      _isPlaying = false;
    }
  }

  /// Listen for playback completion.
  void onComplete(VoidCallback callback) {
    _player?.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        callback();
      }
    });
  }

  /// Dispose the player.
  Future<void> dispose() async {
    try {
      await _player?.dispose();
    } catch (e) {
      debugPrint('SafeAudioPlayer.dispose failed: $e');
    }
    _player = null;
    _isPlaying = false;
  }
}
