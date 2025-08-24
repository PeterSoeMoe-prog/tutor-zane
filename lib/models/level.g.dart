// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LevelModel _$LevelModelFromJson(Map<String, dynamic> json) => LevelModel(
  id: json['id'] as String,
  title: json['title'] as String,
  lessons: (json['lessons'] as List<dynamic>)
      .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LevelModelToJson(LevelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'lessons': instance.lessons,
    };

LevelsRoot _$LevelsRootFromJson(Map<String, dynamic> json) => LevelsRoot(
  levels: (json['levels'] as List<dynamic>)
      .map((e) => LevelModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LevelsRootToJson(LevelsRoot instance) =>
    <String, dynamic>{'levels': instance.levels};
