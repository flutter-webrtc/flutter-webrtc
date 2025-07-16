// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rtc_inbound_rtp_stream_media_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RtcInboundRtpStreamMediaType {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcInboundRtpStreamMediaType);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RtcInboundRtpStreamMediaType()';
}


}

/// @nodoc
class $RtcInboundRtpStreamMediaTypeCopyWith<$Res>  {
$RtcInboundRtpStreamMediaTypeCopyWith(RtcInboundRtpStreamMediaType _, $Res Function(RtcInboundRtpStreamMediaType) __);
}


/// Adds pattern-matching-related methods to [RtcInboundRtpStreamMediaType].
extension RtcInboundRtpStreamMediaTypePatterns on RtcInboundRtpStreamMediaType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RtcInboundRtpStreamMediaType_Audio value)?  audio,TResult Function( RtcInboundRtpStreamMediaType_Video value)?  video,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RtcInboundRtpStreamMediaType_Audio() when audio != null:
return audio(_that);case RtcInboundRtpStreamMediaType_Video() when video != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RtcInboundRtpStreamMediaType_Audio value)  audio,required TResult Function( RtcInboundRtpStreamMediaType_Video value)  video,}){
final _that = this;
switch (_that) {
case RtcInboundRtpStreamMediaType_Audio():
return audio(_that);case RtcInboundRtpStreamMediaType_Video():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RtcInboundRtpStreamMediaType_Audio value)?  audio,TResult? Function( RtcInboundRtpStreamMediaType_Video value)?  video,}){
final _that = this;
switch (_that) {
case RtcInboundRtpStreamMediaType_Audio() when audio != null:
return audio(_that);case RtcInboundRtpStreamMediaType_Video() when video != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool? voiceActivityFlag,  BigInt? totalSamplesReceived,  BigInt? concealedSamples,  BigInt? silentConcealedSamples,  double? audioLevel,  double? totalAudioEnergy,  double? totalSamplesDuration)?  audio,TResult Function( int? framesDecoded,  int? keyFramesDecoded,  int? frameWidth,  int? frameHeight,  double? totalInterFrameDelay,  double? framesPerSecond,  int? firCount,  int? pliCount,  int? sliCount,  BigInt? concealmentEvents,  int? framesReceived)?  video,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RtcInboundRtpStreamMediaType_Audio() when audio != null:
return audio(_that.voiceActivityFlag,_that.totalSamplesReceived,_that.concealedSamples,_that.silentConcealedSamples,_that.audioLevel,_that.totalAudioEnergy,_that.totalSamplesDuration);case RtcInboundRtpStreamMediaType_Video() when video != null:
return video(_that.framesDecoded,_that.keyFramesDecoded,_that.frameWidth,_that.frameHeight,_that.totalInterFrameDelay,_that.framesPerSecond,_that.firCount,_that.pliCount,_that.sliCount,_that.concealmentEvents,_that.framesReceived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool? voiceActivityFlag,  BigInt? totalSamplesReceived,  BigInt? concealedSamples,  BigInt? silentConcealedSamples,  double? audioLevel,  double? totalAudioEnergy,  double? totalSamplesDuration)  audio,required TResult Function( int? framesDecoded,  int? keyFramesDecoded,  int? frameWidth,  int? frameHeight,  double? totalInterFrameDelay,  double? framesPerSecond,  int? firCount,  int? pliCount,  int? sliCount,  BigInt? concealmentEvents,  int? framesReceived)  video,}) {final _that = this;
switch (_that) {
case RtcInboundRtpStreamMediaType_Audio():
return audio(_that.voiceActivityFlag,_that.totalSamplesReceived,_that.concealedSamples,_that.silentConcealedSamples,_that.audioLevel,_that.totalAudioEnergy,_that.totalSamplesDuration);case RtcInboundRtpStreamMediaType_Video():
return video(_that.framesDecoded,_that.keyFramesDecoded,_that.frameWidth,_that.frameHeight,_that.totalInterFrameDelay,_that.framesPerSecond,_that.firCount,_that.pliCount,_that.sliCount,_that.concealmentEvents,_that.framesReceived);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool? voiceActivityFlag,  BigInt? totalSamplesReceived,  BigInt? concealedSamples,  BigInt? silentConcealedSamples,  double? audioLevel,  double? totalAudioEnergy,  double? totalSamplesDuration)?  audio,TResult? Function( int? framesDecoded,  int? keyFramesDecoded,  int? frameWidth,  int? frameHeight,  double? totalInterFrameDelay,  double? framesPerSecond,  int? firCount,  int? pliCount,  int? sliCount,  BigInt? concealmentEvents,  int? framesReceived)?  video,}) {final _that = this;
switch (_that) {
case RtcInboundRtpStreamMediaType_Audio() when audio != null:
return audio(_that.voiceActivityFlag,_that.totalSamplesReceived,_that.concealedSamples,_that.silentConcealedSamples,_that.audioLevel,_that.totalAudioEnergy,_that.totalSamplesDuration);case RtcInboundRtpStreamMediaType_Video() when video != null:
return video(_that.framesDecoded,_that.keyFramesDecoded,_that.frameWidth,_that.frameHeight,_that.totalInterFrameDelay,_that.framesPerSecond,_that.firCount,_that.pliCount,_that.sliCount,_that.concealmentEvents,_that.framesReceived);case _:
  return null;

}
}

}

/// @nodoc


class RtcInboundRtpStreamMediaType_Audio extends RtcInboundRtpStreamMediaType {
  const RtcInboundRtpStreamMediaType_Audio({this.voiceActivityFlag, this.totalSamplesReceived, this.concealedSamples, this.silentConcealedSamples, this.audioLevel, this.totalAudioEnergy, this.totalSamplesDuration}): super._();
  

/// Indicator whether the last RTP packet whose frame was delivered to
/// the [RTCRtpReceiver]'s [MediaStreamTrack][1] for playout contained
/// voice activity or not based on the presence of the V bit in the
/// extension header, as defined in [RFC 6464].
///
/// [RTCRtpReceiver]: https://w3.org/TR/webrtc#rtcrtpreceiver-interface
/// [RFC 6464]: https://tools.ietf.org/html/rfc6464#page-3
/// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
 final  bool? voiceActivityFlag;
/// Total number of samples that have been received on this RTP stream.
/// This includes [concealedSamples].
///
/// [concealedSamples]: https://tinyurl.com/s6c4qe4
 final  BigInt? totalSamplesReceived;
/// Total number of samples that are concealed samples.
///
/// A concealed sample is a sample that was replaced with synthesized
/// samples generated locally before being played out.
/// Examples of samples that have to be concealed are samples from lost
/// packets (reported in [packetsLost]) or samples from packets that
/// arrive too late to be played out (reported in [packetsDiscarded]).
///
/// [packetsLost]: https://tinyurl.com/u2gq965
/// [packetsDiscarded]: https://tinyurl.com/yx7qyox3
 final  BigInt? concealedSamples;
/// Total number of concealed samples inserted that are "silent".
///
/// Playing out silent samples results in silence or comfort noise.
/// This is a subset of [concealedSamples].
///
/// [concealedSamples]: https://tinyurl.com/s6c4qe4
 final  BigInt? silentConcealedSamples;
/// Audio level of the receiving track.
 final  double? audioLevel;
/// Audio energy of the receiving track.
 final  double? totalAudioEnergy;
/// Audio duration of the receiving track.
///
/// For audio durations of tracks attached locally, see
/// [RTCAudioSourceStats][1] instead.
///
/// [1]: https://w3.org/TR/webrtc-stats#dom-rtcaudiosourcestats
 final  double? totalSamplesDuration;

/// Create a copy of RtcInboundRtpStreamMediaType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcInboundRtpStreamMediaType_AudioCopyWith<RtcInboundRtpStreamMediaType_Audio> get copyWith => _$RtcInboundRtpStreamMediaType_AudioCopyWithImpl<RtcInboundRtpStreamMediaType_Audio>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcInboundRtpStreamMediaType_Audio&&(identical(other.voiceActivityFlag, voiceActivityFlag) || other.voiceActivityFlag == voiceActivityFlag)&&(identical(other.totalSamplesReceived, totalSamplesReceived) || other.totalSamplesReceived == totalSamplesReceived)&&(identical(other.concealedSamples, concealedSamples) || other.concealedSamples == concealedSamples)&&(identical(other.silentConcealedSamples, silentConcealedSamples) || other.silentConcealedSamples == silentConcealedSamples)&&(identical(other.audioLevel, audioLevel) || other.audioLevel == audioLevel)&&(identical(other.totalAudioEnergy, totalAudioEnergy) || other.totalAudioEnergy == totalAudioEnergy)&&(identical(other.totalSamplesDuration, totalSamplesDuration) || other.totalSamplesDuration == totalSamplesDuration));
}


@override
int get hashCode => Object.hash(runtimeType,voiceActivityFlag,totalSamplesReceived,concealedSamples,silentConcealedSamples,audioLevel,totalAudioEnergy,totalSamplesDuration);

@override
String toString() {
  return 'RtcInboundRtpStreamMediaType.audio(voiceActivityFlag: $voiceActivityFlag, totalSamplesReceived: $totalSamplesReceived, concealedSamples: $concealedSamples, silentConcealedSamples: $silentConcealedSamples, audioLevel: $audioLevel, totalAudioEnergy: $totalAudioEnergy, totalSamplesDuration: $totalSamplesDuration)';
}


}

/// @nodoc
abstract mixin class $RtcInboundRtpStreamMediaType_AudioCopyWith<$Res> implements $RtcInboundRtpStreamMediaTypeCopyWith<$Res> {
  factory $RtcInboundRtpStreamMediaType_AudioCopyWith(RtcInboundRtpStreamMediaType_Audio value, $Res Function(RtcInboundRtpStreamMediaType_Audio) _then) = _$RtcInboundRtpStreamMediaType_AudioCopyWithImpl;
@useResult
$Res call({
 bool? voiceActivityFlag, BigInt? totalSamplesReceived, BigInt? concealedSamples, BigInt? silentConcealedSamples, double? audioLevel, double? totalAudioEnergy, double? totalSamplesDuration
});




}
/// @nodoc
class _$RtcInboundRtpStreamMediaType_AudioCopyWithImpl<$Res>
    implements $RtcInboundRtpStreamMediaType_AudioCopyWith<$Res> {
  _$RtcInboundRtpStreamMediaType_AudioCopyWithImpl(this._self, this._then);

  final RtcInboundRtpStreamMediaType_Audio _self;
  final $Res Function(RtcInboundRtpStreamMediaType_Audio) _then;

/// Create a copy of RtcInboundRtpStreamMediaType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? voiceActivityFlag = freezed,Object? totalSamplesReceived = freezed,Object? concealedSamples = freezed,Object? silentConcealedSamples = freezed,Object? audioLevel = freezed,Object? totalAudioEnergy = freezed,Object? totalSamplesDuration = freezed,}) {
  return _then(RtcInboundRtpStreamMediaType_Audio(
voiceActivityFlag: freezed == voiceActivityFlag ? _self.voiceActivityFlag : voiceActivityFlag // ignore: cast_nullable_to_non_nullable
as bool?,totalSamplesReceived: freezed == totalSamplesReceived ? _self.totalSamplesReceived : totalSamplesReceived // ignore: cast_nullable_to_non_nullable
as BigInt?,concealedSamples: freezed == concealedSamples ? _self.concealedSamples : concealedSamples // ignore: cast_nullable_to_non_nullable
as BigInt?,silentConcealedSamples: freezed == silentConcealedSamples ? _self.silentConcealedSamples : silentConcealedSamples // ignore: cast_nullable_to_non_nullable
as BigInt?,audioLevel: freezed == audioLevel ? _self.audioLevel : audioLevel // ignore: cast_nullable_to_non_nullable
as double?,totalAudioEnergy: freezed == totalAudioEnergy ? _self.totalAudioEnergy : totalAudioEnergy // ignore: cast_nullable_to_non_nullable
as double?,totalSamplesDuration: freezed == totalSamplesDuration ? _self.totalSamplesDuration : totalSamplesDuration // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc


class RtcInboundRtpStreamMediaType_Video extends RtcInboundRtpStreamMediaType {
  const RtcInboundRtpStreamMediaType_Video({this.framesDecoded, this.keyFramesDecoded, this.frameWidth, this.frameHeight, this.totalInterFrameDelay, this.framesPerSecond, this.firCount, this.pliCount, this.sliCount, this.concealmentEvents, this.framesReceived}): super._();
  

/// Total number of frames correctly decoded for this RTP stream, i.e.
/// frames that would be displayed if no frames are dropped.
 final  int? framesDecoded;
/// Total number of key frames, such as key frames in VP8 [RFC 6386] or
/// IDR-frames in H.264 [RFC 6184], successfully decoded for this RTP
/// media stream.
///
/// This is a subset of [framesDecoded].
/// [framesDecoded] - [keyFramesDecoded] gives you the number of delta
/// frames decoded.
///
/// [RFC 6386]: https://w3.org/TR/webrtc-stats#bib-rfc6386
/// [RFC 6184]: https://w3.org/TR/webrtc-stats#bib-rfc6184
/// [framesDecoded]: https://tinyurl.com/srfwrwt
/// [keyFramesDecoded]: https://tinyurl.com/qtdmhtm
 final  int? keyFramesDecoded;
/// Width of the last decoded frame.
///
/// Before the first frame is decoded this attribute is missing.
 final  int? frameWidth;
/// Height of the last decoded frame.
///
/// Before the first frame is decoded this attribute is missing.
 final  int? frameHeight;
/// Sum of the interframe delays in seconds between consecutively
/// decoded frames, recorded just after a frame has been decoded.
 final  double? totalInterFrameDelay;
/// Number of decoded frames in the last second.
 final  double? framesPerSecond;
/// Total number of Full Intra Request (FIR) packets sent by this
/// receiver.
 final  int? firCount;
/// Total number of Picture Loss Indication (PLI) packets sent by this
/// receiver.
 final  int? pliCount;
/// Total number of Slice Loss Indication (SLI) packets sent by this
/// receiver.
 final  int? sliCount;
/// Number of concealment events.
///
/// This counter increases every time a concealed sample is synthesized
/// after a non-concealed sample. That is, multiple consecutive
/// concealed samples will increase the [concealedSamples] count
/// multiple times but is a single concealment event.
///
/// [concealedSamples]: https://tinyurl.com/s6c4qe4
 final  BigInt? concealmentEvents;
/// Total number of complete frames received on this RTP stream.
///
/// This metric is incremented when the complete frame is received.
 final  int? framesReceived;

/// Create a copy of RtcInboundRtpStreamMediaType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcInboundRtpStreamMediaType_VideoCopyWith<RtcInboundRtpStreamMediaType_Video> get copyWith => _$RtcInboundRtpStreamMediaType_VideoCopyWithImpl<RtcInboundRtpStreamMediaType_Video>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcInboundRtpStreamMediaType_Video&&(identical(other.framesDecoded, framesDecoded) || other.framesDecoded == framesDecoded)&&(identical(other.keyFramesDecoded, keyFramesDecoded) || other.keyFramesDecoded == keyFramesDecoded)&&(identical(other.frameWidth, frameWidth) || other.frameWidth == frameWidth)&&(identical(other.frameHeight, frameHeight) || other.frameHeight == frameHeight)&&(identical(other.totalInterFrameDelay, totalInterFrameDelay) || other.totalInterFrameDelay == totalInterFrameDelay)&&(identical(other.framesPerSecond, framesPerSecond) || other.framesPerSecond == framesPerSecond)&&(identical(other.firCount, firCount) || other.firCount == firCount)&&(identical(other.pliCount, pliCount) || other.pliCount == pliCount)&&(identical(other.sliCount, sliCount) || other.sliCount == sliCount)&&(identical(other.concealmentEvents, concealmentEvents) || other.concealmentEvents == concealmentEvents)&&(identical(other.framesReceived, framesReceived) || other.framesReceived == framesReceived));
}


@override
int get hashCode => Object.hash(runtimeType,framesDecoded,keyFramesDecoded,frameWidth,frameHeight,totalInterFrameDelay,framesPerSecond,firCount,pliCount,sliCount,concealmentEvents,framesReceived);

@override
String toString() {
  return 'RtcInboundRtpStreamMediaType.video(framesDecoded: $framesDecoded, keyFramesDecoded: $keyFramesDecoded, frameWidth: $frameWidth, frameHeight: $frameHeight, totalInterFrameDelay: $totalInterFrameDelay, framesPerSecond: $framesPerSecond, firCount: $firCount, pliCount: $pliCount, sliCount: $sliCount, concealmentEvents: $concealmentEvents, framesReceived: $framesReceived)';
}


}

/// @nodoc
abstract mixin class $RtcInboundRtpStreamMediaType_VideoCopyWith<$Res> implements $RtcInboundRtpStreamMediaTypeCopyWith<$Res> {
  factory $RtcInboundRtpStreamMediaType_VideoCopyWith(RtcInboundRtpStreamMediaType_Video value, $Res Function(RtcInboundRtpStreamMediaType_Video) _then) = _$RtcInboundRtpStreamMediaType_VideoCopyWithImpl;
@useResult
$Res call({
 int? framesDecoded, int? keyFramesDecoded, int? frameWidth, int? frameHeight, double? totalInterFrameDelay, double? framesPerSecond, int? firCount, int? pliCount, int? sliCount, BigInt? concealmentEvents, int? framesReceived
});




}
/// @nodoc
class _$RtcInboundRtpStreamMediaType_VideoCopyWithImpl<$Res>
    implements $RtcInboundRtpStreamMediaType_VideoCopyWith<$Res> {
  _$RtcInboundRtpStreamMediaType_VideoCopyWithImpl(this._self, this._then);

  final RtcInboundRtpStreamMediaType_Video _self;
  final $Res Function(RtcInboundRtpStreamMediaType_Video) _then;

/// Create a copy of RtcInboundRtpStreamMediaType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? framesDecoded = freezed,Object? keyFramesDecoded = freezed,Object? frameWidth = freezed,Object? frameHeight = freezed,Object? totalInterFrameDelay = freezed,Object? framesPerSecond = freezed,Object? firCount = freezed,Object? pliCount = freezed,Object? sliCount = freezed,Object? concealmentEvents = freezed,Object? framesReceived = freezed,}) {
  return _then(RtcInboundRtpStreamMediaType_Video(
framesDecoded: freezed == framesDecoded ? _self.framesDecoded : framesDecoded // ignore: cast_nullable_to_non_nullable
as int?,keyFramesDecoded: freezed == keyFramesDecoded ? _self.keyFramesDecoded : keyFramesDecoded // ignore: cast_nullable_to_non_nullable
as int?,frameWidth: freezed == frameWidth ? _self.frameWidth : frameWidth // ignore: cast_nullable_to_non_nullable
as int?,frameHeight: freezed == frameHeight ? _self.frameHeight : frameHeight // ignore: cast_nullable_to_non_nullable
as int?,totalInterFrameDelay: freezed == totalInterFrameDelay ? _self.totalInterFrameDelay : totalInterFrameDelay // ignore: cast_nullable_to_non_nullable
as double?,framesPerSecond: freezed == framesPerSecond ? _self.framesPerSecond : framesPerSecond // ignore: cast_nullable_to_non_nullable
as double?,firCount: freezed == firCount ? _self.firCount : firCount // ignore: cast_nullable_to_non_nullable
as int?,pliCount: freezed == pliCount ? _self.pliCount : pliCount // ignore: cast_nullable_to_non_nullable
as int?,sliCount: freezed == sliCount ? _self.sliCount : sliCount // ignore: cast_nullable_to_non_nullable
as int?,concealmentEvents: freezed == concealmentEvents ? _self.concealmentEvents : concealmentEvents // ignore: cast_nullable_to_non_nullable
as BigInt?,framesReceived: freezed == framesReceived ? _self.framesReceived : framesReceived // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
