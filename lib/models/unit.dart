class UnitModel {
  final String id; // e.g., "unit1"
  final String title; // e.g., "Unit 1"
  final List<LessonRef> lessonRefs;

  UnitModel({required this.id, required this.title, required this.lessonRefs});
}

class LessonRef {
  final String id; // lesson id or youtubeId
  LessonRef(this.id);
}
