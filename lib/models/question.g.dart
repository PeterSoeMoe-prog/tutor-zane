// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  text: json['text'] as String,
  options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
  correctIndex: (json['correctIndex'] as num).toInt(),
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'text': instance.text,
  'options': instance.options,
  'correctIndex': instance.correctIndex,
};
