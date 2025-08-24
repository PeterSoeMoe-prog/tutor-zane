import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selected;

  Future<void> _completeOnboarding() async {
    if (_selected == null) return;
    final prefs = Hive.box('prefs');
    await prefs.put('englishLevel', _selected);
    await prefs.put('onboardingDone', true);
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Get Started')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your English level',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'This helps us recommend where to start. You can change it later.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _LevelChip(
                  label: 'Beginner',
                  selected: _selected == 'beginner',
                  onTap: () => setState(() => _selected = 'beginner'),
                ),
                _LevelChip(
                  label: 'Intermediate',
                  selected: _selected == 'intermediate',
                  onTap: () => setState(() => _selected = 'intermediate'),
                ),
                _LevelChip(
                  label: 'Advanced',
                  selected: _selected == 'advanced',
                  onTap: () => setState(() => _selected = 'advanced'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selected == null ? null : _completeOnboarding,
                child: const Text('Continue'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.indigo : Colors.grey.shade300),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.indigo.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
