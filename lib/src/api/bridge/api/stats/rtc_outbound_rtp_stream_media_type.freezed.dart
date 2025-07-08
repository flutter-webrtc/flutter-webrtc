// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rtc_outbound_rtp_stream_media_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RtcOutboundRtpStreamStatsMediaType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BigInt? totalSamplesSent, bool? voiceActivityFlag)
    audio,
    required TResult Function(
      int? frameWidth,
      int? frameHeight,
      double? framesPerSecond,
    )
    video,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BigInt? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult? Function(
      int? frameWidth,
      int? frameHeight,
      double? framesPerSecond,
    )?
    video,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BigInt? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult Function(
      int? frameWidth,
      int? frameHeight,
      double? framesPerSecond,
    )?
    video,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcOutboundRtpStreamStatsMediaType_Audio value)
    audio,
    required TResult Function(RtcOutboundRtpStreamStatsMediaType_Video value)
    video,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcOutboundRtpStreamStatsMediaType_Audio value)? audio,
    TResult? Function(RtcOutboundRtpStreamStatsMediaType_Video value)? video,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcOutboundRtpStreamStatsMediaType_Audio value)? audio,
    TResult Function(RtcOutboundRtpStreamStatsMediaType_Video value)? video,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> {
  factory $RtcOutboundRtpStreamStatsMediaTypeCopyWith(
    RtcOutboundRtpStreamStatsMediaType value,
    $Res Function(RtcOutboundRtpStreamStatsMediaType) then,
  ) =
      _$RtcOutboundRtpStreamStatsMediaTypeCopyWithImpl<
        $Res,
        RtcOutboundRtpStreamStatsMediaType
      >;
}

/// @nodoc
class _$RtcOutboundRtpStreamStatsMediaTypeCopyWithImpl<
  $Res,
  $Val extends RtcOutboundRtpStreamStatsMediaType
>
    implements $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> {
  _$RtcOutboundRtpStreamStatsMediaTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RtcOutboundRtpStreamStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RtcOutboundRtpStreamStatsMediaType_AudioImplCopyWith<$Res> {
  factory _$$RtcOutboundRtpStreamStatsMediaType_AudioImplCopyWith(
    _$RtcOutboundRtpStreamStatsMediaType_AudioImpl value,
    $Res Function(_$RtcOutboundRtpStreamStatsMediaType_AudioImpl) then,
  ) = __$$RtcOutboundRtpStreamStatsMediaType_AudioImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt? totalSamplesSent, bool? voiceActivityFlag});
}

/// @nodoc
class __$$RtcOutboundRtpStreamStatsMediaType_AudioImplCopyWithImpl<$Res>
    extends
        _$RtcOutboundRtpStreamStatsMediaTypeCopyWithImpl<
          $Res,
          _$RtcOutboundRtpStreamStatsMediaType_AudioImpl
        >
    implements _$$RtcOutboundRtpStreamStatsMediaType_AudioImplCopyWith<$Res> {
  __$$RtcOutboundRtpStreamStatsMediaType_AudioImplCopyWithImpl(
    _$RtcOutboundRtpStreamStatsMediaType_AudioImpl _value,
    $Res Function(_$RtcOutboundRtpStreamStatsMediaType_AudioImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcOutboundRtpStreamStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSamplesSent = freezed,
    Object? voiceActivityFlag = freezed,
  }) {
    return _then(
      _$RtcOutboundRtpStreamStatsMediaType_AudioImpl(
        totalSamplesSent: freezed == totalSamplesSent
            ? _value.totalSamplesSent
            : totalSamplesSent // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        voiceActivityFlag: freezed == voiceActivityFlag
            ? _value.voiceActivityFlag
            : voiceActivityFlag // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc

class _$RtcOutboundRtpStreamStatsMediaType_AudioImpl
    extends RtcOutboundRtpStreamStatsMediaType_Audio {
  const _$RtcOutboundRtpStreamStatsMediaType_AudioImpl({
    this.totalSamplesSent,
    this.voiceActivityFlag,
  }) : super._();

  /// Total number of samples that have been sent over the RTP stream.
  @override
  final BigInt? totalSamplesSent;

  /// Whether the last RTP packet sent contained voice activity or not
  /// based on the presence of the V bit in the extension header.
  @override
  final bool? voiceActivityFlag;

  @override
  String toString() {
    return 'RtcOutboundRtpStreamStatsMediaType.audio(totalSamplesSent: $totalSamplesSent, voiceActivityFlag: $voiceActivityFlag)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcOutboundRtpStreamStatsMediaType_AudioImpl &&
            (identical(other.totalSamplesSent, totalSamplesSent) ||
                other.totalSamplesSent == totalSamplesSent) &&
            (identical(other.voiceActivityFlag, voiceActivityFlag) ||
                other.voiceActivityFlag == voiceActivityFlag));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, totalSamplesSent, voiceActivityFlag);

  /// Create a copy of RtcOutboundRtpStreamStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcOutboundRtpStreamStatsMediaType_AudioImplCopyWith<
    _$RtcOutboundRtpStreamStatsMediaType_AudioImpl
  >
  get copyWith =>
      __$$RtcOutboundRtpStreamStatsMediaType_AudioImplCopyWithImpl<
        _$RtcOutboundRtpStreamStatsMediaType_AudioImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BigInt? totalSamplesSent, bool? voiceActivityFlag)
    audio,
    required TResult Function(
      int? frameWidth,
      int? frameHeight,
      double? framesPerSecond,
    )
    video,
  }) {
    return audio(totalSamplesSent, voiceActivityFlag);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BigInt? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult? Function(
      int? frameWidth,
      int? frameHeight,
      double? framesPerSecond,
    )?
    video,
  }) {
    return audio?.call(totalSamplesSent, voiceActivityFlag);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BigInt? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult Function(
      int? frameWidth,
      int? frameHeight,
      double? framesPerSecond,
    )?
    video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(totalSamplesSent, voiceActivityFlag);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcOutboundRtpStreamStatsMediaType_Audio value)
    audio,
    required TResult Function(RtcOutboundRtpStreamStatsMediaType_Video value)
    video,
  }) {
    return audio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcOutboundRtpStreamStatsMediaType_Audio value)? audio,
    TResult? Function(RtcOutboundRtpStreamStatsMediaType_Video value)? video,
  }) {
    return audio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcOutboundRtpStreamStatsMediaType_Audio value)? audio,
    TResult Function(RtcOutboundRtpStreamStatsMediaType_Video value)? video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(this);
    }
    return orElse();
  }
}

abstract class RtcOutboundRtpStreamStatsMediaType_Audio
    extends RtcOutboundRtpStreamStatsMediaType {
  const factory RtcOutboundRtpStreamStatsMediaType_Audio({
    final BigInt? totalSamplesSent,
    final bool? voiceActivityFlag,
  }) = _$RtcOutboundRtpStreamStatsMediaType_AudioImpl;
  const RtcOutboundRtpStreamStatsMediaType_Audio._() : super._();

  /// Total number of samples that have been sent over the RTP stream.
  BigInt? get totalSamplesSent;

  /// Whether the last RTP packet sent contained voice activity or not
  /// based on the presence of the V bit in the extension header.
  bool? get voiceActivityFlag;

  /// Create a copy of RtcOutboundRtpStreamStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcOutboundRtpStreamStatsMediaType_AudioImplCopyWith<
    _$RtcOutboundRtpStreamStatsMediaType_AudioImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcOutboundRtpStreamStatsMediaType_VideoImplCopyWith<$Res> {
  factory _$$RtcOutboundRtpStreamStatsMediaType_VideoImplCopyWith(
    _$RtcOutboundRtpStreamStatsMediaType_VideoImpl value,
    $Res Function(_$RtcOutboundRtpStreamStatsMediaType_VideoImpl) then,
  ) = __$$RtcOutboundRtpStreamStatsMediaType_VideoImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int? frameWidth, int? frameHeight, double? framesPerSecond});
}

/// @nodoc
class __$$RtcOutboundRtpStreamStatsMediaType_VideoImplCopyWithImpl<$Res>
    extends
        _$RtcOutboundRtpStreamStatsMediaTypeCopyWithImpl<
          $Res,
          _$RtcOutboundRtpStreamStatsMediaType_VideoImpl
        >
    implements _$$RtcOutboundRtpStreamStatsMediaType_VideoImplCopyWith<$Res> {
  __$$RtcOutboundRtpStreamStatsMediaType_VideoImplCopyWithImpl(
    _$RtcOutboundRtpStreamStatsMediaType_VideoImpl _value,
    $Res Function(_$RtcOutboundRtpStreamStatsMediaType_VideoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcOutboundRtpStreamStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frameWidth = freezed,
    Object? frameHeight = freezed,
    Object? framesPerSecond = freezed,
  }) {
    return _then(
      _$RtcOutboundRtpStreamStatsMediaType_VideoImpl(
        frameWidth: freezed == frameWidth
            ? _value.frameWidth
            : frameWidth // ignore: cast_nullable_to_non_nullable
                  as int?,
        frameHeight: freezed == frameHeight
            ? _value.frameHeight
            : frameHeight // ignore: cast_nullable_to_non_nullable
                  as int?,
        framesPerSecond: freezed == framesPerSecond
            ? _value.framesPerSecond
            : framesPerSecond // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc

class _$RtcOutboundRtpStreamStatsMediaType_VideoImpl
    extends RtcOutboundRtpStreamStatsMediaType_Video {
  const _$RtcOutboundRtpStreamStatsMediaType_VideoImpl({
    this.frameWidth,
    this.frameHeight,
    this.framesPerSecond,
  }) : super._();

  /// Width of the last encoded frame.
  ///
  /// The resolution of the encoded frame may be lower than the media
  /// source (see [RTCVideoSourceStats.width][1]).
  ///
  /// Before the first frame is encoded this attribute is missing.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-width
  @override
  final int? frameWidth;

  /// Height of the last encoded frame.
  ///
  /// The resolution of the encoded frame may be lower than the media
  /// source (see [RTCVideoSourceStats.height][1]).
  ///
  /// Before the first frame is encoded this attribute is missing.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-height
  @override
  final int? frameHeight;

  /// Number of encoded frames during the last second.
  ///
  /// This may be lower than the media source frame rate (see
  /// [RTCVideoSourceStats.framesPerSecond][1]).
  ///
  /// [1]: https://tinyurl.com/rrmkrfk
  @override
  final double? framesPerSecond;

  @override
  String toString() {
    return 'RtcOutboundRtpStreamStatsMediaType.video(frameWidth: $frameWidth, frameHeight: $frameHeight, framesPerSecond: $framesPerSecond)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcOutboundRtpStreamStatsMediaType_VideoImpl &&
            (identical(other.frameWidth, frameWidth) ||
                other.frameWidth == frameWidth) &&
            (identical(other.frameHeight, frameHeight) ||
                other.frameHeight == frameHeight) &&
            (identical(other.framesPerSecond, framesPerSecond) ||
                other.framesPerSecond == framesPerSecond));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, frameWidth, frameHeight, framesPerSecond);

  /// Create a copy of RtcOutboundRtpStreamStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcOutboundRtpStreamStatsMediaType_VideoImplCopyWith<
    _$RtcOutboundRtpStreamStatsMediaType_VideoImpl
  >
  get copyWith =>
      __$$RtcOutboundRtpStreamStatsMediaType_VideoImplCopyWithImpl<
        _$RtcOutboundRtpStreamStatsMediaType_VideoImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BigInt? totalSamplesSent, bool? voiceActivityFlag)
    audio,
    required TResult Function(
      int? frameWidth,
      int? frameHeight,
      double? framesPerSecond,
    )
    video,
  }) {
    return video(frameWidth, frameHeight, framesPerSecond);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BigInt? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult? Function(
      int? frameWidth,
      int? frameHeight,
      double? framesPerSecond,
    )?
    video,
  }) {
    return video?.call(frameWidth, frameHeight, framesPerSecond);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BigInt? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult Function(
      int? frameWidth,
      int? frameHeight,
      double? framesPerSecond,
    )?
    video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(frameWidth, frameHeight, framesPerSecond);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcOutboundRtpStreamStatsMediaType_Audio value)
    audio,
    required TResult Function(RtcOutboundRtpStreamStatsMediaType_Video value)
    video,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcOutboundRtpStreamStatsMediaType_Audio value)? audio,
    TResult? Function(RtcOutboundRtpStreamStatsMediaType_Video value)? video,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcOutboundRtpStreamStatsMediaType_Audio value)? audio,
    TResult Function(RtcOutboundRtpStreamStatsMediaType_Video value)? video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }
}

abstract class RtcOutboundRtpStreamStatsMediaType_Video
    extends RtcOutboundRtpStreamStatsMediaType {
  const factory RtcOutboundRtpStreamStatsMediaType_Video({
    final int? frameWidth,
    final int? frameHeight,
    final double? framesPerSecond,
  }) = _$RtcOutboundRtpStreamStatsMediaType_VideoImpl;
  const RtcOutboundRtpStreamStatsMediaType_Video._() : super._();

  /// Width of the last encoded frame.
  ///
  /// The resolution of the encoded frame may be lower than the media
  /// source (see [RTCVideoSourceStats.width][1]).
  ///
  /// Before the first frame is encoded this attribute is missing.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-width
  int? get frameWidth;

  /// Height of the last encoded frame.
  ///
  /// The resolution of the encoded frame may be lower than the media
  /// source (see [RTCVideoSourceStats.height][1]).
  ///
  /// Before the first frame is encoded this attribute is missing.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-height
  int? get frameHeight;

  /// Number of encoded frames during the last second.
  ///
  /// This may be lower than the media source frame rate (see
  /// [RTCVideoSourceStats.framesPerSecond][1]).
  ///
  /// [1]: https://tinyurl.com/rrmkrfk
  double? get framesPerSecond;

  /// Create a copy of RtcOutboundRtpStreamStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcOutboundRtpStreamStatsMediaType_VideoImplCopyWith<
    _$RtcOutboundRtpStreamStatsMediaType_VideoImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
