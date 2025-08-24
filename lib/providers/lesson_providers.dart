import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lesson.dart';
import '../models/level.dart';
import 'content_providers.dart';

/// Finds a lesson by its YouTube ID (or lesson id) across all levels.
final lessonByIdProvider = FutureProvider.family<Lesson?, String>((ref, id) async {
  final levelsRoot = await ref.watch(levelsProvider.future);
  for (final LevelModel level in levelsRoot.levels) {
    for (final lesson in level.lessons) {
      if (lesson.youtubeId == id || lesson.id == id) {
        return lesson;
      }
    }
  }
  return null;
});
