import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String displayName,
    String? photoUrl,
    String? bio,
    String? location,
    @Default(0) int xpTotal,
    @Default(0) int streakCount,
    String? tier,
    @JsonKey(fromJson: _tsToDateTime, toJson: _dateTimeToTs)
    DateTime? createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

DateTime? _tsToDateTime(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  throw ArgumentError.value(value, 'value', 'Unsupported timestamp value');
}

Object? _dateTimeToTs(DateTime? value) {
  if (value == null) return null;
  return Timestamp.fromDate(value);
}
