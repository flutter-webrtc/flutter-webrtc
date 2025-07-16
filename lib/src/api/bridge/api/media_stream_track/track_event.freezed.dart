// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrackEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrackEvent()';
}


}

/// @nodoc
class $TrackEventCopyWith<$Res>  {
$TrackEventCopyWith(TrackEvent _, $Res Function(TrackEvent) __);
}


/// Adds pattern-matching-related methods to [TrackEvent].
extension TrackEventPatterns on TrackEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TrackEvent_Ended value)?  ended,TResult Function( TrackEvent_AudioLevelUpdated value)?  audioLevelUpdated,TResult Function( TrackEvent_TrackCreated value)?  trackCreated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TrackEvent_Ended() when ended != null:
return ended(_that);case TrackEvent_AudioLevelUpdated() when audioLevelUpdated != null:
return audioLevelUpdated(_that);case TrackEvent_TrackCreated() when trackCreated != null:
return trackCreated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TrackEvent_Ended value)  ended,required TResult Function( TrackEvent_AudioLevelUpdated value)  audioLevelUpdated,required TResult Function( TrackEvent_TrackCreated value)  trackCreated,}){
final _that = this;
switch (_that) {
case TrackEvent_Ended():
return ended(_that);case TrackEvent_AudioLevelUpdated():
return audioLevelUpdated(_that);case TrackEvent_TrackCreated():
return trackCreated(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TrackEvent_Ended value)?  ended,TResult? Function( TrackEvent_AudioLevelUpdated value)?  audioLevelUpdated,TResult? Function( TrackEvent_TrackCreated value)?  trackCreated,}){
final _that = this;
switch (_that) {
case TrackEvent_Ended() when ended != null:
return ended(_that);case TrackEvent_AudioLevelUpdated() when audioLevelUpdated != null:
return audioLevelUpdated(_that);case TrackEvent_TrackCreated() when trackCreated != null:
return trackCreated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  ended,TResult Function( int field0)?  audioLevelUpdated,TResult Function()?  trackCreated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TrackEvent_Ended() when ended != null:
return ended();case TrackEvent_AudioLevelUpdated() when audioLevelUpdated != null:
return audioLevelUpdated(_that.field0);case TrackEvent_TrackCreated() when trackCreated != null:
return trackCreated();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  ended,required TResult Function( int field0)  audioLevelUpdated,required TResult Function()  trackCreated,}) {final _that = this;
switch (_that) {
case TrackEvent_Ended():
return ended();case TrackEvent_AudioLevelUpdated():
return audioLevelUpdated(_that.field0);case TrackEvent_TrackCreated():
return trackCreated();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  ended,TResult? Function( int field0)?  audioLevelUpdated,TResult? Function()?  trackCreated,}) {final _that = this;
switch (_that) {
case TrackEvent_Ended() when ended != null:
return ended();case TrackEvent_AudioLevelUpdated() when audioLevelUpdated != null:
return audioLevelUpdated(_that.field0);case TrackEvent_TrackCreated() when trackCreated != null:
return trackCreated();case _:
  return null;

}
}

}

/// @nodoc


class TrackEvent_Ended extends TrackEvent {
  const TrackEvent_Ended(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackEvent_Ended);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrackEvent.ended()';
}


}




/// @nodoc


class TrackEvent_AudioLevelUpdated extends TrackEvent {
  const TrackEvent_AudioLevelUpdated(this.field0): super._();
  

 final  int field0;

/// Create a copy of TrackEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackEvent_AudioLevelUpdatedCopyWith<TrackEvent_AudioLevelUpdated> get copyWith => _$TrackEvent_AudioLevelUpdatedCopyWithImpl<TrackEvent_AudioLevelUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackEvent_AudioLevelUpdated&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'TrackEvent.audioLevelUpdated(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $TrackEvent_AudioLevelUpdatedCopyWith<$Res> implements $TrackEventCopyWith<$Res> {
  factory $TrackEvent_AudioLevelUpdatedCopyWith(TrackEvent_AudioLevelUpdated value, $Res Function(TrackEvent_AudioLevelUpdated) _then) = _$TrackEvent_AudioLevelUpdatedCopyWithImpl;
@useResult
$Res call({
 int field0
});




}
/// @nodoc
class _$TrackEvent_AudioLevelUpdatedCopyWithImpl<$Res>
    implements $TrackEvent_AudioLevelUpdatedCopyWith<$Res> {
  _$TrackEvent_AudioLevelUpdatedCopyWithImpl(this._self, this._then);

  final TrackEvent_AudioLevelUpdated _self;
  final $Res Function(TrackEvent_AudioLevelUpdated) _then;

/// Create a copy of TrackEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(TrackEvent_AudioLevelUpdated(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class TrackEvent_TrackCreated extends TrackEvent {
  const TrackEvent_TrackCreated(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackEvent_TrackCreated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrackEvent.trackCreated()';
}


}




// dart format on
