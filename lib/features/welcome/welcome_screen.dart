import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/content_providers.dart';
import '../../providers/progress_providers.dart';
import '../../models/level.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncLevels = ref.watch(levelsProvider);
    final progress = ref.watch(progressServiceProvider);

    String? computeNextLessonYoutubeId(LevelsRoot data) {
      for (final level in data.levels) {
        for (final lesson in level.lessons) {
          final completed = progress.isLessonCompleted(lesson.id) ||
              progress.isLessonCompleted(lesson.youtubeId);
          if (!completed) return lesson.youtubeId;
        }
      }
      // If all completed or empty, default to first available
      for (final level in data.levels) {
        if (level.lessons.isNotEmpty) return level.lessons.first.youtubeId;
      }
      return null;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              const SizedBox(height: 54),
              // Big, attractive title
              Text(
                'WELCOME',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: const Color(0xFF4A148C), // deep purple
                  fontSize: (theme.textTheme.displaySmall?.fontSize ?? 36) * 1.56,
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 20),
              // Supporting copy
              Text(
                'Watch short YouTube lessons and take quick quizzes to lock it in.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              // Temporary: Back to Intro (Onboarding)
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () => context.go('/onboarding'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Intro'),
                ),
              ),
              const SizedBox(height: 8),
              // Resume where you left off
              asyncLevels.when(
                data: (data) {
                  final nextId = computeNextLessonYoutubeId(data);
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: nextId == null
                          ? null
                          : () => context.go('/levels/video/$nextId'),
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Resume learning'),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  width: double.infinity,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => SizedBox(
                  width: double.infinity,
                  child: Text(' '),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          ),
          // Full-bleed bottom image with overlayed button (no side padding)
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Show the full image (no horizontal cropping)
                Image.asset(
                  'assets/images/1.png',
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.contain,
                ),
                // Subtle gradient at the bottom for legibility
                Align(
                  alignment: Alignment.bottomCenter,
                  child: IgnorePointer(
                    child: Container(
                      height: 140,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0x99000000),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom overlay button
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        child: _PulsingContinueButton(
                          onPressed: () => context.go('/levels'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _PulsingContinueButton extends StatefulWidget {
  const _PulsingContinueButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_PulsingContinueButton> createState() => _PulsingContinueButtonState();
}

class _PulsingContinueButtonState extends State<_PulsingContinueButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: _scale,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        icon: const Icon(Icons.play_arrow, size: 28),
        label: const Text('Continue'),
        onPressed: widget.onPressed,
      ),
    );
  }
}
