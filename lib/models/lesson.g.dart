// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  youtubeId: json['youtubeId'] as String,
  questions: (json['questions'] as List<dynamic>)
      .map((e) => Question.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'youtubeId': instance.youtubeId,
  'questions': instance.questions,
};
