// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rtc_ice_candidate_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RtcIceCandidateStats {

 IceCandidateStats get field0;
/// Create a copy of RtcIceCandidateStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcIceCandidateStatsCopyWith<RtcIceCandidateStats> get copyWith => _$RtcIceCandidateStatsCopyWithImpl<RtcIceCandidateStats>(this as RtcIceCandidateStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcIceCandidateStats&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'RtcIceCandidateStats(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $RtcIceCandidateStatsCopyWith<$Res>  {
  factory $RtcIceCandidateStatsCopyWith(RtcIceCandidateStats value, $Res Function(RtcIceCandidateStats) _then) = _$RtcIceCandidateStatsCopyWithImpl;
@useResult
$Res call({
 IceCandidateStats field0
});




}
/// @nodoc
class _$RtcIceCandidateStatsCopyWithImpl<$Res>
    implements $RtcIceCandidateStatsCopyWith<$Res> {
  _$RtcIceCandidateStatsCopyWithImpl(this._self, this._then);

  final RtcIceCandidateStats _self;
  final $Res Function(RtcIceCandidateStats) _then;

/// Create a copy of RtcIceCandidateStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field0 = null,}) {
  return _then(_self.copyWith(
field0: null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as IceCandidateStats,
  ));
}

}


/// Adds pattern-matching-related methods to [RtcIceCandidateStats].
extension RtcIceCandidateStatsPatterns on RtcIceCandidateStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RtcIceCandidateStats_Local value)?  local,TResult Function( RtcIceCandidateStats_Remote value)?  remote,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RtcIceCandidateStats_Local() when local != null:
return local(_that);case RtcIceCandidateStats_Remote() when remote != null:
return remote(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RtcIceCandidateStats_Local value)  local,required TResult Function( RtcIceCandidateStats_Remote value)  remote,}){
final _that = this;
switch (_that) {
case RtcIceCandidateStats_Local():
return local(_that);case RtcIceCandidateStats_Remote():
return remote(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RtcIceCandidateStats_Local value)?  local,TResult? Function( RtcIceCandidateStats_Remote value)?  remote,}){
final _that = this;
switch (_that) {
case RtcIceCandidateStats_Local() when local != null:
return local(_that);case RtcIceCandidateStats_Remote() when remote != null:
return remote(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( IceCandidateStats field0)?  local,TResult Function( IceCandidateStats field0)?  remote,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RtcIceCandidateStats_Local() when local != null:
return local(_that.field0);case RtcIceCandidateStats_Remote() when remote != null:
return remote(_that.field0);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( IceCandidateStats field0)  local,required TResult Function( IceCandidateStats field0)  remote,}) {final _that = this;
switch (_that) {
case RtcIceCandidateStats_Local():
return local(_that.field0);case RtcIceCandidateStats_Remote():
return remote(_that.field0);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( IceCandidateStats field0)?  local,TResult? Function( IceCandidateStats field0)?  remote,}) {final _that = this;
switch (_that) {
case RtcIceCandidateStats_Local() when local != null:
return local(_that.field0);case RtcIceCandidateStats_Remote() when remote != null:
return remote(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class RtcIceCandidateStats_Local extends RtcIceCandidateStats {
  const RtcIceCandidateStats_Local(this.field0): super._();
  

@override final  IceCandidateStats field0;

/// Create a copy of RtcIceCandidateStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcIceCandidateStats_LocalCopyWith<RtcIceCandidateStats_Local> get copyWith => _$RtcIceCandidateStats_LocalCopyWithImpl<RtcIceCandidateStats_Local>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcIceCandidateStats_Local&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'RtcIceCandidateStats.local(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $RtcIceCandidateStats_LocalCopyWith<$Res> implements $RtcIceCandidateStatsCopyWith<$Res> {
  factory $RtcIceCandidateStats_LocalCopyWith(RtcIceCandidateStats_Local value, $Res Function(RtcIceCandidateStats_Local) _then) = _$RtcIceCandidateStats_LocalCopyWithImpl;
@override @useResult
$Res call({
 IceCandidateStats field0
});




}
/// @nodoc
class _$RtcIceCandidateStats_LocalCopyWithImpl<$Res>
    implements $RtcIceCandidateStats_LocalCopyWith<$Res> {
  _$RtcIceCandidateStats_LocalCopyWithImpl(this._self, this._then);

  final RtcIceCandidateStats_Local _self;
  final $Res Function(RtcIceCandidateStats_Local) _then;

/// Create a copy of RtcIceCandidateStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(RtcIceCandidateStats_Local(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as IceCandidateStats,
  ));
}


}

/// @nodoc


class RtcIceCandidateStats_Remote extends RtcIceCandidateStats {
  const RtcIceCandidateStats_Remote(this.field0): super._();
  

@override final  IceCandidateStats field0;

/// Create a copy of RtcIceCandidateStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcIceCandidateStats_RemoteCopyWith<RtcIceCandidateStats_Remote> get copyWith => _$RtcIceCandidateStats_RemoteCopyWithImpl<RtcIceCandidateStats_Remote>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcIceCandidateStats_Remote&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'RtcIceCandidateStats.remote(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $RtcIceCandidateStats_RemoteCopyWith<$Res> implements $RtcIceCandidateStatsCopyWith<$Res> {
  factory $RtcIceCandidateStats_RemoteCopyWith(RtcIceCandidateStats_Remote value, $Res Function(RtcIceCandidateStats_Remote) _then) = _$RtcIceCandidateStats_RemoteCopyWithImpl;
@override @useResult
$Res call({
 IceCandidateStats field0
});




}
/// @nodoc
class _$RtcIceCandidateStats_RemoteCopyWithImpl<$Res>
    implements $RtcIceCandidateStats_RemoteCopyWith<$Res> {
  _$RtcIceCandidateStats_RemoteCopyWithImpl(this._self, this._then);

  final RtcIceCandidateStats_Remote _self;
  final $Res Function(RtcIceCandidateStats_Remote) _then;

/// Create a copy of RtcIceCandidateStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(RtcIceCandidateStats_Remote(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as IceCandidateStats,
  ));
}


}

// dart format on
