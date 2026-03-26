// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PromptImpl _$$PromptImplFromJson(Map<String, dynamic> json) => _$PromptImpl(
  id: json['id'] as String,
  text: json['text'] as String,
  date: _tsToDateTime(json['date']),
  active: json['active'] as bool? ?? true,
);

Map<String, dynamic> _$$PromptImplToJson(_$PromptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'date': _dateTimeToTs(instance.date),
      'active': instance.active,
    };
