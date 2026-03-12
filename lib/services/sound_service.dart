import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/breathing_technique.dart';

/// Service for playing phase-transition sounds.
class SoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

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
