import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/breathing_technique.dart';
import '../services/sound_service.dart';

/// State for the breathing timer.
class TimerState {
  final BreathingPhase currentPhase;
  final int secondsRemaining;
  final int cycleCount;
  final bool isRunning;
  final double progress; // 0.0 to 1.0 within current phase
  final int currentPhaseIndex;
  final List<MapEntry<BreathingPhase, int>> phases;

  const TimerState({
    required this.currentPhase,
    required this.secondsRemaining,
    required this.cycleCount,
    required this.isRunning,
    required this.progress,
    required this.currentPhaseIndex,
    required this.phases,
  });

  TimerState copyWith({
    BreathingPhase? currentPhase,
    int? secondsRemaining,
    int? cycleCount,
    bool? isRunning,
    double? progress,
    int? currentPhaseIndex,
    List<MapEntry<BreathingPhase, int>>? phases,
  }) {
    return TimerState(
      currentPhase: currentPhase ?? this.currentPhase,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      cycleCount: cycleCount ?? this.cycleCount,
      isRunning: isRunning ?? this.isRunning,
      progress: progress ?? this.progress,
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      phases: phases ?? this.phases,
    );
  }
}

/// Notifier that manages the breathing timer logic.
class TimerNotifier extends StateNotifier<TimerState> {
  final BreathingTechnique technique;
  final SoundService _soundService;
  Timer? _timer;
  int _elapsed = 0; // milliseconds elapsed in current phase

  TimerNotifier(this.technique, this._soundService)
      : super(TimerState(
          currentPhase: technique.phases.first.key,
          secondsRemaining: technique.phases.first.value,
          cycleCount: 0,
          isRunning: false,
          progress: 0.0,
          currentPhaseIndex: 0,
          phases: technique.phases,
        ));

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _soundService.playPhaseSound(state.currentPhase);

    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _elapsed += 50;
      final phaseDurationMs = state.phases[state.currentPhaseIndex].value * 1000;
      final progress = _elapsed / phaseDurationMs;

      if (_elapsed >= phaseDurationMs) {
        _moveToNextPhase();
      } else {
        state = state.copyWith(
          progress: progress.clamp(0.0, 1.0),
          secondsRemaining: ((phaseDurationMs - _elapsed) / 1000).ceil(),
        );
      }
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _elapsed = 0;
    state = TimerState(
      currentPhase: technique.phases.first.key,
      secondsRemaining: technique.phases.first.value,
      cycleCount: 0,
      isRunning: false,
      progress: 0.0,
      currentPhaseIndex: 0,
      phases: technique.phases,
    );
  }

  void _moveToNextPhase() {
    _elapsed = 0;
    int nextIndex = state.currentPhaseIndex + 1;
    int newCycleCount = state.cycleCount;

    if (nextIndex >= state.phases.length) {
      nextIndex = 0;
      newCycleCount++;
    }

    final nextPhase = state.phases[nextIndex];
    _soundService.playPhaseSound(nextPhase.key);

    state = state.copyWith(
      currentPhase: nextPhase.key,
      currentPhaseIndex: nextIndex,
      secondsRemaining: nextPhase.value,
      cycleCount: newCycleCount,
      progress: 0.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider family for creating a timer for a specific technique.
final timerProvider =
    StateNotifierProvider.autoDispose.family<TimerNotifier, TimerState, BreathingTechnique>(
  (ref, technique) {
    final soundService = ref.read(soundServiceProvider);
    return TimerNotifier(technique, soundService);
  },
);
