import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'prompt.freezed.dart';
part 'prompt.g.dart';

@freezed
class Prompt with _$Prompt {
  const factory Prompt({
    required String id,
    required String text,
    @JsonKey(fromJson: _tsToDateTime, toJson: _dateTimeToTs)
    required DateTime date,
    @Default(true) bool active,
  }) = _Prompt;

  factory Prompt.fromJson(Map<String, dynamic> json) => _$PromptFromJson(json);
}

DateTime _tsToDateTime(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.parse(value);
  throw ArgumentError.value(value, 'value', 'Unsupported timestamp value');
}

Object _dateTimeToTs(DateTime value) => Timestamp.fromDate(value);

