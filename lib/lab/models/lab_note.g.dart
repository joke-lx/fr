// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabNote _$LabNoteFromJson(Map<String, dynamic> json) => LabNote(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  color: json['color'] as String?,
);

Map<String, dynamic> _$LabNoteToJson(LabNote instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'color': instance.color,
};
