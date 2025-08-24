import 'package:json_annotation/json_annotation.dart';

import 'lesson.dart';

part 'level.g.dart';

@JsonSerializable()
class LevelModel {
  final String id;
  final String title;
  final List<Lesson> lessons;

  LevelModel({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) => _$LevelModelFromJson(json);
  Map<String, dynamic> toJson() => _$LevelModelToJson(this);
}

@JsonSerializable()
class LevelsRoot {
  final List<LevelModel> levels;
  LevelsRoot({required this.levels});

  factory LevelsRoot.fromJson(Map<String, dynamic> json) => _$LevelsRootFromJson(json);
  Map<String, dynamic> toJson() => _$LevelsRootToJson(this);
}
