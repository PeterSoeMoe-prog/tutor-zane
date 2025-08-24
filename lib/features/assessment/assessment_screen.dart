import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/assessment_providers.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key, required this.levelId, required this.blockIndex});

  final String levelId;
  final int blockIndex; // 1-based

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  int _current = 0;
  int _selected = -1;
  int _score = 0;

  // Simple placeholder questions; in Phase 2, load from content
  late final List<_Q> _questions = [
    _Q('Choose the correct greeting for morning', ['Good night', 'Good morning', 'See you', 'Later'], 1),
    _Q('Pick a polite reply to thanks', ["Please", "You're welcome", "No"], 1),
    _Q('Which phrase talks about future?', ['I went', "I'm going to", 'I was'], 1),
    _Q('Best request at a restaurant', ['Give me water', 'Can I have water, please?', 'Water.'], 1),
    _Q('Which is a comparative?', ['big', 'bigger', 'biggest'], 1),
  ];

  void _submitOne() {
    if (_selected == _questions[_current].correct) _score++;
    setState(() {
      _selected = -1;
      _current++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _questions.length;
    if (_current >= total) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final svc = ref.read(assessmentServiceProvider);
        final router = GoRouter.of(context);
        await svc.markAssessmentCompleted(widget.levelId, widget.blockIndex);
        if (!mounted) return;
        router.go('/levels/results', extra: {'score': _score, 'total': total});
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final q = _questions[_current];

    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment ${widget.blockIndex}')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    _selected == i ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _selected == i ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text(q.options[i]),
                  onTap: () => setState(() => _selected = i),
                ),
              ),
            const Spacer(),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected == -1 ? null : _submitOne,
                  child: Text(_current + 1 == total ? 'Finish' : 'Next'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Q {
  final String text;
  final List<String> options;
  final int correct;
  _Q(this.text, this.options, this.correct);
}
