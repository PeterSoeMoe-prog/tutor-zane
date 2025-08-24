import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/content_repository.dart';
import '../models/level.dart';
import '../models/unit_dto.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

final levelsProvider = FutureProvider<LevelsRoot>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.loadLevels();
});

/// Finds a LevelModel by id from the loaded content.
final levelByIdProvider = FutureProvider.family<LevelModel?, String>((ref, id) async {
  final root = await ref.watch(levelsProvider.future);
  try {
    return root.levels.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
});

/// Provides units for a given level if available in the JSON. Returns null if not present.
final unitsByLevelProvider = FutureProvider.family<List<UnitDTO>?, String>((ref, levelId) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.loadUnitsForLevel(levelId);
});
