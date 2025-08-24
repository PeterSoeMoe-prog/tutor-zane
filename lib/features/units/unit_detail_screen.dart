import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/content_providers.dart';
import '../../models/level.dart';

class UnitDetailScreen extends ConsumerWidget {
  const UnitDetailScreen({super.key, required this.levelId, required this.unitNumber});

  final String levelId;
  final int unitNumber; // 1-based index

  static const int unitSize = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLevel = ref.watch(levelByIdProvider(levelId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Unit $unitNumber'),
      ),
      body: asyncLevel.when(
        data: (LevelModel? level) {
          if (level == null) {
            return const Center(child: Text('Level not found'));
          }

          final start = (unitNumber - 1) * unitSize;
          if (start < 0 || start >= level.lessons.length) {
            return const Center(child: Text('Unit not found'));
          }
          final end = (start + unitSize) > level.lessons.length ? level.lessons.length : (start + unitSize);
          final lessons = level.lessons.sublist(start, end);

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Card(
                  child: ListTile(
                    title: Text(lesson.title),
                    subtitle: Text(lesson.description),
                    trailing: const Icon(Icons.play_circle_fill),
                    onTap: () => context.go('/levels/video/${lesson.youtubeId}')
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load: $e')),
      ),
    );
  }
}
