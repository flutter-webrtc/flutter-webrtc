// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rtc_outbound_rtp_stream_media_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RtcOutboundRtpStreamStatsMediaType {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcOutboundRtpStreamStatsMediaType);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RtcOutboundRtpStreamStatsMediaType()';
}


}

/// @nodoc
class $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res>  {
$RtcOutboundRtpStreamStatsMediaTypeCopyWith(RtcOutboundRtpStreamStatsMediaType _, $Res Function(RtcOutboundRtpStreamStatsMediaType) __);
}


/// Adds pattern-matching-related methods to [RtcOutboundRtpStreamStatsMediaType].
extension RtcOutboundRtpStreamStatsMediaTypePatterns on RtcOutboundRtpStreamStatsMediaType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RtcOutboundRtpStreamStatsMediaType_Audio value)?  audio,TResult Function( RtcOutboundRtpStreamStatsMediaType_Video value)?  video,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RtcOutboundRtpStreamStatsMediaType_Audio() when audio != null:
return audio(_that);case RtcOutboundRtpStreamStatsMediaType_Video() when video != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RtcOutboundRtpStreamStatsMediaType_Audio value)  audio,required TResult Function( RtcOutboundRtpStreamStatsMediaType_Video value)  video,}){
final _that = this;
switch (_that) {
case RtcOutboundRtpStreamStatsMediaType_Audio():
return audio(_that);case RtcOutboundRtpStreamStatsMediaType_Video():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RtcOutboundRtpStreamStatsMediaType_Audio value)?  audio,TResult? Function( RtcOutboundRtpStreamStatsMediaType_Video value)?  video,}){
final _that = this;
switch (_that) {
case RtcOutboundRtpStreamStatsMediaType_Audio() when audio != null:
return audio(_that);case RtcOutboundRtpStreamStatsMediaType_Video() when video != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( BigInt? totalSamplesSent,  bool? voiceActivityFlag)?  audio,TResult Function( int? frameWidth,  int? frameHeight,  double? framesPerSecond)?  video,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RtcOutboundRtpStreamStatsMediaType_Audio() when audio != null:
return audio(_that.totalSamplesSent,_that.voiceActivityFlag);case RtcOutboundRtpStreamStatsMediaType_Video() when video != null:
return video(_that.frameWidth,_that.frameHeight,_that.framesPerSecond);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( BigInt? totalSamplesSent,  bool? voiceActivityFlag)  audio,required TResult Function( int? frameWidth,  int? frameHeight,  double? framesPerSecond)  video,}) {final _that = this;
switch (_that) {
case RtcOutboundRtpStreamStatsMediaType_Audio():
return audio(_that.totalSamplesSent,_that.voiceActivityFlag);case RtcOutboundRtpStreamStatsMediaType_Video():
return video(_that.frameWidth,_that.frameHeight,_that.framesPerSecond);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( BigInt? totalSamplesSent,  bool? voiceActivityFlag)?  audio,TResult? Function( int? frameWidth,  int? frameHeight,  double? framesPerSecond)?  video,}) {final _that = this;
switch (_that) {
case RtcOutboundRtpStreamStatsMediaType_Audio() when audio != null:
return audio(_that.totalSamplesSent,_that.voiceActivityFlag);case RtcOutboundRtpStreamStatsMediaType_Video() when video != null:
return video(_that.frameWidth,_that.frameHeight,_that.framesPerSecond);case _:
  return null;

}
}

}

/// @nodoc


class RtcOutboundRtpStreamStatsMediaType_Audio extends RtcOutboundRtpStreamStatsMediaType {
  const RtcOutboundRtpStreamStatsMediaType_Audio({this.totalSamplesSent, this.voiceActivityFlag}): super._();
  

/// Total number of samples that have been sent over the RTP stream.
 final  BigInt? totalSamplesSent;
/// Whether the last RTP packet sent contained voice activity or not
/// based on the presence of the V bit in the extension header.
 final  bool? voiceActivityFlag;

/// Create a copy of RtcOutboundRtpStreamStatsMediaType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcOutboundRtpStreamStatsMediaType_AudioCopyWith<RtcOutboundRtpStreamStatsMediaType_Audio> get copyWith => _$RtcOutboundRtpStreamStatsMediaType_AudioCopyWithImpl<RtcOutboundRtpStreamStatsMediaType_Audio>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcOutboundRtpStreamStatsMediaType_Audio&&(identical(other.totalSamplesSent, totalSamplesSent) || other.totalSamplesSent == totalSamplesSent)&&(identical(other.voiceActivityFlag, voiceActivityFlag) || other.voiceActivityFlag == voiceActivityFlag));
}


@override
int get hashCode => Object.hash(runtimeType,totalSamplesSent,voiceActivityFlag);

@override
String toString() {
  return 'RtcOutboundRtpStreamStatsMediaType.audio(totalSamplesSent: $totalSamplesSent, voiceActivityFlag: $voiceActivityFlag)';
}


}

/// @nodoc
abstract mixin class $RtcOutboundRtpStreamStatsMediaType_AudioCopyWith<$Res> implements $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> {
  factory $RtcOutboundRtpStreamStatsMediaType_AudioCopyWith(RtcOutboundRtpStreamStatsMediaType_Audio value, $Res Function(RtcOutboundRtpStreamStatsMediaType_Audio) _then) = _$RtcOutboundRtpStreamStatsMediaType_AudioCopyWithImpl;
@useResult
$Res call({
 BigInt? totalSamplesSent, bool? voiceActivityFlag
});




}
/// @nodoc
class _$RtcOutboundRtpStreamStatsMediaType_AudioCopyWithImpl<$Res>
    implements $RtcOutboundRtpStreamStatsMediaType_AudioCopyWith<$Res> {
  _$RtcOutboundRtpStreamStatsMediaType_AudioCopyWithImpl(this._self, this._then);

  final RtcOutboundRtpStreamStatsMediaType_Audio _self;
  final $Res Function(RtcOutboundRtpStreamStatsMediaType_Audio) _then;

/// Create a copy of RtcOutboundRtpStreamStatsMediaType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? totalSamplesSent = freezed,Object? voiceActivityFlag = freezed,}) {
  return _then(RtcOutboundRtpStreamStatsMediaType_Audio(
totalSamplesSent: freezed == totalSamplesSent ? _self.totalSamplesSent : totalSamplesSent // ignore: cast_nullable_to_non_nullable
as BigInt?,voiceActivityFlag: freezed == voiceActivityFlag ? _self.voiceActivityFlag : voiceActivityFlag // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc


class RtcOutboundRtpStreamStatsMediaType_Video extends RtcOutboundRtpStreamStatsMediaType {
  const RtcOutboundRtpStreamStatsMediaType_Video({this.frameWidth, this.frameHeight, this.framesPerSecond}): super._();
  

/// Width of the last encoded frame.
///
/// The resolution of the encoded frame may be lower than the media
/// source (see [RTCVideoSourceStats.width][1]).
///
/// Before the first frame is encoded this attribute is missing.
///
/// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-width
 final  int? frameWidth;
/// Height of the last encoded frame.
///
/// The resolution of the encoded frame may be lower than the media
/// source (see [RTCVideoSourceStats.height][1]).
///
/// Before the first frame is encoded this attribute is missing.
///
/// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-height
 final  int? frameHeight;
/// Number of encoded frames during the last second.
///
/// This may be lower than the media source frame rate (see
/// [RTCVideoSourceStats.framesPerSecond][1]).
///
/// [1]: https://tinyurl.com/rrmkrfk
 final  double? framesPerSecond;

/// Create a copy of RtcOutboundRtpStreamStatsMediaType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcOutboundRtpStreamStatsMediaType_VideoCopyWith<RtcOutboundRtpStreamStatsMediaType_Video> get copyWith => _$RtcOutboundRtpStreamStatsMediaType_VideoCopyWithImpl<RtcOutboundRtpStreamStatsMediaType_Video>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcOutboundRtpStreamStatsMediaType_Video&&(identical(other.frameWidth, frameWidth) || other.frameWidth == frameWidth)&&(identical(other.frameHeight, frameHeight) || other.frameHeight == frameHeight)&&(identical(other.framesPerSecond, framesPerSecond) || other.framesPerSecond == framesPerSecond));
}


@override
int get hashCode => Object.hash(runtimeType,frameWidth,frameHeight,framesPerSecond);

@override
String toString() {
  return 'RtcOutboundRtpStreamStatsMediaType.video(frameWidth: $frameWidth, frameHeight: $frameHeight, framesPerSecond: $framesPerSecond)';
}


}

/// @nodoc
abstract mixin class $RtcOutboundRtpStreamStatsMediaType_VideoCopyWith<$Res> implements $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> {
  factory $RtcOutboundRtpStreamStatsMediaType_VideoCopyWith(RtcOutboundRtpStreamStatsMediaType_Video value, $Res Function(RtcOutboundRtpStreamStatsMediaType_Video) _then) = _$RtcOutboundRtpStreamStatsMediaType_VideoCopyWithImpl;
@useResult
$Res call({
 int? frameWidth, int? frameHeight, double? framesPerSecond
});




}
/// @nodoc
class _$RtcOutboundRtpStreamStatsMediaType_VideoCopyWithImpl<$Res>
    implements $RtcOutboundRtpStreamStatsMediaType_VideoCopyWith<$Res> {
  _$RtcOutboundRtpStreamStatsMediaType_VideoCopyWithImpl(this._self, this._then);

  final RtcOutboundRtpStreamStatsMediaType_Video _self;
  final $Res Function(RtcOutboundRtpStreamStatsMediaType_Video) _then;

/// Create a copy of RtcOutboundRtpStreamStatsMediaType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? frameWidth = freezed,Object? frameHeight = freezed,Object? framesPerSecond = freezed,}) {
  return _then(RtcOutboundRtpStreamStatsMediaType_Video(
frameWidth: freezed == frameWidth ? _self.frameWidth : frameWidth // ignore: cast_nullable_to_non_nullable
as int?,frameHeight: freezed == frameHeight ? _self.frameHeight : frameHeight // ignore: cast_nullable_to_non_nullable
as int?,framesPerSecond: freezed == framesPerSecond ? _self.framesPerSecond : framesPerSecond // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
