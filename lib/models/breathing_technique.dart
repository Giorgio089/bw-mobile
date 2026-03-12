import 'package:flutter/material.dart';

/// Represents a single breathing phase.
enum BreathingPhase {
  inhale,
  hold,
  exhale,
  holdAfterExhale,
}

/// Immutable model for a breathing technique.
class BreathingTechnique {
  final String id;
  final String name;
  final String description;
  final Color color;
  final int inhaleDuration; // seconds
  final int holdDuration; // seconds (0 = skip)
  final int exhaleDuration; // seconds
  final int holdAfterExhaleDuration; // seconds (0 = skip)

  const BreathingTechnique({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.holdAfterExhaleDuration,
  });

  /// Returns the ordered list of phases with their durations.
  List<MapEntry<BreathingPhase, int>> get phases {
    final result = <MapEntry<BreathingPhase, int>>[];
    result.add(MapEntry(BreathingPhase.inhale, inhaleDuration));
    if (holdDuration > 0) {
      result.add(MapEntry(BreathingPhase.hold, holdDuration));
    }
    result.add(MapEntry(BreathingPhase.exhale, exhaleDuration));
    if (holdAfterExhaleDuration > 0) {
      result.add(MapEntry(BreathingPhase.holdAfterExhale, holdAfterExhaleDuration));
    }
    return result;
  }

  /// Total duration of one full cycle in seconds.
  int get cycleDuration =>
      inhaleDuration + holdDuration + exhaleDuration + holdAfterExhaleDuration;
}
