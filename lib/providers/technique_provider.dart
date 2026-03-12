import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/breathing_technique.dart';

/// Provides the list of available breathing techniques.
final techniquesProvider = Provider<List<BreathingTechnique>>((ref) {
  return const [
    BreathingTechnique(
      id: 'box',
      name: 'Box Breathing',
      description: 'Gleiche Intervalle für Ruhe und Fokus.\n4s einatmen · 4s halten · 4s ausatmen · 4s halten',
      color: Color(0xFFC4B7E6), // Lavendel
      inhaleDuration: 4,
      holdDuration: 4,
      exhaleDuration: 4,
      holdAfterExhaleDuration: 4,
    ),
    BreathingTechnique(
      id: '478',
      name: '4-7-8 Relaxing',
      description: 'Tiefenentspannung für besseren Schlaf.\n4s einatmen · 7s halten · 8s ausatmen',
      color: Color(0xFFA8E6CF), // Mint
      inhaleDuration: 4,
      holdDuration: 7,
      exhaleDuration: 8,
      holdAfterExhaleDuration: 0,
    ),
    BreathingTechnique(
      id: 'coherent',
      name: 'Coherent Breathing',
      description: 'Harmonisiert Herzschlag und Atmung.\n5s einatmen · 5s ausatmen',
      color: Color(0xFFFFD3B6), // Pfirsich
      inhaleDuration: 5,
      holdDuration: 0,
      exhaleDuration: 5,
      holdAfterExhaleDuration: 0,
    ),
  ];
});
