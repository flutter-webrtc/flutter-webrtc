// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rtc_media_source_stats_media_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RtcMediaSourceStatsMediaType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int? width,
      int? height,
      int? frames,
      double? framesPerSecond,
    )
    rtcVideoSourceStats,
    required TResult Function(
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement,
    )
    rtcAudioSourceStats,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int? width,
      int? height,
      int? frames,
      double? framesPerSecond,
    )?
    rtcVideoSourceStats,
    TResult? Function(
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement,
    )?
    rtcAudioSourceStats,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int? width,
      int? height,
      int? frames,
      double? framesPerSecond,
    )?
    rtcVideoSourceStats,
    TResult Function(
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement,
    )?
    rtcAudioSourceStats,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(
      RtcMediaSourceStatsMediaType_RtcVideoSourceStats value,
    )
    rtcVideoSourceStats,
    required TResult Function(
      RtcMediaSourceStatsMediaType_RtcAudioSourceStats value,
    )
    rtcAudioSourceStats,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)?
    rtcVideoSourceStats,
    TResult? Function(RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)?
    rtcAudioSourceStats,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)?
    rtcVideoSourceStats,
    TResult Function(RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)?
    rtcAudioSourceStats,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RtcMediaSourceStatsMediaTypeCopyWith<$Res> {
  factory $RtcMediaSourceStatsMediaTypeCopyWith(
    RtcMediaSourceStatsMediaType value,
    $Res Function(RtcMediaSourceStatsMediaType) then,
  ) =
      _$RtcMediaSourceStatsMediaTypeCopyWithImpl<
        $Res,
        RtcMediaSourceStatsMediaType
      >;
}

/// @nodoc
class _$RtcMediaSourceStatsMediaTypeCopyWithImpl<
  $Res,
  $Val extends RtcMediaSourceStatsMediaType
>
    implements $RtcMediaSourceStatsMediaTypeCopyWith<$Res> {
  _$RtcMediaSourceStatsMediaTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RtcMediaSourceStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImplCopyWith<
  $Res
> {
  factory _$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImplCopyWith(
    _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl value,
    $Res Function(_$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl) then,
  ) =
      __$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImplCopyWithImpl<
        $Res
      >;
  @useResult
  $Res call({int? width, int? height, int? frames, double? framesPerSecond});
}

/// @nodoc
class __$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImplCopyWithImpl<$Res>
    extends
        _$RtcMediaSourceStatsMediaTypeCopyWithImpl<
          $Res,
          _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl
        >
    implements
        _$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImplCopyWith<$Res> {
  __$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImplCopyWithImpl(
    _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl _value,
    $Res Function(_$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcMediaSourceStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = freezed,
    Object? height = freezed,
    Object? frames = freezed,
    Object? framesPerSecond = freezed,
  }) {
    return _then(
      _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl(
        width: freezed == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        frames: freezed == frames
            ? _value.frames
            : frames // ignore: cast_nullable_to_non_nullable
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

class _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl
    extends RtcMediaSourceStatsMediaType_RtcVideoSourceStats {
  const _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl({
    this.width,
    this.height,
    this.frames,
    this.framesPerSecond,
  }) : super._();

  /// Width (in pixels) of the last frame originating from the source.
  /// Before a frame has been produced this attribute is missing.
  @override
  final int? width;

  /// Height (in pixels) of the last frame originating from the source.
  /// Before a frame has been produced this attribute is missing.
  @override
  final int? height;

  /// Total number of frames originating from this source.
  @override
  final int? frames;

  /// Number of frames originating from the source, measured during the
  /// last second. For the first second of this object's lifetime this
  /// attribute is missing.
  @override
  final double? framesPerSecond;

  @override
  String toString() {
    return 'RtcMediaSourceStatsMediaType.rtcVideoSourceStats(width: $width, height: $height, frames: $frames, framesPerSecond: $framesPerSecond)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.frames, frames) || other.frames == frames) &&
            (identical(other.framesPerSecond, framesPerSecond) ||
                other.framesPerSecond == framesPerSecond));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, width, height, frames, framesPerSecond);

  /// Create a copy of RtcMediaSourceStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImplCopyWith<
    _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl
  >
  get copyWith =>
      __$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImplCopyWithImpl<
        _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int? width,
      int? height,
      int? frames,
      double? framesPerSecond,
    )
    rtcVideoSourceStats,
    required TResult Function(
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement,
    )
    rtcAudioSourceStats,
  }) {
    return rtcVideoSourceStats(width, height, frames, framesPerSecond);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int? width,
      int? height,
      int? frames,
      double? framesPerSecond,
    )?
    rtcVideoSourceStats,
    TResult? Function(
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement,
    )?
    rtcAudioSourceStats,
  }) {
    return rtcVideoSourceStats?.call(width, height, frames, framesPerSecond);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int? width,
      int? height,
      int? frames,
      double? framesPerSecond,
    )?
    rtcVideoSourceStats,
    TResult Function(
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement,
    )?
    rtcAudioSourceStats,
    required TResult orElse(),
  }) {
    if (rtcVideoSourceStats != null) {
      return rtcVideoSourceStats(width, height, frames, framesPerSecond);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(
      RtcMediaSourceStatsMediaType_RtcVideoSourceStats value,
    )
    rtcVideoSourceStats,
    required TResult Function(
      RtcMediaSourceStatsMediaType_RtcAudioSourceStats value,
    )
    rtcAudioSourceStats,
  }) {
    return rtcVideoSourceStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)?
    rtcVideoSourceStats,
    TResult? Function(RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)?
    rtcAudioSourceStats,
  }) {
    return rtcVideoSourceStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)?
    rtcVideoSourceStats,
    TResult Function(RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)?
    rtcAudioSourceStats,
    required TResult orElse(),
  }) {
    if (rtcVideoSourceStats != null) {
      return rtcVideoSourceStats(this);
    }
    return orElse();
  }
}

abstract class RtcMediaSourceStatsMediaType_RtcVideoSourceStats
    extends RtcMediaSourceStatsMediaType {
  const factory RtcMediaSourceStatsMediaType_RtcVideoSourceStats({
    final int? width,
    final int? height,
    final int? frames,
    final double? framesPerSecond,
  }) = _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl;
  const RtcMediaSourceStatsMediaType_RtcVideoSourceStats._() : super._();

  /// Width (in pixels) of the last frame originating from the source.
  /// Before a frame has been produced this attribute is missing.
  int? get width;

  /// Height (in pixels) of the last frame originating from the source.
  /// Before a frame has been produced this attribute is missing.
  int? get height;

  /// Total number of frames originating from this source.
  int? get frames;

  /// Number of frames originating from the source, measured during the
  /// last second. For the first second of this object's lifetime this
  /// attribute is missing.
  double? get framesPerSecond;

  /// Create a copy of RtcMediaSourceStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImplCopyWith<
    _$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImplCopyWith<
  $Res
> {
  factory _$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImplCopyWith(
    _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl value,
    $Res Function(_$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl) then,
  ) =
      __$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImplCopyWithImpl<
        $Res
      >;
  @useResult
  $Res call({
    double? audioLevel,
    double? totalAudioEnergy,
    double? totalSamplesDuration,
    double? echoReturnLoss,
    double? echoReturnLossEnhancement,
  });
}

/// @nodoc
class __$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImplCopyWithImpl<$Res>
    extends
        _$RtcMediaSourceStatsMediaTypeCopyWithImpl<
          $Res,
          _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl
        >
    implements
        _$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImplCopyWith<$Res> {
  __$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImplCopyWithImpl(
    _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl _value,
    $Res Function(_$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RtcMediaSourceStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audioLevel = freezed,
    Object? totalAudioEnergy = freezed,
    Object? totalSamplesDuration = freezed,
    Object? echoReturnLoss = freezed,
    Object? echoReturnLossEnhancement = freezed,
  }) {
    return _then(
      _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl(
        audioLevel: freezed == audioLevel
            ? _value.audioLevel
            : audioLevel // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalAudioEnergy: freezed == totalAudioEnergy
            ? _value.totalAudioEnergy
            : totalAudioEnergy // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalSamplesDuration: freezed == totalSamplesDuration
            ? _value.totalSamplesDuration
            : totalSamplesDuration // ignore: cast_nullable_to_non_nullable
                  as double?,
        echoReturnLoss: freezed == echoReturnLoss
            ? _value.echoReturnLoss
            : echoReturnLoss // ignore: cast_nullable_to_non_nullable
                  as double?,
        echoReturnLossEnhancement: freezed == echoReturnLossEnhancement
            ? _value.echoReturnLossEnhancement
            : echoReturnLossEnhancement // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc

class _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl
    extends RtcMediaSourceStatsMediaType_RtcAudioSourceStats {
  const _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl({
    this.audioLevel,
    this.totalAudioEnergy,
    this.totalSamplesDuration,
    this.echoReturnLoss,
    this.echoReturnLossEnhancement,
  }) : super._();

  /// Audio level of the media source.
  @override
  final double? audioLevel;

  /// Audio energy of the media source.
  @override
  final double? totalAudioEnergy;

  /// Audio duration of the media source.
  @override
  final double? totalSamplesDuration;

  /// Only exists when the [MediaStreamTrack][1] is sourced from a
  /// microphone where echo cancellation is applied.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  @override
  final double? echoReturnLoss;

  /// Only exists when the [MediaStreamTrack][1] is sourced from a
  /// microphone where echo cancellation is applied.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  @override
  final double? echoReturnLossEnhancement;

  @override
  String toString() {
    return 'RtcMediaSourceStatsMediaType.rtcAudioSourceStats(audioLevel: $audioLevel, totalAudioEnergy: $totalAudioEnergy, totalSamplesDuration: $totalSamplesDuration, echoReturnLoss: $echoReturnLoss, echoReturnLossEnhancement: $echoReturnLossEnhancement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl &&
            (identical(other.audioLevel, audioLevel) ||
                other.audioLevel == audioLevel) &&
            (identical(other.totalAudioEnergy, totalAudioEnergy) ||
                other.totalAudioEnergy == totalAudioEnergy) &&
            (identical(other.totalSamplesDuration, totalSamplesDuration) ||
                other.totalSamplesDuration == totalSamplesDuration) &&
            (identical(other.echoReturnLoss, echoReturnLoss) ||
                other.echoReturnLoss == echoReturnLoss) &&
            (identical(
                  other.echoReturnLossEnhancement,
                  echoReturnLossEnhancement,
                ) ||
                other.echoReturnLossEnhancement == echoReturnLossEnhancement));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    audioLevel,
    totalAudioEnergy,
    totalSamplesDuration,
    echoReturnLoss,
    echoReturnLossEnhancement,
  );

  /// Create a copy of RtcMediaSourceStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImplCopyWith<
    _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl
  >
  get copyWith =>
      __$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImplCopyWithImpl<
        _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int? width,
      int? height,
      int? frames,
      double? framesPerSecond,
    )
    rtcVideoSourceStats,
    required TResult Function(
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement,
    )
    rtcAudioSourceStats,
  }) {
    return rtcAudioSourceStats(
      audioLevel,
      totalAudioEnergy,
      totalSamplesDuration,
      echoReturnLoss,
      echoReturnLossEnhancement,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int? width,
      int? height,
      int? frames,
      double? framesPerSecond,
    )?
    rtcVideoSourceStats,
    TResult? Function(
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement,
    )?
    rtcAudioSourceStats,
  }) {
    return rtcAudioSourceStats?.call(
      audioLevel,
      totalAudioEnergy,
      totalSamplesDuration,
      echoReturnLoss,
      echoReturnLossEnhancement,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int? width,
      int? height,
      int? frames,
      double? framesPerSecond,
    )?
    rtcVideoSourceStats,
    TResult Function(
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement,
    )?
    rtcAudioSourceStats,
    required TResult orElse(),
  }) {
    if (rtcAudioSourceStats != null) {
      return rtcAudioSourceStats(
        audioLevel,
        totalAudioEnergy,
        totalSamplesDuration,
        echoReturnLoss,
        echoReturnLossEnhancement,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(
      RtcMediaSourceStatsMediaType_RtcVideoSourceStats value,
    )
    rtcVideoSourceStats,
    required TResult Function(
      RtcMediaSourceStatsMediaType_RtcAudioSourceStats value,
    )
    rtcAudioSourceStats,
  }) {
    return rtcAudioSourceStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)?
    rtcVideoSourceStats,
    TResult? Function(RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)?
    rtcAudioSourceStats,
  }) {
    return rtcAudioSourceStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)?
    rtcVideoSourceStats,
    TResult Function(RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)?
    rtcAudioSourceStats,
    required TResult orElse(),
  }) {
    if (rtcAudioSourceStats != null) {
      return rtcAudioSourceStats(this);
    }
    return orElse();
  }
}

abstract class RtcMediaSourceStatsMediaType_RtcAudioSourceStats
    extends RtcMediaSourceStatsMediaType {
  const factory RtcMediaSourceStatsMediaType_RtcAudioSourceStats({
    final double? audioLevel,
    final double? totalAudioEnergy,
    final double? totalSamplesDuration,
    final double? echoReturnLoss,
    final double? echoReturnLossEnhancement,
  }) = _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl;
  const RtcMediaSourceStatsMediaType_RtcAudioSourceStats._() : super._();

  /// Audio level of the media source.
  double? get audioLevel;

  /// Audio energy of the media source.
  double? get totalAudioEnergy;

  /// Audio duration of the media source.
  double? get totalSamplesDuration;

  /// Only exists when the [MediaStreamTrack][1] is sourced from a
  /// microphone where echo cancellation is applied.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  double? get echoReturnLoss;

  /// Only exists when the [MediaStreamTrack][1] is sourced from a
  /// microphone where echo cancellation is applied.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  double? get echoReturnLossEnhancement;

  /// Create a copy of RtcMediaSourceStatsMediaType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImplCopyWith<
    _$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
