// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrackEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ended,
    required TResult Function(int field0) audioLevelUpdated,
    required TResult Function() trackCreated,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ended,
    TResult? Function(int field0)? audioLevelUpdated,
    TResult? Function()? trackCreated,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ended,
    TResult Function(int field0)? audioLevelUpdated,
    TResult Function()? trackCreated,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrackEvent_Ended value) ended,
    required TResult Function(TrackEvent_AudioLevelUpdated value)
    audioLevelUpdated,
    required TResult Function(TrackEvent_TrackCreated value) trackCreated,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrackEvent_Ended value)? ended,
    TResult? Function(TrackEvent_AudioLevelUpdated value)? audioLevelUpdated,
    TResult? Function(TrackEvent_TrackCreated value)? trackCreated,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrackEvent_Ended value)? ended,
    TResult Function(TrackEvent_AudioLevelUpdated value)? audioLevelUpdated,
    TResult Function(TrackEvent_TrackCreated value)? trackCreated,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackEventCopyWith<$Res> {
  factory $TrackEventCopyWith(
    TrackEvent value,
    $Res Function(TrackEvent) then,
  ) = _$TrackEventCopyWithImpl<$Res, TrackEvent>;
}

/// @nodoc
class _$TrackEventCopyWithImpl<$Res, $Val extends TrackEvent>
    implements $TrackEventCopyWith<$Res> {
  _$TrackEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TrackEvent_EndedImplCopyWith<$Res> {
  factory _$$TrackEvent_EndedImplCopyWith(
    _$TrackEvent_EndedImpl value,
    $Res Function(_$TrackEvent_EndedImpl) then,
  ) = __$$TrackEvent_EndedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TrackEvent_EndedImplCopyWithImpl<$Res>
    extends _$TrackEventCopyWithImpl<$Res, _$TrackEvent_EndedImpl>
    implements _$$TrackEvent_EndedImplCopyWith<$Res> {
  __$$TrackEvent_EndedImplCopyWithImpl(
    _$TrackEvent_EndedImpl _value,
    $Res Function(_$TrackEvent_EndedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrackEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TrackEvent_EndedImpl extends TrackEvent_Ended {
  const _$TrackEvent_EndedImpl() : super._();

  @override
  String toString() {
    return 'TrackEvent.ended()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$TrackEvent_EndedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ended,
    required TResult Function(int field0) audioLevelUpdated,
    required TResult Function() trackCreated,
  }) {
    return ended();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ended,
    TResult? Function(int field0)? audioLevelUpdated,
    TResult? Function()? trackCreated,
  }) {
    return ended?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ended,
    TResult Function(int field0)? audioLevelUpdated,
    TResult Function()? trackCreated,
    required TResult orElse(),
  }) {
    if (ended != null) {
      return ended();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrackEvent_Ended value) ended,
    required TResult Function(TrackEvent_AudioLevelUpdated value)
    audioLevelUpdated,
    required TResult Function(TrackEvent_TrackCreated value) trackCreated,
  }) {
    return ended(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrackEvent_Ended value)? ended,
    TResult? Function(TrackEvent_AudioLevelUpdated value)? audioLevelUpdated,
    TResult? Function(TrackEvent_TrackCreated value)? trackCreated,
  }) {
    return ended?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrackEvent_Ended value)? ended,
    TResult Function(TrackEvent_AudioLevelUpdated value)? audioLevelUpdated,
    TResult Function(TrackEvent_TrackCreated value)? trackCreated,
    required TResult orElse(),
  }) {
    if (ended != null) {
      return ended(this);
    }
    return orElse();
  }
}

abstract class TrackEvent_Ended extends TrackEvent {
  const factory TrackEvent_Ended() = _$TrackEvent_EndedImpl;
  const TrackEvent_Ended._() : super._();
}

/// @nodoc
abstract class _$$TrackEvent_AudioLevelUpdatedImplCopyWith<$Res> {
  factory _$$TrackEvent_AudioLevelUpdatedImplCopyWith(
    _$TrackEvent_AudioLevelUpdatedImpl value,
    $Res Function(_$TrackEvent_AudioLevelUpdatedImpl) then,
  ) = __$$TrackEvent_AudioLevelUpdatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int field0});
}

/// @nodoc
class __$$TrackEvent_AudioLevelUpdatedImplCopyWithImpl<$Res>
    extends _$TrackEventCopyWithImpl<$Res, _$TrackEvent_AudioLevelUpdatedImpl>
    implements _$$TrackEvent_AudioLevelUpdatedImplCopyWith<$Res> {
  __$$TrackEvent_AudioLevelUpdatedImplCopyWithImpl(
    _$TrackEvent_AudioLevelUpdatedImpl _value,
    $Res Function(_$TrackEvent_AudioLevelUpdatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrackEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$TrackEvent_AudioLevelUpdatedImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TrackEvent_AudioLevelUpdatedImpl extends TrackEvent_AudioLevelUpdated {
  const _$TrackEvent_AudioLevelUpdatedImpl(this.field0) : super._();

  @override
  final int field0;

  @override
  String toString() {
    return 'TrackEvent.audioLevelUpdated(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackEvent_AudioLevelUpdatedImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of TrackEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackEvent_AudioLevelUpdatedImplCopyWith<
    _$TrackEvent_AudioLevelUpdatedImpl
  >
  get copyWith =>
      __$$TrackEvent_AudioLevelUpdatedImplCopyWithImpl<
        _$TrackEvent_AudioLevelUpdatedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ended,
    required TResult Function(int field0) audioLevelUpdated,
    required TResult Function() trackCreated,
  }) {
    return audioLevelUpdated(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ended,
    TResult? Function(int field0)? audioLevelUpdated,
    TResult? Function()? trackCreated,
  }) {
    return audioLevelUpdated?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ended,
    TResult Function(int field0)? audioLevelUpdated,
    TResult Function()? trackCreated,
    required TResult orElse(),
  }) {
    if (audioLevelUpdated != null) {
      return audioLevelUpdated(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrackEvent_Ended value) ended,
    required TResult Function(TrackEvent_AudioLevelUpdated value)
    audioLevelUpdated,
    required TResult Function(TrackEvent_TrackCreated value) trackCreated,
  }) {
    return audioLevelUpdated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrackEvent_Ended value)? ended,
    TResult? Function(TrackEvent_AudioLevelUpdated value)? audioLevelUpdated,
    TResult? Function(TrackEvent_TrackCreated value)? trackCreated,
  }) {
    return audioLevelUpdated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrackEvent_Ended value)? ended,
    TResult Function(TrackEvent_AudioLevelUpdated value)? audioLevelUpdated,
    TResult Function(TrackEvent_TrackCreated value)? trackCreated,
    required TResult orElse(),
  }) {
    if (audioLevelUpdated != null) {
      return audioLevelUpdated(this);
    }
    return orElse();
  }
}

abstract class TrackEvent_AudioLevelUpdated extends TrackEvent {
  const factory TrackEvent_AudioLevelUpdated(final int field0) =
      _$TrackEvent_AudioLevelUpdatedImpl;
  const TrackEvent_AudioLevelUpdated._() : super._();

  int get field0;

  /// Create a copy of TrackEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackEvent_AudioLevelUpdatedImplCopyWith<
    _$TrackEvent_AudioLevelUpdatedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrackEvent_TrackCreatedImplCopyWith<$Res> {
  factory _$$TrackEvent_TrackCreatedImplCopyWith(
    _$TrackEvent_TrackCreatedImpl value,
    $Res Function(_$TrackEvent_TrackCreatedImpl) then,
  ) = __$$TrackEvent_TrackCreatedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TrackEvent_TrackCreatedImplCopyWithImpl<$Res>
    extends _$TrackEventCopyWithImpl<$Res, _$TrackEvent_TrackCreatedImpl>
    implements _$$TrackEvent_TrackCreatedImplCopyWith<$Res> {
  __$$TrackEvent_TrackCreatedImplCopyWithImpl(
    _$TrackEvent_TrackCreatedImpl _value,
    $Res Function(_$TrackEvent_TrackCreatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrackEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TrackEvent_TrackCreatedImpl extends TrackEvent_TrackCreated {
  const _$TrackEvent_TrackCreatedImpl() : super._();

  @override
  String toString() {
    return 'TrackEvent.trackCreated()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackEvent_TrackCreatedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ended,
    required TResult Function(int field0) audioLevelUpdated,
    required TResult Function() trackCreated,
  }) {
    return trackCreated();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ended,
    TResult? Function(int field0)? audioLevelUpdated,
    TResult? Function()? trackCreated,
  }) {
    return trackCreated?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ended,
    TResult Function(int field0)? audioLevelUpdated,
    TResult Function()? trackCreated,
    required TResult orElse(),
  }) {
    if (trackCreated != null) {
      return trackCreated();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrackEvent_Ended value) ended,
    required TResult Function(TrackEvent_AudioLevelUpdated value)
    audioLevelUpdated,
    required TResult Function(TrackEvent_TrackCreated value) trackCreated,
  }) {
    return trackCreated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrackEvent_Ended value)? ended,
    TResult? Function(TrackEvent_AudioLevelUpdated value)? audioLevelUpdated,
    TResult? Function(TrackEvent_TrackCreated value)? trackCreated,
  }) {
    return trackCreated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrackEvent_Ended value)? ended,
    TResult Function(TrackEvent_AudioLevelUpdated value)? audioLevelUpdated,
    TResult Function(TrackEvent_TrackCreated value)? trackCreated,
    required TResult orElse(),
  }) {
    if (trackCreated != null) {
      return trackCreated(this);
    }
    return orElse();
  }
}

abstract class TrackEvent_TrackCreated extends TrackEvent {
  const factory TrackEvent_TrackCreated() = _$TrackEvent_TrackCreatedImpl;
  const TrackEvent_TrackCreated._() : super._();
}
