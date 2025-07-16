// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rtc_media_source_stats_media_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RtcMediaSourceStatsMediaType {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcMediaSourceStatsMediaType);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RtcMediaSourceStatsMediaType()';
}


}

/// @nodoc
class $RtcMediaSourceStatsMediaTypeCopyWith<$Res>  {
$RtcMediaSourceStatsMediaTypeCopyWith(RtcMediaSourceStatsMediaType _, $Res Function(RtcMediaSourceStatsMediaType) __);
}


/// Adds pattern-matching-related methods to [RtcMediaSourceStatsMediaType].
extension RtcMediaSourceStatsMediaTypePatterns on RtcMediaSourceStatsMediaType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)?  rtcVideoSourceStats,TResult Function( RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)?  rtcAudioSourceStats,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RtcMediaSourceStatsMediaType_RtcVideoSourceStats() when rtcVideoSourceStats != null:
return rtcVideoSourceStats(_that);case RtcMediaSourceStatsMediaType_RtcAudioSourceStats() when rtcAudioSourceStats != null:
return rtcAudioSourceStats(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)  rtcVideoSourceStats,required TResult Function( RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)  rtcAudioSourceStats,}){
final _that = this;
switch (_that) {
case RtcMediaSourceStatsMediaType_RtcVideoSourceStats():
return rtcVideoSourceStats(_that);case RtcMediaSourceStatsMediaType_RtcAudioSourceStats():
return rtcAudioSourceStats(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)?  rtcVideoSourceStats,TResult? Function( RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)?  rtcAudioSourceStats,}){
final _that = this;
switch (_that) {
case RtcMediaSourceStatsMediaType_RtcVideoSourceStats() when rtcVideoSourceStats != null:
return rtcVideoSourceStats(_that);case RtcMediaSourceStatsMediaType_RtcAudioSourceStats() when rtcAudioSourceStats != null:
return rtcAudioSourceStats(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int? width,  int? height,  int? frames,  double? framesPerSecond)?  rtcVideoSourceStats,TResult Function( double? audioLevel,  double? totalAudioEnergy,  double? totalSamplesDuration,  double? echoReturnLoss,  double? echoReturnLossEnhancement)?  rtcAudioSourceStats,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RtcMediaSourceStatsMediaType_RtcVideoSourceStats() when rtcVideoSourceStats != null:
return rtcVideoSourceStats(_that.width,_that.height,_that.frames,_that.framesPerSecond);case RtcMediaSourceStatsMediaType_RtcAudioSourceStats() when rtcAudioSourceStats != null:
return rtcAudioSourceStats(_that.audioLevel,_that.totalAudioEnergy,_that.totalSamplesDuration,_that.echoReturnLoss,_that.echoReturnLossEnhancement);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int? width,  int? height,  int? frames,  double? framesPerSecond)  rtcVideoSourceStats,required TResult Function( double? audioLevel,  double? totalAudioEnergy,  double? totalSamplesDuration,  double? echoReturnLoss,  double? echoReturnLossEnhancement)  rtcAudioSourceStats,}) {final _that = this;
switch (_that) {
case RtcMediaSourceStatsMediaType_RtcVideoSourceStats():
return rtcVideoSourceStats(_that.width,_that.height,_that.frames,_that.framesPerSecond);case RtcMediaSourceStatsMediaType_RtcAudioSourceStats():
return rtcAudioSourceStats(_that.audioLevel,_that.totalAudioEnergy,_that.totalSamplesDuration,_that.echoReturnLoss,_that.echoReturnLossEnhancement);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int? width,  int? height,  int? frames,  double? framesPerSecond)?  rtcVideoSourceStats,TResult? Function( double? audioLevel,  double? totalAudioEnergy,  double? totalSamplesDuration,  double? echoReturnLoss,  double? echoReturnLossEnhancement)?  rtcAudioSourceStats,}) {final _that = this;
switch (_that) {
case RtcMediaSourceStatsMediaType_RtcVideoSourceStats() when rtcVideoSourceStats != null:
return rtcVideoSourceStats(_that.width,_that.height,_that.frames,_that.framesPerSecond);case RtcMediaSourceStatsMediaType_RtcAudioSourceStats() when rtcAudioSourceStats != null:
return rtcAudioSourceStats(_that.audioLevel,_that.totalAudioEnergy,_that.totalSamplesDuration,_that.echoReturnLoss,_that.echoReturnLossEnhancement);case _:
  return null;

}
}

}

/// @nodoc


class RtcMediaSourceStatsMediaType_RtcVideoSourceStats extends RtcMediaSourceStatsMediaType {
  const RtcMediaSourceStatsMediaType_RtcVideoSourceStats({this.width, this.height, this.frames, this.framesPerSecond}): super._();
  

/// Width (in pixels) of the last frame originating from the source.
/// Before a frame has been produced this attribute is missing.
 final  int? width;
/// Height (in pixels) of the last frame originating from the source.
/// Before a frame has been produced this attribute is missing.
 final  int? height;
/// Total number of frames originating from this source.
 final  int? frames;
/// Number of frames originating from the source, measured during the
/// last second. For the first second of this object's lifetime this
/// attribute is missing.
 final  double? framesPerSecond;

/// Create a copy of RtcMediaSourceStatsMediaType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWith<RtcMediaSourceStatsMediaType_RtcVideoSourceStats> get copyWith => _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWithImpl<RtcMediaSourceStatsMediaType_RtcVideoSourceStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcMediaSourceStatsMediaType_RtcVideoSourceStats&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.frames, frames) || other.frames == frames)&&(identical(other.framesPerSecond, framesPerSecond) || other.framesPerSecond == framesPerSecond));
}


@override
int get hashCode => Object.hash(runtimeType,width,height,frames,framesPerSecond);

@override
String toString() {
  return 'RtcMediaSourceStatsMediaType.rtcVideoSourceStats(width: $width, height: $height, frames: $frames, framesPerSecond: $framesPerSecond)';
}


}

/// @nodoc
abstract mixin class $RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWith<$Res> implements $RtcMediaSourceStatsMediaTypeCopyWith<$Res> {
  factory $RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWith(RtcMediaSourceStatsMediaType_RtcVideoSourceStats value, $Res Function(RtcMediaSourceStatsMediaType_RtcVideoSourceStats) _then) = _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWithImpl;
@useResult
$Res call({
 int? width, int? height, int? frames, double? framesPerSecond
});




}
/// @nodoc
class _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWithImpl<$Res>
    implements $RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWith<$Res> {
  _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWithImpl(this._self, this._then);

  final RtcMediaSourceStatsMediaType_RtcVideoSourceStats _self;
  final $Res Function(RtcMediaSourceStatsMediaType_RtcVideoSourceStats) _then;

/// Create a copy of RtcMediaSourceStatsMediaType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? width = freezed,Object? height = freezed,Object? frames = freezed,Object? framesPerSecond = freezed,}) {
  return _then(RtcMediaSourceStatsMediaType_RtcVideoSourceStats(
width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,frames: freezed == frames ? _self.frames : frames // ignore: cast_nullable_to_non_nullable
as int?,framesPerSecond: freezed == framesPerSecond ? _self.framesPerSecond : framesPerSecond // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc


class RtcMediaSourceStatsMediaType_RtcAudioSourceStats extends RtcMediaSourceStatsMediaType {
  const RtcMediaSourceStatsMediaType_RtcAudioSourceStats({this.audioLevel, this.totalAudioEnergy, this.totalSamplesDuration, this.echoReturnLoss, this.echoReturnLossEnhancement}): super._();
  

/// Audio level of the media source.
 final  double? audioLevel;
/// Audio energy of the media source.
 final  double? totalAudioEnergy;
/// Audio duration of the media source.
 final  double? totalSamplesDuration;
/// Only exists when the [MediaStreamTrack][1] is sourced from a
/// microphone where echo cancellation is applied.
///
/// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
 final  double? echoReturnLoss;
/// Only exists when the [MediaStreamTrack][1] is sourced from a
/// microphone where echo cancellation is applied.
///
/// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
 final  double? echoReturnLossEnhancement;

/// Create a copy of RtcMediaSourceStatsMediaType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWith<RtcMediaSourceStatsMediaType_RtcAudioSourceStats> get copyWith => _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWithImpl<RtcMediaSourceStatsMediaType_RtcAudioSourceStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcMediaSourceStatsMediaType_RtcAudioSourceStats&&(identical(other.audioLevel, audioLevel) || other.audioLevel == audioLevel)&&(identical(other.totalAudioEnergy, totalAudioEnergy) || other.totalAudioEnergy == totalAudioEnergy)&&(identical(other.totalSamplesDuration, totalSamplesDuration) || other.totalSamplesDuration == totalSamplesDuration)&&(identical(other.echoReturnLoss, echoReturnLoss) || other.echoReturnLoss == echoReturnLoss)&&(identical(other.echoReturnLossEnhancement, echoReturnLossEnhancement) || other.echoReturnLossEnhancement == echoReturnLossEnhancement));
}


@override
int get hashCode => Object.hash(runtimeType,audioLevel,totalAudioEnergy,totalSamplesDuration,echoReturnLoss,echoReturnLossEnhancement);

@override
String toString() {
  return 'RtcMediaSourceStatsMediaType.rtcAudioSourceStats(audioLevel: $audioLevel, totalAudioEnergy: $totalAudioEnergy, totalSamplesDuration: $totalSamplesDuration, echoReturnLoss: $echoReturnLoss, echoReturnLossEnhancement: $echoReturnLossEnhancement)';
}


}

/// @nodoc
abstract mixin class $RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWith<$Res> implements $RtcMediaSourceStatsMediaTypeCopyWith<$Res> {
  factory $RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWith(RtcMediaSourceStatsMediaType_RtcAudioSourceStats value, $Res Function(RtcMediaSourceStatsMediaType_RtcAudioSourceStats) _then) = _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWithImpl;
@useResult
$Res call({
 double? audioLevel, double? totalAudioEnergy, double? totalSamplesDuration, double? echoReturnLoss, double? echoReturnLossEnhancement
});




}
/// @nodoc
class _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWithImpl<$Res>
    implements $RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWith<$Res> {
  _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWithImpl(this._self, this._then);

  final RtcMediaSourceStatsMediaType_RtcAudioSourceStats _self;
  final $Res Function(RtcMediaSourceStatsMediaType_RtcAudioSourceStats) _then;

/// Create a copy of RtcMediaSourceStatsMediaType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? audioLevel = freezed,Object? totalAudioEnergy = freezed,Object? totalSamplesDuration = freezed,Object? echoReturnLoss = freezed,Object? echoReturnLossEnhancement = freezed,}) {
  return _then(RtcMediaSourceStatsMediaType_RtcAudioSourceStats(
audioLevel: freezed == audioLevel ? _self.audioLevel : audioLevel // ignore: cast_nullable_to_non_nullable
as double?,totalAudioEnergy: freezed == totalAudioEnergy ? _self.totalAudioEnergy : totalAudioEnergy // ignore: cast_nullable_to_non_nullable
as double?,totalSamplesDuration: freezed == totalSamplesDuration ? _self.totalSamplesDuration : totalSamplesDuration // ignore: cast_nullable_to_non_nullable
as double?,echoReturnLoss: freezed == echoReturnLoss ? _self.echoReturnLoss : echoReturnLoss // ignore: cast_nullable_to_non_nullable
as double?,echoReturnLossEnhancement: freezed == echoReturnLossEnhancement ? _self.echoReturnLossEnhancement : echoReturnLossEnhancement // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
