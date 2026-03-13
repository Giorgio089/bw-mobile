import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/breathing_technique.dart';

/// Service for playing phase-transition sounds.
class SoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  /// Preload sounds into memory (internal buffer of AudioPlayer).
  Future<void> preload() async {
    try {
      // In audioplayers 6.x, we can set source to prepare it
      // but since we reuse one player, we just ensure it's ready.
      // For multiple sounds playing simultaneously or zero-latency switching,
      // multiple players or a pool might be better, but for this app one is fine.
      await _player.setSource(AssetSource('sounds/inhale.wav'));
      await _player.setSource(AssetSource('sounds/exhale.wav'));
      await _player.setSource(AssetSource('sounds/hold.wav'));
    } catch (_) {
      // Ignore errors if assets aren't yet available
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  Future<void> playPhaseSound(BreathingPhase phase) async {
    if (_isMuted) return;

    String asset;
    switch (phase) {
      case BreathingPhase.inhale:
        asset = 'sounds/inhale.wav';
        break;
      case BreathingPhase.exhale:
        asset = 'sounds/exhale.wav';
        break;
      case BreathingPhase.hold:
      case BreathingPhase.holdAfterExhale:
        asset = 'sounds/hold.wav';
        break;
    }

    try {
      // Stop current sound if playing and start new one
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Silently handle missing audio or playback errors
    }
  }

  void dispose() {
    _player.dispose();
  }
}

/// Global provider for the sound service.
final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(() => service.dispose());
  return service;
});
