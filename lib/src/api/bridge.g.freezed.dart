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
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
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
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
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
      _$GetMediaErrorCopyWithImpl<$Res>;
  $Res call({String field0});
}

/// @nodoc
class _$GetMediaErrorCopyWithImpl<$Res>
    implements $GetMediaErrorCopyWith<$Res> {
  _$GetMediaErrorCopyWithImpl(this._value, this._then);

  final GetMediaError _value;
  // ignore: unused_field
  final $Res Function(GetMediaError) _then;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_value.copyWith(
      field0: field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$GetMediaError_AudioCopyWith<$Res>
    implements $GetMediaErrorCopyWith<$Res> {
  factory _$$GetMediaError_AudioCopyWith(_$GetMediaError_Audio value,
          $Res Function(_$GetMediaError_Audio) then) =
      __$$GetMediaError_AudioCopyWithImpl<$Res>;
  @override
  $Res call({String field0});
}

/// @nodoc
class __$$GetMediaError_AudioCopyWithImpl<$Res>
    extends _$GetMediaErrorCopyWithImpl<$Res>
    implements _$$GetMediaError_AudioCopyWith<$Res> {
  __$$GetMediaError_AudioCopyWithImpl(
      _$GetMediaError_Audio _value, $Res Function(_$GetMediaError_Audio) _then)
      : super(_value, (v) => _then(v as _$GetMediaError_Audio));

  @override
  _$GetMediaError_Audio get _value => super._value as _$GetMediaError_Audio;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$GetMediaError_Audio(
      field0 == freezed
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
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
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
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
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
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
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
  $Res call({String field0});
}

/// @nodoc
class __$$GetMediaError_VideoCopyWithImpl<$Res>
    extends _$GetMediaErrorCopyWithImpl<$Res>
    implements _$$GetMediaError_VideoCopyWith<$Res> {
  __$$GetMediaError_VideoCopyWithImpl(
      _$GetMediaError_Video _value, $Res Function(_$GetMediaError_Video) _then)
      : super(_value, (v) => _then(v as _$GetMediaError_Video));

  @override
  _$GetMediaError_Video get _value => super._value as _$GetMediaError_Video;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$GetMediaError_Video(
      field0 == freezed
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
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
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
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
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
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
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
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
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
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
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
      _$GetMediaResultCopyWithImpl<$Res>;
}

/// @nodoc
class _$GetMediaResultCopyWithImpl<$Res>
    implements $GetMediaResultCopyWith<$Res> {
  _$GetMediaResultCopyWithImpl(this._value, this._then);

  final GetMediaResult _value;
  // ignore: unused_field
  final $Res Function(GetMediaResult) _then;
}

/// @nodoc
abstract class _$$GetMediaResult_OkCopyWith<$Res> {
  factory _$$GetMediaResult_OkCopyWith(
          _$GetMediaResult_Ok value, $Res Function(_$GetMediaResult_Ok) then) =
      __$$GetMediaResult_OkCopyWithImpl<$Res>;
  $Res call({List<MediaStreamTrack> field0});
}

/// @nodoc
class __$$GetMediaResult_OkCopyWithImpl<$Res>
    extends _$GetMediaResultCopyWithImpl<$Res>
    implements _$$GetMediaResult_OkCopyWith<$Res> {
  __$$GetMediaResult_OkCopyWithImpl(
      _$GetMediaResult_Ok _value, $Res Function(_$GetMediaResult_Ok) _then)
      : super(_value, (v) => _then(v as _$GetMediaResult_Ok));

  @override
  _$GetMediaResult_Ok get _value => super._value as _$GetMediaResult_Ok;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$GetMediaResult_Ok(
      field0 == freezed
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
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
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
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
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
  $Res call({GetMediaError field0});

  $GetMediaErrorCopyWith<$Res> get field0;
}

/// @nodoc
class __$$GetMediaResult_ErrCopyWithImpl<$Res>
    extends _$GetMediaResultCopyWithImpl<$Res>
    implements _$$GetMediaResult_ErrCopyWith<$Res> {
  __$$GetMediaResult_ErrCopyWithImpl(
      _$GetMediaResult_Err _value, $Res Function(_$GetMediaResult_Err) _then)
      : super(_value, (v) => _then(v as _$GetMediaResult_Err));

  @override
  _$GetMediaResult_Err get _value => super._value as _$GetMediaResult_Err;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$GetMediaResult_Err(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as GetMediaError,
    ));
  }

  @override
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
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
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
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
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
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
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
      _$PeerConnectionEventCopyWithImpl<$Res>;
}

/// @nodoc
class _$PeerConnectionEventCopyWithImpl<$Res>
    implements $PeerConnectionEventCopyWith<$Res> {
  _$PeerConnectionEventCopyWithImpl(this._value, this._then);

  final PeerConnectionEvent _value;
  // ignore: unused_field
  final $Res Function(PeerConnectionEvent) _then;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_PeerCreatedCopyWith<$Res> {
  factory _$$PeerConnectionEvent_PeerCreatedCopyWith(
          _$PeerConnectionEvent_PeerCreated value,
          $Res Function(_$PeerConnectionEvent_PeerCreated) then) =
      __$$PeerConnectionEvent_PeerCreatedCopyWithImpl<$Res>;
  $Res call({int id});
}

/// @nodoc
class __$$PeerConnectionEvent_PeerCreatedCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_PeerCreatedCopyWith<$Res> {
  __$$PeerConnectionEvent_PeerCreatedCopyWithImpl(
      _$PeerConnectionEvent_PeerCreated _value,
      $Res Function(_$PeerConnectionEvent_PeerCreated) _then)
      : super(_value, (v) => _then(v as _$PeerConnectionEvent_PeerCreated));

  @override
  _$PeerConnectionEvent_PeerCreated get _value =>
      super._value as _$PeerConnectionEvent_PeerCreated;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(_$PeerConnectionEvent_PeerCreated(
      id: id == freezed
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
            const DeepCollectionEquality().equals(other.id, id));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(id));

  @JsonKey(ignore: true)
  @override
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
  $Res call({String sdpMid, int sdpMlineIndex, String candidate});
}

/// @nodoc
class __$$PeerConnectionEvent_IceCandidateCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_IceCandidateCopyWith<$Res> {
  __$$PeerConnectionEvent_IceCandidateCopyWithImpl(
      _$PeerConnectionEvent_IceCandidate _value,
      $Res Function(_$PeerConnectionEvent_IceCandidate) _then)
      : super(_value, (v) => _then(v as _$PeerConnectionEvent_IceCandidate));

  @override
  _$PeerConnectionEvent_IceCandidate get _value =>
      super._value as _$PeerConnectionEvent_IceCandidate;

  @override
  $Res call({
    Object? sdpMid = freezed,
    Object? sdpMlineIndex = freezed,
    Object? candidate = freezed,
  }) {
    return _then(_$PeerConnectionEvent_IceCandidate(
      sdpMid: sdpMid == freezed
          ? _value.sdpMid
          : sdpMid // ignore: cast_nullable_to_non_nullable
              as String,
      sdpMlineIndex: sdpMlineIndex == freezed
          ? _value.sdpMlineIndex
          : sdpMlineIndex // ignore: cast_nullable_to_non_nullable
              as int,
      candidate: candidate == freezed
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
            const DeepCollectionEquality().equals(other.sdpMid, sdpMid) &&
            const DeepCollectionEquality()
                .equals(other.sdpMlineIndex, sdpMlineIndex) &&
            const DeepCollectionEquality().equals(other.candidate, candidate));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(sdpMid),
      const DeepCollectionEquality().hash(sdpMlineIndex),
      const DeepCollectionEquality().hash(candidate));

  @JsonKey(ignore: true)
  @override
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
  $Res call({IceGatheringState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl(
      _$PeerConnectionEvent_IceGatheringStateChange _value,
      $Res Function(_$PeerConnectionEvent_IceGatheringStateChange) _then)
      : super(_value,
            (v) => _then(v as _$PeerConnectionEvent_IceGatheringStateChange));

  @override
  _$PeerConnectionEvent_IceGatheringStateChange get _value =>
      super._value as _$PeerConnectionEvent_IceGatheringStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$PeerConnectionEvent_IceGatheringStateChange(
      field0 == freezed
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
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
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
  $Res call(
      {String address, int port, String url, int errorCode, String errorText});
}

/// @nodoc
class __$$PeerConnectionEvent_IceCandidateErrorCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_IceCandidateErrorCopyWith<$Res> {
  __$$PeerConnectionEvent_IceCandidateErrorCopyWithImpl(
      _$PeerConnectionEvent_IceCandidateError _value,
      $Res Function(_$PeerConnectionEvent_IceCandidateError) _then)
      : super(
            _value, (v) => _then(v as _$PeerConnectionEvent_IceCandidateError));

  @override
  _$PeerConnectionEvent_IceCandidateError get _value =>
      super._value as _$PeerConnectionEvent_IceCandidateError;

  @override
  $Res call({
    Object? address = freezed,
    Object? port = freezed,
    Object? url = freezed,
    Object? errorCode = freezed,
    Object? errorText = freezed,
  }) {
    return _then(_$PeerConnectionEvent_IceCandidateError(
      address: address == freezed
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      port: port == freezed
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: errorCode == freezed
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as int,
      errorText: errorText == freezed
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
            const DeepCollectionEquality().equals(other.address, address) &&
            const DeepCollectionEquality().equals(other.port, port) &&
            const DeepCollectionEquality().equals(other.url, url) &&
            const DeepCollectionEquality().equals(other.errorCode, errorCode) &&
            const DeepCollectionEquality().equals(other.errorText, errorText));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(address),
      const DeepCollectionEquality().hash(port),
      const DeepCollectionEquality().hash(url),
      const DeepCollectionEquality().hash(errorCode),
      const DeepCollectionEquality().hash(errorText));

  @JsonKey(ignore: true)
  @override
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
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_NegotiationNeededCopyWith<$Res> {
  __$$PeerConnectionEvent_NegotiationNeededCopyWithImpl(
      _$PeerConnectionEvent_NegotiationNeeded _value,
      $Res Function(_$PeerConnectionEvent_NegotiationNeeded) _then)
      : super(
            _value, (v) => _then(v as _$PeerConnectionEvent_NegotiationNeeded));

  @override
  _$PeerConnectionEvent_NegotiationNeeded get _value =>
      super._value as _$PeerConnectionEvent_NegotiationNeeded;
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
  $Res call({SignalingState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_SignallingChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_SignallingChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_SignallingChangeCopyWithImpl(
      _$PeerConnectionEvent_SignallingChange _value,
      $Res Function(_$PeerConnectionEvent_SignallingChange) _then)
      : super(
            _value, (v) => _then(v as _$PeerConnectionEvent_SignallingChange));

  @override
  _$PeerConnectionEvent_SignallingChange get _value =>
      super._value as _$PeerConnectionEvent_SignallingChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$PeerConnectionEvent_SignallingChange(
      field0 == freezed
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
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
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
  $Res call({IceConnectionState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl(
      _$PeerConnectionEvent_IceConnectionStateChange _value,
      $Res Function(_$PeerConnectionEvent_IceConnectionStateChange) _then)
      : super(_value,
            (v) => _then(v as _$PeerConnectionEvent_IceConnectionStateChange));

  @override
  _$PeerConnectionEvent_IceConnectionStateChange get _value =>
      super._value as _$PeerConnectionEvent_IceConnectionStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$PeerConnectionEvent_IceConnectionStateChange(
      field0 == freezed
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
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
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
  $Res call({PeerConnectionState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_ConnectionStateChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl(
      _$PeerConnectionEvent_ConnectionStateChange _value,
      $Res Function(_$PeerConnectionEvent_ConnectionStateChange) _then)
      : super(_value,
            (v) => _then(v as _$PeerConnectionEvent_ConnectionStateChange));

  @override
  _$PeerConnectionEvent_ConnectionStateChange get _value =>
      super._value as _$PeerConnectionEvent_ConnectionStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$PeerConnectionEvent_ConnectionStateChange(
      field0 == freezed
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
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
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
  $Res call({RtcTrackEvent field0});
}

/// @nodoc
class __$$PeerConnectionEvent_TrackCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_TrackCopyWith<$Res> {
  __$$PeerConnectionEvent_TrackCopyWithImpl(_$PeerConnectionEvent_Track _value,
      $Res Function(_$PeerConnectionEvent_Track) _then)
      : super(_value, (v) => _then(v as _$PeerConnectionEvent_Track));

  @override
  _$PeerConnectionEvent_Track get _value =>
      super._value as _$PeerConnectionEvent_Track;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$PeerConnectionEvent_Track(
      field0 == freezed
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
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
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
