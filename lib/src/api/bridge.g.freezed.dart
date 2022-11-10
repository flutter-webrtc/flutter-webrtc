// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'bridge.g.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$GetMediaError {
  String get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) audio,
    required TResult Function(String field0) video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? audio,
    TResult? Function(String field0)? video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaError_Audio value) audio,
    required TResult Function(GetMediaError_Video value) video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetMediaError_Audio value)? audio,
    TResult? Function(GetMediaError_Video value)? video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GetMediaErrorCopyWith<GetMediaError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMediaErrorCopyWith<$Res> {
  factory $GetMediaErrorCopyWith(
          GetMediaError value, $Res Function(GetMediaError) then) =
      _$GetMediaErrorCopyWithImpl<$Res, GetMediaError>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$GetMediaErrorCopyWithImpl<$Res, $Val extends GetMediaError>
    implements $GetMediaErrorCopyWith<$Res> {
  _$GetMediaErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_value.copyWith(
      field0: null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetMediaError_AudioCopyWith<$Res>
    implements $GetMediaErrorCopyWith<$Res> {
  factory _$$GetMediaError_AudioCopyWith(_$GetMediaError_Audio value,
          $Res Function(_$GetMediaError_Audio) then) =
      __$$GetMediaError_AudioCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$GetMediaError_AudioCopyWithImpl<$Res>
    extends _$GetMediaErrorCopyWithImpl<$Res, _$GetMediaError_Audio>
    implements _$$GetMediaError_AudioCopyWith<$Res> {
  __$$GetMediaError_AudioCopyWithImpl(
      _$GetMediaError_Audio _value, $Res Function(_$GetMediaError_Audio) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$GetMediaError_Audio(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetMediaError_Audio implements GetMediaError_Audio {
  const _$GetMediaError_Audio(this.field0);

  @override
  final String field0;

  @override
  String toString() {
    return 'GetMediaError.audio(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMediaError_Audio &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMediaError_AudioCopyWith<_$GetMediaError_Audio> get copyWith =>
      __$$GetMediaError_AudioCopyWithImpl<_$GetMediaError_Audio>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) audio,
    required TResult Function(String field0) video,
  }) {
    return audio(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? audio,
    TResult? Function(String field0)? video,
  }) {
    return audio?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaError_Audio value) audio,
    required TResult Function(GetMediaError_Video value) video,
  }) {
    return audio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetMediaError_Audio value)? audio,
    TResult? Function(GetMediaError_Video value)? video,
  }) {
    return audio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(this);
    }
    return orElse();
  }
}

abstract class GetMediaError_Audio implements GetMediaError {
  const factory GetMediaError_Audio(final String field0) =
      _$GetMediaError_Audio;

  @override
  String get field0;
  @override
  @JsonKey(ignore: true)
  _$$GetMediaError_AudioCopyWith<_$GetMediaError_Audio> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetMediaError_VideoCopyWith<$Res>
    implements $GetMediaErrorCopyWith<$Res> {
  factory _$$GetMediaError_VideoCopyWith(_$GetMediaError_Video value,
          $Res Function(_$GetMediaError_Video) then) =
      __$$GetMediaError_VideoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$GetMediaError_VideoCopyWithImpl<$Res>
    extends _$GetMediaErrorCopyWithImpl<$Res, _$GetMediaError_Video>
    implements _$$GetMediaError_VideoCopyWith<$Res> {
  __$$GetMediaError_VideoCopyWithImpl(
      _$GetMediaError_Video _value, $Res Function(_$GetMediaError_Video) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$GetMediaError_Video(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetMediaError_Video implements GetMediaError_Video {
  const _$GetMediaError_Video(this.field0);

  @override
  final String field0;

  @override
  String toString() {
    return 'GetMediaError.video(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMediaError_Video &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMediaError_VideoCopyWith<_$GetMediaError_Video> get copyWith =>
      __$$GetMediaError_VideoCopyWithImpl<_$GetMediaError_Video>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) audio,
    required TResult Function(String field0) video,
  }) {
    return video(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? audio,
    TResult? Function(String field0)? video,
  }) {
    return video?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaError_Audio value) audio,
    required TResult Function(GetMediaError_Video value) video,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetMediaError_Audio value)? audio,
    TResult? Function(GetMediaError_Video value)? video,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }
}

abstract class GetMediaError_Video implements GetMediaError {
  const factory GetMediaError_Video(final String field0) =
      _$GetMediaError_Video;

  @override
  String get field0;
  @override
  @JsonKey(ignore: true)
  _$$GetMediaError_VideoCopyWith<_$GetMediaError_Video> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GetMediaResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MediaStreamTrack> field0) ok,
    required TResult Function(GetMediaError field0) err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<MediaStreamTrack> field0)? ok,
    TResult? Function(GetMediaError field0)? err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaResult_Ok value) ok,
    required TResult Function(GetMediaResult_Err value) err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetMediaResult_Ok value)? ok,
    TResult? Function(GetMediaResult_Err value)? err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMediaResultCopyWith<$Res> {
  factory $GetMediaResultCopyWith(
          GetMediaResult value, $Res Function(GetMediaResult) then) =
      _$GetMediaResultCopyWithImpl<$Res, GetMediaResult>;
}

/// @nodoc
class _$GetMediaResultCopyWithImpl<$Res, $Val extends GetMediaResult>
    implements $GetMediaResultCopyWith<$Res> {
  _$GetMediaResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$GetMediaResult_OkCopyWith<$Res> {
  factory _$$GetMediaResult_OkCopyWith(
          _$GetMediaResult_Ok value, $Res Function(_$GetMediaResult_Ok) then) =
      __$$GetMediaResult_OkCopyWithImpl<$Res>;
  @useResult
  $Res call({List<MediaStreamTrack> field0});
}

/// @nodoc
class __$$GetMediaResult_OkCopyWithImpl<$Res>
    extends _$GetMediaResultCopyWithImpl<$Res, _$GetMediaResult_Ok>
    implements _$$GetMediaResult_OkCopyWith<$Res> {
  __$$GetMediaResult_OkCopyWithImpl(
      _$GetMediaResult_Ok _value, $Res Function(_$GetMediaResult_Ok) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$GetMediaResult_Ok(
      null == field0
          ? _value._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<MediaStreamTrack>,
    ));
  }
}

/// @nodoc

class _$GetMediaResult_Ok implements GetMediaResult_Ok {
  const _$GetMediaResult_Ok(final List<MediaStreamTrack> field0)
      : _field0 = field0;

  final List<MediaStreamTrack> _field0;
  @override
  List<MediaStreamTrack> get field0 {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  @override
  String toString() {
    return 'GetMediaResult.ok(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMediaResult_Ok &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMediaResult_OkCopyWith<_$GetMediaResult_Ok> get copyWith =>
      __$$GetMediaResult_OkCopyWithImpl<_$GetMediaResult_Ok>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MediaStreamTrack> field0) ok,
    required TResult Function(GetMediaError field0) err,
  }) {
    return ok(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<MediaStreamTrack> field0)? ok,
    TResult? Function(GetMediaError field0)? err,
  }) {
    return ok?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
    required TResult orElse(),
  }) {
    if (ok != null) {
      return ok(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaResult_Ok value) ok,
    required TResult Function(GetMediaResult_Err value) err,
  }) {
    return ok(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetMediaResult_Ok value)? ok,
    TResult? Function(GetMediaResult_Err value)? err,
  }) {
    return ok?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
    required TResult orElse(),
  }) {
    if (ok != null) {
      return ok(this);
    }
    return orElse();
  }
}

abstract class GetMediaResult_Ok implements GetMediaResult {
  const factory GetMediaResult_Ok(final List<MediaStreamTrack> field0) =
      _$GetMediaResult_Ok;

  List<MediaStreamTrack> get field0;
  @JsonKey(ignore: true)
  _$$GetMediaResult_OkCopyWith<_$GetMediaResult_Ok> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetMediaResult_ErrCopyWith<$Res> {
  factory _$$GetMediaResult_ErrCopyWith(_$GetMediaResult_Err value,
          $Res Function(_$GetMediaResult_Err) then) =
      __$$GetMediaResult_ErrCopyWithImpl<$Res>;
  @useResult
  $Res call({GetMediaError field0});

  $GetMediaErrorCopyWith<$Res> get field0;
}

/// @nodoc
class __$$GetMediaResult_ErrCopyWithImpl<$Res>
    extends _$GetMediaResultCopyWithImpl<$Res, _$GetMediaResult_Err>
    implements _$$GetMediaResult_ErrCopyWith<$Res> {
  __$$GetMediaResult_ErrCopyWithImpl(
      _$GetMediaResult_Err _value, $Res Function(_$GetMediaResult_Err) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$GetMediaResult_Err(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as GetMediaError,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $GetMediaErrorCopyWith<$Res> get field0 {
    return $GetMediaErrorCopyWith<$Res>(_value.field0, (value) {
      return _then(_value.copyWith(field0: value));
    });
  }
}

/// @nodoc

class _$GetMediaResult_Err implements GetMediaResult_Err {
  const _$GetMediaResult_Err(this.field0);

  @override
  final GetMediaError field0;

  @override
  String toString() {
    return 'GetMediaResult.err(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMediaResult_Err &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMediaResult_ErrCopyWith<_$GetMediaResult_Err> get copyWith =>
      __$$GetMediaResult_ErrCopyWithImpl<_$GetMediaResult_Err>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MediaStreamTrack> field0) ok,
    required TResult Function(GetMediaError field0) err,
  }) {
    return err(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<MediaStreamTrack> field0)? ok,
    TResult? Function(GetMediaError field0)? err,
  }) {
    return err?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
    required TResult orElse(),
  }) {
    if (err != null) {
      return err(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaResult_Ok value) ok,
    required TResult Function(GetMediaResult_Err value) err,
  }) {
    return err(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GetMediaResult_Ok value)? ok,
    TResult? Function(GetMediaResult_Err value)? err,
  }) {
    return err?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
    required TResult orElse(),
  }) {
    if (err != null) {
      return err(this);
    }
    return orElse();
  }
}

abstract class GetMediaResult_Err implements GetMediaResult {
  const factory GetMediaResult_Err(final GetMediaError field0) =
      _$GetMediaResult_Err;

  GetMediaError get field0;
  @JsonKey(ignore: true)
  _$$GetMediaResult_ErrCopyWith<_$GetMediaResult_Err> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PeerConnectionEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int id)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
        peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
        iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
        iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
        negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
        signallingChange,
    required TResult Function(
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEventCopyWith(
          PeerConnectionEvent value, $Res Function(PeerConnectionEvent) then) =
      _$PeerConnectionEventCopyWithImpl<$Res, PeerConnectionEvent>;
}

/// @nodoc
class _$PeerConnectionEventCopyWithImpl<$Res, $Val extends PeerConnectionEvent>
    implements $PeerConnectionEventCopyWith<$Res> {
  _$PeerConnectionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_PeerCreatedCopyWith<$Res> {
  factory _$$PeerConnectionEvent_PeerCreatedCopyWith(
          _$PeerConnectionEvent_PeerCreated value,
          $Res Function(_$PeerConnectionEvent_PeerCreated) then) =
      __$$PeerConnectionEvent_PeerCreatedCopyWithImpl<$Res>;
  @useResult
  $Res call({int id});
}

/// @nodoc
class __$$PeerConnectionEvent_PeerCreatedCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res,
        _$PeerConnectionEvent_PeerCreated>
    implements _$$PeerConnectionEvent_PeerCreatedCopyWith<$Res> {
  __$$PeerConnectionEvent_PeerCreatedCopyWithImpl(
      _$PeerConnectionEvent_PeerCreated _value,
      $Res Function(_$PeerConnectionEvent_PeerCreated) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$PeerConnectionEvent_PeerCreated(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_PeerCreated
    implements PeerConnectionEvent_PeerCreated {
  const _$PeerConnectionEvent_PeerCreated({required this.id});

  /// ID of the created [`PeerConnection`].
  @override
  final int id;

  @override
  String toString() {
    return 'PeerConnectionEvent.peerCreated(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_PeerCreated &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_PeerCreatedCopyWith<_$PeerConnectionEvent_PeerCreated>
      get copyWith => __$$PeerConnectionEvent_PeerCreatedCopyWithImpl<
          _$PeerConnectionEvent_PeerCreated>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return peerCreated(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int id)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return peerCreated?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (peerCreated != null) {
      return peerCreated(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
        peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
        iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
        iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
        negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
        signallingChange,
    required TResult Function(
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return peerCreated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return peerCreated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (peerCreated != null) {
      return peerCreated(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_PeerCreated implements PeerConnectionEvent {
  const factory PeerConnectionEvent_PeerCreated({required final int id}) =
      _$PeerConnectionEvent_PeerCreated;

  /// ID of the created [`PeerConnection`].
  int get id;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_PeerCreatedCopyWith<_$PeerConnectionEvent_PeerCreated>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceCandidateCopyWith<$Res> {
  factory _$$PeerConnectionEvent_IceCandidateCopyWith(
          _$PeerConnectionEvent_IceCandidate value,
          $Res Function(_$PeerConnectionEvent_IceCandidate) then) =
      __$$PeerConnectionEvent_IceCandidateCopyWithImpl<$Res>;
  @useResult
  $Res call({String sdpMid, int sdpMlineIndex, String candidate});
}

/// @nodoc
class __$$PeerConnectionEvent_IceCandidateCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res,
        _$PeerConnectionEvent_IceCandidate>
    implements _$$PeerConnectionEvent_IceCandidateCopyWith<$Res> {
  __$$PeerConnectionEvent_IceCandidateCopyWithImpl(
      _$PeerConnectionEvent_IceCandidate _value,
      $Res Function(_$PeerConnectionEvent_IceCandidate) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sdpMid = null,
    Object? sdpMlineIndex = null,
    Object? candidate = null,
  }) {
    return _then(_$PeerConnectionEvent_IceCandidate(
      sdpMid: null == sdpMid
          ? _value.sdpMid
          : sdpMid // ignore: cast_nullable_to_non_nullable
              as String,
      sdpMlineIndex: null == sdpMlineIndex
          ? _value.sdpMlineIndex
          : sdpMlineIndex // ignore: cast_nullable_to_non_nullable
              as int,
      candidate: null == candidate
          ? _value.candidate
          : candidate // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_IceCandidate
    implements PeerConnectionEvent_IceCandidate {
  const _$PeerConnectionEvent_IceCandidate(
      {required this.sdpMid,
      required this.sdpMlineIndex,
      required this.candidate});

  /// Media stream "identification-tag" defined in [RFC 5888] for the
  /// media component the discovered [RTCIceCandidate][1] is associated
  /// with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5888]: https://tools.ietf.org/html/rfc5888
  @override
  final String sdpMid;

  /// Index (starting at zero) of the media description in the SDP this
  /// [RTCIceCandidate][1] is associated with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  @override
  final int sdpMlineIndex;

  /// Candidate-attribute as defined in Section 15.1 of [RFC 5245].
  ///
  /// If this [RTCIceCandidate][1] represents an end-of-candidates
  /// indication or a peer reflexive remote candidate, candidate is an
  /// empty string.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5245]: https://tools.ietf.org/html/rfc5245
  @override
  final String candidate;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceCandidate(sdpMid: $sdpMid, sdpMlineIndex: $sdpMlineIndex, candidate: $candidate)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceCandidate &&
            (identical(other.sdpMid, sdpMid) || other.sdpMid == sdpMid) &&
            (identical(other.sdpMlineIndex, sdpMlineIndex) ||
                other.sdpMlineIndex == sdpMlineIndex) &&
            (identical(other.candidate, candidate) ||
                other.candidate == candidate));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, sdpMid, sdpMlineIndex, candidate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_IceCandidateCopyWith<
          _$PeerConnectionEvent_IceCandidate>
      get copyWith => __$$PeerConnectionEvent_IceCandidateCopyWithImpl<
          _$PeerConnectionEvent_IceCandidate>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return iceCandidate(sdpMid, sdpMlineIndex, candidate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int id)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return iceCandidate?.call(sdpMid, sdpMlineIndex, candidate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (iceCandidate != null) {
      return iceCandidate(sdpMid, sdpMlineIndex, candidate);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
        peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
        iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
        iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
        negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
        signallingChange,
    required TResult Function(
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return iceCandidate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return iceCandidate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (iceCandidate != null) {
      return iceCandidate(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_IceCandidate implements PeerConnectionEvent {
  const factory PeerConnectionEvent_IceCandidate(
      {required final String sdpMid,
      required final int sdpMlineIndex,
      required final String candidate}) = _$PeerConnectionEvent_IceCandidate;

  /// Media stream "identification-tag" defined in [RFC 5888] for the
  /// media component the discovered [RTCIceCandidate][1] is associated
  /// with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5888]: https://tools.ietf.org/html/rfc5888
  String get sdpMid;

  /// Index (starting at zero) of the media description in the SDP this
  /// [RTCIceCandidate][1] is associated with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  int get sdpMlineIndex;

  /// Candidate-attribute as defined in Section 15.1 of [RFC 5245].
  ///
  /// If this [RTCIceCandidate][1] represents an end-of-candidates
  /// indication or a peer reflexive remote candidate, candidate is an
  /// empty string.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5245]: https://tools.ietf.org/html/rfc5245
  String get candidate;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_IceCandidateCopyWith<
          _$PeerConnectionEvent_IceCandidate>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith<$Res> {
  factory _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith(
          _$PeerConnectionEvent_IceGatheringStateChange value,
          $Res Function(_$PeerConnectionEvent_IceGatheringStateChange) then) =
      __$$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl<$Res>;
  @useResult
  $Res call({IceGatheringState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res,
        _$PeerConnectionEvent_IceGatheringStateChange>
    implements _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl(
      _$PeerConnectionEvent_IceGatheringStateChange _value,
      $Res Function(_$PeerConnectionEvent_IceGatheringStateChange) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$PeerConnectionEvent_IceGatheringStateChange(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceGatheringState,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_IceGatheringStateChange
    implements PeerConnectionEvent_IceGatheringStateChange {
  const _$PeerConnectionEvent_IceGatheringStateChange(this.field0);

  @override
  final IceGatheringState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceGatheringStateChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceGatheringStateChange &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith<
          _$PeerConnectionEvent_IceGatheringStateChange>
      get copyWith =>
          __$$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl<
              _$PeerConnectionEvent_IceGatheringStateChange>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return iceGatheringStateChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int id)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return iceGatheringStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (iceGatheringStateChange != null) {
      return iceGatheringStateChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
        peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
        iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
        iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
        negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
        signallingChange,
    required TResult Function(
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return iceGatheringStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return iceGatheringStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (iceGatheringStateChange != null) {
      return iceGatheringStateChange(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_IceGatheringStateChange
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_IceGatheringStateChange(
          final IceGatheringState field0) =
      _$PeerConnectionEvent_IceGatheringStateChange;

  IceGatheringState get field0;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith<
          _$PeerConnectionEvent_IceGatheringStateChange>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceCandidateErrorCopyWith<$Res> {
  factory _$$PeerConnectionEvent_IceCandidateErrorCopyWith(
          _$PeerConnectionEvent_IceCandidateError value,
          $Res Function(_$PeerConnectionEvent_IceCandidateError) then) =
      __$$PeerConnectionEvent_IceCandidateErrorCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String address, int port, String url, int errorCode, String errorText});
}

/// @nodoc
class __$$PeerConnectionEvent_IceCandidateErrorCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res,
        _$PeerConnectionEvent_IceCandidateError>
    implements _$$PeerConnectionEvent_IceCandidateErrorCopyWith<$Res> {
  __$$PeerConnectionEvent_IceCandidateErrorCopyWithImpl(
      _$PeerConnectionEvent_IceCandidateError _value,
      $Res Function(_$PeerConnectionEvent_IceCandidateError) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? port = null,
    Object? url = null,
    Object? errorCode = null,
    Object? errorText = null,
  }) {
    return _then(_$PeerConnectionEvent_IceCandidateError(
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: null == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as int,
      errorText: null == errorText
          ? _value.errorText
          : errorText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_IceCandidateError
    implements PeerConnectionEvent_IceCandidateError {
  const _$PeerConnectionEvent_IceCandidateError(
      {required this.address,
      required this.port,
      required this.url,
      required this.errorCode,
      required this.errorText});

  /// Local IP address used to communicate with the STUN or TURN server.
  @override
  final String address;

  /// Port used to communicate with the STUN or TURN server.
  @override
  final int port;

  /// STUN or TURN URL identifying the STUN or TURN server for which the
  /// failure occurred.
  @override
  final String url;

  /// Numeric STUN error code returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If no host candidate can reach the server, it will be set to the
  /// value `701` which is outside the STUN error code range.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  @override
  final int errorCode;

  /// STUN reason text returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If the server could not be reached, it will be set to an
  /// implementation-specific value providing details about the error.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  @override
  final String errorText;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceCandidateError(address: $address, port: $port, url: $url, errorCode: $errorCode, errorText: $errorText)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceCandidateError &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            (identical(other.errorText, errorText) ||
                other.errorText == errorText));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, address, port, url, errorCode, errorText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_IceCandidateErrorCopyWith<
          _$PeerConnectionEvent_IceCandidateError>
      get copyWith => __$$PeerConnectionEvent_IceCandidateErrorCopyWithImpl<
          _$PeerConnectionEvent_IceCandidateError>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return iceCandidateError(address, port, url, errorCode, errorText);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int id)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return iceCandidateError?.call(address, port, url, errorCode, errorText);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (iceCandidateError != null) {
      return iceCandidateError(address, port, url, errorCode, errorText);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
        peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
        iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
        iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
        negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
        signallingChange,
    required TResult Function(
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return iceCandidateError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return iceCandidateError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (iceCandidateError != null) {
      return iceCandidateError(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_IceCandidateError
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_IceCandidateError(
          {required final String address,
          required final int port,
          required final String url,
          required final int errorCode,
          required final String errorText}) =
      _$PeerConnectionEvent_IceCandidateError;

  /// Local IP address used to communicate with the STUN or TURN server.
  String get address;

  /// Port used to communicate with the STUN or TURN server.
  int get port;

  /// STUN or TURN URL identifying the STUN or TURN server for which the
  /// failure occurred.
  String get url;

  /// Numeric STUN error code returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If no host candidate can reach the server, it will be set to the
  /// value `701` which is outside the STUN error code range.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  int get errorCode;

  /// STUN reason text returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If the server could not be reached, it will be set to an
  /// implementation-specific value providing details about the error.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  String get errorText;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_IceCandidateErrorCopyWith<
          _$PeerConnectionEvent_IceCandidateError>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_NegotiationNeededCopyWith<$Res> {
  factory _$$PeerConnectionEvent_NegotiationNeededCopyWith(
          _$PeerConnectionEvent_NegotiationNeeded value,
          $Res Function(_$PeerConnectionEvent_NegotiationNeeded) then) =
      __$$PeerConnectionEvent_NegotiationNeededCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PeerConnectionEvent_NegotiationNeededCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res,
        _$PeerConnectionEvent_NegotiationNeeded>
    implements _$$PeerConnectionEvent_NegotiationNeededCopyWith<$Res> {
  __$$PeerConnectionEvent_NegotiationNeededCopyWithImpl(
      _$PeerConnectionEvent_NegotiationNeeded _value,
      $Res Function(_$PeerConnectionEvent_NegotiationNeeded) _then)
      : super(_value, _then);
}

/// @nodoc

class _$PeerConnectionEvent_NegotiationNeeded
    implements PeerConnectionEvent_NegotiationNeeded {
  const _$PeerConnectionEvent_NegotiationNeeded();

  @override
  String toString() {
    return 'PeerConnectionEvent.negotiationNeeded()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_NegotiationNeeded);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return negotiationNeeded();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int id)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return negotiationNeeded?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (negotiationNeeded != null) {
      return negotiationNeeded();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
        peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
        iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
        iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
        negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
        signallingChange,
    required TResult Function(
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return negotiationNeeded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return negotiationNeeded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (negotiationNeeded != null) {
      return negotiationNeeded(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_NegotiationNeeded
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_NegotiationNeeded() =
      _$PeerConnectionEvent_NegotiationNeeded;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_SignallingChangeCopyWith<$Res> {
  factory _$$PeerConnectionEvent_SignallingChangeCopyWith(
          _$PeerConnectionEvent_SignallingChange value,
          $Res Function(_$PeerConnectionEvent_SignallingChange) then) =
      __$$PeerConnectionEvent_SignallingChangeCopyWithImpl<$Res>;
  @useResult
  $Res call({SignalingState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_SignallingChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res,
        _$PeerConnectionEvent_SignallingChange>
    implements _$$PeerConnectionEvent_SignallingChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_SignallingChangeCopyWithImpl(
      _$PeerConnectionEvent_SignallingChange _value,
      $Res Function(_$PeerConnectionEvent_SignallingChange) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$PeerConnectionEvent_SignallingChange(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as SignalingState,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_SignallingChange
    implements PeerConnectionEvent_SignallingChange {
  const _$PeerConnectionEvent_SignallingChange(this.field0);

  @override
  final SignalingState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.signallingChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_SignallingChange &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_SignallingChangeCopyWith<
          _$PeerConnectionEvent_SignallingChange>
      get copyWith => __$$PeerConnectionEvent_SignallingChangeCopyWithImpl<
          _$PeerConnectionEvent_SignallingChange>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return signallingChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int id)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return signallingChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (signallingChange != null) {
      return signallingChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
        peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
        iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
        iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
        negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
        signallingChange,
    required TResult Function(
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return signallingChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return signallingChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (signallingChange != null) {
      return signallingChange(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_SignallingChange
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_SignallingChange(
      final SignalingState field0) = _$PeerConnectionEvent_SignallingChange;

  SignalingState get field0;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_SignallingChangeCopyWith<
          _$PeerConnectionEvent_SignallingChange>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith<$Res> {
  factory _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith(
          _$PeerConnectionEvent_IceConnectionStateChange value,
          $Res Function(_$PeerConnectionEvent_IceConnectionStateChange) then) =
      __$$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl<$Res>;
  @useResult
  $Res call({IceConnectionState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res,
        _$PeerConnectionEvent_IceConnectionStateChange>
    implements _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl(
      _$PeerConnectionEvent_IceConnectionStateChange _value,
      $Res Function(_$PeerConnectionEvent_IceConnectionStateChange) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$PeerConnectionEvent_IceConnectionStateChange(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceConnectionState,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_IceConnectionStateChange
    implements PeerConnectionEvent_IceConnectionStateChange {
  const _$PeerConnectionEvent_IceConnectionStateChange(this.field0);

  @override
  final IceConnectionState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceConnectionStateChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceConnectionStateChange &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith<
          _$PeerConnectionEvent_IceConnectionStateChange>
      get copyWith =>
          __$$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl<
              _$PeerConnectionEvent_IceConnectionStateChange>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return iceConnectionStateChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int id)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return iceConnectionStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (iceConnectionStateChange != null) {
      return iceConnectionStateChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
        peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
        iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
        iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
        negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
        signallingChange,
    required TResult Function(
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return iceConnectionStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return iceConnectionStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (iceConnectionStateChange != null) {
      return iceConnectionStateChange(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_IceConnectionStateChange
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_IceConnectionStateChange(
          final IceConnectionState field0) =
      _$PeerConnectionEvent_IceConnectionStateChange;

  IceConnectionState get field0;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith<
          _$PeerConnectionEvent_IceConnectionStateChange>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_ConnectionStateChangeCopyWith<$Res> {
  factory _$$PeerConnectionEvent_ConnectionStateChangeCopyWith(
          _$PeerConnectionEvent_ConnectionStateChange value,
          $Res Function(_$PeerConnectionEvent_ConnectionStateChange) then) =
      __$$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl<$Res>;
  @useResult
  $Res call({PeerConnectionState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res,
        _$PeerConnectionEvent_ConnectionStateChange>
    implements _$$PeerConnectionEvent_ConnectionStateChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl(
      _$PeerConnectionEvent_ConnectionStateChange _value,
      $Res Function(_$PeerConnectionEvent_ConnectionStateChange) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$PeerConnectionEvent_ConnectionStateChange(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PeerConnectionState,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_ConnectionStateChange
    implements PeerConnectionEvent_ConnectionStateChange {
  const _$PeerConnectionEvent_ConnectionStateChange(this.field0);

  @override
  final PeerConnectionState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.connectionStateChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_ConnectionStateChange &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_ConnectionStateChangeCopyWith<
          _$PeerConnectionEvent_ConnectionStateChange>
      get copyWith => __$$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl<
          _$PeerConnectionEvent_ConnectionStateChange>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return connectionStateChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int id)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return connectionStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (connectionStateChange != null) {
      return connectionStateChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
        peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
        iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
        iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
        negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
        signallingChange,
    required TResult Function(
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return connectionStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return connectionStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (connectionStateChange != null) {
      return connectionStateChange(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_ConnectionStateChange
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_ConnectionStateChange(
          final PeerConnectionState field0) =
      _$PeerConnectionEvent_ConnectionStateChange;

  PeerConnectionState get field0;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_ConnectionStateChangeCopyWith<
          _$PeerConnectionEvent_ConnectionStateChange>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_TrackCopyWith<$Res> {
  factory _$$PeerConnectionEvent_TrackCopyWith(
          _$PeerConnectionEvent_Track value,
          $Res Function(_$PeerConnectionEvent_Track) then) =
      __$$PeerConnectionEvent_TrackCopyWithImpl<$Res>;
  @useResult
  $Res call({RtcTrackEvent field0});
}

/// @nodoc
class __$$PeerConnectionEvent_TrackCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res, _$PeerConnectionEvent_Track>
    implements _$$PeerConnectionEvent_TrackCopyWith<$Res> {
  __$$PeerConnectionEvent_TrackCopyWithImpl(_$PeerConnectionEvent_Track _value,
      $Res Function(_$PeerConnectionEvent_Track) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$PeerConnectionEvent_Track(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as RtcTrackEvent,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_Track implements PeerConnectionEvent_Track {
  const _$PeerConnectionEvent_Track(this.field0);

  @override
  final RtcTrackEvent field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.track(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_Track &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_TrackCopyWith<_$PeerConnectionEvent_Track>
      get copyWith => __$$PeerConnectionEvent_TrackCopyWithImpl<
          _$PeerConnectionEvent_Track>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return track(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int id)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return track?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (track != null) {
      return track(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
        peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
        iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
        iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
        negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
        signallingChange,
    required TResult Function(
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return track(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return track?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
        iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
        iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
        negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
        signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
        iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
        connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (track != null) {
      return track(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_Track implements PeerConnectionEvent {
  const factory PeerConnectionEvent_Track(final RtcTrackEvent field0) =
      _$PeerConnectionEvent_Track;

  RtcTrackEvent get field0;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_TrackCopyWith<_$PeerConnectionEvent_Track>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RtcIceCandidateStats {
  IceCandidateStats get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(IceCandidateStats field0) local,
    required TResult Function(IceCandidateStats field0) remote,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(IceCandidateStats field0)? local,
    TResult? Function(IceCandidateStats field0)? remote,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(IceCandidateStats field0)? local,
    TResult Function(IceCandidateStats field0)? remote,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcIceCandidateStats_Local value) local,
    required TResult Function(RtcIceCandidateStats_Remote value) remote,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcIceCandidateStats_Local value)? local,
    TResult? Function(RtcIceCandidateStats_Remote value)? remote,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcIceCandidateStats_Local value)? local,
    TResult Function(RtcIceCandidateStats_Remote value)? remote,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RtcIceCandidateStatsCopyWith<RtcIceCandidateStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RtcIceCandidateStatsCopyWith<$Res> {
  factory $RtcIceCandidateStatsCopyWith(RtcIceCandidateStats value,
          $Res Function(RtcIceCandidateStats) then) =
      _$RtcIceCandidateStatsCopyWithImpl<$Res, RtcIceCandidateStats>;
  @useResult
  $Res call({IceCandidateStats field0});
}

/// @nodoc
class _$RtcIceCandidateStatsCopyWithImpl<$Res,
        $Val extends RtcIceCandidateStats>
    implements $RtcIceCandidateStatsCopyWith<$Res> {
  _$RtcIceCandidateStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_value.copyWith(
      field0: null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceCandidateStats,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RtcIceCandidateStats_LocalCopyWith<$Res>
    implements $RtcIceCandidateStatsCopyWith<$Res> {
  factory _$$RtcIceCandidateStats_LocalCopyWith(
          _$RtcIceCandidateStats_Local value,
          $Res Function(_$RtcIceCandidateStats_Local) then) =
      __$$RtcIceCandidateStats_LocalCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({IceCandidateStats field0});
}

/// @nodoc
class __$$RtcIceCandidateStats_LocalCopyWithImpl<$Res>
    extends _$RtcIceCandidateStatsCopyWithImpl<$Res,
        _$RtcIceCandidateStats_Local>
    implements _$$RtcIceCandidateStats_LocalCopyWith<$Res> {
  __$$RtcIceCandidateStats_LocalCopyWithImpl(
      _$RtcIceCandidateStats_Local _value,
      $Res Function(_$RtcIceCandidateStats_Local) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$RtcIceCandidateStats_Local(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceCandidateStats,
    ));
  }
}

/// @nodoc

class _$RtcIceCandidateStats_Local implements RtcIceCandidateStats_Local {
  const _$RtcIceCandidateStats_Local(this.field0);

  @override
  final IceCandidateStats field0;

  @override
  String toString() {
    return 'RtcIceCandidateStats.local(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcIceCandidateStats_Local &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcIceCandidateStats_LocalCopyWith<_$RtcIceCandidateStats_Local>
      get copyWith => __$$RtcIceCandidateStats_LocalCopyWithImpl<
          _$RtcIceCandidateStats_Local>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(IceCandidateStats field0) local,
    required TResult Function(IceCandidateStats field0) remote,
  }) {
    return local(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(IceCandidateStats field0)? local,
    TResult? Function(IceCandidateStats field0)? remote,
  }) {
    return local?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(IceCandidateStats field0)? local,
    TResult Function(IceCandidateStats field0)? remote,
    required TResult orElse(),
  }) {
    if (local != null) {
      return local(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcIceCandidateStats_Local value) local,
    required TResult Function(RtcIceCandidateStats_Remote value) remote,
  }) {
    return local(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcIceCandidateStats_Local value)? local,
    TResult? Function(RtcIceCandidateStats_Remote value)? remote,
  }) {
    return local?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcIceCandidateStats_Local value)? local,
    TResult Function(RtcIceCandidateStats_Remote value)? remote,
    required TResult orElse(),
  }) {
    if (local != null) {
      return local(this);
    }
    return orElse();
  }
}

abstract class RtcIceCandidateStats_Local implements RtcIceCandidateStats {
  const factory RtcIceCandidateStats_Local(final IceCandidateStats field0) =
      _$RtcIceCandidateStats_Local;

  @override
  IceCandidateStats get field0;
  @override
  @JsonKey(ignore: true)
  _$$RtcIceCandidateStats_LocalCopyWith<_$RtcIceCandidateStats_Local>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcIceCandidateStats_RemoteCopyWith<$Res>
    implements $RtcIceCandidateStatsCopyWith<$Res> {
  factory _$$RtcIceCandidateStats_RemoteCopyWith(
          _$RtcIceCandidateStats_Remote value,
          $Res Function(_$RtcIceCandidateStats_Remote) then) =
      __$$RtcIceCandidateStats_RemoteCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({IceCandidateStats field0});
}

/// @nodoc
class __$$RtcIceCandidateStats_RemoteCopyWithImpl<$Res>
    extends _$RtcIceCandidateStatsCopyWithImpl<$Res,
        _$RtcIceCandidateStats_Remote>
    implements _$$RtcIceCandidateStats_RemoteCopyWith<$Res> {
  __$$RtcIceCandidateStats_RemoteCopyWithImpl(
      _$RtcIceCandidateStats_Remote _value,
      $Res Function(_$RtcIceCandidateStats_Remote) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$RtcIceCandidateStats_Remote(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceCandidateStats,
    ));
  }
}

/// @nodoc

class _$RtcIceCandidateStats_Remote implements RtcIceCandidateStats_Remote {
  const _$RtcIceCandidateStats_Remote(this.field0);

  @override
  final IceCandidateStats field0;

  @override
  String toString() {
    return 'RtcIceCandidateStats.remote(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcIceCandidateStats_Remote &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcIceCandidateStats_RemoteCopyWith<_$RtcIceCandidateStats_Remote>
      get copyWith => __$$RtcIceCandidateStats_RemoteCopyWithImpl<
          _$RtcIceCandidateStats_Remote>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(IceCandidateStats field0) local,
    required TResult Function(IceCandidateStats field0) remote,
  }) {
    return remote(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(IceCandidateStats field0)? local,
    TResult? Function(IceCandidateStats field0)? remote,
  }) {
    return remote?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(IceCandidateStats field0)? local,
    TResult Function(IceCandidateStats field0)? remote,
    required TResult orElse(),
  }) {
    if (remote != null) {
      return remote(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcIceCandidateStats_Local value) local,
    required TResult Function(RtcIceCandidateStats_Remote value) remote,
  }) {
    return remote(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcIceCandidateStats_Local value)? local,
    TResult? Function(RtcIceCandidateStats_Remote value)? remote,
  }) {
    return remote?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcIceCandidateStats_Local value)? local,
    TResult Function(RtcIceCandidateStats_Remote value)? remote,
    required TResult orElse(),
  }) {
    if (remote != null) {
      return remote(this);
    }
    return orElse();
  }
}

abstract class RtcIceCandidateStats_Remote implements RtcIceCandidateStats {
  const factory RtcIceCandidateStats_Remote(final IceCandidateStats field0) =
      _$RtcIceCandidateStats_Remote;

  @override
  IceCandidateStats get field0;
  @override
  @JsonKey(ignore: true)
  _$$RtcIceCandidateStats_RemoteCopyWith<_$RtcIceCandidateStats_Remote>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RtcInboundRtpStreamMediaType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            bool? voiceActivityFlag,
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)
        audio,
    required TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? firCount,
            int? pliCount,
            int? sliCount,
            int? concealmentEvents,
            int? framesReceived)
        video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            bool? voiceActivityFlag,
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult? Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? firCount,
            int? pliCount,
            int? sliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            bool? voiceActivityFlag,
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? firCount,
            int? pliCount,
            int? sliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcInboundRtpStreamMediaType_Audio value) audio,
    required TResult Function(RtcInboundRtpStreamMediaType_Video value) video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcInboundRtpStreamMediaType_Audio value)? audio,
    TResult? Function(RtcInboundRtpStreamMediaType_Video value)? video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcInboundRtpStreamMediaType_Audio value)? audio,
    TResult Function(RtcInboundRtpStreamMediaType_Video value)? video,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RtcInboundRtpStreamMediaTypeCopyWith<$Res> {
  factory $RtcInboundRtpStreamMediaTypeCopyWith(
          RtcInboundRtpStreamMediaType value,
          $Res Function(RtcInboundRtpStreamMediaType) then) =
      _$RtcInboundRtpStreamMediaTypeCopyWithImpl<$Res,
          RtcInboundRtpStreamMediaType>;
}

/// @nodoc
class _$RtcInboundRtpStreamMediaTypeCopyWithImpl<$Res,
        $Val extends RtcInboundRtpStreamMediaType>
    implements $RtcInboundRtpStreamMediaTypeCopyWith<$Res> {
  _$RtcInboundRtpStreamMediaTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$RtcInboundRtpStreamMediaType_AudioCopyWith<$Res> {
  factory _$$RtcInboundRtpStreamMediaType_AudioCopyWith(
          _$RtcInboundRtpStreamMediaType_Audio value,
          $Res Function(_$RtcInboundRtpStreamMediaType_Audio) then) =
      __$$RtcInboundRtpStreamMediaType_AudioCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {bool? voiceActivityFlag,
      int? totalSamplesReceived,
      int? concealedSamples,
      int? silentConcealedSamples,
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration});
}

/// @nodoc
class __$$RtcInboundRtpStreamMediaType_AudioCopyWithImpl<$Res>
    extends _$RtcInboundRtpStreamMediaTypeCopyWithImpl<$Res,
        _$RtcInboundRtpStreamMediaType_Audio>
    implements _$$RtcInboundRtpStreamMediaType_AudioCopyWith<$Res> {
  __$$RtcInboundRtpStreamMediaType_AudioCopyWithImpl(
      _$RtcInboundRtpStreamMediaType_Audio _value,
      $Res Function(_$RtcInboundRtpStreamMediaType_Audio) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? voiceActivityFlag = freezed,
    Object? totalSamplesReceived = freezed,
    Object? concealedSamples = freezed,
    Object? silentConcealedSamples = freezed,
    Object? audioLevel = freezed,
    Object? totalAudioEnergy = freezed,
    Object? totalSamplesDuration = freezed,
  }) {
    return _then(_$RtcInboundRtpStreamMediaType_Audio(
      voiceActivityFlag: freezed == voiceActivityFlag
          ? _value.voiceActivityFlag
          : voiceActivityFlag // ignore: cast_nullable_to_non_nullable
              as bool?,
      totalSamplesReceived: freezed == totalSamplesReceived
          ? _value.totalSamplesReceived
          : totalSamplesReceived // ignore: cast_nullable_to_non_nullable
              as int?,
      concealedSamples: freezed == concealedSamples
          ? _value.concealedSamples
          : concealedSamples // ignore: cast_nullable_to_non_nullable
              as int?,
      silentConcealedSamples: freezed == silentConcealedSamples
          ? _value.silentConcealedSamples
          : silentConcealedSamples // ignore: cast_nullable_to_non_nullable
              as int?,
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
    ));
  }
}

/// @nodoc

class _$RtcInboundRtpStreamMediaType_Audio
    implements RtcInboundRtpStreamMediaType_Audio {
  const _$RtcInboundRtpStreamMediaType_Audio(
      {this.voiceActivityFlag,
      this.totalSamplesReceived,
      this.concealedSamples,
      this.silentConcealedSamples,
      this.audioLevel,
      this.totalAudioEnergy,
      this.totalSamplesDuration});

  /// Indicator whether the last RTP packet whose frame was delivered to
  /// the [RTCRtpReceiver]'s [MediaStreamTrack][1] for playout contained
  /// voice activity or not based on the presence of the V bit in the
  /// extension header, as defined in [RFC 6464].
  ///
  /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#rtcrtpreceiver-interface
  /// [RFC 6464]: https://tools.ietf.org/html/rfc6464#page-3
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  @override
  final bool? voiceActivityFlag;

  /// Total number of samples that have been received on this RTP stream.
  /// This includes [concealedSamples].
  ///
  /// [concealedSamples]: https://tinyurl.com/s6c4qe4
  @override
  final int? totalSamplesReceived;

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
  @override
  final int? concealedSamples;

  /// Total number of concealed samples inserted that are "silent".
  ///
  /// Playing out silent samples results in silence or comfort noise.
  /// This is a subset of [concealedSamples].
  ///
  /// [concealedSamples]: https://tinyurl.com/s6c4qe4
  @override
  final int? silentConcealedSamples;

  /// Audio level of the receiving track.
  @override
  final double? audioLevel;

  /// Audio energy of the receiving track.
  @override
  final double? totalAudioEnergy;

  /// Audio duration of the receiving track.
  ///
  /// For audio durations of tracks attached locally, see
  /// [RTCAudioSourceStats][1] instead.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcaudiosourcestats
  @override
  final double? totalSamplesDuration;

  @override
  String toString() {
    return 'RtcInboundRtpStreamMediaType.audio(voiceActivityFlag: $voiceActivityFlag, totalSamplesReceived: $totalSamplesReceived, concealedSamples: $concealedSamples, silentConcealedSamples: $silentConcealedSamples, audioLevel: $audioLevel, totalAudioEnergy: $totalAudioEnergy, totalSamplesDuration: $totalSamplesDuration)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcInboundRtpStreamMediaType_Audio &&
            (identical(other.voiceActivityFlag, voiceActivityFlag) ||
                other.voiceActivityFlag == voiceActivityFlag) &&
            (identical(other.totalSamplesReceived, totalSamplesReceived) ||
                other.totalSamplesReceived == totalSamplesReceived) &&
            (identical(other.concealedSamples, concealedSamples) ||
                other.concealedSamples == concealedSamples) &&
            (identical(other.silentConcealedSamples, silentConcealedSamples) ||
                other.silentConcealedSamples == silentConcealedSamples) &&
            (identical(other.audioLevel, audioLevel) ||
                other.audioLevel == audioLevel) &&
            (identical(other.totalAudioEnergy, totalAudioEnergy) ||
                other.totalAudioEnergy == totalAudioEnergy) &&
            (identical(other.totalSamplesDuration, totalSamplesDuration) ||
                other.totalSamplesDuration == totalSamplesDuration));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      voiceActivityFlag,
      totalSamplesReceived,
      concealedSamples,
      silentConcealedSamples,
      audioLevel,
      totalAudioEnergy,
      totalSamplesDuration);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcInboundRtpStreamMediaType_AudioCopyWith<
          _$RtcInboundRtpStreamMediaType_Audio>
      get copyWith => __$$RtcInboundRtpStreamMediaType_AudioCopyWithImpl<
          _$RtcInboundRtpStreamMediaType_Audio>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            bool? voiceActivityFlag,
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)
        audio,
    required TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? firCount,
            int? pliCount,
            int? sliCount,
            int? concealmentEvents,
            int? framesReceived)
        video,
  }) {
    return audio(
        voiceActivityFlag,
        totalSamplesReceived,
        concealedSamples,
        silentConcealedSamples,
        audioLevel,
        totalAudioEnergy,
        totalSamplesDuration);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            bool? voiceActivityFlag,
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult? Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? firCount,
            int? pliCount,
            int? sliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
  }) {
    return audio?.call(
        voiceActivityFlag,
        totalSamplesReceived,
        concealedSamples,
        silentConcealedSamples,
        audioLevel,
        totalAudioEnergy,
        totalSamplesDuration);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            bool? voiceActivityFlag,
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? firCount,
            int? pliCount,
            int? sliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(
          voiceActivityFlag,
          totalSamplesReceived,
          concealedSamples,
          silentConcealedSamples,
          audioLevel,
          totalAudioEnergy,
          totalSamplesDuration);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcInboundRtpStreamMediaType_Audio value) audio,
    required TResult Function(RtcInboundRtpStreamMediaType_Video value) video,
  }) {
    return audio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcInboundRtpStreamMediaType_Audio value)? audio,
    TResult? Function(RtcInboundRtpStreamMediaType_Video value)? video,
  }) {
    return audio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcInboundRtpStreamMediaType_Audio value)? audio,
    TResult Function(RtcInboundRtpStreamMediaType_Video value)? video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(this);
    }
    return orElse();
  }
}

abstract class RtcInboundRtpStreamMediaType_Audio
    implements RtcInboundRtpStreamMediaType {
  const factory RtcInboundRtpStreamMediaType_Audio(
          {final bool? voiceActivityFlag,
          final int? totalSamplesReceived,
          final int? concealedSamples,
          final int? silentConcealedSamples,
          final double? audioLevel,
          final double? totalAudioEnergy,
          final double? totalSamplesDuration}) =
      _$RtcInboundRtpStreamMediaType_Audio;

  /// Indicator whether the last RTP packet whose frame was delivered to
  /// the [RTCRtpReceiver]'s [MediaStreamTrack][1] for playout contained
  /// voice activity or not based on the presence of the V bit in the
  /// extension header, as defined in [RFC 6464].
  ///
  /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#rtcrtpreceiver-interface
  /// [RFC 6464]: https://tools.ietf.org/html/rfc6464#page-3
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  bool? get voiceActivityFlag;

  /// Total number of samples that have been received on this RTP stream.
  /// This includes [concealedSamples].
  ///
  /// [concealedSamples]: https://tinyurl.com/s6c4qe4
  int? get totalSamplesReceived;

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
  int? get concealedSamples;

  /// Total number of concealed samples inserted that are "silent".
  ///
  /// Playing out silent samples results in silence or comfort noise.
  /// This is a subset of [concealedSamples].
  ///
  /// [concealedSamples]: https://tinyurl.com/s6c4qe4
  int? get silentConcealedSamples;

  /// Audio level of the receiving track.
  double? get audioLevel;

  /// Audio energy of the receiving track.
  double? get totalAudioEnergy;

  /// Audio duration of the receiving track.
  ///
  /// For audio durations of tracks attached locally, see
  /// [RTCAudioSourceStats][1] instead.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcaudiosourcestats
  double? get totalSamplesDuration;
  @JsonKey(ignore: true)
  _$$RtcInboundRtpStreamMediaType_AudioCopyWith<
          _$RtcInboundRtpStreamMediaType_Audio>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcInboundRtpStreamMediaType_VideoCopyWith<$Res> {
  factory _$$RtcInboundRtpStreamMediaType_VideoCopyWith(
          _$RtcInboundRtpStreamMediaType_Video value,
          $Res Function(_$RtcInboundRtpStreamMediaType_Video) then) =
      __$$RtcInboundRtpStreamMediaType_VideoCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {int? framesDecoded,
      int? keyFramesDecoded,
      int? frameWidth,
      int? frameHeight,
      double? totalInterFrameDelay,
      double? framesPerSecond,
      int? firCount,
      int? pliCount,
      int? sliCount,
      int? concealmentEvents,
      int? framesReceived});
}

/// @nodoc
class __$$RtcInboundRtpStreamMediaType_VideoCopyWithImpl<$Res>
    extends _$RtcInboundRtpStreamMediaTypeCopyWithImpl<$Res,
        _$RtcInboundRtpStreamMediaType_Video>
    implements _$$RtcInboundRtpStreamMediaType_VideoCopyWith<$Res> {
  __$$RtcInboundRtpStreamMediaType_VideoCopyWithImpl(
      _$RtcInboundRtpStreamMediaType_Video _value,
      $Res Function(_$RtcInboundRtpStreamMediaType_Video) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? framesDecoded = freezed,
    Object? keyFramesDecoded = freezed,
    Object? frameWidth = freezed,
    Object? frameHeight = freezed,
    Object? totalInterFrameDelay = freezed,
    Object? framesPerSecond = freezed,
    Object? firCount = freezed,
    Object? pliCount = freezed,
    Object? sliCount = freezed,
    Object? concealmentEvents = freezed,
    Object? framesReceived = freezed,
  }) {
    return _then(_$RtcInboundRtpStreamMediaType_Video(
      framesDecoded: freezed == framesDecoded
          ? _value.framesDecoded
          : framesDecoded // ignore: cast_nullable_to_non_nullable
              as int?,
      keyFramesDecoded: freezed == keyFramesDecoded
          ? _value.keyFramesDecoded
          : keyFramesDecoded // ignore: cast_nullable_to_non_nullable
              as int?,
      frameWidth: freezed == frameWidth
          ? _value.frameWidth
          : frameWidth // ignore: cast_nullable_to_non_nullable
              as int?,
      frameHeight: freezed == frameHeight
          ? _value.frameHeight
          : frameHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      totalInterFrameDelay: freezed == totalInterFrameDelay
          ? _value.totalInterFrameDelay
          : totalInterFrameDelay // ignore: cast_nullable_to_non_nullable
              as double?,
      framesPerSecond: freezed == framesPerSecond
          ? _value.framesPerSecond
          : framesPerSecond // ignore: cast_nullable_to_non_nullable
              as double?,
      firCount: freezed == firCount
          ? _value.firCount
          : firCount // ignore: cast_nullable_to_non_nullable
              as int?,
      pliCount: freezed == pliCount
          ? _value.pliCount
          : pliCount // ignore: cast_nullable_to_non_nullable
              as int?,
      sliCount: freezed == sliCount
          ? _value.sliCount
          : sliCount // ignore: cast_nullable_to_non_nullable
              as int?,
      concealmentEvents: freezed == concealmentEvents
          ? _value.concealmentEvents
          : concealmentEvents // ignore: cast_nullable_to_non_nullable
              as int?,
      framesReceived: freezed == framesReceived
          ? _value.framesReceived
          : framesReceived // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$RtcInboundRtpStreamMediaType_Video
    implements RtcInboundRtpStreamMediaType_Video {
  const _$RtcInboundRtpStreamMediaType_Video(
      {this.framesDecoded,
      this.keyFramesDecoded,
      this.frameWidth,
      this.frameHeight,
      this.totalInterFrameDelay,
      this.framesPerSecond,
      this.firCount,
      this.pliCount,
      this.sliCount,
      this.concealmentEvents,
      this.framesReceived});

  /// Total number of frames correctly decoded for this RTP stream, i.e.
  /// frames that would be displayed if no frames are dropped.
  @override
  final int? framesDecoded;

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
  @override
  final int? keyFramesDecoded;

  /// Width of the last decoded frame.
  ///
  /// Before the first frame is decoded this attribute is missing.
  @override
  final int? frameWidth;

  /// Height of the last decoded frame.
  ///
  /// Before the first frame is decoded this attribute is missing.
  @override
  final int? frameHeight;

  /// Sum of the interframe delays in seconds between consecutively
  /// decoded frames, recorded just after a frame has been decoded.
  @override
  final double? totalInterFrameDelay;

  /// Number of decoded frames in the last second.
  @override
  final double? framesPerSecond;

  /// Total number of Full Intra Request (FIR) packets sent by this
  /// receiver.
  @override
  final int? firCount;

  /// Total number of Picture Loss Indication (PLI) packets sent by this
  /// receiver.
  @override
  final int? pliCount;

  /// Total number of Slice Loss Indication (SLI) packets sent by this
  /// receiver.
  @override
  final int? sliCount;

  /// Number of concealment events.
  ///
  /// This counter increases every time a concealed sample is synthesized
  /// after a non-concealed sample. That is, multiple consecutive
  /// concealed samples will increase the [concealedSamples] count
  /// multiple times but is a single concealment event.
  ///
  /// [concealedSamples]: https://tinyurl.com/s6c4qe4
  @override
  final int? concealmentEvents;

  /// Total number of complete frames received on this RTP stream.
  ///
  /// This metric is incremented when the complete frame is received.
  @override
  final int? framesReceived;

  @override
  String toString() {
    return 'RtcInboundRtpStreamMediaType.video(framesDecoded: $framesDecoded, keyFramesDecoded: $keyFramesDecoded, frameWidth: $frameWidth, frameHeight: $frameHeight, totalInterFrameDelay: $totalInterFrameDelay, framesPerSecond: $framesPerSecond, firCount: $firCount, pliCount: $pliCount, sliCount: $sliCount, concealmentEvents: $concealmentEvents, framesReceived: $framesReceived)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcInboundRtpStreamMediaType_Video &&
            (identical(other.framesDecoded, framesDecoded) ||
                other.framesDecoded == framesDecoded) &&
            (identical(other.keyFramesDecoded, keyFramesDecoded) ||
                other.keyFramesDecoded == keyFramesDecoded) &&
            (identical(other.frameWidth, frameWidth) ||
                other.frameWidth == frameWidth) &&
            (identical(other.frameHeight, frameHeight) ||
                other.frameHeight == frameHeight) &&
            (identical(other.totalInterFrameDelay, totalInterFrameDelay) ||
                other.totalInterFrameDelay == totalInterFrameDelay) &&
            (identical(other.framesPerSecond, framesPerSecond) ||
                other.framesPerSecond == framesPerSecond) &&
            (identical(other.firCount, firCount) ||
                other.firCount == firCount) &&
            (identical(other.pliCount, pliCount) ||
                other.pliCount == pliCount) &&
            (identical(other.sliCount, sliCount) ||
                other.sliCount == sliCount) &&
            (identical(other.concealmentEvents, concealmentEvents) ||
                other.concealmentEvents == concealmentEvents) &&
            (identical(other.framesReceived, framesReceived) ||
                other.framesReceived == framesReceived));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      framesDecoded,
      keyFramesDecoded,
      frameWidth,
      frameHeight,
      totalInterFrameDelay,
      framesPerSecond,
      firCount,
      pliCount,
      sliCount,
      concealmentEvents,
      framesReceived);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcInboundRtpStreamMediaType_VideoCopyWith<
          _$RtcInboundRtpStreamMediaType_Video>
      get copyWith => __$$RtcInboundRtpStreamMediaType_VideoCopyWithImpl<
          _$RtcInboundRtpStreamMediaType_Video>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            bool? voiceActivityFlag,
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)
        audio,
    required TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? firCount,
            int? pliCount,
            int? sliCount,
            int? concealmentEvents,
            int? framesReceived)
        video,
  }) {
    return video(
        framesDecoded,
        keyFramesDecoded,
        frameWidth,
        frameHeight,
        totalInterFrameDelay,
        framesPerSecond,
        firCount,
        pliCount,
        sliCount,
        concealmentEvents,
        framesReceived);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            bool? voiceActivityFlag,
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult? Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? firCount,
            int? pliCount,
            int? sliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
  }) {
    return video?.call(
        framesDecoded,
        keyFramesDecoded,
        frameWidth,
        frameHeight,
        totalInterFrameDelay,
        framesPerSecond,
        firCount,
        pliCount,
        sliCount,
        concealmentEvents,
        framesReceived);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            bool? voiceActivityFlag,
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? firCount,
            int? pliCount,
            int? sliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(
          framesDecoded,
          keyFramesDecoded,
          frameWidth,
          frameHeight,
          totalInterFrameDelay,
          framesPerSecond,
          firCount,
          pliCount,
          sliCount,
          concealmentEvents,
          framesReceived);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcInboundRtpStreamMediaType_Audio value) audio,
    required TResult Function(RtcInboundRtpStreamMediaType_Video value) video,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcInboundRtpStreamMediaType_Audio value)? audio,
    TResult? Function(RtcInboundRtpStreamMediaType_Video value)? video,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcInboundRtpStreamMediaType_Audio value)? audio,
    TResult Function(RtcInboundRtpStreamMediaType_Video value)? video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }
}

abstract class RtcInboundRtpStreamMediaType_Video
    implements RtcInboundRtpStreamMediaType {
  const factory RtcInboundRtpStreamMediaType_Video(
      {final int? framesDecoded,
      final int? keyFramesDecoded,
      final int? frameWidth,
      final int? frameHeight,
      final double? totalInterFrameDelay,
      final double? framesPerSecond,
      final int? firCount,
      final int? pliCount,
      final int? sliCount,
      final int? concealmentEvents,
      final int? framesReceived}) = _$RtcInboundRtpStreamMediaType_Video;

  /// Total number of frames correctly decoded for this RTP stream, i.e.
  /// frames that would be displayed if no frames are dropped.
  int? get framesDecoded;

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
  int? get keyFramesDecoded;

  /// Width of the last decoded frame.
  ///
  /// Before the first frame is decoded this attribute is missing.
  int? get frameWidth;

  /// Height of the last decoded frame.
  ///
  /// Before the first frame is decoded this attribute is missing.
  int? get frameHeight;

  /// Sum of the interframe delays in seconds between consecutively
  /// decoded frames, recorded just after a frame has been decoded.
  double? get totalInterFrameDelay;

  /// Number of decoded frames in the last second.
  double? get framesPerSecond;

  /// Total number of Full Intra Request (FIR) packets sent by this
  /// receiver.
  int? get firCount;

  /// Total number of Picture Loss Indication (PLI) packets sent by this
  /// receiver.
  int? get pliCount;

  /// Total number of Slice Loss Indication (SLI) packets sent by this
  /// receiver.
  int? get sliCount;

  /// Number of concealment events.
  ///
  /// This counter increases every time a concealed sample is synthesized
  /// after a non-concealed sample. That is, multiple consecutive
  /// concealed samples will increase the [concealedSamples] count
  /// multiple times but is a single concealment event.
  ///
  /// [concealedSamples]: https://tinyurl.com/s6c4qe4
  int? get concealmentEvents;

  /// Total number of complete frames received on this RTP stream.
  ///
  /// This metric is incremented when the complete frame is received.
  int? get framesReceived;
  @JsonKey(ignore: true)
  _$$RtcInboundRtpStreamMediaType_VideoCopyWith<
          _$RtcInboundRtpStreamMediaType_Video>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RtcMediaSourceStatsMediaType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)
        rtcVideoSourceStats,
    required TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)
        rtcAudioSourceStats,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult? Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(
            RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)
        rtcVideoSourceStats,
    required TResult Function(
            RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)
        rtcAudioSourceStats,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)?
        rtcVideoSourceStats,
    TResult? Function(RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)?
        rtcAudioSourceStats,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)?
        rtcVideoSourceStats,
    TResult Function(RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)?
        rtcAudioSourceStats,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RtcMediaSourceStatsMediaTypeCopyWith<$Res> {
  factory $RtcMediaSourceStatsMediaTypeCopyWith(
          RtcMediaSourceStatsMediaType value,
          $Res Function(RtcMediaSourceStatsMediaType) then) =
      _$RtcMediaSourceStatsMediaTypeCopyWithImpl<$Res,
          RtcMediaSourceStatsMediaType>;
}

/// @nodoc
class _$RtcMediaSourceStatsMediaTypeCopyWithImpl<$Res,
        $Val extends RtcMediaSourceStatsMediaType>
    implements $RtcMediaSourceStatsMediaTypeCopyWith<$Res> {
  _$RtcMediaSourceStatsMediaTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWith<
    $Res> {
  factory _$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWith(
          _$RtcMediaSourceStatsMediaType_RtcVideoSourceStats value,
          $Res Function(_$RtcMediaSourceStatsMediaType_RtcVideoSourceStats)
              then) =
      __$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWithImpl<$Res>;
  @useResult
  $Res call({int? width, int? height, int? frames, double? framesPerSecond});
}

/// @nodoc
class __$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWithImpl<$Res>
    extends _$RtcMediaSourceStatsMediaTypeCopyWithImpl<$Res,
        _$RtcMediaSourceStatsMediaType_RtcVideoSourceStats>
    implements
        _$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWith<$Res> {
  __$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWithImpl(
      _$RtcMediaSourceStatsMediaType_RtcVideoSourceStats _value,
      $Res Function(_$RtcMediaSourceStatsMediaType_RtcVideoSourceStats) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = freezed,
    Object? height = freezed,
    Object? frames = freezed,
    Object? framesPerSecond = freezed,
  }) {
    return _then(_$RtcMediaSourceStatsMediaType_RtcVideoSourceStats(
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
    ));
  }
}

/// @nodoc

class _$RtcMediaSourceStatsMediaType_RtcVideoSourceStats
    implements RtcMediaSourceStatsMediaType_RtcVideoSourceStats {
  const _$RtcMediaSourceStatsMediaType_RtcVideoSourceStats(
      {this.width, this.height, this.frames, this.framesPerSecond});

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcMediaSourceStatsMediaType_RtcVideoSourceStats &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.frames, frames) || other.frames == frames) &&
            (identical(other.framesPerSecond, framesPerSecond) ||
                other.framesPerSecond == framesPerSecond));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, width, height, frames, framesPerSecond);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWith<
          _$RtcMediaSourceStatsMediaType_RtcVideoSourceStats>
      get copyWith =>
          __$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWithImpl<
                  _$RtcMediaSourceStatsMediaType_RtcVideoSourceStats>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)
        rtcVideoSourceStats,
    required TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)
        rtcAudioSourceStats,
  }) {
    return rtcVideoSourceStats(width, height, frames, framesPerSecond);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult? Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
  }) {
    return rtcVideoSourceStats?.call(width, height, frames, framesPerSecond);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
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
            RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)
        rtcVideoSourceStats,
    required TResult Function(
            RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)
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
    implements RtcMediaSourceStatsMediaType {
  const factory RtcMediaSourceStatsMediaType_RtcVideoSourceStats(
          {final int? width,
          final int? height,
          final int? frames,
          final double? framesPerSecond}) =
      _$RtcMediaSourceStatsMediaType_RtcVideoSourceStats;

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
  @JsonKey(ignore: true)
  _$$RtcMediaSourceStatsMediaType_RtcVideoSourceStatsCopyWith<
          _$RtcMediaSourceStatsMediaType_RtcVideoSourceStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWith<
    $Res> {
  factory _$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWith(
          _$RtcMediaSourceStatsMediaType_RtcAudioSourceStats value,
          $Res Function(_$RtcMediaSourceStatsMediaType_RtcAudioSourceStats)
              then) =
      __$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement});
}

/// @nodoc
class __$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWithImpl<$Res>
    extends _$RtcMediaSourceStatsMediaTypeCopyWithImpl<$Res,
        _$RtcMediaSourceStatsMediaType_RtcAudioSourceStats>
    implements
        _$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWith<$Res> {
  __$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWithImpl(
      _$RtcMediaSourceStatsMediaType_RtcAudioSourceStats _value,
      $Res Function(_$RtcMediaSourceStatsMediaType_RtcAudioSourceStats) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audioLevel = freezed,
    Object? totalAudioEnergy = freezed,
    Object? totalSamplesDuration = freezed,
    Object? echoReturnLoss = freezed,
    Object? echoReturnLossEnhancement = freezed,
  }) {
    return _then(_$RtcMediaSourceStatsMediaType_RtcAudioSourceStats(
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
    ));
  }
}

/// @nodoc

class _$RtcMediaSourceStatsMediaType_RtcAudioSourceStats
    implements RtcMediaSourceStatsMediaType_RtcAudioSourceStats {
  const _$RtcMediaSourceStatsMediaType_RtcAudioSourceStats(
      {this.audioLevel,
      this.totalAudioEnergy,
      this.totalSamplesDuration,
      this.echoReturnLoss,
      this.echoReturnLossEnhancement});

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcMediaSourceStatsMediaType_RtcAudioSourceStats &&
            (identical(other.audioLevel, audioLevel) ||
                other.audioLevel == audioLevel) &&
            (identical(other.totalAudioEnergy, totalAudioEnergy) ||
                other.totalAudioEnergy == totalAudioEnergy) &&
            (identical(other.totalSamplesDuration, totalSamplesDuration) ||
                other.totalSamplesDuration == totalSamplesDuration) &&
            (identical(other.echoReturnLoss, echoReturnLoss) ||
                other.echoReturnLoss == echoReturnLoss) &&
            (identical(other.echoReturnLossEnhancement,
                    echoReturnLossEnhancement) ||
                other.echoReturnLossEnhancement == echoReturnLossEnhancement));
  }

  @override
  int get hashCode => Object.hash(runtimeType, audioLevel, totalAudioEnergy,
      totalSamplesDuration, echoReturnLoss, echoReturnLossEnhancement);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWith<
          _$RtcMediaSourceStatsMediaType_RtcAudioSourceStats>
      get copyWith =>
          __$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWithImpl<
                  _$RtcMediaSourceStatsMediaType_RtcAudioSourceStats>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)
        rtcVideoSourceStats,
    required TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)
        rtcAudioSourceStats,
  }) {
    return rtcAudioSourceStats(audioLevel, totalAudioEnergy,
        totalSamplesDuration, echoReturnLoss, echoReturnLossEnhancement);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult? Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
  }) {
    return rtcAudioSourceStats?.call(audioLevel, totalAudioEnergy,
        totalSamplesDuration, echoReturnLoss, echoReturnLossEnhancement);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
    required TResult orElse(),
  }) {
    if (rtcAudioSourceStats != null) {
      return rtcAudioSourceStats(audioLevel, totalAudioEnergy,
          totalSamplesDuration, echoReturnLoss, echoReturnLossEnhancement);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(
            RtcMediaSourceStatsMediaType_RtcVideoSourceStats value)
        rtcVideoSourceStats,
    required TResult Function(
            RtcMediaSourceStatsMediaType_RtcAudioSourceStats value)
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
    implements RtcMediaSourceStatsMediaType {
  const factory RtcMediaSourceStatsMediaType_RtcAudioSourceStats(
          {final double? audioLevel,
          final double? totalAudioEnergy,
          final double? totalSamplesDuration,
          final double? echoReturnLoss,
          final double? echoReturnLossEnhancement}) =
      _$RtcMediaSourceStatsMediaType_RtcAudioSourceStats;

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
  @JsonKey(ignore: true)
  _$$RtcMediaSourceStatsMediaType_RtcAudioSourceStatsCopyWith<
          _$RtcMediaSourceStatsMediaType_RtcAudioSourceStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RtcOutboundRtpStreamStatsMediaType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? totalSamplesSent, bool? voiceActivityFlag)
        audio,
    required TResult Function(
            int? frameWidth, int? frameHeight, double? framesPerSecond)
        video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult? Function(
            int? frameWidth, int? frameHeight, double? framesPerSecond)?
        video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult Function(
            int? frameWidth, int? frameHeight, double? framesPerSecond)?
        video,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RtcOutboundRtpStreamStatsMediaType_Audio value)
        audio,
    required TResult Function(RtcOutboundRtpStreamStatsMediaType_Video value)
        video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RtcOutboundRtpStreamStatsMediaType_Audio value)? audio,
    TResult? Function(RtcOutboundRtpStreamStatsMediaType_Video value)? video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RtcOutboundRtpStreamStatsMediaType_Audio value)? audio,
    TResult Function(RtcOutboundRtpStreamStatsMediaType_Video value)? video,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> {
  factory $RtcOutboundRtpStreamStatsMediaTypeCopyWith(
          RtcOutboundRtpStreamStatsMediaType value,
          $Res Function(RtcOutboundRtpStreamStatsMediaType) then) =
      _$RtcOutboundRtpStreamStatsMediaTypeCopyWithImpl<$Res,
          RtcOutboundRtpStreamStatsMediaType>;
}

/// @nodoc
class _$RtcOutboundRtpStreamStatsMediaTypeCopyWithImpl<$Res,
        $Val extends RtcOutboundRtpStreamStatsMediaType>
    implements $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> {
  _$RtcOutboundRtpStreamStatsMediaTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$RtcOutboundRtpStreamStatsMediaType_AudioCopyWith<$Res> {
  factory _$$RtcOutboundRtpStreamStatsMediaType_AudioCopyWith(
          _$RtcOutboundRtpStreamStatsMediaType_Audio value,
          $Res Function(_$RtcOutboundRtpStreamStatsMediaType_Audio) then) =
      __$$RtcOutboundRtpStreamStatsMediaType_AudioCopyWithImpl<$Res>;
  @useResult
  $Res call({int? totalSamplesSent, bool? voiceActivityFlag});
}

/// @nodoc
class __$$RtcOutboundRtpStreamStatsMediaType_AudioCopyWithImpl<$Res>
    extends _$RtcOutboundRtpStreamStatsMediaTypeCopyWithImpl<$Res,
        _$RtcOutboundRtpStreamStatsMediaType_Audio>
    implements _$$RtcOutboundRtpStreamStatsMediaType_AudioCopyWith<$Res> {
  __$$RtcOutboundRtpStreamStatsMediaType_AudioCopyWithImpl(
      _$RtcOutboundRtpStreamStatsMediaType_Audio _value,
      $Res Function(_$RtcOutboundRtpStreamStatsMediaType_Audio) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSamplesSent = freezed,
    Object? voiceActivityFlag = freezed,
  }) {
    return _then(_$RtcOutboundRtpStreamStatsMediaType_Audio(
      totalSamplesSent: freezed == totalSamplesSent
          ? _value.totalSamplesSent
          : totalSamplesSent // ignore: cast_nullable_to_non_nullable
              as int?,
      voiceActivityFlag: freezed == voiceActivityFlag
          ? _value.voiceActivityFlag
          : voiceActivityFlag // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$RtcOutboundRtpStreamStatsMediaType_Audio
    implements RtcOutboundRtpStreamStatsMediaType_Audio {
  const _$RtcOutboundRtpStreamStatsMediaType_Audio(
      {this.totalSamplesSent, this.voiceActivityFlag});

  /// Total number of samples that have been sent over the RTP stream.
  @override
  final int? totalSamplesSent;

  /// Whether the last RTP packet sent contained voice activity or not
  /// based on the presence of the V bit in the extension header.
  @override
  final bool? voiceActivityFlag;

  @override
  String toString() {
    return 'RtcOutboundRtpStreamStatsMediaType.audio(totalSamplesSent: $totalSamplesSent, voiceActivityFlag: $voiceActivityFlag)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcOutboundRtpStreamStatsMediaType_Audio &&
            (identical(other.totalSamplesSent, totalSamplesSent) ||
                other.totalSamplesSent == totalSamplesSent) &&
            (identical(other.voiceActivityFlag, voiceActivityFlag) ||
                other.voiceActivityFlag == voiceActivityFlag));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, totalSamplesSent, voiceActivityFlag);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcOutboundRtpStreamStatsMediaType_AudioCopyWith<
          _$RtcOutboundRtpStreamStatsMediaType_Audio>
      get copyWith => __$$RtcOutboundRtpStreamStatsMediaType_AudioCopyWithImpl<
          _$RtcOutboundRtpStreamStatsMediaType_Audio>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? totalSamplesSent, bool? voiceActivityFlag)
        audio,
    required TResult Function(
            int? frameWidth, int? frameHeight, double? framesPerSecond)
        video,
  }) {
    return audio(totalSamplesSent, voiceActivityFlag);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult? Function(
            int? frameWidth, int? frameHeight, double? framesPerSecond)?
        video,
  }) {
    return audio?.call(totalSamplesSent, voiceActivityFlag);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult Function(
            int? frameWidth, int? frameHeight, double? framesPerSecond)?
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
    implements RtcOutboundRtpStreamStatsMediaType {
  const factory RtcOutboundRtpStreamStatsMediaType_Audio(
          {final int? totalSamplesSent, final bool? voiceActivityFlag}) =
      _$RtcOutboundRtpStreamStatsMediaType_Audio;

  /// Total number of samples that have been sent over the RTP stream.
  int? get totalSamplesSent;

  /// Whether the last RTP packet sent contained voice activity or not
  /// based on the presence of the V bit in the extension header.
  bool? get voiceActivityFlag;
  @JsonKey(ignore: true)
  _$$RtcOutboundRtpStreamStatsMediaType_AudioCopyWith<
          _$RtcOutboundRtpStreamStatsMediaType_Audio>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcOutboundRtpStreamStatsMediaType_VideoCopyWith<$Res> {
  factory _$$RtcOutboundRtpStreamStatsMediaType_VideoCopyWith(
          _$RtcOutboundRtpStreamStatsMediaType_Video value,
          $Res Function(_$RtcOutboundRtpStreamStatsMediaType_Video) then) =
      __$$RtcOutboundRtpStreamStatsMediaType_VideoCopyWithImpl<$Res>;
  @useResult
  $Res call({int? frameWidth, int? frameHeight, double? framesPerSecond});
}

/// @nodoc
class __$$RtcOutboundRtpStreamStatsMediaType_VideoCopyWithImpl<$Res>
    extends _$RtcOutboundRtpStreamStatsMediaTypeCopyWithImpl<$Res,
        _$RtcOutboundRtpStreamStatsMediaType_Video>
    implements _$$RtcOutboundRtpStreamStatsMediaType_VideoCopyWith<$Res> {
  __$$RtcOutboundRtpStreamStatsMediaType_VideoCopyWithImpl(
      _$RtcOutboundRtpStreamStatsMediaType_Video _value,
      $Res Function(_$RtcOutboundRtpStreamStatsMediaType_Video) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frameWidth = freezed,
    Object? frameHeight = freezed,
    Object? framesPerSecond = freezed,
  }) {
    return _then(_$RtcOutboundRtpStreamStatsMediaType_Video(
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
    ));
  }
}

/// @nodoc

class _$RtcOutboundRtpStreamStatsMediaType_Video
    implements RtcOutboundRtpStreamStatsMediaType_Video {
  const _$RtcOutboundRtpStreamStatsMediaType_Video(
      {this.frameWidth, this.frameHeight, this.framesPerSecond});

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcOutboundRtpStreamStatsMediaType_Video &&
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

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcOutboundRtpStreamStatsMediaType_VideoCopyWith<
          _$RtcOutboundRtpStreamStatsMediaType_Video>
      get copyWith => __$$RtcOutboundRtpStreamStatsMediaType_VideoCopyWithImpl<
          _$RtcOutboundRtpStreamStatsMediaType_Video>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? totalSamplesSent, bool? voiceActivityFlag)
        audio,
    required TResult Function(
            int? frameWidth, int? frameHeight, double? framesPerSecond)
        video,
  }) {
    return video(frameWidth, frameHeight, framesPerSecond);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult? Function(
            int? frameWidth, int? frameHeight, double? framesPerSecond)?
        video,
  }) {
    return video?.call(frameWidth, frameHeight, framesPerSecond);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? totalSamplesSent, bool? voiceActivityFlag)? audio,
    TResult Function(
            int? frameWidth, int? frameHeight, double? framesPerSecond)?
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
    implements RtcOutboundRtpStreamStatsMediaType {
  const factory RtcOutboundRtpStreamStatsMediaType_Video(
          {final int? frameWidth,
          final int? frameHeight,
          final double? framesPerSecond}) =
      _$RtcOutboundRtpStreamStatsMediaType_Video;

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
  @JsonKey(ignore: true)
  _$$RtcOutboundRtpStreamStatsMediaType_VideoCopyWith<
          _$RtcOutboundRtpStreamStatsMediaType_Video>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RtcStatsType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)
        rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived, IceRole? iceRole)
        rtcTransportStats,
    required TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult? Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult? Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult? Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult? Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult? Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
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
            RtcStatsType_RtcRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RtcStatsType_Unimplemented value) unimplemented,
  }) =>
      throw _privateConstructorUsedError;
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
  }) =>
      throw _privateConstructorUsedError;
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
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RtcStatsTypeCopyWith<$Res> {
  factory $RtcStatsTypeCopyWith(
          RtcStatsType value, $Res Function(RtcStatsType) then) =
      _$RtcStatsTypeCopyWithImpl<$Res, RtcStatsType>;
}

/// @nodoc
class _$RtcStatsTypeCopyWithImpl<$Res, $Val extends RtcStatsType>
    implements $RtcStatsTypeCopyWith<$Res> {
  _$RtcStatsTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcMediaSourceStatsCopyWith<$Res> {
  factory _$$RtcStatsType_RtcMediaSourceStatsCopyWith(
          _$RtcStatsType_RtcMediaSourceStats value,
          $Res Function(_$RtcStatsType_RtcMediaSourceStats) then) =
      __$$RtcStatsType_RtcMediaSourceStatsCopyWithImpl<$Res>;
  @useResult
  $Res call({String? trackIdentifier, RtcMediaSourceStatsMediaType kind});

  $RtcMediaSourceStatsMediaTypeCopyWith<$Res> get kind;
}

/// @nodoc
class __$$RtcStatsType_RtcMediaSourceStatsCopyWithImpl<$Res>
    extends _$RtcStatsTypeCopyWithImpl<$Res, _$RtcStatsType_RtcMediaSourceStats>
    implements _$$RtcStatsType_RtcMediaSourceStatsCopyWith<$Res> {
  __$$RtcStatsType_RtcMediaSourceStatsCopyWithImpl(
      _$RtcStatsType_RtcMediaSourceStats _value,
      $Res Function(_$RtcStatsType_RtcMediaSourceStats) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackIdentifier = freezed,
    Object? kind = null,
  }) {
    return _then(_$RtcStatsType_RtcMediaSourceStats(
      trackIdentifier: freezed == trackIdentifier
          ? _value.trackIdentifier
          : trackIdentifier // ignore: cast_nullable_to_non_nullable
              as String?,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as RtcMediaSourceStatsMediaType,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $RtcMediaSourceStatsMediaTypeCopyWith<$Res> get kind {
    return $RtcMediaSourceStatsMediaTypeCopyWith<$Res>(_value.kind, (value) {
      return _then(_value.copyWith(kind: value));
    });
  }
}

/// @nodoc

class _$RtcStatsType_RtcMediaSourceStats
    implements RtcStatsType_RtcMediaSourceStats {
  const _$RtcStatsType_RtcMediaSourceStats(
      {this.trackIdentifier, required this.kind});

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcMediaSourceStats &&
            (identical(other.trackIdentifier, trackIdentifier) ||
                other.trackIdentifier == trackIdentifier) &&
            (identical(other.kind, kind) || other.kind == kind));
  }

  @override
  int get hashCode => Object.hash(runtimeType, trackIdentifier, kind);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcMediaSourceStatsCopyWith<
          _$RtcStatsType_RtcMediaSourceStats>
      get copyWith => __$$RtcStatsType_RtcMediaSourceStatsCopyWithImpl<
          _$RtcStatsType_RtcMediaSourceStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)
        rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived, IceRole? iceRole)
        rtcTransportStats,
    required TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcMediaSourceStats(trackIdentifier, kind);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult? Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult? Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult? Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult? Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult? Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcMediaSourceStats?.call(trackIdentifier, kind);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
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
            RtcStatsType_RtcRemoteOutboundRtpStreamStats value)
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

abstract class RtcStatsType_RtcMediaSourceStats implements RtcStatsType {
  const factory RtcStatsType_RtcMediaSourceStats(
          {final String? trackIdentifier,
          required final RtcMediaSourceStatsMediaType kind}) =
      _$RtcStatsType_RtcMediaSourceStats;

  /// Value of the [MediaStreamTrack][1]'s ID attribute.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  String? get trackIdentifier;

  /// Fields which should be in these [`RtcStats`] based on their `kind`.
  RtcMediaSourceStatsMediaType get kind;
  @JsonKey(ignore: true)
  _$$RtcStatsType_RtcMediaSourceStatsCopyWith<
          _$RtcStatsType_RtcMediaSourceStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcIceCandidateStatsCopyWith<$Res> {
  factory _$$RtcStatsType_RtcIceCandidateStatsCopyWith(
          _$RtcStatsType_RtcIceCandidateStats value,
          $Res Function(_$RtcStatsType_RtcIceCandidateStats) then) =
      __$$RtcStatsType_RtcIceCandidateStatsCopyWithImpl<$Res>;
  @useResult
  $Res call({RtcIceCandidateStats field0});

  $RtcIceCandidateStatsCopyWith<$Res> get field0;
}

/// @nodoc
class __$$RtcStatsType_RtcIceCandidateStatsCopyWithImpl<$Res>
    extends _$RtcStatsTypeCopyWithImpl<$Res,
        _$RtcStatsType_RtcIceCandidateStats>
    implements _$$RtcStatsType_RtcIceCandidateStatsCopyWith<$Res> {
  __$$RtcStatsType_RtcIceCandidateStatsCopyWithImpl(
      _$RtcStatsType_RtcIceCandidateStats _value,
      $Res Function(_$RtcStatsType_RtcIceCandidateStats) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$RtcStatsType_RtcIceCandidateStats(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as RtcIceCandidateStats,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $RtcIceCandidateStatsCopyWith<$Res> get field0 {
    return $RtcIceCandidateStatsCopyWith<$Res>(_value.field0, (value) {
      return _then(_value.copyWith(field0: value));
    });
  }
}

/// @nodoc

class _$RtcStatsType_RtcIceCandidateStats
    implements RtcStatsType_RtcIceCandidateStats {
  const _$RtcStatsType_RtcIceCandidateStats(this.field0);

  @override
  final RtcIceCandidateStats field0;

  @override
  String toString() {
    return 'RtcStatsType.rtcIceCandidateStats(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcIceCandidateStats &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcIceCandidateStatsCopyWith<
          _$RtcStatsType_RtcIceCandidateStats>
      get copyWith => __$$RtcStatsType_RtcIceCandidateStatsCopyWithImpl<
          _$RtcStatsType_RtcIceCandidateStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)
        rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived, IceRole? iceRole)
        rtcTransportStats,
    required TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcIceCandidateStats(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult? Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult? Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult? Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult? Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult? Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcIceCandidateStats?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
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
            RtcStatsType_RtcRemoteOutboundRtpStreamStats value)
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

abstract class RtcStatsType_RtcIceCandidateStats implements RtcStatsType {
  const factory RtcStatsType_RtcIceCandidateStats(
      final RtcIceCandidateStats field0) = _$RtcStatsType_RtcIceCandidateStats;

  RtcIceCandidateStats get field0;
  @JsonKey(ignore: true)
  _$$RtcStatsType_RtcIceCandidateStatsCopyWith<
          _$RtcStatsType_RtcIceCandidateStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcOutboundRtpStreamStatsCopyWith<$Res> {
  factory _$$RtcStatsType_RtcOutboundRtpStreamStatsCopyWith(
          _$RtcStatsType_RtcOutboundRtpStreamStats value,
          $Res Function(_$RtcStatsType_RtcOutboundRtpStreamStats) then) =
      __$$RtcStatsType_RtcOutboundRtpStreamStatsCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String? trackId,
      RtcOutboundRtpStreamStatsMediaType mediaType,
      int? bytesSent,
      int? packetsSent,
      String? mediaSourceId});

  $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> get mediaType;
}

/// @nodoc
class __$$RtcStatsType_RtcOutboundRtpStreamStatsCopyWithImpl<$Res>
    extends _$RtcStatsTypeCopyWithImpl<$Res,
        _$RtcStatsType_RtcOutboundRtpStreamStats>
    implements _$$RtcStatsType_RtcOutboundRtpStreamStatsCopyWith<$Res> {
  __$$RtcStatsType_RtcOutboundRtpStreamStatsCopyWithImpl(
      _$RtcStatsType_RtcOutboundRtpStreamStats _value,
      $Res Function(_$RtcStatsType_RtcOutboundRtpStreamStats) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackId = freezed,
    Object? mediaType = null,
    Object? bytesSent = freezed,
    Object? packetsSent = freezed,
    Object? mediaSourceId = freezed,
  }) {
    return _then(_$RtcStatsType_RtcOutboundRtpStreamStats(
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
              as int?,
      packetsSent: freezed == packetsSent
          ? _value.packetsSent
          : packetsSent // ignore: cast_nullable_to_non_nullable
              as int?,
      mediaSourceId: freezed == mediaSourceId
          ? _value.mediaSourceId
          : mediaSourceId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res> get mediaType {
    return $RtcOutboundRtpStreamStatsMediaTypeCopyWith<$Res>(_value.mediaType,
        (value) {
      return _then(_value.copyWith(mediaType: value));
    });
  }
}

/// @nodoc

class _$RtcStatsType_RtcOutboundRtpStreamStats
    implements RtcStatsType_RtcOutboundRtpStreamStats {
  const _$RtcStatsType_RtcOutboundRtpStreamStats(
      {this.trackId,
      required this.mediaType,
      this.bytesSent,
      this.packetsSent,
      this.mediaSourceId});

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
  final int? bytesSent;

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcOutboundRtpStreamStats &&
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
      runtimeType, trackId, mediaType, bytesSent, packetsSent, mediaSourceId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcOutboundRtpStreamStatsCopyWith<
          _$RtcStatsType_RtcOutboundRtpStreamStats>
      get copyWith => __$$RtcStatsType_RtcOutboundRtpStreamStatsCopyWithImpl<
          _$RtcStatsType_RtcOutboundRtpStreamStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)
        rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived, IceRole? iceRole)
        rtcTransportStats,
    required TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcOutboundRtpStreamStats(
        trackId, mediaType, bytesSent, packetsSent, mediaSourceId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult? Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult? Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult? Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult? Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult? Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcOutboundRtpStreamStats?.call(
        trackId, mediaType, bytesSent, packetsSent, mediaSourceId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcOutboundRtpStreamStats != null) {
      return rtcOutboundRtpStreamStats(
          trackId, mediaType, bytesSent, packetsSent, mediaSourceId);
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
            RtcStatsType_RtcRemoteOutboundRtpStreamStats value)
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

abstract class RtcStatsType_RtcOutboundRtpStreamStats implements RtcStatsType {
  const factory RtcStatsType_RtcOutboundRtpStreamStats(
      {final String? trackId,
      required final RtcOutboundRtpStreamStatsMediaType mediaType,
      final int? bytesSent,
      final int? packetsSent,
      final String? mediaSourceId}) = _$RtcStatsType_RtcOutboundRtpStreamStats;

  /// ID of the stats object representing the current track attachment to
  /// the sender of the stream.
  String? get trackId;

  /// Fields which should be in these [`RtcStats`] based on their
  /// `media_type`.
  RtcOutboundRtpStreamStatsMediaType get mediaType;

  /// Total number of bytes sent for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? get bytesSent;

  /// Total number of RTP packets sent for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? get packetsSent;

  /// ID of the stats object representing the track currently attached to
  /// the sender of the stream.
  String? get mediaSourceId;
  @JsonKey(ignore: true)
  _$$RtcStatsType_RtcOutboundRtpStreamStatsCopyWith<
          _$RtcStatsType_RtcOutboundRtpStreamStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcInboundRtpStreamStatsCopyWith<$Res> {
  factory _$$RtcStatsType_RtcInboundRtpStreamStatsCopyWith(
          _$RtcStatsType_RtcInboundRtpStreamStats value,
          $Res Function(_$RtcStatsType_RtcInboundRtpStreamStats) then) =
      __$$RtcStatsType_RtcInboundRtpStreamStatsCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String? remoteId,
      int? bytesReceived,
      int? packetsReceived,
      int? packetsLost,
      double? jitter,
      double? totalDecodeTime,
      int? jitterBufferEmittedCount,
      RtcInboundRtpStreamMediaType? mediaType});

  $RtcInboundRtpStreamMediaTypeCopyWith<$Res>? get mediaType;
}

/// @nodoc
class __$$RtcStatsType_RtcInboundRtpStreamStatsCopyWithImpl<$Res>
    extends _$RtcStatsTypeCopyWithImpl<$Res,
        _$RtcStatsType_RtcInboundRtpStreamStats>
    implements _$$RtcStatsType_RtcInboundRtpStreamStatsCopyWith<$Res> {
  __$$RtcStatsType_RtcInboundRtpStreamStatsCopyWithImpl(
      _$RtcStatsType_RtcInboundRtpStreamStats _value,
      $Res Function(_$RtcStatsType_RtcInboundRtpStreamStats) _then)
      : super(_value, _then);

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
    return _then(_$RtcStatsType_RtcInboundRtpStreamStats(
      remoteId: freezed == remoteId
          ? _value.remoteId
          : remoteId // ignore: cast_nullable_to_non_nullable
              as String?,
      bytesReceived: freezed == bytesReceived
          ? _value.bytesReceived
          : bytesReceived // ignore: cast_nullable_to_non_nullable
              as int?,
      packetsReceived: freezed == packetsReceived
          ? _value.packetsReceived
          : packetsReceived // ignore: cast_nullable_to_non_nullable
              as int?,
      packetsLost: freezed == packetsLost
          ? _value.packetsLost
          : packetsLost // ignore: cast_nullable_to_non_nullable
              as int?,
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
              as int?,
      mediaType: freezed == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as RtcInboundRtpStreamMediaType?,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $RtcInboundRtpStreamMediaTypeCopyWith<$Res>? get mediaType {
    if (_value.mediaType == null) {
      return null;
    }

    return $RtcInboundRtpStreamMediaTypeCopyWith<$Res>(_value.mediaType!,
        (value) {
      return _then(_value.copyWith(mediaType: value));
    });
  }
}

/// @nodoc

class _$RtcStatsType_RtcInboundRtpStreamStats
    implements RtcStatsType_RtcInboundRtpStreamStats {
  const _$RtcStatsType_RtcInboundRtpStreamStats(
      {this.remoteId,
      this.bytesReceived,
      this.packetsReceived,
      this.packetsLost,
      this.jitter,
      this.totalDecodeTime,
      this.jitterBufferEmittedCount,
      this.mediaType});

  /// ID of the stats object representing the receiving track.
  @override
  final String? remoteId;

  /// Total number of bytes received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final int? bytesReceived;

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
  final int? packetsLost;

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
  final int? jitterBufferEmittedCount;

  /// Fields which should be in these [`RtcStats`] based on their
  /// `media_type`.
  @override
  final RtcInboundRtpStreamMediaType? mediaType;

  @override
  String toString() {
    return 'RtcStatsType.rtcInboundRtpStreamStats(remoteId: $remoteId, bytesReceived: $bytesReceived, packetsReceived: $packetsReceived, packetsLost: $packetsLost, jitter: $jitter, totalDecodeTime: $totalDecodeTime, jitterBufferEmittedCount: $jitterBufferEmittedCount, mediaType: $mediaType)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcInboundRtpStreamStats &&
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
                    other.jitterBufferEmittedCount, jitterBufferEmittedCount) ||
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
      mediaType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcInboundRtpStreamStatsCopyWith<
          _$RtcStatsType_RtcInboundRtpStreamStats>
      get copyWith => __$$RtcStatsType_RtcInboundRtpStreamStatsCopyWithImpl<
          _$RtcStatsType_RtcInboundRtpStreamStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)
        rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived, IceRole? iceRole)
        rtcTransportStats,
    required TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
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
        mediaType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult? Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult? Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult? Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult? Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult? Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
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
        mediaType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
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
          mediaType);
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
            RtcStatsType_RtcRemoteOutboundRtpStreamStats value)
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

abstract class RtcStatsType_RtcInboundRtpStreamStats implements RtcStatsType {
  const factory RtcStatsType_RtcInboundRtpStreamStats(
          {final String? remoteId,
          final int? bytesReceived,
          final int? packetsReceived,
          final int? packetsLost,
          final double? jitter,
          final double? totalDecodeTime,
          final int? jitterBufferEmittedCount,
          final RtcInboundRtpStreamMediaType? mediaType}) =
      _$RtcStatsType_RtcInboundRtpStreamStats;

  /// ID of the stats object representing the receiving track.
  String? get remoteId;

  /// Total number of bytes received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? get bytesReceived;

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
  int? get packetsLost;

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
  int? get jitterBufferEmittedCount;

  /// Fields which should be in these [`RtcStats`] based on their
  /// `media_type`.
  RtcInboundRtpStreamMediaType? get mediaType;
  @JsonKey(ignore: true)
  _$$RtcStatsType_RtcInboundRtpStreamStatsCopyWith<
          _$RtcStatsType_RtcInboundRtpStreamStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcIceCandidatePairStatsCopyWith<$Res> {
  factory _$$RtcStatsType_RtcIceCandidatePairStatsCopyWith(
          _$RtcStatsType_RtcIceCandidatePairStats value,
          $Res Function(_$RtcStatsType_RtcIceCandidatePairStats) then) =
      __$$RtcStatsType_RtcIceCandidatePairStatsCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {RtcStatsIceCandidatePairState state,
      bool? nominated,
      int? bytesSent,
      int? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate});
}

/// @nodoc
class __$$RtcStatsType_RtcIceCandidatePairStatsCopyWithImpl<$Res>
    extends _$RtcStatsTypeCopyWithImpl<$Res,
        _$RtcStatsType_RtcIceCandidatePairStats>
    implements _$$RtcStatsType_RtcIceCandidatePairStatsCopyWith<$Res> {
  __$$RtcStatsType_RtcIceCandidatePairStatsCopyWithImpl(
      _$RtcStatsType_RtcIceCandidatePairStats _value,
      $Res Function(_$RtcStatsType_RtcIceCandidatePairStats) _then)
      : super(_value, _then);

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
    return _then(_$RtcStatsType_RtcIceCandidatePairStats(
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
              as int?,
      bytesReceived: freezed == bytesReceived
          ? _value.bytesReceived
          : bytesReceived // ignore: cast_nullable_to_non_nullable
              as int?,
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
    ));
  }
}

/// @nodoc

class _$RtcStatsType_RtcIceCandidatePairStats
    implements RtcStatsType_RtcIceCandidatePairStats {
  const _$RtcStatsType_RtcIceCandidatePairStats(
      {required this.state,
      this.nominated,
      this.bytesSent,
      this.bytesReceived,
      this.totalRoundTripTime,
      this.currentRoundTripTime,
      this.availableOutgoingBitrate});

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
  final int? bytesSent;

  /// Total number of payload bytes received on this candidate pair, i.e.
  /// not including headers or padding.
  @override
  final int? bytesReceived;

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcIceCandidatePairStats &&
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
                    other.availableOutgoingBitrate, availableOutgoingBitrate) ||
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
      availableOutgoingBitrate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcIceCandidatePairStatsCopyWith<
          _$RtcStatsType_RtcIceCandidatePairStats>
      get copyWith => __$$RtcStatsType_RtcIceCandidatePairStatsCopyWithImpl<
          _$RtcStatsType_RtcIceCandidatePairStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)
        rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived, IceRole? iceRole)
        rtcTransportStats,
    required TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcIceCandidatePairStats(state, nominated, bytesSent, bytesReceived,
        totalRoundTripTime, currentRoundTripTime, availableOutgoingBitrate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult? Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult? Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult? Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult? Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult? Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
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
        availableOutgoingBitrate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
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
          availableOutgoingBitrate);
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
            RtcStatsType_RtcRemoteOutboundRtpStreamStats value)
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

abstract class RtcStatsType_RtcIceCandidatePairStats implements RtcStatsType {
  const factory RtcStatsType_RtcIceCandidatePairStats(
          {required final RtcStatsIceCandidatePairState state,
          final bool? nominated,
          final int? bytesSent,
          final int? bytesReceived,
          final double? totalRoundTripTime,
          final double? currentRoundTripTime,
          final double? availableOutgoingBitrate}) =
      _$RtcStatsType_RtcIceCandidatePairStats;

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
  int? get bytesSent;

  /// Total number of payload bytes received on this candidate pair, i.e.
  /// not including headers or padding.
  int? get bytesReceived;

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
  @JsonKey(ignore: true)
  _$$RtcStatsType_RtcIceCandidatePairStatsCopyWith<
          _$RtcStatsType_RtcIceCandidatePairStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcTransportStatsCopyWith<$Res> {
  factory _$$RtcStatsType_RtcTransportStatsCopyWith(
          _$RtcStatsType_RtcTransportStats value,
          $Res Function(_$RtcStatsType_RtcTransportStats) then) =
      __$$RtcStatsType_RtcTransportStatsCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {int? packetsSent,
      int? packetsReceived,
      int? bytesSent,
      int? bytesReceived,
      IceRole? iceRole});
}

/// @nodoc
class __$$RtcStatsType_RtcTransportStatsCopyWithImpl<$Res>
    extends _$RtcStatsTypeCopyWithImpl<$Res, _$RtcStatsType_RtcTransportStats>
    implements _$$RtcStatsType_RtcTransportStatsCopyWith<$Res> {
  __$$RtcStatsType_RtcTransportStatsCopyWithImpl(
      _$RtcStatsType_RtcTransportStats _value,
      $Res Function(_$RtcStatsType_RtcTransportStats) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packetsSent = freezed,
    Object? packetsReceived = freezed,
    Object? bytesSent = freezed,
    Object? bytesReceived = freezed,
    Object? iceRole = freezed,
  }) {
    return _then(_$RtcStatsType_RtcTransportStats(
      packetsSent: freezed == packetsSent
          ? _value.packetsSent
          : packetsSent // ignore: cast_nullable_to_non_nullable
              as int?,
      packetsReceived: freezed == packetsReceived
          ? _value.packetsReceived
          : packetsReceived // ignore: cast_nullable_to_non_nullable
              as int?,
      bytesSent: freezed == bytesSent
          ? _value.bytesSent
          : bytesSent // ignore: cast_nullable_to_non_nullable
              as int?,
      bytesReceived: freezed == bytesReceived
          ? _value.bytesReceived
          : bytesReceived // ignore: cast_nullable_to_non_nullable
              as int?,
      iceRole: freezed == iceRole
          ? _value.iceRole
          : iceRole // ignore: cast_nullable_to_non_nullable
              as IceRole?,
    ));
  }
}

/// @nodoc

class _$RtcStatsType_RtcTransportStats
    implements RtcStatsType_RtcTransportStats {
  const _$RtcStatsType_RtcTransportStats(
      {this.packetsSent,
      this.packetsReceived,
      this.bytesSent,
      this.bytesReceived,
      this.iceRole});

  /// Total number of packets sent over this transport.
  @override
  final int? packetsSent;

  /// Total number of packets received on this transport.
  @override
  final int? packetsReceived;

  /// Total number of payload bytes sent on this [RTCPeerConnection], i.e.
  /// not including headers or padding.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  @override
  final int? bytesSent;

  /// Total number of bytes received on this [RTCPeerConnection], i.e. not
  /// including headers or padding.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  @override
  final int? bytesReceived;

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcTransportStats &&
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
  int get hashCode => Object.hash(runtimeType, packetsSent, packetsReceived,
      bytesSent, bytesReceived, iceRole);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcTransportStatsCopyWith<_$RtcStatsType_RtcTransportStats>
      get copyWith => __$$RtcStatsType_RtcTransportStatsCopyWithImpl<
          _$RtcStatsType_RtcTransportStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)
        rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived, IceRole? iceRole)
        rtcTransportStats,
    required TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcTransportStats(
        packetsSent, packetsReceived, bytesSent, bytesReceived, iceRole);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult? Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult? Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult? Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult? Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult? Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcTransportStats?.call(
        packetsSent, packetsReceived, bytesSent, bytesReceived, iceRole);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcTransportStats != null) {
      return rtcTransportStats(
          packetsSent, packetsReceived, bytesSent, bytesReceived, iceRole);
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
            RtcStatsType_RtcRemoteOutboundRtpStreamStats value)
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

abstract class RtcStatsType_RtcTransportStats implements RtcStatsType {
  const factory RtcStatsType_RtcTransportStats(
      {final int? packetsSent,
      final int? packetsReceived,
      final int? bytesSent,
      final int? bytesReceived,
      final IceRole? iceRole}) = _$RtcStatsType_RtcTransportStats;

  /// Total number of packets sent over this transport.
  int? get packetsSent;

  /// Total number of packets received on this transport.
  int? get packetsReceived;

  /// Total number of payload bytes sent on this [RTCPeerConnection], i.e.
  /// not including headers or padding.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  int? get bytesSent;

  /// Total number of bytes received on this [RTCPeerConnection], i.e. not
  /// including headers or padding.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  int? get bytesReceived;

  /// Set to the current value of the [role][1] of the underlying
  /// [RTCDtlsTransport][2]'s [transport][3].
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
  /// [2]: https://w3.org/TR/webrtc#rtcdtlstransport-interface
  /// [3]: https://w3.org/TR/webrtc#dom-rtcdtlstransport-icetransport
  IceRole? get iceRole;
  @JsonKey(ignore: true)
  _$$RtcStatsType_RtcTransportStatsCopyWith<_$RtcStatsType_RtcTransportStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWith<$Res> {
  factory _$$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWith(
          _$RtcStatsType_RtcRemoteInboundRtpStreamStats value,
          $Res Function(_$RtcStatsType_RtcRemoteInboundRtpStreamStats) then) =
      __$$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String? localId,
      double? jitter,
      double? roundTripTime,
      double? fractionLost,
      int? reportsReceived,
      int? roundTripTimeMeasurements});
}

/// @nodoc
class __$$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWithImpl<$Res>
    extends _$RtcStatsTypeCopyWithImpl<$Res,
        _$RtcStatsType_RtcRemoteInboundRtpStreamStats>
    implements _$$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWith<$Res> {
  __$$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWithImpl(
      _$RtcStatsType_RtcRemoteInboundRtpStreamStats _value,
      $Res Function(_$RtcStatsType_RtcRemoteInboundRtpStreamStats) _then)
      : super(_value, _then);

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
    return _then(_$RtcStatsType_RtcRemoteInboundRtpStreamStats(
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
              as int?,
      roundTripTimeMeasurements: freezed == roundTripTimeMeasurements
          ? _value.roundTripTimeMeasurements
          : roundTripTimeMeasurements // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$RtcStatsType_RtcRemoteInboundRtpStreamStats
    implements RtcStatsType_RtcRemoteInboundRtpStreamStats {
  const _$RtcStatsType_RtcRemoteInboundRtpStreamStats(
      {this.localId,
      this.jitter,
      this.roundTripTime,
      this.fractionLost,
      this.reportsReceived,
      this.roundTripTimeMeasurements});

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
  /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
  /// [2]: https://tools.ietf.org/html/rfc3550#appendix-A.3
  @override
  final double? fractionLost;

  /// Total number of RTCP RR blocks received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  @override
  final int? reportsReceived;

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcRemoteInboundRtpStreamStats &&
            (identical(other.localId, localId) || other.localId == localId) &&
            (identical(other.jitter, jitter) || other.jitter == jitter) &&
            (identical(other.roundTripTime, roundTripTime) ||
                other.roundTripTime == roundTripTime) &&
            (identical(other.fractionLost, fractionLost) ||
                other.fractionLost == fractionLost) &&
            (identical(other.reportsReceived, reportsReceived) ||
                other.reportsReceived == reportsReceived) &&
            (identical(other.roundTripTimeMeasurements,
                    roundTripTimeMeasurements) ||
                other.roundTripTimeMeasurements == roundTripTimeMeasurements));
  }

  @override
  int get hashCode => Object.hash(runtimeType, localId, jitter, roundTripTime,
      fractionLost, reportsReceived, roundTripTimeMeasurements);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWith<
          _$RtcStatsType_RtcRemoteInboundRtpStreamStats>
      get copyWith =>
          __$$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWithImpl<
              _$RtcStatsType_RtcRemoteInboundRtpStreamStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)
        rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived, IceRole? iceRole)
        rtcTransportStats,
    required TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcRemoteInboundRtpStreamStats(localId, jitter, roundTripTime,
        fractionLost, reportsReceived, roundTripTimeMeasurements);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult? Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult? Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult? Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult? Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult? Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcRemoteInboundRtpStreamStats?.call(localId, jitter, roundTripTime,
        fractionLost, reportsReceived, roundTripTimeMeasurements);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcRemoteInboundRtpStreamStats != null) {
      return rtcRemoteInboundRtpStreamStats(localId, jitter, roundTripTime,
          fractionLost, reportsReceived, roundTripTimeMeasurements);
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
            RtcStatsType_RtcRemoteOutboundRtpStreamStats value)
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
    implements RtcStatsType {
  const factory RtcStatsType_RtcRemoteInboundRtpStreamStats(
          {final String? localId,
          final double? jitter,
          final double? roundTripTime,
          final double? fractionLost,
          final int? reportsReceived,
          final int? roundTripTimeMeasurements}) =
      _$RtcStatsType_RtcRemoteInboundRtpStreamStats;

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
  /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
  /// [2]: https://tools.ietf.org/html/rfc3550#appendix-A.3
  double? get fractionLost;

  /// Total number of RTCP RR blocks received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? get reportsReceived;

  /// Total number of RTCP RR blocks received for this [SSRC] that contain
  /// a valid round trip time. This counter will increment if the
  /// [roundTripTime] is undefined.
  ///
  /// [roundTripTime]: https://tinyurl.com/ssg83hq
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? get roundTripTimeMeasurements;
  @JsonKey(ignore: true)
  _$$RtcStatsType_RtcRemoteInboundRtpStreamStatsCopyWith<
          _$RtcStatsType_RtcRemoteInboundRtpStreamStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWith<$Res> {
  factory _$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWith(
          _$RtcStatsType_RtcRemoteOutboundRtpStreamStats value,
          $Res Function(_$RtcStatsType_RtcRemoteOutboundRtpStreamStats) then) =
      __$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWithImpl<$Res>;
  @useResult
  $Res call({String? localId, double? remoteTimestamp, int? reportsSent});
}

/// @nodoc
class __$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWithImpl<$Res>
    extends _$RtcStatsTypeCopyWithImpl<$Res,
        _$RtcStatsType_RtcRemoteOutboundRtpStreamStats>
    implements _$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWith<$Res> {
  __$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWithImpl(
      _$RtcStatsType_RtcRemoteOutboundRtpStreamStats _value,
      $Res Function(_$RtcStatsType_RtcRemoteOutboundRtpStreamStats) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localId = freezed,
    Object? remoteTimestamp = freezed,
    Object? reportsSent = freezed,
  }) {
    return _then(_$RtcStatsType_RtcRemoteOutboundRtpStreamStats(
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
              as int?,
    ));
  }
}

/// @nodoc

class _$RtcStatsType_RtcRemoteOutboundRtpStreamStats
    implements RtcStatsType_RtcRemoteOutboundRtpStreamStats {
  const _$RtcStatsType_RtcRemoteOutboundRtpStreamStats(
      {this.localId, this.remoteTimestamp, this.reportsSent});

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
  final int? reportsSent;

  @override
  String toString() {
    return 'RtcStatsType.rtcRemoteOutboundRtpStreamStats(localId: $localId, remoteTimestamp: $remoteTimestamp, reportsSent: $reportsSent)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_RtcRemoteOutboundRtpStreamStats &&
            (identical(other.localId, localId) || other.localId == localId) &&
            (identical(other.remoteTimestamp, remoteTimestamp) ||
                other.remoteTimestamp == remoteTimestamp) &&
            (identical(other.reportsSent, reportsSent) ||
                other.reportsSent == reportsSent));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, localId, remoteTimestamp, reportsSent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWith<
          _$RtcStatsType_RtcRemoteOutboundRtpStreamStats>
      get copyWith =>
          __$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWithImpl<
              _$RtcStatsType_RtcRemoteOutboundRtpStreamStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)
        rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived, IceRole? iceRole)
        rtcTransportStats,
    required TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return rtcRemoteOutboundRtpStreamStats(
        localId, remoteTimestamp, reportsSent);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult? Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult? Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult? Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult? Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult? Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return rtcRemoteOutboundRtpStreamStats?.call(
        localId, remoteTimestamp, reportsSent);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplemented,
    required TResult orElse(),
  }) {
    if (rtcRemoteOutboundRtpStreamStats != null) {
      return rtcRemoteOutboundRtpStreamStats(
          localId, remoteTimestamp, reportsSent);
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
            RtcStatsType_RtcRemoteOutboundRtpStreamStats value)
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
    implements RtcStatsType {
  const factory RtcStatsType_RtcRemoteOutboundRtpStreamStats(
      {final String? localId,
      final double? remoteTimestamp,
      final int? reportsSent}) = _$RtcStatsType_RtcRemoteOutboundRtpStreamStats;

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
  int? get reportsSent;
  @JsonKey(ignore: true)
  _$$RtcStatsType_RtcRemoteOutboundRtpStreamStatsCopyWith<
          _$RtcStatsType_RtcRemoteOutboundRtpStreamStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RtcStatsType_UnimplementedCopyWith<$Res> {
  factory _$$RtcStatsType_UnimplementedCopyWith(
          _$RtcStatsType_Unimplemented value,
          $Res Function(_$RtcStatsType_Unimplemented) then) =
      __$$RtcStatsType_UnimplementedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RtcStatsType_UnimplementedCopyWithImpl<$Res>
    extends _$RtcStatsTypeCopyWithImpl<$Res, _$RtcStatsType_Unimplemented>
    implements _$$RtcStatsType_UnimplementedCopyWith<$Res> {
  __$$RtcStatsType_UnimplementedCopyWithImpl(
      _$RtcStatsType_Unimplemented _value,
      $Res Function(_$RtcStatsType_Unimplemented) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RtcStatsType_Unimplemented implements RtcStatsType_Unimplemented {
  const _$RtcStatsType_Unimplemented();

  @override
  String toString() {
    return 'RtcStatsType.unimplemented()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RtcStatsType_Unimplemented);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)
        rtcMediaSourceStats,
    required TResult Function(RtcIceCandidateStats field0) rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived, IceRole? iceRole)
        rtcTransportStats,
    required TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplemented,
  }) {
    return unimplemented();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult? Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult? Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult? Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult? Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult? Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult? Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult? Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult? Function()? unimplemented,
  }) {
    return unimplemented?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? trackIdentifier, RtcMediaSourceStatsMediaType kind)?
        rtcMediaSourceStats,
    TResult Function(RtcIceCandidateStats field0)? rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            RtcOutboundRtpStreamStatsMediaType mediaType,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            int? packetsLost,
            double? jitter,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RtcInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RtcStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived, IceRole? iceRole)?
        rtcTransportStats,
    TResult Function(
            String? localId,
            double? jitter,
            double? roundTripTime,
            double? fractionLost,
            int? reportsReceived,
            int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
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
            RtcStatsType_RtcRemoteOutboundRtpStreamStats value)
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

abstract class RtcStatsType_Unimplemented implements RtcStatsType {
  const factory RtcStatsType_Unimplemented() = _$RtcStatsType_Unimplemented;
}
