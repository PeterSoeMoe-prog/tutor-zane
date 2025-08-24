import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/level.dart';
import 'content_providers.dart';
import 'progress_providers.dart';

class AssessmentService {
  final Box box;
  AssessmentService(this.box);

  String _key(String levelId, int blockIndex) => 'assessment_${levelId}_$blockIndex';

  bool isAssessmentCompleted(String levelId, int blockIndex) {
    return box.get(_key(levelId, blockIndex)) == true;
  }

  Future<void> markAssessmentCompleted(String levelId, int blockIndex) async {
    await box.put(_key(levelId, blockIndex), true);
  }
}

final assessmentServiceProvider = Provider<AssessmentService>((ref) {
  final box = Hive.box('progress');
  return AssessmentService(box);
});

/// Returns whether the assessment for a block (2 units = 12 lessons) is available
final assessmentAvailabilityProvider = FutureProvider.family<bool, ({String levelId, int blockIndex})>((ref, params) async {
  final levels = await ref.watch(levelsProvider.future);
  final level = levels.levels.firstWhere((l) => l.id == params.levelId, orElse: () => LevelModel(id: '', title: '', lessons: const []));
  if (level.id.isEmpty) return false;

  const lessonsPerBlock = 12; // 2 units * 6 lessons per unit
  final required = params.blockIndex * lessonsPerBlock;

  final progress = ref.watch(progressServiceProvider);
  final completed = level.lessons.where((l) => progress.isLessonCompleted(l.id) || progress.isLessonCompleted(l.youtubeId)).length;
  return completed >= required;
});
