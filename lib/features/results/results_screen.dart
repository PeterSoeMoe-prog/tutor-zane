import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    int? score;
    int? total;
    bool? correct;
    if (extra is Map) {
      if (extra['score'] is int) score = extra['score'] as int;
      if (extra['total'] is int) total = extra['total'] as int;
      if (extra['correct'] is bool) correct = extra['correct'] as bool;
    }

    Widget header;
    String message;

    if (score != null && total != null) {
      final passed = score > (total / 2);
      header = Icon(
        passed ? Icons.emoji_events : Icons.insights,
        color: passed ? Colors.amber : Colors.blueGrey,
        size: 96,
      );
      message = 'You scored $score out of $total';
    } else {
      final ok = correct == true;
      header = Icon(
        ok ? Icons.check_circle : Icons.cancel,
        color: ok ? Colors.green : Colors.red,
        size: 96,
      );
      message = ok ? 'Correct! Great job.' : 'Not quite. Keep practicing!';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              header,
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Levels'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
