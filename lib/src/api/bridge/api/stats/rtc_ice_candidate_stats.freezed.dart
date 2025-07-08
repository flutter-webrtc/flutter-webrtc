// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rtc_ice_candidate_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RtcIceCandidateStats {
  IceCandidateStats get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(IceCandidateStats field0) local,
    required TResult Function(IceCandidateStats field0) remote,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(IceCandidateStats field0)? local,
    TResult? Function(IceCandidateStats field0)? remote,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(IceCandidateStats field0)? local,
    TResult Function(IceCandidateStats field0)? remote,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcIceCandidateStats_Local value) local,
    required TResult Function(RtcIceCandidateStats_Remote value) remote,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcIceCandidateStats_Local value)? local,
    TResult? Function(RtcIceCandidateStats_Remote value)? remote,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcIceCandidateStats_Local value)? local,
    TResult Function(RtcIceCandidateStats_Remote value)? remote,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of RtcIceCandidateStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RtcIceCandidateStatsCopyWith<RtcIceCandidateStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RtcIceCandidateStatsCopyWith<$Res> {
  factory $RtcIceCandidateStatsCopyWith(
    RtcIceCandidateStats value,
    $Res Function(RtcIceCandidateStats) then,
  ) = _$RtcIceCandidateStatsCopyWithImpl<$Res, RtcIceCandidateStats>;
  @useResult
  $Res call({IceCandidateStats field0});
}

/// @nodoc
class _$RtcIceCandidateStatsCopyWithImpl<
  $Res,
  $Val extends RtcIceCandidateStats
>
    implements $RtcIceCandidateStatsCopyWith<$Res> {
  _$RtcIceCandidateStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RtcIceCandidateStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _value.copyWith(
            field0: null == field0
                ? _value.field0
                : field0 // ignore: cast_nullable_to_non_nullable
                      as IceCandidateStats,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RtcIceCandidateStats_LocalImplCopyWith<$Res>
    implements $RtcIceCandidateStatsCopyWith<$Res> {
  factory _$$RtcIceCandidateStats_LocalImplCopyWith(
    _$RtcIceCandidateStats_LocalImpl value,
    $Res Function(_$RtcIceCandidateStats_LocalImpl) then,
  ) = __$$RtcIceCandidateStats_LocalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({IceCandidateStats field0});
}

/// @nodoc
class __$$RtcIceCandidateStats_LocalImplCopyWithImpl<$Res>
    extends
        _$RtcIceCandidateStatsCopyWithImpl<
          $Res,
          _$RtcIceCandidateStats_LocalImpl
        >
    implements _$$RtcIceCandidateStats_LocalImplCopyWith<$Res> {
  __$$RtcIceCandidateStats_LocalImplCopyWithImpl(
    _$RtcIceCandidateStats_LocalImpl _value,
    $Res Function(_$RtcIceCandidateStats_LocalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcIceCandidateStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$RtcIceCandidateStats_LocalImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as IceCandidateStats,
      ),
    );
  }
}

/// @nodoc

class _$RtcIceCandidateStats_LocalImpl extends RtcIceCandidateStats_Local {
  const _$RtcIceCandidateStats_LocalImpl(this.field0) : super._();

  @override
  final IceCandidateStats field0;

  @override
  String toString() {
    return 'RtcIceCandidateStats.local(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcIceCandidateStats_LocalImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of RtcIceCandidateStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcIceCandidateStats_LocalImplCopyWith<_$RtcIceCandidateStats_LocalImpl>
  get copyWith =>
      __$$RtcIceCandidateStats_LocalImplCopyWithImpl<
        _$RtcIceCandidateStats_LocalImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(IceCandidateStats field0) local,
    required TResult Function(IceCandidateStats field0) remote,
  }) {
    return local(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(IceCandidateStats field0)? local,
    TResult? Function(IceCandidateStats field0)? remote,
  }) {
    return local?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(IceCandidateStats field0)? local,
    TResult Function(IceCandidateStats field0)? remote,
    required TResult orElse(),
  }) {
    if (local != null) {
      return local(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcIceCandidateStats_Local value) local,
    required TResult Function(RtcIceCandidateStats_Remote value) remote,
  }) {
    return local(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcIceCandidateStats_Local value)? local,
    TResult? Function(RtcIceCandidateStats_Remote value)? remote,
  }) {
    return local?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcIceCandidateStats_Local value)? local,
    TResult Function(RtcIceCandidateStats_Remote value)? remote,
    required TResult orElse(),
  }) {
    if (local != null) {
      return local(this);
    }
    return orElse();
  }
}

abstract class RtcIceCandidateStats_Local extends RtcIceCandidateStats {
  const factory RtcIceCandidateStats_Local(final IceCandidateStats field0) =
      _$RtcIceCandidateStats_LocalImpl;
  const RtcIceCandidateStats_Local._() : super._();

  @override
  IceCandidateStats get field0;

  /// Create a copy of RtcIceCandidateStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcIceCandidateStats_LocalImplCopyWith<_$RtcIceCandidateStats_LocalImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcIceCandidateStats_RemoteImplCopyWith<$Res>
    implements $RtcIceCandidateStatsCopyWith<$Res> {
  factory _$$RtcIceCandidateStats_RemoteImplCopyWith(
    _$RtcIceCandidateStats_RemoteImpl value,
    $Res Function(_$RtcIceCandidateStats_RemoteImpl) then,
  ) = __$$RtcIceCandidateStats_RemoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({IceCandidateStats field0});
}

/// @nodoc
class __$$RtcIceCandidateStats_RemoteImplCopyWithImpl<$Res>
    extends
        _$RtcIceCandidateStatsCopyWithImpl<
          $Res,
          _$RtcIceCandidateStats_RemoteImpl
        >
    implements _$$RtcIceCandidateStats_RemoteImplCopyWith<$Res> {
  __$$RtcIceCandidateStats_RemoteImplCopyWithImpl(
    _$RtcIceCandidateStats_RemoteImpl _value,
    $Res Function(_$RtcIceCandidateStats_RemoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcIceCandidateStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$RtcIceCandidateStats_RemoteImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as IceCandidateStats,
      ),
    );
  }
}

/// @nodoc

class _$RtcIceCandidateStats_RemoteImpl extends RtcIceCandidateStats_Remote {
  const _$RtcIceCandidateStats_RemoteImpl(this.field0) : super._();

  @override
  final IceCandidateStats field0;

  @override
  String toString() {
    return 'RtcIceCandidateStats.remote(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcIceCandidateStats_RemoteImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of RtcIceCandidateStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcIceCandidateStats_RemoteImplCopyWith<_$RtcIceCandidateStats_RemoteImpl>
  get copyWith =>
      __$$RtcIceCandidateStats_RemoteImplCopyWithImpl<
        _$RtcIceCandidateStats_RemoteImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(IceCandidateStats field0) local,
    required TResult Function(IceCandidateStats field0) remote,
  }) {
    return remote(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(IceCandidateStats field0)? local,
    TResult? Function(IceCandidateStats field0)? remote,
  }) {
    return remote?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(IceCandidateStats field0)? local,
    TResult Function(IceCandidateStats field0)? remote,
    required TResult orElse(),
  }) {
    if (remote != null) {
      return remote(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcIceCandidateStats_Local value) local,
    required TResult Function(RtcIceCandidateStats_Remote value) remote,
  }) {
    return remote(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcIceCandidateStats_Local value)? local,
    TResult? Function(RtcIceCandidateStats_Remote value)? remote,
  }) {
    return remote?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcIceCandidateStats_Local value)? local,
    TResult Function(RtcIceCandidateStats_Remote value)? remote,
    required TResult orElse(),
  }) {
    if (remote != null) {
      return remote(this);
    }
    return orElse();
  }
}

abstract class RtcIceCandidateStats_Remote extends RtcIceCandidateStats {
  const factory RtcIceCandidateStats_Remote(final IceCandidateStats field0) =
      _$RtcIceCandidateStats_RemoteImpl;
  const RtcIceCandidateStats_Remote._() : super._();

  @override
  IceCandidateStats get field0;

  /// Create a copy of RtcIceCandidateStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcIceCandidateStats_RemoteImplCopyWith<_$RtcIceCandidateStats_RemoteImpl>
  get copyWith => throw _privateConstructorUsedError;
}
