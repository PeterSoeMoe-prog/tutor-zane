import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/lesson_providers.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _current = 0;
  int _selectedIndex = -1;
  int _score = 0;

  void _submitOne({required int correctIndex}) {
    if (_selectedIndex == correctIndex) {
      _score++;
    }
    setState(() {
      _selectedIndex = -1;
      _current++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncLesson = ref.watch(lessonByIdProvider(widget.lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: asyncLesson.when(
        data: (lesson) {
          if (lesson == null || lesson.questions.isEmpty) {
            return const Center(child: Text('No questions available.'));
          }
          final total = lesson.questions.length;
          if (_current >= total) {
            // Finished: navigate to results and replace stack
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/levels/results', extra: {
                'score': _score,
                'total': total,
              });
            });
            return const SizedBox.shrink();
          }

          final q = lesson.questions[_current];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lesson: ${lesson.title}', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: (_current + 1) / total),
                const SizedBox(height: 12),
                Text('Question ${_current + 1} of $total', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Text(q.text, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (var i = 0; i < q.options.length; i++)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        _selectedIndex == i
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: _selectedIndex == i ? Theme.of(context).colorScheme.primary : null,
                      ),
                      title: Text(q.options[i]),
                      onTap: () => setState(() => _selectedIndex = i),
                    ),
                  ),
                const Spacer(),
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedIndex == -1
                          ? null
                          : () => _submitOne(correctIndex: q.correctIndex),
                      child: Text(_current + 1 == total ? 'Finish' : 'Next'),
                    ),
                  ),
                )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load lesson: $e')),
      ),
    );
  }
}
