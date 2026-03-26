// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      xpTotal: (json['xpTotal'] as num?)?.toInt() ?? 0,
      streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
      tier: json['tier'] as String?,
      createdAt: _tsToDateTime(json['createdAt']),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'xpTotal': instance.xpTotal,
      'streakCount': instance.streakCount,
      'tier': instance.tier,
      'createdAt': _dateTimeToTs(instance.createdAt),
    };
