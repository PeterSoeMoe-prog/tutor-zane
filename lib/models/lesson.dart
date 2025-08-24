import 'package:json_annotation/json_annotation.dart';

import 'question.dart';

part 'lesson.g.dart';

@JsonSerializable()
class Lesson {
  final String id;
  final String title;
  final String description;
  final String youtubeId;
  final List<Question> questions;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeId,
    required this.questions,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  Map<String, dynamic> toJson() => _$LessonToJson(this);
}
