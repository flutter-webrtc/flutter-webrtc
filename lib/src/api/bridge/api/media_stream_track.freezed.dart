// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_stream_track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GetMediaError {

 String get field0;
/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetMediaErrorCopyWith<GetMediaError> get copyWith => _$GetMediaErrorCopyWithImpl<GetMediaError>(this as GetMediaError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'GetMediaError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $GetMediaErrorCopyWith<$Res>  {
  factory $GetMediaErrorCopyWith(GetMediaError value, $Res Function(GetMediaError) _then) = _$GetMediaErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$GetMediaErrorCopyWithImpl<$Res>
    implements $GetMediaErrorCopyWith<$Res> {
  _$GetMediaErrorCopyWithImpl(this._self, this._then);

  final GetMediaError _self;
  final $Res Function(GetMediaError) _then;

/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field0 = null,}) {
  return _then(_self.copyWith(
field0: null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GetMediaError].
extension GetMediaErrorPatterns on GetMediaError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetMediaError_Audio value)?  audio,TResult Function( GetMediaError_Video value)?  video,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetMediaError_Audio() when audio != null:
return audio(_that);case GetMediaError_Video() when video != null:
return video(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetMediaError_Audio value)  audio,required TResult Function( GetMediaError_Video value)  video,}){
final _that = this;
switch (_that) {
case GetMediaError_Audio():
return audio(_that);case GetMediaError_Video():
return video(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetMediaError_Audio value)?  audio,TResult? Function( GetMediaError_Video value)?  video,}){
final _that = this;
switch (_that) {
case GetMediaError_Audio() when audio != null:
return audio(_that);case GetMediaError_Video() when video != null:
return video(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String field0)?  audio,TResult Function( String field0)?  video,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetMediaError_Audio() when audio != null:
return audio(_that.field0);case GetMediaError_Video() when video != null:
return video(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String field0)  audio,required TResult Function( String field0)  video,}) {final _that = this;
switch (_that) {
case GetMediaError_Audio():
return audio(_that.field0);case GetMediaError_Video():
return video(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String field0)?  audio,TResult? Function( String field0)?  video,}) {final _that = this;
switch (_that) {
case GetMediaError_Audio() when audio != null:
return audio(_that.field0);case GetMediaError_Video() when video != null:
return video(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class GetMediaError_Audio extends GetMediaError {
  const GetMediaError_Audio(this.field0): super._();
  

@override final  String field0;

/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetMediaError_AudioCopyWith<GetMediaError_Audio> get copyWith => _$GetMediaError_AudioCopyWithImpl<GetMediaError_Audio>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaError_Audio&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'GetMediaError.audio(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $GetMediaError_AudioCopyWith<$Res> implements $GetMediaErrorCopyWith<$Res> {
  factory $GetMediaError_AudioCopyWith(GetMediaError_Audio value, $Res Function(GetMediaError_Audio) _then) = _$GetMediaError_AudioCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$GetMediaError_AudioCopyWithImpl<$Res>
    implements $GetMediaError_AudioCopyWith<$Res> {
  _$GetMediaError_AudioCopyWithImpl(this._self, this._then);

  final GetMediaError_Audio _self;
  final $Res Function(GetMediaError_Audio) _then;

/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(GetMediaError_Audio(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class GetMediaError_Video extends GetMediaError {
  const GetMediaError_Video(this.field0): super._();
  

@override final  String field0;

/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetMediaError_VideoCopyWith<GetMediaError_Video> get copyWith => _$GetMediaError_VideoCopyWithImpl<GetMediaError_Video>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaError_Video&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'GetMediaError.video(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $GetMediaError_VideoCopyWith<$Res> implements $GetMediaErrorCopyWith<$Res> {
  factory $GetMediaError_VideoCopyWith(GetMediaError_Video value, $Res Function(GetMediaError_Video) _then) = _$GetMediaError_VideoCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$GetMediaError_VideoCopyWithImpl<$Res>
    implements $GetMediaError_VideoCopyWith<$Res> {
  _$GetMediaError_VideoCopyWithImpl(this._self, this._then);

  final GetMediaError_Video _self;
  final $Res Function(GetMediaError_Video) _then;

/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(GetMediaError_Video(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GetMediaResult {

 Object get field0;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaResult&&const DeepCollectionEquality().equals(other.field0, field0));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(field0));

@override
String toString() {
  return 'GetMediaResult(field0: $field0)';
}


}

/// @nodoc
class $GetMediaResultCopyWith<$Res>  {
$GetMediaResultCopyWith(GetMediaResult _, $Res Function(GetMediaResult) __);
}


/// Adds pattern-matching-related methods to [GetMediaResult].
extension GetMediaResultPatterns on GetMediaResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetMediaResult_Ok value)?  ok,TResult Function( GetMediaResult_Err value)?  err,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetMediaResult_Ok() when ok != null:
return ok(_that);case GetMediaResult_Err() when err != null:
return err(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetMediaResult_Ok value)  ok,required TResult Function( GetMediaResult_Err value)  err,}){
final _that = this;
switch (_that) {
case GetMediaResult_Ok():
return ok(_that);case GetMediaResult_Err():
return err(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetMediaResult_Ok value)?  ok,TResult? Function( GetMediaResult_Err value)?  err,}){
final _that = this;
switch (_that) {
case GetMediaResult_Ok() when ok != null:
return ok(_that);case GetMediaResult_Err() when err != null:
return err(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<MediaStreamTrack> field0)?  ok,TResult Function( GetMediaError field0)?  err,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetMediaResult_Ok() when ok != null:
return ok(_that.field0);case GetMediaResult_Err() when err != null:
return err(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<MediaStreamTrack> field0)  ok,required TResult Function( GetMediaError field0)  err,}) {final _that = this;
switch (_that) {
case GetMediaResult_Ok():
return ok(_that.field0);case GetMediaResult_Err():
return err(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<MediaStreamTrack> field0)?  ok,TResult? Function( GetMediaError field0)?  err,}) {final _that = this;
switch (_that) {
case GetMediaResult_Ok() when ok != null:
return ok(_that.field0);case GetMediaResult_Err() when err != null:
return err(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class GetMediaResult_Ok extends GetMediaResult {
  const GetMediaResult_Ok(final  List<MediaStreamTrack> field0): _field0 = field0,super._();
  

 final  List<MediaStreamTrack> _field0;
@override List<MediaStreamTrack> get field0 {
  if (_field0 is EqualUnmodifiableListView) return _field0;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_field0);
}


/// Create a copy of GetMediaResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetMediaResult_OkCopyWith<GetMediaResult_Ok> get copyWith => _$GetMediaResult_OkCopyWithImpl<GetMediaResult_Ok>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaResult_Ok&&const DeepCollectionEquality().equals(other._field0, _field0));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_field0));

@override
String toString() {
  return 'GetMediaResult.ok(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $GetMediaResult_OkCopyWith<$Res> implements $GetMediaResultCopyWith<$Res> {
  factory $GetMediaResult_OkCopyWith(GetMediaResult_Ok value, $Res Function(GetMediaResult_Ok) _then) = _$GetMediaResult_OkCopyWithImpl;
@useResult
$Res call({
 List<MediaStreamTrack> field0
});




}
/// @nodoc
class _$GetMediaResult_OkCopyWithImpl<$Res>
    implements $GetMediaResult_OkCopyWith<$Res> {
  _$GetMediaResult_OkCopyWithImpl(this._self, this._then);

  final GetMediaResult_Ok _self;
  final $Res Function(GetMediaResult_Ok) _then;

/// Create a copy of GetMediaResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(GetMediaResult_Ok(
null == field0 ? _self._field0 : field0 // ignore: cast_nullable_to_non_nullable
as List<MediaStreamTrack>,
  ));
}


}

/// @nodoc


class GetMediaResult_Err extends GetMediaResult {
  const GetMediaResult_Err(this.field0): super._();
  

@override final  GetMediaError field0;

/// Create a copy of GetMediaResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetMediaResult_ErrCopyWith<GetMediaResult_Err> get copyWith => _$GetMediaResult_ErrCopyWithImpl<GetMediaResult_Err>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaResult_Err&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'GetMediaResult.err(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $GetMediaResult_ErrCopyWith<$Res> implements $GetMediaResultCopyWith<$Res> {
  factory $GetMediaResult_ErrCopyWith(GetMediaResult_Err value, $Res Function(GetMediaResult_Err) _then) = _$GetMediaResult_ErrCopyWithImpl;
@useResult
$Res call({
 GetMediaError field0
});


$GetMediaErrorCopyWith<$Res> get field0;

}
/// @nodoc
class _$GetMediaResult_ErrCopyWithImpl<$Res>
    implements $GetMediaResult_ErrCopyWith<$Res> {
  _$GetMediaResult_ErrCopyWithImpl(this._self, this._then);

  final GetMediaResult_Err _self;
  final $Res Function(GetMediaResult_Err) _then;

/// Create a copy of GetMediaResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(GetMediaResult_Err(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as GetMediaError,
  ));
}

/// Create a copy of GetMediaResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetMediaErrorCopyWith<$Res> get field0 {
  
  return $GetMediaErrorCopyWith<$Res>(_self.field0, (value) {
    return _then(_self.copyWith(field0: value));
  });
}
}

// dart format on
