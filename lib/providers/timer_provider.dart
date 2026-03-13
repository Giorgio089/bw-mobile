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
  final int currentPhaseIndex;
  final List<MapEntry<BreathingPhase, int>> phases;
  final Duration phaseDuration;

  const TimerState({
    required this.currentPhase,
    required this.secondsRemaining,
    required this.cycleCount,
    required this.isRunning,
    required this.currentPhaseIndex,
    required this.phases,
    required this.phaseDuration,
  });

  TimerState copyWith({
    BreathingPhase? currentPhase,
    int? secondsRemaining,
    int? cycleCount,
    bool? isRunning,
    int? currentPhaseIndex,
    List<MapEntry<BreathingPhase, int>>? phases,
    Duration? phaseDuration,
  }) {
    return TimerState(
      currentPhase: currentPhase ?? this.currentPhase,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      cycleCount: cycleCount ?? this.cycleCount,
      isRunning: isRunning ?? this.isRunning,
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      phases: phases ?? this.phases,
      phaseDuration: phaseDuration ?? this.phaseDuration,
    );
  }
}

/// Notifier that manages the breathing timer logic.
class TimerNotifier extends StateNotifier<TimerState> {
  final BreathingTechnique technique;
  final SoundService _soundService;
  Timer? _timer;
  DateTime? _startTime;
  Duration _elapsedOffset = Duration.zero;

  TimerNotifier(this.technique, this._soundService)
      : super(TimerState(
          currentPhase: technique.phases.first.key,
          secondsRemaining: technique.phases.first.value,
          cycleCount: 0,
          isRunning: false,
          currentPhaseIndex: 0,
          phases: technique.phases,
          phaseDuration: Duration(seconds: technique.phases.first.value),
        ));

  void start() {
    if (state.isRunning) return;
    
    _startTime = DateTime.now();
    state = state.copyWith(isRunning: true);
    _soundService.playPhaseSound(state.currentPhase);

    // Update every 100ms for responsiveness (e.g. countdown)
    // but without the heavy state rebuilds of high-frequency progress
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _tick();
    });
  }

  void _tick() {
    if (_startTime == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(_startTime!) + _elapsedOffset;
    final phaseDuration = state.phaseDuration;

    if (elapsed >= phaseDuration) {
      _moveToNextPhase();
    } else {
      final newSecondsRemaining = (phaseDuration.inMilliseconds - elapsed.inMilliseconds) ~/ 1000 + 1;
      if (newSecondsRemaining != state.secondsRemaining) {
        state = state.copyWith(secondsRemaining: newSecondsRemaining);
      }
    }
  }

  void pause() {
    if (!state.isRunning) return;
    
    if (_startTime != null) {
      _elapsedOffset += DateTime.now().difference(_startTime!);
    }
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _startTime = null;
    _elapsedOffset = Duration.zero;
    state = TimerState(
      currentPhase: technique.phases.first.key,
      secondsRemaining: technique.phases.first.value,
      cycleCount: 0,
      isRunning: false,
      currentPhaseIndex: 0,
      phases: technique.phases,
      phaseDuration: Duration(seconds: technique.phases.first.value),
    );
  }

  void _moveToNextPhase() {
    _startTime = DateTime.now();
    _elapsedOffset = Duration.zero;
    
    int nextIndex = state.currentPhaseIndex + 1;
    int newCycleCount = state.cycleCount;

    if (nextIndex >= state.phases.length) {
      nextIndex = 0;
      newCycleCount++;
    }

    final nextPhase = state.phases[nextIndex];
    final nextDuration = Duration(seconds: nextPhase.value);
    
    _soundService.playPhaseSound(nextPhase.key);

    state = state.copyWith(
      currentPhase: nextPhase.key,
      currentPhaseIndex: nextIndex,
      secondsRemaining: nextPhase.value,
      cycleCount: newCycleCount,
      phaseDuration: nextDuration,
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
