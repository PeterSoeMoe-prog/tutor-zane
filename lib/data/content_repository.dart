import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/level.dart';

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
}
