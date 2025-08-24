import '../models/lesson.dart';

class UnitDTO {
  final String id;
  final String title;
  final List<Lesson> lessons;

  UnitDTO({required this.id, required this.title, required this.lessons});
}
