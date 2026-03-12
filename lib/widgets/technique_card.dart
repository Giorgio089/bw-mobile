import 'package:flutter/material.dart';
import '../models/breathing_technique.dart';

/// A styled card for displaying a breathing technique on the home screen.
class TechniqueCard extends StatelessWidget {
  final BreathingTechnique technique;
  final VoidCallback onTap;

  const TechniqueCard({
    super.key,
    required this.technique,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: technique.color.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: technique.color.withAlpha(50),
              highlightColor: technique.color.withAlpha(25),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Color accent dot
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            technique.color,
                            technique.color.withAlpha(120),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _techniqueIcon(technique.id),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            technique.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2D3A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            technique.description.split('\n').first,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            technique.description.split('\n').last,
                            style: TextStyle(
                              fontSize: 12,
                              color: technique.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _techniqueIcon(String id) {
    switch (id) {
      case 'box':
        return Icons.crop_square_rounded;
      case '478':
        return Icons.nightlight_round;
      case 'coherent':
        return Icons.favorite_rounded;
      default:
        return Icons.air;
    }
  }
}
