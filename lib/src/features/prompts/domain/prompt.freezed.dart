// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prompt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Prompt _$PromptFromJson(Map<String, dynamic> json) {
  return _Prompt.fromJson(json);
}

/// @nodoc
mixin _$Prompt {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _tsToDateTime, toJson: _dateTimeToTs)
  DateTime get date => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;

  /// Serializes this Prompt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Prompt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromptCopyWith<Prompt> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromptCopyWith<$Res> {
  factory $PromptCopyWith(Prompt value, $Res Function(Prompt) then) =
      _$PromptCopyWithImpl<$Res, Prompt>;
  @useResult
  $Res call({
    String id,
    String text,
    @JsonKey(fromJson: _tsToDateTime, toJson: _dateTimeToTs) DateTime date,
    bool active,
  });
}

/// @nodoc
class _$PromptCopyWithImpl<$Res, $Val extends Prompt>
    implements $PromptCopyWith<$Res> {
  _$PromptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Prompt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? date = null,
    Object? active = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            active: null == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PromptImplCopyWith<$Res> implements $PromptCopyWith<$Res> {
  factory _$$PromptImplCopyWith(
    _$PromptImpl value,
    $Res Function(_$PromptImpl) then,
  ) = __$$PromptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String text,
    @JsonKey(fromJson: _tsToDateTime, toJson: _dateTimeToTs) DateTime date,
    bool active,
  });
}

/// @nodoc
class __$$PromptImplCopyWithImpl<$Res>
    extends _$PromptCopyWithImpl<$Res, _$PromptImpl>
    implements _$$PromptImplCopyWith<$Res> {
  __$$PromptImplCopyWithImpl(
    _$PromptImpl _value,
    $Res Function(_$PromptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Prompt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? date = null,
    Object? active = null,
  }) {
    return _then(
      _$PromptImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        active: null == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PromptImpl implements _Prompt {
  const _$PromptImpl({
    required this.id,
    required this.text,
    @JsonKey(fromJson: _tsToDateTime, toJson: _dateTimeToTs) required this.date,
    this.active = true,
  });

  factory _$PromptImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromptImplFromJson(json);

  @override
  final String id;
  @override
  final String text;
  @override
  @JsonKey(fromJson: _tsToDateTime, toJson: _dateTimeToTs)
  final DateTime date;
  @override
  @JsonKey()
  final bool active;

  @override
  String toString() {
    return 'Prompt(id: $id, text: $text, date: $date, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text, date, active);

  /// Create a copy of Prompt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromptImplCopyWith<_$PromptImpl> get copyWith =>
      __$$PromptImplCopyWithImpl<_$PromptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PromptImplToJson(this);
  }
}

abstract class _Prompt implements Prompt {
  const factory _Prompt({
    required final String id,
    required final String text,
    @JsonKey(fromJson: _tsToDateTime, toJson: _dateTimeToTs)
    required final DateTime date,
    final bool active,
  }) = _$PromptImpl;

  factory _Prompt.fromJson(Map<String, dynamic> json) = _$PromptImpl.fromJson;

  @override
  String get id;
  @override
  String get text;
  @override
  @JsonKey(fromJson: _tsToDateTime, toJson: _dateTimeToTs)
  DateTime get date;
  @override
  bool get active;

  /// Create a copy of Prompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromptImplCopyWith<_$PromptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
