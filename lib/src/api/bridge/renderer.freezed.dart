// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'renderer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TextureEvent {

/// ID of the texture.
 PlatformInt64 get textureId;
/// Create a copy of TextureEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextureEventCopyWith<TextureEvent> get copyWith => _$TextureEventCopyWithImpl<TextureEvent>(this as TextureEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextureEvent&&(identical(other.textureId, textureId) || other.textureId == textureId));
}


@override
int get hashCode => Object.hash(runtimeType,textureId);

@override
String toString() {
  return 'TextureEvent(textureId: $textureId)';
}


}

/// @nodoc
abstract mixin class $TextureEventCopyWith<$Res>  {
  factory $TextureEventCopyWith(TextureEvent value, $Res Function(TextureEvent) _then) = _$TextureEventCopyWithImpl;
@useResult
$Res call({
 int textureId
});




}
/// @nodoc
class _$TextureEventCopyWithImpl<$Res>
    implements $TextureEventCopyWith<$Res> {
  _$TextureEventCopyWithImpl(this._self, this._then);

  final TextureEvent _self;
  final $Res Function(TextureEvent) _then;

/// Create a copy of TextureEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? textureId = null,}) {
  return _then(_self.copyWith(
textureId: null == textureId ? _self.textureId : textureId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TextureEvent].
extension TextureEventPatterns on TextureEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TextureEvent_OnTextureChange value)?  onTextureChange,TResult Function( TextureEvent_OnFirstFrameRendered value)?  onFirstFrameRendered,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TextureEvent_OnTextureChange() when onTextureChange != null:
return onTextureChange(_that);case TextureEvent_OnFirstFrameRendered() when onFirstFrameRendered != null:
return onFirstFrameRendered(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TextureEvent_OnTextureChange value)  onTextureChange,required TResult Function( TextureEvent_OnFirstFrameRendered value)  onFirstFrameRendered,}){
final _that = this;
switch (_that) {
case TextureEvent_OnTextureChange():
return onTextureChange(_that);case TextureEvent_OnFirstFrameRendered():
return onFirstFrameRendered(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TextureEvent_OnTextureChange value)?  onTextureChange,TResult? Function( TextureEvent_OnFirstFrameRendered value)?  onFirstFrameRendered,}){
final _that = this;
switch (_that) {
case TextureEvent_OnTextureChange() when onTextureChange != null:
return onTextureChange(_that);case TextureEvent_OnFirstFrameRendered() when onFirstFrameRendered != null:
return onFirstFrameRendered(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( PlatformInt64 textureId,  int width,  int height,  int rotation)?  onTextureChange,TResult Function( PlatformInt64 textureId)?  onFirstFrameRendered,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TextureEvent_OnTextureChange() when onTextureChange != null:
return onTextureChange(_that.textureId,_that.width,_that.height,_that.rotation);case TextureEvent_OnFirstFrameRendered() when onFirstFrameRendered != null:
return onFirstFrameRendered(_that.textureId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( PlatformInt64 textureId,  int width,  int height,  int rotation)  onTextureChange,required TResult Function( PlatformInt64 textureId)  onFirstFrameRendered,}) {final _that = this;
switch (_that) {
case TextureEvent_OnTextureChange():
return onTextureChange(_that.textureId,_that.width,_that.height,_that.rotation);case TextureEvent_OnFirstFrameRendered():
return onFirstFrameRendered(_that.textureId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( PlatformInt64 textureId,  int width,  int height,  int rotation)?  onTextureChange,TResult? Function( PlatformInt64 textureId)?  onFirstFrameRendered,}) {final _that = this;
switch (_that) {
case TextureEvent_OnTextureChange() when onTextureChange != null:
return onTextureChange(_that.textureId,_that.width,_that.height,_that.rotation);case TextureEvent_OnFirstFrameRendered() when onFirstFrameRendered != null:
return onFirstFrameRendered(_that.textureId);case _:
  return null;

}
}

}

/// @nodoc


class TextureEvent_OnTextureChange extends TextureEvent {
  const TextureEvent_OnTextureChange({required this.textureId, required this.width, required this.height, required this.rotation}): super._();
  

/// ID of the texture.
@override final  PlatformInt64 textureId;
/// Width of the last processed frame.
 final  int width;
/// Height of the last processed frame.
 final  int height;
/// Rotation of the last processed frame.
 final  int rotation;

/// Create a copy of TextureEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextureEvent_OnTextureChangeCopyWith<TextureEvent_OnTextureChange> get copyWith => _$TextureEvent_OnTextureChangeCopyWithImpl<TextureEvent_OnTextureChange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextureEvent_OnTextureChange&&(identical(other.textureId, textureId) || other.textureId == textureId)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.rotation, rotation) || other.rotation == rotation));
}


@override
int get hashCode => Object.hash(runtimeType,textureId,width,height,rotation);

@override
String toString() {
  return 'TextureEvent.onTextureChange(textureId: $textureId, width: $width, height: $height, rotation: $rotation)';
}


}

/// @nodoc
abstract mixin class $TextureEvent_OnTextureChangeCopyWith<$Res> implements $TextureEventCopyWith<$Res> {
  factory $TextureEvent_OnTextureChangeCopyWith(TextureEvent_OnTextureChange value, $Res Function(TextureEvent_OnTextureChange) _then) = _$TextureEvent_OnTextureChangeCopyWithImpl;
@override @useResult
$Res call({
 PlatformInt64 textureId, int width, int height, int rotation
});




}
/// @nodoc
class _$TextureEvent_OnTextureChangeCopyWithImpl<$Res>
    implements $TextureEvent_OnTextureChangeCopyWith<$Res> {
  _$TextureEvent_OnTextureChangeCopyWithImpl(this._self, this._then);

  final TextureEvent_OnTextureChange _self;
  final $Res Function(TextureEvent_OnTextureChange) _then;

/// Create a copy of TextureEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? textureId = null,Object? width = null,Object? height = null,Object? rotation = null,}) {
  return _then(TextureEvent_OnTextureChange(
textureId: null == textureId ? _self.textureId : textureId // ignore: cast_nullable_to_non_nullable
as PlatformInt64,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class TextureEvent_OnFirstFrameRendered extends TextureEvent {
  const TextureEvent_OnFirstFrameRendered({required this.textureId}): super._();
  

/// ID of the texture.
@override final  PlatformInt64 textureId;

/// Create a copy of TextureEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextureEvent_OnFirstFrameRenderedCopyWith<TextureEvent_OnFirstFrameRendered> get copyWith => _$TextureEvent_OnFirstFrameRenderedCopyWithImpl<TextureEvent_OnFirstFrameRendered>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextureEvent_OnFirstFrameRendered&&(identical(other.textureId, textureId) || other.textureId == textureId));
}


@override
int get hashCode => Object.hash(runtimeType,textureId);

@override
String toString() {
  return 'TextureEvent.onFirstFrameRendered(textureId: $textureId)';
}


}

/// @nodoc
abstract mixin class $TextureEvent_OnFirstFrameRenderedCopyWith<$Res> implements $TextureEventCopyWith<$Res> {
  factory $TextureEvent_OnFirstFrameRenderedCopyWith(TextureEvent_OnFirstFrameRendered value, $Res Function(TextureEvent_OnFirstFrameRendered) _then) = _$TextureEvent_OnFirstFrameRenderedCopyWithImpl;
@override @useResult
$Res call({
 PlatformInt64 textureId
});




}
/// @nodoc
class _$TextureEvent_OnFirstFrameRenderedCopyWithImpl<$Res>
    implements $TextureEvent_OnFirstFrameRenderedCopyWith<$Res> {
  _$TextureEvent_OnFirstFrameRenderedCopyWithImpl(this._self, this._then);

  final TextureEvent_OnFirstFrameRendered _self;
  final $Res Function(TextureEvent_OnFirstFrameRendered) _then;

/// Create a copy of TextureEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? textureId = null,}) {
  return _then(TextureEvent_OnFirstFrameRendered(
textureId: null == textureId ? _self.textureId : textureId // ignore: cast_nullable_to_non_nullable
as PlatformInt64,
  ));
}


}

// dart format on
