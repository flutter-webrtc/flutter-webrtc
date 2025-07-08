// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RtcStatsType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )
    rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )
    rtcOutboundRtpStreamStats,
    required TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )
    rtcInboundRtpStreamStats,
    required TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )
    rtcIceCandidatePairStats,
    required TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )
    rtcTransportStats,
    required TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult? Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult? Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult? Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult? Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcStatsType_RtcMediaSourceStats value)
    rtcMediaSourceStats,
    required TResult Function(RtcStatsType_RtcIceCandidateStats value)
    rtcIceCandidateStats,
    required TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)
    rtcOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)
    rtcInboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcIceCandidatePairStats value)
    rtcIceCandidatePairStats,
    required TResult Function(RtcStatsType_RtcTransportStats value)
    rtcTransportStats,
    required TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult? Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult? Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult? Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult? Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_Unimplemented value)? unimplemented,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function(RtcStatsType_Unimplemented value)? unimplemented,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RtcStatsTypeCopyWith<$Res> {
  factory $RtcStatsTypeCopyWith(
    RtcStatsType value,
    $Res Function(RtcStatsType) then,
  ) = _$RtcStatsTypeCopyWithImpl<$Res, RtcStatsType>;
}

/// @nodoc
class _$RtcStatsTypeCopyWithImpl<$Res, $Val extends RtcStatsType>
    implements $RtcStatsTypeCopyWith<$Res> {
  _$RtcStatsTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RtcStatsType_RtcMediaSourceStatsImplCopyWith<$Res> {
  factory _$$RtcStatsType_RtcMediaSourceStatsImplCopyWith(
    _$RtcStatsType_RtcMediaSourceStatsImpl value,
    $Res Function(_$RtcStatsType_RtcMediaSourceStatsImpl) then,
  ) = __$$RtcStatsType_RtcMediaSourceStatsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? trackIdentifier, RtcMediaSourceStatsMediaType kind});

  $RtcMediaSourceStatsMediaTypeCopyWith<$Res> get kind;
}

/// @nodoc
class __$$RtcStatsType_RtcMediaSourceStatsImplCopyWithImpl<$Res>
    extends
        _$RtcStatsTypeCopyWithImpl<$Res, _$RtcStatsType_RtcMediaSourceStatsImpl>
    implements _$$RtcStatsType_RtcMediaSourceStatsImplCopyWith<$Res> {
  __$$RtcStatsType_RtcMediaSourceStatsImplCopyWithImpl(
    _$RtcStatsType_RtcMediaSourceStatsImpl _value,
    $Res Function(_$RtcStatsType_RtcMediaSourceStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? trackIdentifier = freezed, Object? kind = null}) {
    return _then(
      _$RtcStatsType_RtcMediaSourceStatsImpl(
        trackIdentifier: freezed == trackIdentifier
            ? _value.trackIdentifier
            : trackIdentifier // ignore: cast_nullable_to_non_nullable
                  as String?,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as RtcMediaSourceStatsMediaType,
      ),
    );
  }

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RtcMediaSourceStatsMediaTypeCopyWith<$Res> get kind {
    return $RtcMediaSourceStatsMediaTypeCopyWith<$Res>(_value.kind, (value) {
      return _then(_value.copyWith(kind: value));
    });
  }
}

/// @nodoc

class _$RtcStatsType_RtcMediaSourceStatsImpl
    extends RtcStatsType_RtcMediaSourceStats {
  const _$RtcStatsType_RtcMediaSourceStatsImpl({
    this.trackIdentifier,
    required this.kind,
  }) : super._();

  /// Value of the [MediaStreamTrack][1]'s ID attribute.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  @override
  final String? trackIdentifier;

  /// Fields which should be in these [`RtcStats`] based on their `kind`.
  @override
  final RtcMediaSourceStatsMediaType kind;

  @override
  String toString() {
    return 'RtcStatsType.rtcMediaSourceStats(trackIdentifier: $trackIdentifier, kind: $kind)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcMediaSourceStatsImpl &&
            (identical(other.trackIdentifier, trackIdentifier) ||
                other.trackIdentifier == trackIdentifier) &&
            (identical(other.kind, kind) || other.kind == kind));
  }

  @override
  int get hashCode => Object.hash(runtimeType, trackIdentifier, kind);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcMediaSourceStatsImplCopyWith<
    _$RtcStatsType_RtcMediaSourceStatsImpl
  >
  get copyWith =>
      __$$RtcStatsType_RtcMediaSourceStatsImplCopyWithImpl<
        _$RtcStatsType_RtcMediaSourceStatsImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )
    rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )
    rtcOutboundRtpStreamStats,
    required TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )
    rtcInboundRtpStreamStats,
    required TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )
    rtcIceCandidatePairStats,
    required TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )
    rtcTransportStats,
    required TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcMediaSourceStats(trackIdentifier, kind);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult? Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult? Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult? Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult? Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcMediaSourceStats?.call(trackIdentifier, kind);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcMediaSourceStats != null) {
      return rtcMediaSourceStats(trackIdentifier, kind);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcStatsType_RtcMediaSourceStats value)
    rtcMediaSourceStats,
    required TResult Function(RtcStatsType_RtcIceCandidateStats value)
    rtcIceCandidateStats,
    required TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)
    rtcOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)
    rtcInboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcIceCandidatePairStats value)
    rtcIceCandidatePairStats,
    required TResult Function(RtcStatsType_RtcTransportStats value)
    rtcTransportStats,
    required TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) {
    return rtcMediaSourceStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult? Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult? Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult? Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult? Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_Unimplemented value)? unimplemented,
  }) {
    return rtcMediaSourceStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function(RtcStatsType_Unimplemented value)? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcMediaSourceStats != null) {
      return rtcMediaSourceStats(this);
    }
    return orElse();
  }
}

abstract class RtcStatsType_RtcMediaSourceStats extends RtcStatsType {
  const factory RtcStatsType_RtcMediaSourceStats({
    final String? trackIdentifier,
    required final RtcMediaSourceStatsMediaType kind,
  }) = _$RtcStatsType_RtcMediaSourceStatsImpl;
  const RtcStatsType_RtcMediaSourceStats._() : super._();

  /// Value of the [MediaStreamTrack][1]'s ID attribute.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  String? get trackIdentifier;

  /// Fields which should be in these [`RtcStats`] based on their `kind`.
  RtcMediaSourceStatsMediaType get kind;

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcStatsType_RtcMediaSourceStatsImplCopyWith<
    _$RtcStatsType_RtcMediaSourceStatsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcIceCandidateStatsImplCopyWith<$Res> {
  factory _$$RtcStatsType_RtcIceCandidateStatsImplCopyWith(
    _$RtcStatsType_RtcIceCandidateStatsImpl value,
    $Res Function(_$RtcStatsType_RtcIceCandidateStatsImpl) then,
  ) = __$$RtcStatsType_RtcIceCandidateStatsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({RtcIceCandidateStats field0});

  $RtcIceCandidateStatsCopyWith<$Res> get field0;
}

/// @nodoc
class __$$RtcStatsType_RtcIceCandidateStatsImplCopyWithImpl<$Res>
    extends
        _$RtcStatsTypeCopyWithImpl<
          $Res,
          _$RtcStatsType_RtcIceCandidateStatsImpl
        >
    implements _$$RtcStatsType_RtcIceCandidateStatsImplCopyWith<$Res> {
  __$$RtcStatsType_RtcIceCandidateStatsImplCopyWithImpl(
    _$RtcStatsType_RtcIceCandidateStatsImpl _value,
    $Res Function(_$RtcStatsType_RtcIceCandidateStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$RtcStatsType_RtcIceCandidateStatsImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as RtcIceCandidateStats,
      ),
    );
  }

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RtcIceCandidateStatsCopyWith<$Res> get field0 {
    return $RtcIceCandidateStatsCopyWith<$Res>(_value.field0, (value) {
      return _then(_value.copyWith(field0: value));
    });
  }
}

/// @nodoc

class _$RtcStatsType_RtcIceCandidateStatsImpl
    extends RtcStatsType_RtcIceCandidateStats {
  const _$RtcStatsType_RtcIceCandidateStatsImpl(this.field0) : super._();

  @override
  final RtcIceCandidateStats field0;

  @override
  String toString() {
    return 'RtcStatsType.rtcIceCandidateStats(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcIceCandidateStatsImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcIceCandidateStatsImplCopyWith<
    _$RtcStatsType_RtcIceCandidateStatsImpl
  >
  get copyWith =>
      __$$RtcStatsType_RtcIceCandidateStatsImplCopyWithImpl<
        _$RtcStatsType_RtcIceCandidateStatsImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )
    rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )
    rtcOutboundRtpStreamStats,
    required TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )
    rtcInboundRtpStreamStats,
    required TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )
    rtcIceCandidatePairStats,
    required TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )
    rtcTransportStats,
    required TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcIceCandidateStats(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult? Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult? Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult? Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult? Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcIceCandidateStats?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcIceCandidateStats != null) {
      return rtcIceCandidateStats(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcStatsType_RtcMediaSourceStats value)
    rtcMediaSourceStats,
    required TResult Function(RtcStatsType_RtcIceCandidateStats value)
    rtcIceCandidateStats,
    required TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)
    rtcOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)
    rtcInboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcIceCandidatePairStats value)
    rtcIceCandidatePairStats,
    required TResult Function(RtcStatsType_RtcTransportStats value)
    rtcTransportStats,
    required TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) {
    return rtcIceCandidateStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult? Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult? Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult? Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult? Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_Unimplemented value)? unimplemented,
  }) {
    return rtcIceCandidateStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function(RtcStatsType_Unimplemented value)? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcIceCandidateStats != null) {
      return rtcIceCandidateStats(this);
    }
    return orElse();
  }
}

abstract class RtcStatsType_RtcIceCandidateStats extends RtcStatsType {
  const factory RtcStatsType_RtcIceCandidateStats(
    final RtcIceCandidateStats field0,
  ) = _$RtcStatsType_RtcIceCandidateStatsImpl;
  const RtcStatsType_RtcIceCandidateStats._() : super._();

  RtcIceCandidateStats get field0;

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcStatsType_RtcIceCandidateStatsImplCopyWith<
    _$RtcStatsType_RtcIceCandidateStatsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcOutboundRtpStreamStatsImplCopyWith<$Res> {
  factory _$$RtcStatsType_RtcOutboundRtpStreamStatsImplCopyWith(
    _$RtcStatsType_RtcOutboundRtpStreamStatsImpl value,
    $Res Function(_$RtcStatsType_RtcOutboundRtpStreamStatsImpl) then,
  ) = __$$RtcStatsType_RtcOutboundRtpStreamStatsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String? trackId,
    RtcOutboundRtpStreamStatsMediaType mediaType,
    BigInt? bytesSent,
    int? packetsSent,
    String? mediaSourceId,
  });

  $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> get mediaType;
}

/// @nodoc
class __$$RtcStatsType_RtcOutboundRtpStreamStatsImplCopyWithImpl<$Res>
    extends
        _$RtcStatsTypeCopyWithImpl<
          $Res,
          _$RtcStatsType_RtcOutboundRtpStreamStatsImpl
        >
    implements _$$RtcStatsType_RtcOutboundRtpStreamStatsImplCopyWith<$Res> {
  __$$RtcStatsType_RtcOutboundRtpStreamStatsImplCopyWithImpl(
    _$RtcStatsType_RtcOutboundRtpStreamStatsImpl _value,
    $Res Function(_$RtcStatsType_RtcOutboundRtpStreamStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackId = freezed,
    Object? mediaType = null,
    Object? bytesSent = freezed,
    Object? packetsSent = freezed,
    Object? mediaSourceId = freezed,
  }) {
    return _then(
      _$RtcStatsType_RtcOutboundRtpStreamStatsImpl(
        trackId: freezed == trackId
            ? _value.trackId
            : trackId // ignore: cast_nullable_to_non_nullable
                  as String?,
        mediaType: null == mediaType
            ? _value.mediaType
            : mediaType // ignore: cast_nullable_to_non_nullable
                  as RtcOutboundRtpStreamStatsMediaType,
        bytesSent: freezed == bytesSent
            ? _value.bytesSent
            : bytesSent // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        packetsSent: freezed == packetsSent
            ? _value.packetsSent
            : packetsSent // ignore: cast_nullable_to_non_nullable
                  as int?,
        mediaSourceId: freezed == mediaSourceId
            ? _value.mediaSourceId
            : mediaSourceId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> get mediaType {
    return $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res>(_value.mediaType, (
      value,
    ) {
      return _then(_value.copyWith(mediaType: value));
    });
  }
}

/// @nodoc

class _$RtcStatsType_RtcOutboundRtpStreamStatsImpl
    extends RtcStatsType_RtcOutboundRtpStreamStats {
  const _$RtcStatsType_RtcOutboundRtpStreamStatsImpl({
    this.trackId,
    required this.mediaType,
    this.bytesSent,
    this.packetsSent,
    this.mediaSourceId,
  }) : super._();

  /// ID of the stats object representing the current track attachment to
  /// the sender of the stream.
  @override
  final String? trackId;

  /// Fields which should be in these [`RtcStats`] based on their
  /// `media_type`.
  @override
  final RtcOutboundRtpStreamStatsMediaType mediaType;

  /// Total number of bytes sent for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final BigInt? bytesSent;

  /// Total number of RTP packets sent for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final int? packetsSent;

  /// ID of the stats object representing the track currently attached to
  /// the sender of the stream.
  @override
  final String? mediaSourceId;

  @override
  String toString() {
    return 'RtcStatsType.rtcOutboundRtpStreamStats(trackId: $trackId, mediaType: $mediaType, bytesSent: $bytesSent, packetsSent: $packetsSent, mediaSourceId: $mediaSourceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcOutboundRtpStreamStatsImpl &&
            (identical(other.trackId, trackId) || other.trackId == trackId) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.bytesSent, bytesSent) ||
                other.bytesSent == bytesSent) &&
            (identical(other.packetsSent, packetsSent) ||
                other.packetsSent == packetsSent) &&
            (identical(other.mediaSourceId, mediaSourceId) ||
                other.mediaSourceId == mediaSourceId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trackId,
    mediaType,
    bytesSent,
    packetsSent,
    mediaSourceId,
  );

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcOutboundRtpStreamStatsImplCopyWith<
    _$RtcStatsType_RtcOutboundRtpStreamStatsImpl
  >
  get copyWith =>
      __$$RtcStatsType_RtcOutboundRtpStreamStatsImplCopyWithImpl<
        _$RtcStatsType_RtcOutboundRtpStreamStatsImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )
    rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )
    rtcOutboundRtpStreamStats,
    required TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )
    rtcInboundRtpStreamStats,
    required TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )
    rtcIceCandidatePairStats,
    required TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )
    rtcTransportStats,
    required TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcOutboundRtpStreamStats(
      trackId,
      mediaType,
      bytesSent,
      packetsSent,
      mediaSourceId,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult? Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult? Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult? Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult? Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcOutboundRtpStreamStats?.call(
      trackId,
      mediaType,
      bytesSent,
      packetsSent,
      mediaSourceId,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcOutboundRtpStreamStats != null) {
      return rtcOutboundRtpStreamStats(
        trackId,
        mediaType,
        bytesSent,
        packetsSent,
        mediaSourceId,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcStatsType_RtcMediaSourceStats value)
    rtcMediaSourceStats,
    required TResult Function(RtcStatsType_RtcIceCandidateStats value)
    rtcIceCandidateStats,
    required TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)
    rtcOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)
    rtcInboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcIceCandidatePairStats value)
    rtcIceCandidatePairStats,
    required TResult Function(RtcStatsType_RtcTransportStats value)
    rtcTransportStats,
    required TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) {
    return rtcOutboundRtpStreamStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult? Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult? Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult? Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult? Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_Unimplemented value)? unimplemented,
  }) {
    return rtcOutboundRtpStreamStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function(RtcStatsType_Unimplemented value)? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcOutboundRtpStreamStats != null) {
      return rtcOutboundRtpStreamStats(this);
    }
    return orElse();
  }
}

abstract class RtcStatsType_RtcOutboundRtpStreamStats extends RtcStatsType {
  const factory RtcStatsType_RtcOutboundRtpStreamStats({
    final String? trackId,
    required final RtcOutboundRtpStreamStatsMediaType mediaType,
    final BigInt? bytesSent,
    final int? packetsSent,
    final String? mediaSourceId,
  }) = _$RtcStatsType_RtcOutboundRtpStreamStatsImpl;
  const RtcStatsType_RtcOutboundRtpStreamStats._() : super._();

  /// ID of the stats object representing the current track attachment to
  /// the sender of the stream.
  String? get trackId;

  /// Fields which should be in these [`RtcStats`] based on their
  /// `media_type`.
  RtcOutboundRtpStreamStatsMediaType get mediaType;

  /// Total number of bytes sent for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  BigInt? get bytesSent;

  /// Total number of RTP packets sent for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? get packetsSent;

  /// ID of the stats object representing the track currently attached to
  /// the sender of the stream.
  String? get mediaSourceId;

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcStatsType_RtcOutboundRtpStreamStatsImplCopyWith<
    _$RtcStatsType_RtcOutboundRtpStreamStatsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcInboundRtpStreamStatsImplCopyWith<$Res> {
  factory _$$RtcStatsType_RtcInboundRtpStreamStatsImplCopyWith(
    _$RtcStatsType_RtcInboundRtpStreamStatsImpl value,
    $Res Function(_$RtcStatsType_RtcInboundRtpStreamStatsImpl) then,
  ) = __$$RtcStatsType_RtcInboundRtpStreamStatsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String? remoteId,
    BigInt? bytesReceived,
    int? packetsReceived,
    BigInt? packetsLost,
    double? jitter,
    double? totalDecodeTime,
    BigInt? jitterBufferEmittedCount,
    RtcInboundRtpStreamMediaType? mediaType,
  });

  $RtcInboundRtpStreamMediaTypeCopyWith<$Res>? get mediaType;
}

/// @nodoc
class __$$RtcStatsType_RtcInboundRtpStreamStatsImplCopyWithImpl<$Res>
    extends
        _$RtcStatsTypeCopyWithImpl<
          $Res,
          _$RtcStatsType_RtcInboundRtpStreamStatsImpl
        >
    implements _$$RtcStatsType_RtcInboundRtpStreamStatsImplCopyWith<$Res> {
  __$$RtcStatsType_RtcInboundRtpStreamStatsImplCopyWithImpl(
    _$RtcStatsType_RtcInboundRtpStreamStatsImpl _value,
    $Res Function(_$RtcStatsType_RtcInboundRtpStreamStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remoteId = freezed,
    Object? bytesReceived = freezed,
    Object? packetsReceived = freezed,
    Object? packetsLost = freezed,
    Object? jitter = freezed,
    Object? totalDecodeTime = freezed,
    Object? jitterBufferEmittedCount = freezed,
    Object? mediaType = freezed,
  }) {
    return _then(
      _$RtcStatsType_RtcInboundRtpStreamStatsImpl(
        remoteId: freezed == remoteId
            ? _value.remoteId
            : remoteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        bytesReceived: freezed == bytesReceived
            ? _value.bytesReceived
            : bytesReceived // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        packetsReceived: freezed == packetsReceived
            ? _value.packetsReceived
            : packetsReceived // ignore: cast_nullable_to_non_nullable
                  as int?,
        packetsLost: freezed == packetsLost
            ? _value.packetsLost
            : packetsLost // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        jitter: freezed == jitter
            ? _value.jitter
            : jitter // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalDecodeTime: freezed == totalDecodeTime
            ? _value.totalDecodeTime
            : totalDecodeTime // ignore: cast_nullable_to_non_nullable
                  as double?,
        jitterBufferEmittedCount: freezed == jitterBufferEmittedCount
            ? _value.jitterBufferEmittedCount
            : jitterBufferEmittedCount // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        mediaType: freezed == mediaType
            ? _value.mediaType
            : mediaType // ignore: cast_nullable_to_non_nullable
                  as RtcInboundRtpStreamMediaType?,
      ),
    );
  }

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RtcInboundRtpStreamMediaTypeCopyWith<$Res>? get mediaType {
    if (_value.mediaType == null) {
      return null;
    }

    return $RtcInboundRtpStreamMediaTypeCopyWith<$Res>(_value.mediaType!, (
      value,
    ) {
      return _then(_value.copyWith(mediaType: value));
    });
  }
}

/// @nodoc

class _$RtcStatsType_RtcInboundRtpStreamStatsImpl
    extends RtcStatsType_RtcInboundRtpStreamStats {
  const _$RtcStatsType_RtcInboundRtpStreamStatsImpl({
    this.remoteId,
    this.bytesReceived,
    this.packetsReceived,
    this.packetsLost,
    this.jitter,
    this.totalDecodeTime,
    this.jitterBufferEmittedCount,
    this.mediaType,
  }) : super._();

  /// ID of the stats object representing the receiving track.
  @override
  final String? remoteId;

  /// Total number of bytes received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final BigInt? bytesReceived;

  /// Total number of RTP data packets received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final int? packetsReceived;

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
  @override
  final BigInt? packetsLost;

  /// Packet jitter measured in seconds for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final double? jitter;

  /// Total number of seconds that have been spent decoding the
  /// [framesDecoded] frames of the stream.
  ///
  /// The average decode time can be calculated by dividing this value
  /// with [framesDecoded]. The time it takes to decode one frame is the
  /// time passed between feeding the decoder a frame and the decoder
  /// returning decoded data for that frame.
  ///
  /// [framesDecoded]: https://tinyurl.com/srfwrwt
  @override
  final double? totalDecodeTime;

  /// Total number of audio samples or video frames that have come out of
  /// the jitter buffer (increasing [jitterBufferDelay]).
  ///
  /// [jitterBufferDelay]: https://tinyurl.com/qvoojt5
  @override
  final BigInt? jitterBufferEmittedCount;

  /// Fields which should be in these [`RtcStats`] based on their
  /// `media_type`.
  @override
  final RtcInboundRtpStreamMediaType? mediaType;

  @override
  String toString() {
    return 'RtcStatsType.rtcInboundRtpStreamStats(remoteId: $remoteId, bytesReceived: $bytesReceived, packetsReceived: $packetsReceived, packetsLost: $packetsLost, jitter: $jitter, totalDecodeTime: $totalDecodeTime, jitterBufferEmittedCount: $jitterBufferEmittedCount, mediaType: $mediaType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcInboundRtpStreamStatsImpl &&
            (identical(other.remoteId, remoteId) ||
                other.remoteId == remoteId) &&
            (identical(other.bytesReceived, bytesReceived) ||
                other.bytesReceived == bytesReceived) &&
            (identical(other.packetsReceived, packetsReceived) ||
                other.packetsReceived == packetsReceived) &&
            (identical(other.packetsLost, packetsLost) ||
                other.packetsLost == packetsLost) &&
            (identical(other.jitter, jitter) || other.jitter == jitter) &&
            (identical(other.totalDecodeTime, totalDecodeTime) ||
                other.totalDecodeTime == totalDecodeTime) &&
            (identical(
                  other.jitterBufferEmittedCount,
                  jitterBufferEmittedCount,
                ) ||
                other.jitterBufferEmittedCount == jitterBufferEmittedCount) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    remoteId,
    bytesReceived,
    packetsReceived,
    packetsLost,
    jitter,
    totalDecodeTime,
    jitterBufferEmittedCount,
    mediaType,
  );

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcInboundRtpStreamStatsImplCopyWith<
    _$RtcStatsType_RtcInboundRtpStreamStatsImpl
  >
  get copyWith =>
      __$$RtcStatsType_RtcInboundRtpStreamStatsImplCopyWithImpl<
        _$RtcStatsType_RtcInboundRtpStreamStatsImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )
    rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )
    rtcOutboundRtpStreamStats,
    required TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )
    rtcInboundRtpStreamStats,
    required TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )
    rtcIceCandidatePairStats,
    required TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )
    rtcTransportStats,
    required TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcInboundRtpStreamStats(
      remoteId,
      bytesReceived,
      packetsReceived,
      packetsLost,
      jitter,
      totalDecodeTime,
      jitterBufferEmittedCount,
      mediaType,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult? Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult? Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult? Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult? Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcInboundRtpStreamStats?.call(
      remoteId,
      bytesReceived,
      packetsReceived,
      packetsLost,
      jitter,
      totalDecodeTime,
      jitterBufferEmittedCount,
      mediaType,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcInboundRtpStreamStats != null) {
      return rtcInboundRtpStreamStats(
        remoteId,
        bytesReceived,
        packetsReceived,
        packetsLost,
        jitter,
        totalDecodeTime,
        jitterBufferEmittedCount,
        mediaType,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcStatsType_RtcMediaSourceStats value)
    rtcMediaSourceStats,
    required TResult Function(RtcStatsType_RtcIceCandidateStats value)
    rtcIceCandidateStats,
    required TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)
    rtcOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)
    rtcInboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcIceCandidatePairStats value)
    rtcIceCandidatePairStats,
    required TResult Function(RtcStatsType_RtcTransportStats value)
    rtcTransportStats,
    required TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) {
    return rtcInboundRtpStreamStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult? Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult? Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult? Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult? Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_Unimplemented value)? unimplemented,
  }) {
    return rtcInboundRtpStreamStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function(RtcStatsType_Unimplemented value)? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcInboundRtpStreamStats != null) {
      return rtcInboundRtpStreamStats(this);
    }
    return orElse();
  }
}

abstract class RtcStatsType_RtcInboundRtpStreamStats extends RtcStatsType {
  const factory RtcStatsType_RtcInboundRtpStreamStats({
    final String? remoteId,
    final BigInt? bytesReceived,
    final int? packetsReceived,
    final BigInt? packetsLost,
    final double? jitter,
    final double? totalDecodeTime,
    final BigInt? jitterBufferEmittedCount,
    final RtcInboundRtpStreamMediaType? mediaType,
  }) = _$RtcStatsType_RtcInboundRtpStreamStatsImpl;
  const RtcStatsType_RtcInboundRtpStreamStats._() : super._();

  /// ID of the stats object representing the receiving track.
  String? get remoteId;

  /// Total number of bytes received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  BigInt? get bytesReceived;

  /// Total number of RTP data packets received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? get packetsReceived;

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
  BigInt? get packetsLost;

  /// Packet jitter measured in seconds for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  double? get jitter;

  /// Total number of seconds that have been spent decoding the
  /// [framesDecoded] frames of the stream.
  ///
  /// The average decode time can be calculated by dividing this value
  /// with [framesDecoded]. The time it takes to decode one frame is the
  /// time passed between feeding the decoder a frame and the decoder
  /// returning decoded data for that frame.
  ///
  /// [framesDecoded]: https://tinyurl.com/srfwrwt
  double? get totalDecodeTime;

  /// Total number of audio samples or video frames that have come out of
  /// the jitter buffer (increasing [jitterBufferDelay]).
  ///
  /// [jitterBufferDelay]: https://tinyurl.com/qvoojt5
  BigInt? get jitterBufferEmittedCount;

  /// Fields which should be in these [`RtcStats`] based on their
  /// `media_type`.
  RtcInboundRtpStreamMediaType? get mediaType;

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcStatsType_RtcInboundRtpStreamStatsImplCopyWith<
    _$RtcStatsType_RtcInboundRtpStreamStatsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcIceCandidatePairStatsImplCopyWith<$Res> {
  factory _$$RtcStatsType_RtcIceCandidatePairStatsImplCopyWith(
    _$RtcStatsType_RtcIceCandidatePairStatsImpl value,
    $Res Function(_$RtcStatsType_RtcIceCandidatePairStatsImpl) then,
  ) = __$$RtcStatsType_RtcIceCandidatePairStatsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    RtcStatsIceCandidatePairState state,
    bool? nominated,
    BigInt? bytesSent,
    BigInt? bytesReceived,
    double? totalRoundTripTime,
    double? currentRoundTripTime,
    double? availableOutgoingBitrate,
  });
}

/// @nodoc
class __$$RtcStatsType_RtcIceCandidatePairStatsImplCopyWithImpl<$Res>
    extends
        _$RtcStatsTypeCopyWithImpl<
          $Res,
          _$RtcStatsType_RtcIceCandidatePairStatsImpl
        >
    implements _$$RtcStatsType_RtcIceCandidatePairStatsImplCopyWith<$Res> {
  __$$RtcStatsType_RtcIceCandidatePairStatsImplCopyWithImpl(
    _$RtcStatsType_RtcIceCandidatePairStatsImpl _value,
    $Res Function(_$RtcStatsType_RtcIceCandidatePairStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? nominated = freezed,
    Object? bytesSent = freezed,
    Object? bytesReceived = freezed,
    Object? totalRoundTripTime = freezed,
    Object? currentRoundTripTime = freezed,
    Object? availableOutgoingBitrate = freezed,
  }) {
    return _then(
      _$RtcStatsType_RtcIceCandidatePairStatsImpl(
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as RtcStatsIceCandidatePairState,
        nominated: freezed == nominated
            ? _value.nominated
            : nominated // ignore: cast_nullable_to_non_nullable
                  as bool?,
        bytesSent: freezed == bytesSent
            ? _value.bytesSent
            : bytesSent // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        bytesReceived: freezed == bytesReceived
            ? _value.bytesReceived
            : bytesReceived // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        totalRoundTripTime: freezed == totalRoundTripTime
            ? _value.totalRoundTripTime
            : totalRoundTripTime // ignore: cast_nullable_to_non_nullable
                  as double?,
        currentRoundTripTime: freezed == currentRoundTripTime
            ? _value.currentRoundTripTime
            : currentRoundTripTime // ignore: cast_nullable_to_non_nullable
                  as double?,
        availableOutgoingBitrate: freezed == availableOutgoingBitrate
            ? _value.availableOutgoingBitrate
            : availableOutgoingBitrate // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc

class _$RtcStatsType_RtcIceCandidatePairStatsImpl
    extends RtcStatsType_RtcIceCandidatePairStats {
  const _$RtcStatsType_RtcIceCandidatePairStatsImpl({
    required this.state,
    this.nominated,
    this.bytesSent,
    this.bytesReceived,
    this.totalRoundTripTime,
    this.currentRoundTripTime,
    this.availableOutgoingBitrate,
  }) : super._();

  /// State of the checklist for the local and remote candidates in a
  /// pair.
  @override
  final RtcStatsIceCandidatePairState state;

  /// Related to updating the nominated flag described in
  /// [Section 7.1.3.2.4 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.4
  @override
  final bool? nominated;

  /// Total number of payload bytes sent on this candidate pair, i.e. not
  /// including headers or padding.
  @override
  final BigInt? bytesSent;

  /// Total number of payload bytes received on this candidate pair, i.e.
  /// not including headers or padding.
  @override
  final BigInt? bytesReceived;

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
  @override
  final double? totalRoundTripTime;

  /// Latest round trip time measured in seconds, computed from both STUN
  /// connectivity checks [STUN-PATH-CHAR], including those that are sent
  /// for consent verification [RFC 7675].
  ///
  /// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats#bib-stun-path-char
  /// [RFC 7675]: https://tools.ietf.org/html/rfc7675
  @override
  final double? currentRoundTripTime;

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
  @override
  final double? availableOutgoingBitrate;

  @override
  String toString() {
    return 'RtcStatsType.rtcIceCandidatePairStats(state: $state, nominated: $nominated, bytesSent: $bytesSent, bytesReceived: $bytesReceived, totalRoundTripTime: $totalRoundTripTime, currentRoundTripTime: $currentRoundTripTime, availableOutgoingBitrate: $availableOutgoingBitrate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcIceCandidatePairStatsImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.nominated, nominated) ||
                other.nominated == nominated) &&
            (identical(other.bytesSent, bytesSent) ||
                other.bytesSent == bytesSent) &&
            (identical(other.bytesReceived, bytesReceived) ||
                other.bytesReceived == bytesReceived) &&
            (identical(other.totalRoundTripTime, totalRoundTripTime) ||
                other.totalRoundTripTime == totalRoundTripTime) &&
            (identical(other.currentRoundTripTime, currentRoundTripTime) ||
                other.currentRoundTripTime == currentRoundTripTime) &&
            (identical(
                  other.availableOutgoingBitrate,
                  availableOutgoingBitrate,
                ) ||
                other.availableOutgoingBitrate == availableOutgoingBitrate));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    state,
    nominated,
    bytesSent,
    bytesReceived,
    totalRoundTripTime,
    currentRoundTripTime,
    availableOutgoingBitrate,
  );

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcIceCandidatePairStatsImplCopyWith<
    _$RtcStatsType_RtcIceCandidatePairStatsImpl
  >
  get copyWith =>
      __$$RtcStatsType_RtcIceCandidatePairStatsImplCopyWithImpl<
        _$RtcStatsType_RtcIceCandidatePairStatsImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )
    rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )
    rtcOutboundRtpStreamStats,
    required TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )
    rtcInboundRtpStreamStats,
    required TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )
    rtcIceCandidatePairStats,
    required TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )
    rtcTransportStats,
    required TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcIceCandidatePairStats(
      state,
      nominated,
      bytesSent,
      bytesReceived,
      totalRoundTripTime,
      currentRoundTripTime,
      availableOutgoingBitrate,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult? Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult? Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult? Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult? Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcIceCandidatePairStats?.call(
      state,
      nominated,
      bytesSent,
      bytesReceived,
      totalRoundTripTime,
      currentRoundTripTime,
      availableOutgoingBitrate,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcIceCandidatePairStats != null) {
      return rtcIceCandidatePairStats(
        state,
        nominated,
        bytesSent,
        bytesReceived,
        totalRoundTripTime,
        currentRoundTripTime,
        availableOutgoingBitrate,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcStatsType_RtcMediaSourceStats value)
    rtcMediaSourceStats,
    required TResult Function(RtcStatsType_RtcIceCandidateStats value)
    rtcIceCandidateStats,
    required TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)
    rtcOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)
    rtcInboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcIceCandidatePairStats value)
    rtcIceCandidatePairStats,
    required TResult Function(RtcStatsType_RtcTransportStats value)
    rtcTransportStats,
    required TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) {
    return rtcIceCandidatePairStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult? Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult? Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult? Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult? Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_Unimplemented value)? unimplemented,
  }) {
    return rtcIceCandidatePairStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function(RtcStatsType_Unimplemented value)? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcIceCandidatePairStats != null) {
      return rtcIceCandidatePairStats(this);
    }
    return orElse();
  }
}

abstract class RtcStatsType_RtcIceCandidatePairStats extends RtcStatsType {
  const factory RtcStatsType_RtcIceCandidatePairStats({
    required final RtcStatsIceCandidatePairState state,
    final bool? nominated,
    final BigInt? bytesSent,
    final BigInt? bytesReceived,
    final double? totalRoundTripTime,
    final double? currentRoundTripTime,
    final double? availableOutgoingBitrate,
  }) = _$RtcStatsType_RtcIceCandidatePairStatsImpl;
  const RtcStatsType_RtcIceCandidatePairStats._() : super._();

  /// State of the checklist for the local and remote candidates in a
  /// pair.
  RtcStatsIceCandidatePairState get state;

  /// Related to updating the nominated flag described in
  /// [Section 7.1.3.2.4 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.4
  bool? get nominated;

  /// Total number of payload bytes sent on this candidate pair, i.e. not
  /// including headers or padding.
  BigInt? get bytesSent;

  /// Total number of payload bytes received on this candidate pair, i.e.
  /// not including headers or padding.
  BigInt? get bytesReceived;

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
  double? get totalRoundTripTime;

  /// Latest round trip time measured in seconds, computed from both STUN
  /// connectivity checks [STUN-PATH-CHAR], including those that are sent
  /// for consent verification [RFC 7675].
  ///
  /// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats#bib-stun-path-char
  /// [RFC 7675]: https://tools.ietf.org/html/rfc7675
  double? get currentRoundTripTime;

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
  double? get availableOutgoingBitrate;

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcStatsType_RtcIceCandidatePairStatsImplCopyWith<
    _$RtcStatsType_RtcIceCandidatePairStatsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcTransportStatsImplCopyWith<$Res> {
  factory _$$RtcStatsType_RtcTransportStatsImplCopyWith(
    _$RtcStatsType_RtcTransportStatsImpl value,
    $Res Function(_$RtcStatsType_RtcTransportStatsImpl) then,
  ) = __$$RtcStatsType_RtcTransportStatsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    BigInt? packetsSent,
    BigInt? packetsReceived,
    BigInt? bytesSent,
    BigInt? bytesReceived,
    IceRole? iceRole,
  });
}

/// @nodoc
class __$$RtcStatsType_RtcTransportStatsImplCopyWithImpl<$Res>
    extends
        _$RtcStatsTypeCopyWithImpl<$Res, _$RtcStatsType_RtcTransportStatsImpl>
    implements _$$RtcStatsType_RtcTransportStatsImplCopyWith<$Res> {
  __$$RtcStatsType_RtcTransportStatsImplCopyWithImpl(
    _$RtcStatsType_RtcTransportStatsImpl _value,
    $Res Function(_$RtcStatsType_RtcTransportStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packetsSent = freezed,
    Object? packetsReceived = freezed,
    Object? bytesSent = freezed,
    Object? bytesReceived = freezed,
    Object? iceRole = freezed,
  }) {
    return _then(
      _$RtcStatsType_RtcTransportStatsImpl(
        packetsSent: freezed == packetsSent
            ? _value.packetsSent
            : packetsSent // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        packetsReceived: freezed == packetsReceived
            ? _value.packetsReceived
            : packetsReceived // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        bytesSent: freezed == bytesSent
            ? _value.bytesSent
            : bytesSent // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        bytesReceived: freezed == bytesReceived
            ? _value.bytesReceived
            : bytesReceived // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        iceRole: freezed == iceRole
            ? _value.iceRole
            : iceRole // ignore: cast_nullable_to_non_nullable
                  as IceRole?,
      ),
    );
  }
}

/// @nodoc

class _$RtcStatsType_RtcTransportStatsImpl
    extends RtcStatsType_RtcTransportStats {
  const _$RtcStatsType_RtcTransportStatsImpl({
    this.packetsSent,
    this.packetsReceived,
    this.bytesSent,
    this.bytesReceived,
    this.iceRole,
  }) : super._();

  /// Total number of packets sent over this transport.
  @override
  final BigInt? packetsSent;

  /// Total number of packets received on this transport.
  @override
  final BigInt? packetsReceived;

  /// Total number of payload bytes sent on this [RTCPeerConnection], i.e.
  /// not including headers or padding.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  @override
  final BigInt? bytesSent;

  /// Total number of bytes received on this [RTCPeerConnection], i.e. not
  /// including headers or padding.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  @override
  final BigInt? bytesReceived;

  /// Set to the current value of the [role][1] of the underlying
  /// [RTCDtlsTransport][2]'s [transport][3].
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
  /// [2]: https://w3.org/TR/webrtc#rtcdtlstransport-interface
  /// [3]: https://w3.org/TR/webrtc#dom-rtcdtlstransport-icetransport
  @override
  final IceRole? iceRole;

  @override
  String toString() {
    return 'RtcStatsType.rtcTransportStats(packetsSent: $packetsSent, packetsReceived: $packetsReceived, bytesSent: $bytesSent, bytesReceived: $bytesReceived, iceRole: $iceRole)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcTransportStatsImpl &&
            (identical(other.packetsSent, packetsSent) ||
                other.packetsSent == packetsSent) &&
            (identical(other.packetsReceived, packetsReceived) ||
                other.packetsReceived == packetsReceived) &&
            (identical(other.bytesSent, bytesSent) ||
                other.bytesSent == bytesSent) &&
            (identical(other.bytesReceived, bytesReceived) ||
                other.bytesReceived == bytesReceived) &&
            (identical(other.iceRole, iceRole) || other.iceRole == iceRole));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    packetsSent,
    packetsReceived,
    bytesSent,
    bytesReceived,
    iceRole,
  );

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcTransportStatsImplCopyWith<
    _$RtcStatsType_RtcTransportStatsImpl
  >
  get copyWith =>
      __$$RtcStatsType_RtcTransportStatsImplCopyWithImpl<
        _$RtcStatsType_RtcTransportStatsImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )
    rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )
    rtcOutboundRtpStreamStats,
    required TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )
    rtcInboundRtpStreamStats,
    required TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )
    rtcIceCandidatePairStats,
    required TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )
    rtcTransportStats,
    required TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcTransportStats(
      packetsSent,
      packetsReceived,
      bytesSent,
      bytesReceived,
      iceRole,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult? Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult? Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult? Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult? Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcTransportStats?.call(
      packetsSent,
      packetsReceived,
      bytesSent,
      bytesReceived,
      iceRole,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcTransportStats != null) {
      return rtcTransportStats(
        packetsSent,
        packetsReceived,
        bytesSent,
        bytesReceived,
        iceRole,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcStatsType_RtcMediaSourceStats value)
    rtcMediaSourceStats,
    required TResult Function(RtcStatsType_RtcIceCandidateStats value)
    rtcIceCandidateStats,
    required TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)
    rtcOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)
    rtcInboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcIceCandidatePairStats value)
    rtcIceCandidatePairStats,
    required TResult Function(RtcStatsType_RtcTransportStats value)
    rtcTransportStats,
    required TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) {
    return rtcTransportStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult? Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult? Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult? Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult? Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_Unimplemented value)? unimplemented,
  }) {
    return rtcTransportStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function(RtcStatsType_Unimplemented value)? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcTransportStats != null) {
      return rtcTransportStats(this);
    }
    return orElse();
  }
}

abstract class RtcStatsType_RtcTransportStats extends RtcStatsType {
  const factory RtcStatsType_RtcTransportStats({
    final BigInt? packetsSent,
    final BigInt? packetsReceived,
    final BigInt? bytesSent,
    final BigInt? bytesReceived,
    final IceRole? iceRole,
  }) = _$RtcStatsType_RtcTransportStatsImpl;
  const RtcStatsType_RtcTransportStats._() : super._();

  /// Total number of packets sent over this transport.
  BigInt? get packetsSent;

  /// Total number of packets received on this transport.
  BigInt? get packetsReceived;

  /// Total number of payload bytes sent on this [RTCPeerConnection], i.e.
  /// not including headers or padding.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  BigInt? get bytesSent;

  /// Total number of bytes received on this [RTCPeerConnection], i.e. not
  /// including headers or padding.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  BigInt? get bytesReceived;

  /// Set to the current value of the [role][1] of the underlying
  /// [RTCDtlsTransport][2]'s [transport][3].
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
  /// [2]: https://w3.org/TR/webrtc#rtcdtlstransport-interface
  /// [3]: https://w3.org/TR/webrtc#dom-rtcdtlstransport-icetransport
  IceRole? get iceRole;

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcStatsType_RtcTransportStatsImplCopyWith<
    _$RtcStatsType_RtcTransportStatsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcRemoteInboundRtpStreamStatsImplCopyWith<
  $Res
> {
  factory _$$RtcStatsType_RtcRemoteInboundRtpStreamStatsImplCopyWith(
    _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl value,
    $Res Function(_$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl) then,
  ) = __$$RtcStatsType_RtcRemoteInboundRtpStreamStatsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String? localId,
    double? jitter,
    double? roundTripTime,
    double? fractionLost,
    BigInt? reportsReceived,
    int? roundTripTimeMeasurements,
  });
}

/// @nodoc
class __$$RtcStatsType_RtcRemoteInboundRtpStreamStatsImplCopyWithImpl<$Res>
    extends
        _$RtcStatsTypeCopyWithImpl<
          $Res,
          _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl
        >
    implements
        _$$RtcStatsType_RtcRemoteInboundRtpStreamStatsImplCopyWith<$Res> {
  __$$RtcStatsType_RtcRemoteInboundRtpStreamStatsImplCopyWithImpl(
    _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl _value,
    $Res Function(_$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localId = freezed,
    Object? jitter = freezed,
    Object? roundTripTime = freezed,
    Object? fractionLost = freezed,
    Object? reportsReceived = freezed,
    Object? roundTripTimeMeasurements = freezed,
  }) {
    return _then(
      _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl(
        localId: freezed == localId
            ? _value.localId
            : localId // ignore: cast_nullable_to_non_nullable
                  as String?,
        jitter: freezed == jitter
            ? _value.jitter
            : jitter // ignore: cast_nullable_to_non_nullable
                  as double?,
        roundTripTime: freezed == roundTripTime
            ? _value.roundTripTime
            : roundTripTime // ignore: cast_nullable_to_non_nullable
                  as double?,
        fractionLost: freezed == fractionLost
            ? _value.fractionLost
            : fractionLost // ignore: cast_nullable_to_non_nullable
                  as double?,
        reportsReceived: freezed == reportsReceived
            ? _value.reportsReceived
            : reportsReceived // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        roundTripTimeMeasurements: freezed == roundTripTimeMeasurements
            ? _value.roundTripTimeMeasurements
            : roundTripTimeMeasurements // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl
    extends RtcStatsType_RtcRemoteInboundRtpStreamStats {
  const _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl({
    this.localId,
    this.jitter,
    this.roundTripTime,
    this.fractionLost,
    this.reportsReceived,
    this.roundTripTimeMeasurements,
  }) : super._();

  /// [localId] is used for looking up the local
  /// [RTCOutboundRtpStreamStats][1] object for the same [SSRC].
  ///
  /// [localId]: https://tinyurl.com/r8uhbo9
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcoutboundrtpstreamstats
  @override
  final String? localId;

  /// Packet jitter measured in seconds for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final double? jitter;

  /// Estimated round trip time for this [SSRC] based on the RTCP
  /// timestamps in the RTCP Receiver Report (RR) and measured in seconds.
  /// Calculated as defined in [Section 6.4.1 of RFC 3550][1].
  /// If no RTCP Receiver Report is received with a DLSR value other than
  /// 0, the round trip time is left undefined.
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
  @override
  final double? roundTripTime;

  /// Fraction packet loss reported for this [SSRC].
  /// Calculated as defined in [Section 6.4.1 of RFC 3550][1] and
  /// [Appendix A.3][2].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
  /// [2]: https://tools.ietf.org/html/rfc3550#appendix-A.3
  @override
  final double? fractionLost;

  /// Total number of RTCP RR blocks received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final BigInt? reportsReceived;

  /// Total number of RTCP RR blocks received for this [SSRC] that contain
  /// a valid round trip time. This counter will increment if the
  /// [roundTripTime] is undefined.
  ///
  /// [roundTripTime]: https://tinyurl.com/ssg83hq
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final int? roundTripTimeMeasurements;

  @override
  String toString() {
    return 'RtcStatsType.rtcRemoteInboundRtpStreamStats(localId: $localId, jitter: $jitter, roundTripTime: $roundTripTime, fractionLost: $fractionLost, reportsReceived: $reportsReceived, roundTripTimeMeasurements: $roundTripTimeMeasurements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl &&
            (identical(other.localId, localId) || other.localId == localId) &&
            (identical(other.jitter, jitter) || other.jitter == jitter) &&
            (identical(other.roundTripTime, roundTripTime) ||
                other.roundTripTime == roundTripTime) &&
            (identical(other.fractionLost, fractionLost) ||
                other.fractionLost == fractionLost) &&
            (identical(other.reportsReceived, reportsReceived) ||
                other.reportsReceived == reportsReceived) &&
            (identical(
                  other.roundTripTimeMeasurements,
                  roundTripTimeMeasurements,
                ) ||
                other.roundTripTimeMeasurements == roundTripTimeMeasurements));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    localId,
    jitter,
    roundTripTime,
    fractionLost,
    reportsReceived,
    roundTripTimeMeasurements,
  );

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcRemoteInboundRtpStreamStatsImplCopyWith<
    _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl
  >
  get copyWith =>
      __$$RtcStatsType_RtcRemoteInboundRtpStreamStatsImplCopyWithImpl<
        _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )
    rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )
    rtcOutboundRtpStreamStats,
    required TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )
    rtcInboundRtpStreamStats,
    required TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )
    rtcIceCandidatePairStats,
    required TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )
    rtcTransportStats,
    required TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcRemoteInboundRtpStreamStats(
      localId,
      jitter,
      roundTripTime,
      fractionLost,
      reportsReceived,
      roundTripTimeMeasurements,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult? Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult? Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult? Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult? Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcRemoteInboundRtpStreamStats?.call(
      localId,
      jitter,
      roundTripTime,
      fractionLost,
      reportsReceived,
      roundTripTimeMeasurements,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcRemoteInboundRtpStreamStats != null) {
      return rtcRemoteInboundRtpStreamStats(
        localId,
        jitter,
        roundTripTime,
        fractionLost,
        reportsReceived,
        roundTripTimeMeasurements,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcStatsType_RtcMediaSourceStats value)
    rtcMediaSourceStats,
    required TResult Function(RtcStatsType_RtcIceCandidateStats value)
    rtcIceCandidateStats,
    required TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)
    rtcOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)
    rtcInboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcIceCandidatePairStats value)
    rtcIceCandidatePairStats,
    required TResult Function(RtcStatsType_RtcTransportStats value)
    rtcTransportStats,
    required TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) {
    return rtcRemoteInboundRtpStreamStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult? Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult? Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult? Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult? Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_Unimplemented value)? unimplemented,
  }) {
    return rtcRemoteInboundRtpStreamStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function(RtcStatsType_Unimplemented value)? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcRemoteInboundRtpStreamStats != null) {
      return rtcRemoteInboundRtpStreamStats(this);
    }
    return orElse();
  }
}

abstract class RtcStatsType_RtcRemoteInboundRtpStreamStats
    extends RtcStatsType {
  const factory RtcStatsType_RtcRemoteInboundRtpStreamStats({
    final String? localId,
    final double? jitter,
    final double? roundTripTime,
    final double? fractionLost,
    final BigInt? reportsReceived,
    final int? roundTripTimeMeasurements,
  }) = _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl;
  const RtcStatsType_RtcRemoteInboundRtpStreamStats._() : super._();

  /// [localId] is used for looking up the local
  /// [RTCOutboundRtpStreamStats][1] object for the same [SSRC].
  ///
  /// [localId]: https://tinyurl.com/r8uhbo9
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcoutboundrtpstreamstats
  String? get localId;

  /// Packet jitter measured in seconds for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  double? get jitter;

  /// Estimated round trip time for this [SSRC] based on the RTCP
  /// timestamps in the RTCP Receiver Report (RR) and measured in seconds.
  /// Calculated as defined in [Section 6.4.1 of RFC 3550][1].
  /// If no RTCP Receiver Report is received with a DLSR value other than
  /// 0, the round trip time is left undefined.
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
  double? get roundTripTime;

  /// Fraction packet loss reported for this [SSRC].
  /// Calculated as defined in [Section 6.4.1 of RFC 3550][1] and
  /// [Appendix A.3][2].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
  /// [2]: https://tools.ietf.org/html/rfc3550#appendix-A.3
  double? get fractionLost;

  /// Total number of RTCP RR blocks received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  BigInt? get reportsReceived;

  /// Total number of RTCP RR blocks received for this [SSRC] that contain
  /// a valid round trip time. This counter will increment if the
  /// [roundTripTime] is undefined.
  ///
  /// [roundTripTime]: https://tinyurl.com/ssg83hq
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? get roundTripTimeMeasurements;

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcStatsType_RtcRemoteInboundRtpStreamStatsImplCopyWith<
    _$RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImplCopyWith<
  $Res
> {
  factory _$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImplCopyWith(
    _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl value,
    $Res Function(_$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl) then,
  ) = __$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? localId, double? remoteTimestamp, BigInt? reportsSent});
}

/// @nodoc
class __$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImplCopyWithImpl<$Res>
    extends
        _$RtcStatsTypeCopyWithImpl<
          $Res,
          _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl
        >
    implements
        _$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImplCopyWith<$Res> {
  __$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImplCopyWithImpl(
    _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl _value,
    $Res Function(_$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localId = freezed,
    Object? remoteTimestamp = freezed,
    Object? reportsSent = freezed,
  }) {
    return _then(
      _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl(
        localId: freezed == localId
            ? _value.localId
            : localId // ignore: cast_nullable_to_non_nullable
                  as String?,
        remoteTimestamp: freezed == remoteTimestamp
            ? _value.remoteTimestamp
            : remoteTimestamp // ignore: cast_nullable_to_non_nullable
                  as double?,
        reportsSent: freezed == reportsSent
            ? _value.reportsSent
            : reportsSent // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
      ),
    );
  }
}

/// @nodoc

class _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl
    extends RtcStatsType_RtcRemoteOutboundRtpStreamStats {
  const _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl({
    this.localId,
    this.remoteTimestamp,
    this.reportsSent,
  }) : super._();

  /// [localId] is used for looking up the local
  /// [RTCInboundRtpStreamStats][1] object for the same [SSRC].
  ///
  /// [localId]: https://tinyurl.com/vu9tb2e
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcinboundrtpstreamstats
  @override
  final String? localId;

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
  @override
  final double? remoteTimestamp;

  /// Total number of RTCP SR blocks sent for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final BigInt? reportsSent;

  @override
  String toString() {
    return 'RtcStatsType.rtcRemoteOutboundRtpStreamStats(localId: $localId, remoteTimestamp: $remoteTimestamp, reportsSent: $reportsSent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl &&
            (identical(other.localId, localId) || other.localId == localId) &&
            (identical(other.remoteTimestamp, remoteTimestamp) ||
                other.remoteTimestamp == remoteTimestamp) &&
            (identical(other.reportsSent, reportsSent) ||
                other.reportsSent == reportsSent));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, localId, remoteTimestamp, reportsSent);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImplCopyWith<
    _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl
  >
  get copyWith =>
      __$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImplCopyWithImpl<
        _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )
    rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )
    rtcOutboundRtpStreamStats,
    required TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )
    rtcInboundRtpStreamStats,
    required TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )
    rtcIceCandidatePairStats,
    required TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )
    rtcTransportStats,
    required TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcRemoteOutboundRtpStreamStats(
      localId,
      remoteTimestamp,
      reportsSent,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult? Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult? Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult? Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult? Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcRemoteOutboundRtpStreamStats?.call(
      localId,
      remoteTimestamp,
      reportsSent,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcRemoteOutboundRtpStreamStats != null) {
      return rtcRemoteOutboundRtpStreamStats(
        localId,
        remoteTimestamp,
        reportsSent,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcStatsType_RtcMediaSourceStats value)
    rtcMediaSourceStats,
    required TResult Function(RtcStatsType_RtcIceCandidateStats value)
    rtcIceCandidateStats,
    required TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)
    rtcOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)
    rtcInboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcIceCandidatePairStats value)
    rtcIceCandidatePairStats,
    required TResult Function(RtcStatsType_RtcTransportStats value)
    rtcTransportStats,
    required TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) {
    return rtcRemoteOutboundRtpStreamStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult? Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult? Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult? Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult? Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_Unimplemented value)? unimplemented,
  }) {
    return rtcRemoteOutboundRtpStreamStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function(RtcStatsType_Unimplemented value)? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcRemoteOutboundRtpStreamStats != null) {
      return rtcRemoteOutboundRtpStreamStats(this);
    }
    return orElse();
  }
}

abstract class RtcStatsType_RtcRemoteOutboundRtpStreamStats
    extends RtcStatsType {
  const factory RtcStatsType_RtcRemoteOutboundRtpStreamStats({
    final String? localId,
    final double? remoteTimestamp,
    final BigInt? reportsSent,
  }) = _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl;
  const RtcStatsType_RtcRemoteOutboundRtpStreamStats._() : super._();

  /// [localId] is used for looking up the local
  /// [RTCInboundRtpStreamStats][1] object for the same [SSRC].
  ///
  /// [localId]: https://tinyurl.com/vu9tb2e
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcinboundrtpstreamstats
  String? get localId;

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
  double? get remoteTimestamp;

  /// Total number of RTCP SR blocks sent for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  BigInt? get reportsSent;

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImplCopyWith<
    _$RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_UnimplementedImplCopyWith<$Res> {
  factory _$$RtcStatsType_UnimplementedImplCopyWith(
    _$RtcStatsType_UnimplementedImpl value,
    $Res Function(_$RtcStatsType_UnimplementedImpl) then,
  ) = __$$RtcStatsType_UnimplementedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RtcStatsType_UnimplementedImplCopyWithImpl<$Res>
    extends _$RtcStatsTypeCopyWithImpl<$Res, _$RtcStatsType_UnimplementedImpl>
    implements _$$RtcStatsType_UnimplementedImplCopyWith<$Res> {
  __$$RtcStatsType_UnimplementedImplCopyWithImpl(
    _$RtcStatsType_UnimplementedImpl _value,
    $Res Function(_$RtcStatsType_UnimplementedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcStatsType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RtcStatsType_UnimplementedImpl extends RtcStatsType_Unimplemented {
  const _$RtcStatsType_UnimplementedImpl() : super._();

  @override
  String toString() {
    return 'RtcStatsType.unimplemented()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_UnimplementedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )
    rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )
    rtcOutboundRtpStreamStats,
    required TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )
    rtcInboundRtpStreamStats,
    required TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )
    rtcIceCandidatePairStats,
    required TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )
    rtcTransportStats,
    required TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return unimplemented();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult? Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult? Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult? Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult? Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return unimplemented?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? trackIdentifier,
      RtcMediaSourceStatsMediaType kind,
    )?
    rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
      String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      BigInt? bytesSent,
      int? packetsSent,
      String? mediaSourceId,
    )?
    rtcOutboundRtpStreamStats,
    TResult Function(
      String? remoteId,
      BigInt? bytesReceived,
      int? packetsReceived,
      BigInt? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      BigInt? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType,
    )?
    rtcInboundRtpStreamStats,
    TResult Function(
      RtcStatsIceCandidatePairState state,
      bool? nominated,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate,
    )?
    rtcIceCandidatePairStats,
    TResult Function(
      BigInt? packetsSent,
      BigInt? packetsReceived,
      BigInt? bytesSent,
      BigInt? bytesReceived,
      IceRole? iceRole,
    )?
    rtcTransportStats,
    TResult Function(
      String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      BigInt? reportsReceived,
      int? roundTripTimeMeasurements,
    )?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(
      String? localId,
      double? remoteTimestamp,
      BigInt? reportsSent,
    )?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (unimplemented != null) {
      return unimplemented();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcStatsType_RtcMediaSourceStats value)
    rtcMediaSourceStats,
    required TResult Function(RtcStatsType_RtcIceCandidateStats value)
    rtcIceCandidateStats,
    required TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)
    rtcOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)
    rtcInboundRtpStreamStats,
    required TResult Function(RtcStatsType_RtcIceCandidatePairStats value)
    rtcIceCandidatePairStats,
    required TResult Function(RtcStatsType_RtcTransportStats value)
    rtcTransportStats,
    required TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)
    rtcRemoteInboundRtpStreamStats,
    required TResult Function(
      RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
    )
    rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) {
    return unimplemented(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult? Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult? Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult? Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult? Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult? Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult? Function(RtcStatsType_Unimplemented value)? unimplemented,
  }) {
    return unimplemented?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcStatsType_RtcMediaSourceStats value)?
    rtcMediaSourceStats,
    TResult Function(RtcStatsType_RtcIceCandidateStats value)?
    rtcIceCandidateStats,
    TResult Function(RtcStatsType_RtcOutboundRtpStreamStats value)?
    rtcOutboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcInboundRtpStreamStats value)?
    rtcInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcIceCandidatePairStats value)?
    rtcIceCandidatePairStats,
    TResult Function(RtcStatsType_RtcTransportStats value)? rtcTransportStats,
    TResult Function(RtcStatsType_RtcRemoteInboundRtpStreamStats value)?
    rtcRemoteInboundRtpStreamStats,
    TResult Function(RtcStatsType_RtcRemoteOutboundRtpStreamStats value)?
    rtcRemoteOutboundRtpStreamStats,
    TResult Function(RtcStatsType_Unimplemented value)? unimplemented,
    required TResult orElse(),
  }) {
    if (unimplemented != null) {
      return unimplemented(this);
    }
    return orElse();
  }
}

abstract class RtcStatsType_Unimplemented extends RtcStatsType {
  const factory RtcStatsType_Unimplemented() = _$RtcStatsType_UnimplementedImpl;
  const RtcStatsType_Unimplemented._() : super._();
}
