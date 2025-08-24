import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProgressService {
  final Box box;
  ProgressService(this.box);

  bool isLessonCompleted(String lessonKey) {
    return box.get('lesson_$lessonKey') == true;
  }

  Future<void> markLessonCompleted(String lessonKey) async {
    await box.put('lesson_$lessonKey', true);
  }
}

final progressServiceProvider = Provider<ProgressService>((ref) {
  final box = Hive.box('progress');
  return ProgressService(box);
});
