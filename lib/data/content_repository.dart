import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/level.dart';
import '../models/lesson.dart';
import '../models/unit_dto.dart';

class ContentRepository {
  Future<LevelsRoot> loadLevels() async {
    final raw = await rootBundle.loadString('assets/content/levels.json');
    final map = json.decode(raw) as Map<String, dynamic>;

    // Backward-compatible support: if a level has `units`, flatten their `lessons` into level.lessons.
    if (map['levels'] is List) {
      final levels = (map['levels'] as List).cast<Map<String, dynamic>>();
      final transformed = <Map<String, dynamic>>[];
      for (final level in levels) {
        if (level['units'] is List) {
          final units = (level['units'] as List).cast<Map<String, dynamic>>();
          final lessons = <Map<String, dynamic>>[];
          for (final unit in units) {
            if (unit['lessons'] is List) {
              lessons.addAll((unit['lessons'] as List).cast<Map<String, dynamic>>());
            }
          }
          final copy = Map<String, dynamic>.from(level);
          copy.remove('units');
          copy['lessons'] = lessons;
          transformed.add(copy);
        } else {
          transformed.add(level);
        }
      }
      final out = {'levels': transformed};
      return LevelsRoot.fromJson(out);
    }

    return LevelsRoot.fromJson(map);
  }

  /// Loads true units for a given level if present in the JSON. Returns null if not present.
  Future<List<UnitDTO>?> loadUnitsForLevel(String levelId) async {
    final raw = await rootBundle.loadString('assets/content/levels.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    if (map['levels'] is! List) return null;
    final levels = (map['levels'] as List).cast<Map<String, dynamic>>();
    final level = levels.cast<Map<String, dynamic>?>().firstWhere(
          (l) => l != null && l['id'] == levelId,
          orElse: () => null,
        );
    if (level == null) return null;
    if (level['units'] is! List) return null;
    final units = (level['units'] as List).cast<Map<String, dynamic>>();
    final result = <UnitDTO>[];
    for (final u in units) {
      final id = (u['id'] ?? '').toString();
      final title = (u['title'] ?? '').toString();
      final lessonsRaw = (u['lessons'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
      final lessons = lessonsRaw.map((e) => Lesson.fromJson(e)).toList();
      result.add(UnitDTO(id: id, title: title, lessons: lessons));
    }
    return result;
  }
}
