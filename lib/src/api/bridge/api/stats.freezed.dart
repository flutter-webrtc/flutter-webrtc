// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RtcStatsType {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcStatsType);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RtcStatsType()';
}


}

/// @nodoc
class $RtcStatsTypeCopyWith<$Res>  {
$RtcStatsTypeCopyWith(RtcStatsType _, $Res Function(RtcStatsType) __);
}


/// Adds pattern-matching-related methods to [RtcStatsType].
extension RtcStatsTypePatterns on RtcStatsType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RtcStatsType_RtcMediaSourceStats value)?  rtcMediaSourceStats,TResult Function( RtcStatsType_RtcIceCandidateStats value)?  rtcIceCandidateStats,TResult Function( RtcStatsType_RtcOutboundRtpStreamStats value)?  rtcOutboundRtpStreamStats,TResult Function( RtcStatsType_RtcInboundRtpStreamStats value)?  rtcInboundRtpStreamStats,TResult Function( RtcStatsType_RtcIceCandidatePairStats value)?  rtcIceCandidatePairStats,TResult Function( RtcStatsType_RtcTransportStats value)?  rtcTransportStats,TResult Function( RtcStatsType_RtcRemoteInboundRtpStreamStats value)?  rtcRemoteInboundRtpStreamStats,TResult Function( RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?  rtcRemoteOutboundRtpStreamStats,TResult Function( RtcStatsType_Unimplemented value)?  unimplemented,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RtcStatsType_RtcMediaSourceStats() when rtcMediaSourceStats != null:
return rtcMediaSourceStats(_that);case RtcStatsType_RtcIceCandidateStats() when rtcIceCandidateStats != null:
return rtcIceCandidateStats(_that);case RtcStatsType_RtcOutboundRtpStreamStats() when rtcOutboundRtpStreamStats != null:
return rtcOutboundRtpStreamStats(_that);case RtcStatsType_RtcInboundRtpStreamStats() when rtcInboundRtpStreamStats != null:
return rtcInboundRtpStreamStats(_that);case RtcStatsType_RtcIceCandidatePairStats() when rtcIceCandidatePairStats != null:
return rtcIceCandidatePairStats(_that);case RtcStatsType_RtcTransportStats() when rtcTransportStats != null:
return rtcTransportStats(_that);case RtcStatsType_RtcRemoteInboundRtpStreamStats() when rtcRemoteInboundRtpStreamStats != null:
return rtcRemoteInboundRtpStreamStats(_that);case RtcStatsType_RtcRemoteOutboundRtpStreamStats() when rtcRemoteOutboundRtpStreamStats != null:
return rtcRemoteOutboundRtpStreamStats(_that);case RtcStatsType_Unimplemented() when unimplemented != null:
return unimplemented(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RtcStatsType_RtcMediaSourceStats value)  rtcMediaSourceStats,required TResult Function( RtcStatsType_RtcIceCandidateStats value)  rtcIceCandidateStats,required TResult Function( RtcStatsType_RtcOutboundRtpStreamStats value)  rtcOutboundRtpStreamStats,required TResult Function( RtcStatsType_RtcInboundRtpStreamStats value)  rtcInboundRtpStreamStats,required TResult Function( RtcStatsType_RtcIceCandidatePairStats value)  rtcIceCandidatePairStats,required TResult Function( RtcStatsType_RtcTransportStats value)  rtcTransportStats,required TResult Function( RtcStatsType_RtcRemoteInboundRtpStreamStats value)  rtcRemoteInboundRtpStreamStats,required TResult Function( RtcStatsType_RtcRemoteOutboundRtpStreamStats value)  rtcRemoteOutboundRtpStreamStats,required TResult Function( RtcStatsType_Unimplemented value)  unimplemented,}){
final _that = this;
switch (_that) {
case RtcStatsType_RtcMediaSourceStats():
return rtcMediaSourceStats(_that);case RtcStatsType_RtcIceCandidateStats():
return rtcIceCandidateStats(_that);case RtcStatsType_RtcOutboundRtpStreamStats():
return rtcOutboundRtpStreamStats(_that);case RtcStatsType_RtcInboundRtpStreamStats():
return rtcInboundRtpStreamStats(_that);case RtcStatsType_RtcIceCandidatePairStats():
return rtcIceCandidatePairStats(_that);case RtcStatsType_RtcTransportStats():
return rtcTransportStats(_that);case RtcStatsType_RtcRemoteInboundRtpStreamStats():
return rtcRemoteInboundRtpStreamStats(_that);case RtcStatsType_RtcRemoteOutboundRtpStreamStats():
return rtcRemoteOutboundRtpStreamStats(_that);case RtcStatsType_Unimplemented():
return unimplemented(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RtcStatsType_RtcMediaSourceStats value)?  rtcMediaSourceStats,TResult? Function( RtcStatsType_RtcIceCandidateStats value)?  rtcIceCandidateStats,TResult? Function( RtcStatsType_RtcOutboundRtpStreamStats value)?  rtcOutboundRtpStreamStats,TResult? Function( RtcStatsType_RtcInboundRtpStreamStats value)?  rtcInboundRtpStreamStats,TResult? Function( RtcStatsType_RtcIceCandidatePairStats value)?  rtcIceCandidatePairStats,TResult? Function( RtcStatsType_RtcTransportStats value)?  rtcTransportStats,TResult? Function( RtcStatsType_RtcRemoteInboundRtpStreamStats value)?  rtcRemoteInboundRtpStreamStats,TResult? Function( RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?  rtcRemoteOutboundRtpStreamStats,TResult? Function( RtcStatsType_Unimplemented value)?  unimplemented,}){
final _that = this;
switch (_that) {
case RtcStatsType_RtcMediaSourceStats() when rtcMediaSourceStats != null:
return rtcMediaSourceStats(_that);case RtcStatsType_RtcIceCandidateStats() when rtcIceCandidateStats != null:
return rtcIceCandidateStats(_that);case RtcStatsType_RtcOutboundRtpStreamStats() when rtcOutboundRtpStreamStats != null:
return rtcOutboundRtpStreamStats(_that);case RtcStatsType_RtcInboundRtpStreamStats() when rtcInboundRtpStreamStats != null:
return rtcInboundRtpStreamStats(_that);case RtcStatsType_RtcIceCandidatePairStats() when rtcIceCandidatePairStats != null:
return rtcIceCandidatePairStats(_that);case RtcStatsType_RtcTransportStats() when rtcTransportStats != null:
return rtcTransportStats(_that);case RtcStatsType_RtcRemoteInboundRtpStreamStats() when rtcRemoteInboundRtpStreamStats != null:
return rtcRemoteInboundRtpStreamStats(_that);case RtcStatsType_RtcRemoteOutboundRtpStreamStats() when rtcRemoteOutboundRtpStreamStats != null:
return rtcRemoteOutboundRtpStreamStats(_that);case RtcStatsType_Unimplemented() when unimplemented != null:
return unimplemented(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? trackIdentifier,  RtcMediaSourceStatsMediaType kind)?  rtcMediaSourceStats,TResult Function( RtcIceCandidateStats field0)?  rtcIceCandidateStats,TResult Function( String? trackId,  RtcOutboundRtpStreamStatsMediaType mediaType,  BigInt? bytesSent,  int? packetsSent,  String? mediaSourceId)?  rtcOutboundRtpStreamStats,TResult Function( String? remoteId,  BigInt? bytesReceived,  int? packetsReceived,  BigInt? packetsLost,  double? jitter,  double? totalDecodeTime,  BigInt? jitterBufferEmittedCount,  RtcInboundRtpStreamMediaType? mediaType)?  rtcInboundRtpStreamStats,TResult Function( RtcStatsIceCandidatePairState state,  bool? nominated,  BigInt? bytesSent,  BigInt? bytesReceived,  double? totalRoundTripTime,  double? currentRoundTripTime,  double? availableOutgoingBitrate)?  rtcIceCandidatePairStats,TResult Function( BigInt? packetsSent,  BigInt? packetsReceived,  BigInt? bytesSent,  BigInt? bytesReceived,  IceRole? iceRole)?  rtcTransportStats,TResult Function( String? localId,  double? jitter,  double? roundTripTime,  double? fractionLost,  BigInt? reportsReceived,  int? roundTripTimeMeasurements)?  rtcRemoteInboundRtpStreamStats,TResult Function( String? localId,  double? remoteTimestamp,  BigInt? reportsSent)?  rtcRemoteOutboundRtpStreamStats,TResult Function()?  unimplemented,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RtcStatsType_RtcMediaSourceStats() when rtcMediaSourceStats != null:
return rtcMediaSourceStats(_that.trackIdentifier,_that.kind);case RtcStatsType_RtcIceCandidateStats() when rtcIceCandidateStats != null:
return rtcIceCandidateStats(_that.field0);case RtcStatsType_RtcOutboundRtpStreamStats() when rtcOutboundRtpStreamStats != null:
return rtcOutboundRtpStreamStats(_that.trackId,_that.mediaType,_that.bytesSent,_that.packetsSent,_that.mediaSourceId);case RtcStatsType_RtcInboundRtpStreamStats() when rtcInboundRtpStreamStats != null:
return rtcInboundRtpStreamStats(_that.remoteId,_that.bytesReceived,_that.packetsReceived,_that.packetsLost,_that.jitter,_that.totalDecodeTime,_that.jitterBufferEmittedCount,_that.mediaType);case RtcStatsType_RtcIceCandidatePairStats() when rtcIceCandidatePairStats != null:
return rtcIceCandidatePairStats(_that.state,_that.nominated,_that.bytesSent,_that.bytesReceived,_that.totalRoundTripTime,_that.currentRoundTripTime,_that.availableOutgoingBitrate);case RtcStatsType_RtcTransportStats() when rtcTransportStats != null:
return rtcTransportStats(_that.packetsSent,_that.packetsReceived,_that.bytesSent,_that.bytesReceived,_that.iceRole);case RtcStatsType_RtcRemoteInboundRtpStreamStats() when rtcRemoteInboundRtpStreamStats != null:
return rtcRemoteInboundRtpStreamStats(_that.localId,_that.jitter,_that.roundTripTime,_that.fractionLost,_that.reportsReceived,_that.roundTripTimeMeasurements);case RtcStatsType_RtcRemoteOutboundRtpStreamStats() when rtcRemoteOutboundRtpStreamStats != null:
return rtcRemoteOutboundRtpStreamStats(_that.localId,_that.remoteTimestamp,_that.reportsSent);case RtcStatsType_Unimplemented() when unimplemented != null:
return unimplemented();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? trackIdentifier,  RtcMediaSourceStatsMediaType kind)  rtcMediaSourceStats,required TResult Function( RtcIceCandidateStats field0)  rtcIceCandidateStats,required TResult Function( String? trackId,  RtcOutboundRtpStreamStatsMediaType mediaType,  BigInt? bytesSent,  int? packetsSent,  String? mediaSourceId)  rtcOutboundRtpStreamStats,required TResult Function( String? remoteId,  BigInt? bytesReceived,  int? packetsReceived,  BigInt? packetsLost,  double? jitter,  double? totalDecodeTime,  BigInt? jitterBufferEmittedCount,  RtcInboundRtpStreamMediaType? mediaType)  rtcInboundRtpStreamStats,required TResult Function( RtcStatsIceCandidatePairState state,  bool? nominated,  BigInt? bytesSent,  BigInt? bytesReceived,  double? totalRoundTripTime,  double? currentRoundTripTime,  double? availableOutgoingBitrate)  rtcIceCandidatePairStats,required TResult Function( BigInt? packetsSent,  BigInt? packetsReceived,  BigInt? bytesSent,  BigInt? bytesReceived,  IceRole? iceRole)  rtcTransportStats,required TResult Function( String? localId,  double? jitter,  double? roundTripTime,  double? fractionLost,  BigInt? reportsReceived,  int? roundTripTimeMeasurements)  rtcRemoteInboundRtpStreamStats,required TResult Function( String? localId,  double? remoteTimestamp,  BigInt? reportsSent)  rtcRemoteOutboundRtpStreamStats,required TResult Function()  unimplemented,}) {final _that = this;
switch (_that) {
case RtcStatsType_RtcMediaSourceStats():
return rtcMediaSourceStats(_that.trackIdentifier,_that.kind);case RtcStatsType_RtcIceCandidateStats():
return rtcIceCandidateStats(_that.field0);case RtcStatsType_RtcOutboundRtpStreamStats():
return rtcOutboundRtpStreamStats(_that.trackId,_that.mediaType,_that.bytesSent,_that.packetsSent,_that.mediaSourceId);case RtcStatsType_RtcInboundRtpStreamStats():
return rtcInboundRtpStreamStats(_that.remoteId,_that.bytesReceived,_that.packetsReceived,_that.packetsLost,_that.jitter,_that.totalDecodeTime,_that.jitterBufferEmittedCount,_that.mediaType);case RtcStatsType_RtcIceCandidatePairStats():
return rtcIceCandidatePairStats(_that.state,_that.nominated,_that.bytesSent,_that.bytesReceived,_that.totalRoundTripTime,_that.currentRoundTripTime,_that.availableOutgoingBitrate);case RtcStatsType_RtcTransportStats():
return rtcTransportStats(_that.packetsSent,_that.packetsReceived,_that.bytesSent,_that.bytesReceived,_that.iceRole);case RtcStatsType_RtcRemoteInboundRtpStreamStats():
return rtcRemoteInboundRtpStreamStats(_that.localId,_that.jitter,_that.roundTripTime,_that.fractionLost,_that.reportsReceived,_that.roundTripTimeMeasurements);case RtcStatsType_RtcRemoteOutboundRtpStreamStats():
return rtcRemoteOutboundRtpStreamStats(_that.localId,_that.remoteTimestamp,_that.reportsSent);case RtcStatsType_Unimplemented():
return unimplemented();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? trackIdentifier,  RtcMediaSourceStatsMediaType kind)?  rtcMediaSourceStats,TResult? Function( RtcIceCandidateStats field0)?  rtcIceCandidateStats,TResult? Function( String? trackId,  RtcOutboundRtpStreamStatsMediaType mediaType,  BigInt? bytesSent,  int? packetsSent,  String? mediaSourceId)?  rtcOutboundRtpStreamStats,TResult? Function( String? remoteId,  BigInt? bytesReceived,  int? packetsReceived,  BigInt? packetsLost,  double? jitter,  double? totalDecodeTime,  BigInt? jitterBufferEmittedCount,  RtcInboundRtpStreamMediaType? mediaType)?  rtcInboundRtpStreamStats,TResult? Function( RtcStatsIceCandidatePairState state,  bool? nominated,  BigInt? bytesSent,  BigInt? bytesReceived,  double? totalRoundTripTime,  double? currentRoundTripTime,  double? availableOutgoingBitrate)?  rtcIceCandidatePairStats,TResult? Function( BigInt? packetsSent,  BigInt? packetsReceived,  BigInt? bytesSent,  BigInt? bytesReceived,  IceRole? iceRole)?  rtcTransportStats,TResult? Function( String? localId,  double? jitter,  double? roundTripTime,  double? fractionLost,  BigInt? reportsReceived,  int? roundTripTimeMeasurements)?  rtcRemoteInboundRtpStreamStats,TResult? Function( String? localId,  double? remoteTimestamp,  BigInt? reportsSent)?  rtcRemoteOutboundRtpStreamStats,TResult? Function()?  unimplemented,}) {final _that = this;
switch (_that) {
case RtcStatsType_RtcMediaSourceStats() when rtcMediaSourceStats != null:
return rtcMediaSourceStats(_that.trackIdentifier,_that.kind);case RtcStatsType_RtcIceCandidateStats() when rtcIceCandidateStats != null:
return rtcIceCandidateStats(_that.field0);case RtcStatsType_RtcOutboundRtpStreamStats() when rtcOutboundRtpStreamStats != null:
return rtcOutboundRtpStreamStats(_that.trackId,_that.mediaType,_that.bytesSent,_that.packetsSent,_that.mediaSourceId);case RtcStatsType_RtcInboundRtpStreamStats() when rtcInboundRtpStreamStats != null:
return rtcInboundRtpStreamStats(_that.remoteId,_that.bytesReceived,_that.packetsReceived,_that.packetsLost,_that.jitter,_that.totalDecodeTime,_that.jitterBufferEmittedCount,_that.mediaType);case RtcStatsType_RtcIceCandidatePairStats() when rtcIceCandidatePairStats != null:
return rtcIceCandidatePairStats(_that.state,_that.nominated,_that.bytesSent,_that.bytesReceived,_that.totalRoundTripTime,_that.currentRoundTripTime,_that.availableOutgoingBitrate);case RtcStatsType_RtcTransportStats() when rtcTransportStats != null:
return rtcTransportStats(_that.packetsSent,_that.packetsReceived,_that.bytesSent,_that.bytesReceived,_that.iceRole);case RtcStatsType_RtcRemoteInboundRtpStreamStats() when rtcRemoteInboundRtpStreamStats != null:
return rtcRemoteInboundRtpStreamStats(_that.localId,_that.jitter,_that.roundTripTime,_that.fractionLost,_that.reportsReceived,_that.roundTripTimeMeasurements);case RtcStatsType_RtcRemoteOutboundRtpStreamStats() when rtcRemoteOutboundRtpStreamStats != null:
return rtcRemoteOutboundRtpStreamStats(_that.localId,_that.remoteTimestamp,_that.reportsSent);case RtcStatsType_Unimplemented() when unimplemented != null:
return unimplemented();case _:
  return null;

}
}

}

/// @nodoc


class RtcStatsType_RtcMediaSourceStats extends RtcStatsType {
  const RtcStatsType_RtcMediaSourceStats({this.trackIdentifier, required this.kind}): super._();
  

/// Value of the [MediaStreamTrack][1]'s ID attribute.
///
/// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
 final  String? trackIdentifier;
/// Fields which should be in these [`RtcStats`] based on their `kind`.
 final  RtcMediaSourceStatsMediaType kind;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcStatsType_RtcMediaSourceStatsCopyWith<RtcStatsType_RtcMediaSourceStats> get copyWith => _$RtcStatsType_RtcMediaSourceStatsCopyWithImpl<RtcStatsType_RtcMediaSourceStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcStatsType_RtcMediaSourceStats&&(identical(other.trackIdentifier, trackIdentifier) || other.trackIdentifier == trackIdentifier)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,trackIdentifier,kind);

@override
String toString() {
  return 'RtcStatsType.rtcMediaSourceStats(trackIdentifier: $trackIdentifier, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $RtcStatsType_RtcMediaSourceStatsCopyWith<$Res> implements $RtcStatsTypeCopyWith<$Res> {
  factory $RtcStatsType_RtcMediaSourceStatsCopyWith(RtcStatsType_RtcMediaSourceStats value, $Res Function(RtcStatsType_RtcMediaSourceStats) _then) = _$RtcStatsType_RtcMediaSourceStatsCopyWithImpl;
@useResult
$Res call({
 String? trackIdentifier, RtcMediaSourceStatsMediaType kind
});


$RtcMediaSourceStatsMediaTypeCopyWith<$Res> get kind;

}
/// @nodoc
class _$RtcStatsType_RtcMediaSourceStatsCopyWithImpl<$Res>
    implements $RtcStatsType_RtcMediaSourceStatsCopyWith<$Res> {
  _$RtcStatsType_RtcMediaSourceStatsCopyWithImpl(this._self, this._then);

  final RtcStatsType_RtcMediaSourceStats _self;
  final $Res Function(RtcStatsType_RtcMediaSourceStats) _then;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? trackIdentifier = freezed,Object? kind = null,}) {
  return _then(RtcStatsType_RtcMediaSourceStats(
trackIdentifier: freezed == trackIdentifier ? _self.trackIdentifier : trackIdentifier // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as RtcMediaSourceStatsMediaType,
  ));
}

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RtcMediaSourceStatsMediaTypeCopyWith<$Res> get kind {
  
  return $RtcMediaSourceStatsMediaTypeCopyWith<$Res>(_self.kind, (value) {
    return _then(_self.copyWith(kind: value));
  });
}
}

/// @nodoc


class RtcStatsType_RtcIceCandidateStats extends RtcStatsType {
  const RtcStatsType_RtcIceCandidateStats(this.field0): super._();
  

 final  RtcIceCandidateStats field0;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcStatsType_RtcIceCandidateStatsCopyWith<RtcStatsType_RtcIceCandidateStats> get copyWith => _$RtcStatsType_RtcIceCandidateStatsCopyWithImpl<RtcStatsType_RtcIceCandidateStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcStatsType_RtcIceCandidateStats&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'RtcStatsType.rtcIceCandidateStats(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $RtcStatsType_RtcIceCandidateStatsCopyWith<$Res> implements $RtcStatsTypeCopyWith<$Res> {
  factory $RtcStatsType_RtcIceCandidateStatsCopyWith(RtcStatsType_RtcIceCandidateStats value, $Res Function(RtcStatsType_RtcIceCandidateStats) _then) = _$RtcStatsType_RtcIceCandidateStatsCopyWithImpl;
@useResult
$Res call({
 RtcIceCandidateStats field0
});


$RtcIceCandidateStatsCopyWith<$Res> get field0;

}
/// @nodoc
class _$RtcStatsType_RtcIceCandidateStatsCopyWithImpl<$Res>
    implements $RtcStatsType_RtcIceCandidateStatsCopyWith<$Res> {
  _$RtcStatsType_RtcIceCandidateStatsCopyWithImpl(this._self, this._then);

  final RtcStatsType_RtcIceCandidateStats _self;
  final $Res Function(RtcStatsType_RtcIceCandidateStats) _then;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(RtcStatsType_RtcIceCandidateStats(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as RtcIceCandidateStats,
  ));
}

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RtcIceCandidateStatsCopyWith<$Res> get field0 {
  
  return $RtcIceCandidateStatsCopyWith<$Res>(_self.field0, (value) {
    return _then(_self.copyWith(field0: value));
  });
}
}

/// @nodoc


class RtcStatsType_RtcOutboundRtpStreamStats extends RtcStatsType {
  const RtcStatsType_RtcOutboundRtpStreamStats({this.trackId, required this.mediaType, this.bytesSent, this.packetsSent, this.mediaSourceId}): super._();
  

/// ID of the stats object representing the current track attachment to
/// the sender of the stream.
 final  String? trackId;
/// Fields which should be in these [`RtcStats`] based on their
/// `media_type`.
 final  RtcOutboundRtpStreamStatsMediaType mediaType;
/// Total number of bytes sent for this [SSRC].
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
 final  BigInt? bytesSent;
/// Total number of RTP packets sent for this [SSRC].
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
 final  int? packetsSent;
/// ID of the stats object representing the track currently attached to
/// the sender of the stream.
 final  String? mediaSourceId;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcStatsType_RtcOutboundRtpStreamStatsCopyWith<RtcStatsType_RtcOutboundRtpStreamStats> get copyWith => _$RtcStatsType_RtcOutboundRtpStreamStatsCopyWithImpl<RtcStatsType_RtcOutboundRtpStreamStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcStatsType_RtcOutboundRtpStreamStats&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.bytesSent, bytesSent) || other.bytesSent == bytesSent)&&(identical(other.packetsSent, packetsSent) || other.packetsSent == packetsSent)&&(identical(other.mediaSourceId, mediaSourceId) || other.mediaSourceId == mediaSourceId));
}


@override
int get hashCode => Object.hash(runtimeType,trackId,mediaType,bytesSent,packetsSent,mediaSourceId);

@override
String toString() {
  return 'RtcStatsType.rtcOutboundRtpStreamStats(trackId: $trackId, mediaType: $mediaType, bytesSent: $bytesSent, packetsSent: $packetsSent, mediaSourceId: $mediaSourceId)';
}


}

/// @nodoc
abstract mixin class $RtcStatsType_RtcOutboundRtpStreamStatsCopyWith<$Res> implements $RtcStatsTypeCopyWith<$Res> {
  factory $RtcStatsType_RtcOutboundRtpStreamStatsCopyWith(RtcStatsType_RtcOutboundRtpStreamStats value, $Res Function(RtcStatsType_RtcOutboundRtpStreamStats) _then) = _$RtcStatsType_RtcOutboundRtpStreamStatsCopyWithImpl;
@useResult
$Res call({
 String? trackId, RtcOutboundRtpStreamStatsMediaType mediaType, BigInt? bytesSent, int? packetsSent, String? mediaSourceId
});


$RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> get mediaType;

}
/// @nodoc
class _$RtcStatsType_RtcOutboundRtpStreamStatsCopyWithImpl<$Res>
    implements $RtcStatsType_RtcOutboundRtpStreamStatsCopyWith<$Res> {
  _$RtcStatsType_RtcOutboundRtpStreamStatsCopyWithImpl(this._self, this._then);

  final RtcStatsType_RtcOutboundRtpStreamStats _self;
  final $Res Function(RtcStatsType_RtcOutboundRtpStreamStats) _then;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? trackId = freezed,Object? mediaType = null,Object? bytesSent = freezed,Object? packetsSent = freezed,Object? mediaSourceId = freezed,}) {
  return _then(RtcStatsType_RtcOutboundRtpStreamStats(
trackId: freezed == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as RtcOutboundRtpStreamStatsMediaType,bytesSent: freezed == bytesSent ? _self.bytesSent : bytesSent // ignore: cast_nullable_to_non_nullable
as BigInt?,packetsSent: freezed == packetsSent ? _self.packetsSent : packetsSent // ignore: cast_nullable_to_non_nullable
as int?,mediaSourceId: freezed == mediaSourceId ? _self.mediaSourceId : mediaSourceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> get mediaType {
  
  return $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res>(_self.mediaType, (value) {
    return _then(_self.copyWith(mediaType: value));
  });
}
}

/// @nodoc


class RtcStatsType_RtcInboundRtpStreamStats extends RtcStatsType {
  const RtcStatsType_RtcInboundRtpStreamStats({this.remoteId, this.bytesReceived, this.packetsReceived, this.packetsLost, this.jitter, this.totalDecodeTime, this.jitterBufferEmittedCount, this.mediaType}): super._();
  

/// ID of the stats object representing the receiving track.
 final  String? remoteId;
/// Total number of bytes received for this [SSRC].
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
 final  BigInt? bytesReceived;
/// Total number of RTP data packets received for this [SSRC].
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
 final  int? packetsReceived;
/// Total number of RTP data packets for this [SSRC] that have been lost
/// since the beginning of reception.
///
/// This number is defined to be the number of packets expected less the
/// number of packets actually received, where the number of packets
/// received includes any which are late or duplicates. Thus, packets
/// that arrive late are not counted as lost, and the loss
/// **may be negative** if there are duplicates.
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
 final  BigInt? packetsLost;
/// Packet jitter measured in seconds for this [SSRC].
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
 final  double? jitter;
/// Total number of seconds that have been spent decoding the
/// [framesDecoded] frames of the stream.
///
/// The average decode time can be calculated by dividing this value
/// with [framesDecoded]. The time it takes to decode one frame is the
/// time passed between feeding the decoder a frame and the decoder
/// returning decoded data for that frame.
///
/// [framesDecoded]: https://tinyurl.com/srfwrwt
 final  double? totalDecodeTime;
/// Total number of audio samples or video frames that have come out of
/// the jitter buffer (increasing [jitterBufferDelay]).
///
/// [jitterBufferDelay]: https://tinyurl.com/qvoojt5
 final  BigInt? jitterBufferEmittedCount;
/// Fields which should be in these [`RtcStats`] based on their
/// `media_type`.
 final  RtcInboundRtpStreamMediaType? mediaType;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcStatsType_RtcInboundRtpStreamStatsCopyWith<RtcStatsType_RtcInboundRtpStreamStats> get copyWith => _$RtcStatsType_RtcInboundRtpStreamStatsCopyWithImpl<RtcStatsType_RtcInboundRtpStreamStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcStatsType_RtcInboundRtpStreamStats&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId)&&(identical(other.bytesReceived, bytesReceived) || other.bytesReceived == bytesReceived)&&(identical(other.packetsReceived, packetsReceived) || other.packetsReceived == packetsReceived)&&(identical(other.packetsLost, packetsLost) || other.packetsLost == packetsLost)&&(identical(other.jitter, jitter) || other.jitter == jitter)&&(identical(other.totalDecodeTime, totalDecodeTime) || other.totalDecodeTime == totalDecodeTime)&&(identical(other.jitterBufferEmittedCount, jitterBufferEmittedCount) || other.jitterBufferEmittedCount == jitterBufferEmittedCount)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType));
}


@override
int get hashCode => Object.hash(runtimeType,remoteId,bytesReceived,packetsReceived,packetsLost,jitter,totalDecodeTime,jitterBufferEmittedCount,mediaType);

@override
String toString() {
  return 'RtcStatsType.rtcInboundRtpStreamStats(remoteId: $remoteId, bytesReceived: $bytesReceived, packetsReceived: $packetsReceived, packetsLost: $packetsLost, jitter: $jitter, totalDecodeTime: $totalDecodeTime, jitterBufferEmittedCount: $jitterBufferEmittedCount, mediaType: $mediaType)';
}


}

/// @nodoc
abstract mixin class $RtcStatsType_RtcInboundRtpStreamStatsCopyWith<$Res> implements $RtcStatsTypeCopyWith<$Res> {
  factory $RtcStatsType_RtcInboundRtpStreamStatsCopyWith(RtcStatsType_RtcInboundRtpStreamStats value, $Res Function(RtcStatsType_RtcInboundRtpStreamStats) _then) = _$RtcStatsType_RtcInboundRtpStreamStatsCopyWithImpl;
@useResult
$Res call({
 String? remoteId, BigInt? bytesReceived, int? packetsReceived, BigInt? packetsLost, double? jitter, double? totalDecodeTime, BigInt? jitterBufferEmittedCount, RtcInboundRtpStreamMediaType? mediaType
});


$RtcInboundRtpStreamMediaTypeCopyWith<$Res>? get mediaType;

}
/// @nodoc
class _$RtcStatsType_RtcInboundRtpStreamStatsCopyWithImpl<$Res>
    implements $RtcStatsType_RtcInboundRtpStreamStatsCopyWith<$Res> {
  _$RtcStatsType_RtcInboundRtpStreamStatsCopyWithImpl(this._self, this._then);

  final RtcStatsType_RtcInboundRtpStreamStats _self;
  final $Res Function(RtcStatsType_RtcInboundRtpStreamStats) _then;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? remoteId = freezed,Object? bytesReceived = freezed,Object? packetsReceived = freezed,Object? packetsLost = freezed,Object? jitter = freezed,Object? totalDecodeTime = freezed,Object? jitterBufferEmittedCount = freezed,Object? mediaType = freezed,}) {
  return _then(RtcStatsType_RtcInboundRtpStreamStats(
remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as String?,bytesReceived: freezed == bytesReceived ? _self.bytesReceived : bytesReceived // ignore: cast_nullable_to_non_nullable
as BigInt?,packetsReceived: freezed == packetsReceived ? _self.packetsReceived : packetsReceived // ignore: cast_nullable_to_non_nullable
as int?,packetsLost: freezed == packetsLost ? _self.packetsLost : packetsLost // ignore: cast_nullable_to_non_nullable
as BigInt?,jitter: freezed == jitter ? _self.jitter : jitter // ignore: cast_nullable_to_non_nullable
as double?,totalDecodeTime: freezed == totalDecodeTime ? _self.totalDecodeTime : totalDecodeTime // ignore: cast_nullable_to_non_nullable
as double?,jitterBufferEmittedCount: freezed == jitterBufferEmittedCount ? _self.jitterBufferEmittedCount : jitterBufferEmittedCount // ignore: cast_nullable_to_non_nullable
as BigInt?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as RtcInboundRtpStreamMediaType?,
  ));
}

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RtcInboundRtpStreamMediaTypeCopyWith<$Res>? get mediaType {
    if (_self.mediaType == null) {
    return null;
  }

  return $RtcInboundRtpStreamMediaTypeCopyWith<$Res>(_self.mediaType!, (value) {
    return _then(_self.copyWith(mediaType: value));
  });
}
}

/// @nodoc


class RtcStatsType_RtcIceCandidatePairStats extends RtcStatsType {
  const RtcStatsType_RtcIceCandidatePairStats({required this.state, this.nominated, this.bytesSent, this.bytesReceived, this.totalRoundTripTime, this.currentRoundTripTime, this.availableOutgoingBitrate}): super._();
  

/// State of the checklist for the local and remote candidates in a
/// pair.
 final  RtcStatsIceCandidatePairState state;
/// Related to updating the nominated flag described in
/// [Section 7.1.3.2.4 of RFC 5245][1].
///
/// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.4
 final  bool? nominated;
/// Total number of payload bytes sent on this candidate pair, i.e. not
/// including headers or padding.
 final  BigInt? bytesSent;
/// Total number of payload bytes received on this candidate pair, i.e.
/// not including headers or padding.
 final  BigInt? bytesReceived;
/// Sum of all round trip time measurements in seconds since the
/// beginning of the session, based on STUN connectivity check
/// [STUN-PATH-CHAR] responses ([responsesReceived][2]), including those
/// that reply to requests that are sent in order to verify consent
/// [RFC 7675].
///
/// The average round trip time can be computed from
/// [totalRoundTripTime][1] by dividing it by [responsesReceived][2].
///
/// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats#bib-stun-path-char
/// [RFC 7675]: https://tools.ietf.org/html/rfc7675
/// [1]: https://tinyurl.com/tgr543a
/// [2]: https://tinyurl.com/r3zo2um
 final  double? totalRoundTripTime;
/// Latest round trip time measured in seconds, computed from both STUN
/// connectivity checks [STUN-PATH-CHAR], including those that are sent
/// for consent verification [RFC 7675].
///
/// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats#bib-stun-path-char
/// [RFC 7675]: https://tools.ietf.org/html/rfc7675
 final  double? currentRoundTripTime;
/// Calculated by the underlying congestion control by combining the
/// available bitrate for all the outgoing RTP streams using this
/// candidate pair. The bitrate measurement does not count the size of
/// the IP or other transport layers like TCP or UDP. It is similar to
/// the TIAS defined in [RFC 3890], i.e. it is measured in bits per
/// second and the bitrate is calculated over a 1 second window.
///
/// Implementations that do not calculate a sender-side estimate MUST
/// leave this undefined. Additionally, the value MUST be undefined for
/// candidate pairs that were never used. For pairs in use, the estimate
/// is normally no lower than the bitrate for the packets sent at
/// [lastPacketSentTimestamp][1], but might be higher. For candidate
/// pairs that are not currently in use but were used before,
/// implementations MUST return undefined.
///
/// [RFC 3890]: https://tools.ietf.org/html/rfc3890
/// [1]: https://tinyurl.com/rfc72eh
 final  double? availableOutgoingBitrate;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcStatsType_RtcIceCandidatePairStatsCopyWith<RtcStatsType_RtcIceCandidatePairStats> get copyWith => _$RtcStatsType_RtcIceCandidatePairStatsCopyWithImpl<RtcStatsType_RtcIceCandidatePairStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcStatsType_RtcIceCandidatePairStats&&(identical(other.state, state) || other.state == state)&&(identical(other.nominated, nominated) || other.nominated == nominated)&&(identical(other.bytesSent, bytesSent) || other.bytesSent == bytesSent)&&(identical(other.bytesReceived, bytesReceived) || other.bytesReceived == bytesReceived)&&(identical(other.totalRoundTripTime, totalRoundTripTime) || other.totalRoundTripTime == totalRoundTripTime)&&(identical(other.currentRoundTripTime, currentRoundTripTime) || other.currentRoundTripTime == currentRoundTripTime)&&(identical(other.availableOutgoingBitrate, availableOutgoingBitrate) || other.availableOutgoingBitrate == availableOutgoingBitrate));
}


@override
int get hashCode => Object.hash(runtimeType,state,nominated,bytesSent,bytesReceived,totalRoundTripTime,currentRoundTripTime,availableOutgoingBitrate);

@override
String toString() {
  return 'RtcStatsType.rtcIceCandidatePairStats(state: $state, nominated: $nominated, bytesSent: $bytesSent, bytesReceived: $bytesReceived, totalRoundTripTime: $totalRoundTripTime, currentRoundTripTime: $currentRoundTripTime, availableOutgoingBitrate: $availableOutgoingBitrate)';
}


}

/// @nodoc
abstract mixin class $RtcStatsType_RtcIceCandidatePairStatsCopyWith<$Res> implements $RtcStatsTypeCopyWith<$Res> {
  factory $RtcStatsType_RtcIceCandidatePairStatsCopyWith(RtcStatsType_RtcIceCandidatePairStats value, $Res Function(RtcStatsType_RtcIceCandidatePairStats) _then) = _$RtcStatsType_RtcIceCandidatePairStatsCopyWithImpl;
@useResult
$Res call({
 RtcStatsIceCandidatePairState state, bool? nominated, BigInt? bytesSent, BigInt? bytesReceived, double? totalRoundTripTime, double? currentRoundTripTime, double? availableOutgoingBitrate
});




}
/// @nodoc
class _$RtcStatsType_RtcIceCandidatePairStatsCopyWithImpl<$Res>
    implements $RtcStatsType_RtcIceCandidatePairStatsCopyWith<$Res> {
  _$RtcStatsType_RtcIceCandidatePairStatsCopyWithImpl(this._self, this._then);

  final RtcStatsType_RtcIceCandidatePairStats _self;
  final $Res Function(RtcStatsType_RtcIceCandidatePairStats) _then;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? state = null,Object? nominated = freezed,Object? bytesSent = freezed,Object? bytesReceived = freezed,Object? totalRoundTripTime = freezed,Object? currentRoundTripTime = freezed,Object? availableOutgoingBitrate = freezed,}) {
  return _then(RtcStatsType_RtcIceCandidatePairStats(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RtcStatsIceCandidatePairState,nominated: freezed == nominated ? _self.nominated : nominated // ignore: cast_nullable_to_non_nullable
as bool?,bytesSent: freezed == bytesSent ? _self.bytesSent : bytesSent // ignore: cast_nullable_to_non_nullable
as BigInt?,bytesReceived: freezed == bytesReceived ? _self.bytesReceived : bytesReceived // ignore: cast_nullable_to_non_nullable
as BigInt?,totalRoundTripTime: freezed == totalRoundTripTime ? _self.totalRoundTripTime : totalRoundTripTime // ignore: cast_nullable_to_non_nullable
as double?,currentRoundTripTime: freezed == currentRoundTripTime ? _self.currentRoundTripTime : currentRoundTripTime // ignore: cast_nullable_to_non_nullable
as double?,availableOutgoingBitrate: freezed == availableOutgoingBitrate ? _self.availableOutgoingBitrate : availableOutgoingBitrate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc


class RtcStatsType_RtcTransportStats extends RtcStatsType {
  const RtcStatsType_RtcTransportStats({this.packetsSent, this.packetsReceived, this.bytesSent, this.bytesReceived, this.iceRole}): super._();
  

/// Total number of packets sent over this transport.
 final  BigInt? packetsSent;
/// Total number of packets received on this transport.
 final  BigInt? packetsReceived;
/// Total number of payload bytes sent on this [RTCPeerConnection], i.e.
/// not including headers or padding.
///
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
 final  BigInt? bytesSent;
/// Total number of bytes received on this [RTCPeerConnection], i.e. not
/// including headers or padding.
///
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
 final  BigInt? bytesReceived;
/// Set to the current value of the [role][1] of the underlying
/// [RTCDtlsTransport][2]'s [transport][3].
///
/// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
/// [2]: https://w3.org/TR/webrtc#rtcdtlstransport-interface
/// [3]: https://w3.org/TR/webrtc#dom-rtcdtlstransport-icetransport
 final  IceRole? iceRole;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcStatsType_RtcTransportStatsCopyWith<RtcStatsType_RtcTransportStats> get copyWith => _$RtcStatsType_RtcTransportStatsCopyWithImpl<RtcStatsType_RtcTransportStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcStatsType_RtcTransportStats&&(identical(other.packetsSent, packetsSent) || other.packetsSent == packetsSent)&&(identical(other.packetsReceived, packetsReceived) || other.packetsReceived == packetsReceived)&&(identical(other.bytesSent, bytesSent) || other.bytesSent == bytesSent)&&(identical(other.bytesReceived, bytesReceived) || other.bytesReceived == bytesReceived)&&(identical(other.iceRole, iceRole) || other.iceRole == iceRole));
}


@override
int get hashCode => Object.hash(runtimeType,packetsSent,packetsReceived,bytesSent,bytesReceived,iceRole);

@override
String toString() {
  return 'RtcStatsType.rtcTransportStats(packetsSent: $packetsSent, packetsReceived: $packetsReceived, bytesSent: $bytesSent, bytesReceived: $bytesReceived, iceRole: $iceRole)';
}


}

/// @nodoc
abstract mixin class $RtcStatsType_RtcTransportStatsCopyWith<$Res> implements $RtcStatsTypeCopyWith<$Res> {
  factory $RtcStatsType_RtcTransportStatsCopyWith(RtcStatsType_RtcTransportStats value, $Res Function(RtcStatsType_RtcTransportStats) _then) = _$RtcStatsType_RtcTransportStatsCopyWithImpl;
@useResult
$Res call({
 BigInt? packetsSent, BigInt? packetsReceived, BigInt? bytesSent, BigInt? bytesReceived, IceRole? iceRole
});




}
/// @nodoc
class _$RtcStatsType_RtcTransportStatsCopyWithImpl<$Res>
    implements $RtcStatsType_RtcTransportStatsCopyWith<$Res> {
  _$RtcStatsType_RtcTransportStatsCopyWithImpl(this._self, this._then);

  final RtcStatsType_RtcTransportStats _self;
  final $Res Function(RtcStatsType_RtcTransportStats) _then;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetsSent = freezed,Object? packetsReceived = freezed,Object? bytesSent = freezed,Object? bytesReceived = freezed,Object? iceRole = freezed,}) {
  return _then(RtcStatsType_RtcTransportStats(
packetsSent: freezed == packetsSent ? _self.packetsSent : packetsSent // ignore: cast_nullable_to_non_nullable
as BigInt?,packetsReceived: freezed == packetsReceived ? _self.packetsReceived : packetsReceived // ignore: cast_nullable_to_non_nullable
as BigInt?,bytesSent: freezed == bytesSent ? _self.bytesSent : bytesSent // ignore: cast_nullable_to_non_nullable
as BigInt?,bytesReceived: freezed == bytesReceived ? _self.bytesReceived : bytesReceived // ignore: cast_nullable_to_non_nullable
as BigInt?,iceRole: freezed == iceRole ? _self.iceRole : iceRole // ignore: cast_nullable_to_non_nullable
as IceRole?,
  ));
}


}

/// @nodoc


class RtcStatsType_RtcRemoteInboundRtpStreamStats extends RtcStatsType {
  const RtcStatsType_RtcRemoteInboundRtpStreamStats({this.localId, this.jitter, this.roundTripTime, this.fractionLost, this.reportsReceived, this.roundTripTimeMeasurements}): super._();
  

/// [localId] is used for looking up the local
/// [RTCOutboundRtpStreamStats][1] object for the same [SSRC].
///
/// [localId]: https://tinyurl.com/r8uhbo9
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
/// [1]: https://w3.org/TR/webrtc-stats#dom-rtcoutboundrtpstreamstats
 final  String? localId;
/// Packet jitter measured in seconds for this [SSRC].
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
 final  double? jitter;
/// Estimated round trip time for this [SSRC] based on the RTCP
/// timestamps in the RTCP Receiver Report (RR) and measured in seconds.
/// Calculated as defined in [Section 6.4.1 of RFC 3550][1].
/// If no RTCP Receiver Report is received with a DLSR value other than
/// 0, the round trip time is left undefined.
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
/// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
 final  double? roundTripTime;
/// Fraction packet loss reported for this [SSRC].
/// Calculated as defined in [Section 6.4.1 of RFC 3550][1] and
/// [Appendix A.3][2].
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
/// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
/// [2]: https://tools.ietf.org/html/rfc3550#appendix-A.3
 final  double? fractionLost;
/// Total number of RTCP RR blocks received for this [SSRC].
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
 final  BigInt? reportsReceived;
/// Total number of RTCP RR blocks received for this [SSRC] that contain
/// a valid round trip time. This counter will increment if the
/// [roundTripTime] is undefined.
///
/// [roundTripTime]: https://tinyurl.com/ssg83hq
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
 final  int? roundTripTimeMeasurements;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWith<RtcStatsType_RtcRemoteInboundRtpStreamStats> get copyWith => _$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWithImpl<RtcStatsType_RtcRemoteInboundRtpStreamStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcStatsType_RtcRemoteInboundRtpStreamStats&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.jitter, jitter) || other.jitter == jitter)&&(identical(other.roundTripTime, roundTripTime) || other.roundTripTime == roundTripTime)&&(identical(other.fractionLost, fractionLost) || other.fractionLost == fractionLost)&&(identical(other.reportsReceived, reportsReceived) || other.reportsReceived == reportsReceived)&&(identical(other.roundTripTimeMeasurements, roundTripTimeMeasurements) || other.roundTripTimeMeasurements == roundTripTimeMeasurements));
}


@override
int get hashCode => Object.hash(runtimeType,localId,jitter,roundTripTime,fractionLost,reportsReceived,roundTripTimeMeasurements);

@override
String toString() {
  return 'RtcStatsType.rtcRemoteInboundRtpStreamStats(localId: $localId, jitter: $jitter, roundTripTime: $roundTripTime, fractionLost: $fractionLost, reportsReceived: $reportsReceived, roundTripTimeMeasurements: $roundTripTimeMeasurements)';
}


}

/// @nodoc
abstract mixin class $RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWith<$Res> implements $RtcStatsTypeCopyWith<$Res> {
  factory $RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWith(RtcStatsType_RtcRemoteInboundRtpStreamStats value, $Res Function(RtcStatsType_RtcRemoteInboundRtpStreamStats) _then) = _$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWithImpl;
@useResult
$Res call({
 String? localId, double? jitter, double? roundTripTime, double? fractionLost, BigInt? reportsReceived, int? roundTripTimeMeasurements
});




}
/// @nodoc
class _$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWithImpl<$Res>
    implements $RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWith<$Res> {
  _$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWithImpl(this._self, this._then);

  final RtcStatsType_RtcRemoteInboundRtpStreamStats _self;
  final $Res Function(RtcStatsType_RtcRemoteInboundRtpStreamStats) _then;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? localId = freezed,Object? jitter = freezed,Object? roundTripTime = freezed,Object? fractionLost = freezed,Object? reportsReceived = freezed,Object? roundTripTimeMeasurements = freezed,}) {
  return _then(RtcStatsType_RtcRemoteInboundRtpStreamStats(
localId: freezed == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as String?,jitter: freezed == jitter ? _self.jitter : jitter // ignore: cast_nullable_to_non_nullable
as double?,roundTripTime: freezed == roundTripTime ? _self.roundTripTime : roundTripTime // ignore: cast_nullable_to_non_nullable
as double?,fractionLost: freezed == fractionLost ? _self.fractionLost : fractionLost // ignore: cast_nullable_to_non_nullable
as double?,reportsReceived: freezed == reportsReceived ? _self.reportsReceived : reportsReceived // ignore: cast_nullable_to_non_nullable
as BigInt?,roundTripTimeMeasurements: freezed == roundTripTimeMeasurements ? _self.roundTripTimeMeasurements : roundTripTimeMeasurements // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class RtcStatsType_RtcRemoteOutboundRtpStreamStats extends RtcStatsType {
  const RtcStatsType_RtcRemoteOutboundRtpStreamStats({this.localId, this.remoteTimestamp, this.reportsSent}): super._();
  

/// [localId] is used for looking up the local
/// [RTCInboundRtpStreamStats][1] object for the same [SSRC].
///
/// [localId]: https://tinyurl.com/vu9tb2e
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
/// [1]: https://w3.org/TR/webrtc-stats#dom-rtcinboundrtpstreamstats
 final  String? localId;
/// [remoteTimestamp] (as [HIGHRES-TIME]) is the remote timestamp at
/// which these statistics were sent by the remote endpoint. This
/// differs from timestamp, which represents the time at which the
/// statistics were generated or received by the local endpoint. The
/// [remoteTimestamp], if present, is derived from the NTP timestamp in
/// an RTCP Sender Report (SR) block, which reflects the remote
/// endpoint's clock. That clock may not be synchronized with the local
/// clock.
///
/// [HIGRES-TIME]: https://w3.org/TR/webrtc-stats#bib-highres-time
/// [remoteTimestamp]: https://tinyurl.com/rzlhs87
 final  double? remoteTimestamp;
/// Total number of RTCP SR blocks sent for this [SSRC].
///
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
 final  BigInt? reportsSent;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWith<RtcStatsType_RtcRemoteOutboundRtpStreamStats> get copyWith => _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWithImpl<RtcStatsType_RtcRemoteOutboundRtpStreamStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcStatsType_RtcRemoteOutboundRtpStreamStats&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.remoteTimestamp, remoteTimestamp) || other.remoteTimestamp == remoteTimestamp)&&(identical(other.reportsSent, reportsSent) || other.reportsSent == reportsSent));
}


@override
int get hashCode => Object.hash(runtimeType,localId,remoteTimestamp,reportsSent);

@override
String toString() {
  return 'RtcStatsType.rtcRemoteOutboundRtpStreamStats(localId: $localId, remoteTimestamp: $remoteTimestamp, reportsSent: $reportsSent)';
}


}

/// @nodoc
abstract mixin class $RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWith<$Res> implements $RtcStatsTypeCopyWith<$Res> {
  factory $RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWith(RtcStatsType_RtcRemoteOutboundRtpStreamStats value, $Res Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats) _then) = _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWithImpl;
@useResult
$Res call({
 String? localId, double? remoteTimestamp, BigInt? reportsSent
});




}
/// @nodoc
class _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWithImpl<$Res>
    implements $RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWith<$Res> {
  _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWithImpl(this._self, this._then);

  final RtcStatsType_RtcRemoteOutboundRtpStreamStats _self;
  final $Res Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats) _then;

/// Create a copy of RtcStatsType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? localId = freezed,Object? remoteTimestamp = freezed,Object? reportsSent = freezed,}) {
  return _then(RtcStatsType_RtcRemoteOutboundRtpStreamStats(
localId: freezed == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as String?,remoteTimestamp: freezed == remoteTimestamp ? _self.remoteTimestamp : remoteTimestamp // ignore: cast_nullable_to_non_nullable
as double?,reportsSent: freezed == reportsSent ? _self.reportsSent : reportsSent // ignore: cast_nullable_to_non_nullable
as BigInt?,
  ));
}


}

/// @nodoc


class RtcStatsType_Unimplemented extends RtcStatsType {
  const RtcStatsType_Unimplemented(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RtcStatsType_Unimplemented);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RtcStatsType.unimplemented()';
}


}




// dart format on
