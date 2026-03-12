import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/breathing_technique.dart';
import '../providers/timer_provider.dart';
import '../services/sound_service.dart';
import '../widgets/breathing_circle.dart';

/// Timer screen with the animated breathing circle.
class TimerScreen extends ConsumerStatefulWidget {
  final BreathingTechnique technique;

  const TimerScreen({super.key, required this.technique});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<Color?> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bgAnimation = ColorTween(
      begin: const Color(0xFFF5F5F7),
      end: widget.technique.color.withAlpha(25),
    ).animate(CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider(widget.technique));
    final notifier = ref.read(timerProvider(widget.technique).notifier);
    final soundService = ref.read(soundServiceProvider);

    // Animate background based on running state
    if (timerState.isRunning) {
      _bgController.forward();
    } else {
      _bgController.reverse();
    }

    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _bgAnimation.value,
          body: SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                        color: const Color(0xFF2D2D3A),
                        onPressed: () {
                          notifier.reset();
                          Navigator.of(context).pop();
                        },
                      ),
                      Expanded(
                        child: Text(
                          widget.technique.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D3A),
                          ),
                        ),
                      ),
                      // Mute toggle
                      IconButton(
                        icon: Icon(
                          soundService.isMuted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          size: 22,
                        ),
                        color: const Color(0xFF2D2D3A),
                        onPressed: () {
                          setState(() {
                            soundService.toggleMute();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Breathing circle
                BreathingCircle(
                  phase: timerState.currentPhase,
                  progress: timerState.progress,
                  color: widget.technique.color,
                  secondsRemaining: timerState.secondsRemaining,
                ),

                const SizedBox(height: 32),

                // Cycle counter
                AnimatedOpacity(
                  opacity: timerState.cycleCount > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    'Zyklus ${timerState.cycleCount}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset button
                      _ControlButton(
                        icon: Icons.refresh_rounded,
                        color: Colors.grey.shade400,
                        size: 52,
                        onTap: () => notifier.reset(),
                      ),
                      const SizedBox(width: 24),
                      // Play / Pause
                      _ControlButton(
                        icon: timerState.isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: widget.technique.color,
                        size: 72,
                        onTap: () {
                          if (timerState.isRunning) {
                            notifier.pause();
                          } else {
                            notifier.start();
                          }
                        },
                      ),
                      const SizedBox(width: 24),
                      // Spacer to balance layout
                      const SizedBox(width: 52),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A round control button with a subtle shadow.
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(50),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}
