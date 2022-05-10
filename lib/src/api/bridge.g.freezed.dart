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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$GetMediaErrorTearOff {
  const _$GetMediaErrorTearOff();

  Audio audio(String field0) {
    return Audio(
      field0,
    );
  }

  Video video(String field0) {
    return Video(
      field0,
    );
  }
}

/// @nodoc
const $GetMediaError = _$GetMediaErrorTearOff();

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
    required TResult Function(Audio value) audio,
    required TResult Function(Video value) video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Audio value)? audio,
    TResult Function(Video value)? video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Audio value)? audio,
    TResult Function(Video value)? video,
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
abstract class $AudioCopyWith<$Res> implements $GetMediaErrorCopyWith<$Res> {
  factory $AudioCopyWith(Audio value, $Res Function(Audio) then) =
      _$AudioCopyWithImpl<$Res>;
  @override
  $Res call({String field0});
}

/// @nodoc
class _$AudioCopyWithImpl<$Res> extends _$GetMediaErrorCopyWithImpl<$Res>
    implements $AudioCopyWith<$Res> {
  _$AudioCopyWithImpl(Audio _value, $Res Function(Audio) _then)
      : super(_value, (v) => _then(v as Audio));

  @override
  Audio get _value => super._value as Audio;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(Audio(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$Audio implements Audio {
  const _$Audio(this.field0);

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
            other is Audio &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $AudioCopyWith<Audio> get copyWith =>
      _$AudioCopyWithImpl<Audio>(this, _$identity);

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
    required TResult Function(Audio value) audio,
    required TResult Function(Video value) video,
  }) {
    return audio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Audio value)? audio,
    TResult Function(Video value)? video,
  }) {
    return audio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Audio value)? audio,
    TResult Function(Video value)? video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(this);
    }
    return orElse();
  }
}

abstract class Audio implements GetMediaError {
  const factory Audio(String field0) = _$Audio;

  @override
  String get field0;
  @override
  @JsonKey(ignore: true)
  $AudioCopyWith<Audio> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoCopyWith<$Res> implements $GetMediaErrorCopyWith<$Res> {
  factory $VideoCopyWith(Video value, $Res Function(Video) then) =
      _$VideoCopyWithImpl<$Res>;
  @override
  $Res call({String field0});
}

/// @nodoc
class _$VideoCopyWithImpl<$Res> extends _$GetMediaErrorCopyWithImpl<$Res>
    implements $VideoCopyWith<$Res> {
  _$VideoCopyWithImpl(Video _value, $Res Function(Video) _then)
      : super(_value, (v) => _then(v as Video));

  @override
  Video get _value => super._value as Video;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(Video(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$Video implements Video {
  const _$Video(this.field0);

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
            other is Video &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $VideoCopyWith<Video> get copyWith =>
      _$VideoCopyWithImpl<Video>(this, _$identity);

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
    required TResult Function(Audio value) audio,
    required TResult Function(Video value) video,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Audio value)? audio,
    TResult Function(Video value)? video,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Audio value)? audio,
    TResult Function(Video value)? video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }
}

abstract class Video implements GetMediaError {
  const factory Video(String field0) = _$Video;

  @override
  String get field0;
  @override
  @JsonKey(ignore: true)
  $VideoCopyWith<Video> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
class _$GetMediaResultTearOff {
  const _$GetMediaResultTearOff();

  Ok ok(List<MediaStreamTrack> field0) {
    return Ok(
      field0,
    );
  }

  Err err(GetMediaError field0) {
    return Err(
      field0,
    );
  }
}

/// @nodoc
const $GetMediaResult = _$GetMediaResultTearOff();

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
    required TResult Function(Ok value) ok,
    required TResult Function(Err value) err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Ok value)? ok,
    TResult Function(Err value)? err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Ok value)? ok,
    TResult Function(Err value)? err,
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
abstract class $OkCopyWith<$Res> {
  factory $OkCopyWith(Ok value, $Res Function(Ok) then) =
      _$OkCopyWithImpl<$Res>;
  $Res call({List<MediaStreamTrack> field0});
}

/// @nodoc
class _$OkCopyWithImpl<$Res> extends _$GetMediaResultCopyWithImpl<$Res>
    implements $OkCopyWith<$Res> {
  _$OkCopyWithImpl(Ok _value, $Res Function(Ok) _then)
      : super(_value, (v) => _then(v as Ok));

  @override
  Ok get _value => super._value as Ok;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(Ok(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<MediaStreamTrack>,
    ));
  }
}

/// @nodoc

class _$Ok implements Ok {
  const _$Ok(this.field0);

  @override
  final List<MediaStreamTrack> field0;

  @override
  String toString() {
    return 'GetMediaResult.ok(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Ok &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $OkCopyWith<Ok> get copyWith => _$OkCopyWithImpl<Ok>(this, _$identity);

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
    required TResult Function(Ok value) ok,
    required TResult Function(Err value) err,
  }) {
    return ok(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Ok value)? ok,
    TResult Function(Err value)? err,
  }) {
    return ok?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Ok value)? ok,
    TResult Function(Err value)? err,
    required TResult orElse(),
  }) {
    if (ok != null) {
      return ok(this);
    }
    return orElse();
  }
}

abstract class Ok implements GetMediaResult {
  const factory Ok(List<MediaStreamTrack> field0) = _$Ok;

  List<MediaStreamTrack> get field0;
  @JsonKey(ignore: true)
  $OkCopyWith<Ok> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ErrCopyWith<$Res> {
  factory $ErrCopyWith(Err value, $Res Function(Err) then) =
      _$ErrCopyWithImpl<$Res>;
  $Res call({GetMediaError field0});

  $GetMediaErrorCopyWith<$Res> get field0;
}

/// @nodoc
class _$ErrCopyWithImpl<$Res> extends _$GetMediaResultCopyWithImpl<$Res>
    implements $ErrCopyWith<$Res> {
  _$ErrCopyWithImpl(Err _value, $Res Function(Err) _then)
      : super(_value, (v) => _then(v as Err));

  @override
  Err get _value => super._value as Err;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(Err(
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

class _$Err implements Err {
  const _$Err(this.field0);

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
            other is Err &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $ErrCopyWith<Err> get copyWith => _$ErrCopyWithImpl<Err>(this, _$identity);

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
    required TResult Function(Ok value) ok,
    required TResult Function(Err value) err,
  }) {
    return err(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Ok value)? ok,
    TResult Function(Err value)? err,
  }) {
    return err?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Ok value)? ok,
    TResult Function(Err value)? err,
    required TResult orElse(),
  }) {
    if (err != null) {
      return err(this);
    }
    return orElse();
  }
}

abstract class Err implements GetMediaResult {
  const factory Err(GetMediaError field0) = _$Err;

  GetMediaError get field0;
  @JsonKey(ignore: true)
  $ErrCopyWith<Err> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
class _$PeerConnectionEventTearOff {
  const _$PeerConnectionEventTearOff();

  PeerCreated peerCreated({required int id}) {
    return PeerCreated(
      id: id,
    );
  }

  IceCandidate iceCandidate(
      {required String sdpMid,
      required int sdpMlineIndex,
      required String candidate}) {
    return IceCandidate(
      sdpMid: sdpMid,
      sdpMlineIndex: sdpMlineIndex,
      candidate: candidate,
    );
  }

  IceGatheringStateChange iceGatheringStateChange(IceGatheringState field0) {
    return IceGatheringStateChange(
      field0,
    );
  }

  IceCandidateError iceCandidateError(
      {required String address,
      required int port,
      required String url,
      required int errorCode,
      required String errorText}) {
    return IceCandidateError(
      address: address,
      port: port,
      url: url,
      errorCode: errorCode,
      errorText: errorText,
    );
  }

  NegotiationNeeded negotiationNeeded() {
    return const NegotiationNeeded();
  }

  SignallingChange signallingChange(SignalingState field0) {
    return SignallingChange(
      field0,
    );
  }

  IceConnectionStateChange iceConnectionStateChange(IceConnectionState field0) {
    return IceConnectionStateChange(
      field0,
    );
  }

  ConnectionStateChange connectionStateChange(PeerConnectionState field0) {
    return ConnectionStateChange(
      field0,
    );
  }

  Track track(RtcTrackEvent field0) {
    return Track(
      field0,
    );
  }
}

/// @nodoc
const $PeerConnectionEvent = _$PeerConnectionEventTearOff();

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
    required TResult Function(PeerCreated value) peerCreated,
    required TResult Function(IceCandidate value) iceCandidate,
    required TResult Function(IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(IceCandidateError value) iceCandidateError,
    required TResult Function(NegotiationNeeded value) negotiationNeeded,
    required TResult Function(SignallingChange value) signallingChange,
    required TResult Function(IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(Track value) track,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
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
abstract class $PeerCreatedCopyWith<$Res> {
  factory $PeerCreatedCopyWith(
          PeerCreated value, $Res Function(PeerCreated) then) =
      _$PeerCreatedCopyWithImpl<$Res>;
  $Res call({int id});
}

/// @nodoc
class _$PeerCreatedCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $PeerCreatedCopyWith<$Res> {
  _$PeerCreatedCopyWithImpl(
      PeerCreated _value, $Res Function(PeerCreated) _then)
      : super(_value, (v) => _then(v as PeerCreated));

  @override
  PeerCreated get _value => super._value as PeerCreated;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(PeerCreated(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PeerCreated implements PeerCreated {
  const _$PeerCreated({required this.id});

  @override

  /// ID of the created [`PeerConnection`].
  final int id;

  @override
  String toString() {
    return 'PeerConnectionEvent.peerCreated(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PeerCreated &&
            const DeepCollectionEquality().equals(other.id, id));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(id));

  @JsonKey(ignore: true)
  @override
  $PeerCreatedCopyWith<PeerCreated> get copyWith =>
      _$PeerCreatedCopyWithImpl<PeerCreated>(this, _$identity);

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
    required TResult Function(PeerCreated value) peerCreated,
    required TResult Function(IceCandidate value) iceCandidate,
    required TResult Function(IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(IceCandidateError value) iceCandidateError,
    required TResult Function(NegotiationNeeded value) negotiationNeeded,
    required TResult Function(SignallingChange value) signallingChange,
    required TResult Function(IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(Track value) track,
  }) {
    return peerCreated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
  }) {
    return peerCreated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
    required TResult orElse(),
  }) {
    if (peerCreated != null) {
      return peerCreated(this);
    }
    return orElse();
  }
}

abstract class PeerCreated implements PeerConnectionEvent {
  const factory PeerCreated({required int id}) = _$PeerCreated;

  /// ID of the created [`PeerConnection`].
  int get id;
  @JsonKey(ignore: true)
  $PeerCreatedCopyWith<PeerCreated> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IceCandidateCopyWith<$Res> {
  factory $IceCandidateCopyWith(
          IceCandidate value, $Res Function(IceCandidate) then) =
      _$IceCandidateCopyWithImpl<$Res>;
  $Res call({String sdpMid, int sdpMlineIndex, String candidate});
}

/// @nodoc
class _$IceCandidateCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $IceCandidateCopyWith<$Res> {
  _$IceCandidateCopyWithImpl(
      IceCandidate _value, $Res Function(IceCandidate) _then)
      : super(_value, (v) => _then(v as IceCandidate));

  @override
  IceCandidate get _value => super._value as IceCandidate;

  @override
  $Res call({
    Object? sdpMid = freezed,
    Object? sdpMlineIndex = freezed,
    Object? candidate = freezed,
  }) {
    return _then(IceCandidate(
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

class _$IceCandidate implements IceCandidate {
  const _$IceCandidate(
      {required this.sdpMid,
      required this.sdpMlineIndex,
      required this.candidate});

  @override

  /// Media stream "identification-tag" defined in [RFC 5888] for the
  /// media component the discovered [RTCIceCandidate][1] is associated
  /// with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5888]: https://tools.ietf.org/html/rfc5888
  final String sdpMid;
  @override

  /// Index (starting at zero) of the media description in the SDP this
  /// [RTCIceCandidate][1] is associated with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  final int sdpMlineIndex;
  @override

  /// Candidate-attribute as defined in Section 15.1 of [RFC 5245].
  ///
  /// If this [RTCIceCandidate][1] represents an end-of-candidates
  /// indication or a peer reflexive remote candidate, candidate is an
  /// empty string.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5245]: https://tools.ietf.org/html/rfc5245
  final String candidate;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceCandidate(sdpMid: $sdpMid, sdpMlineIndex: $sdpMlineIndex, candidate: $candidate)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IceCandidate &&
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
  $IceCandidateCopyWith<IceCandidate> get copyWith =>
      _$IceCandidateCopyWithImpl<IceCandidate>(this, _$identity);

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
    required TResult Function(PeerCreated value) peerCreated,
    required TResult Function(IceCandidate value) iceCandidate,
    required TResult Function(IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(IceCandidateError value) iceCandidateError,
    required TResult Function(NegotiationNeeded value) negotiationNeeded,
    required TResult Function(SignallingChange value) signallingChange,
    required TResult Function(IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(Track value) track,
  }) {
    return iceCandidate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
  }) {
    return iceCandidate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
    required TResult orElse(),
  }) {
    if (iceCandidate != null) {
      return iceCandidate(this);
    }
    return orElse();
  }
}

abstract class IceCandidate implements PeerConnectionEvent {
  const factory IceCandidate(
      {required String sdpMid,
      required int sdpMlineIndex,
      required String candidate}) = _$IceCandidate;

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
  $IceCandidateCopyWith<IceCandidate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IceGatheringStateChangeCopyWith<$Res> {
  factory $IceGatheringStateChangeCopyWith(IceGatheringStateChange value,
          $Res Function(IceGatheringStateChange) then) =
      _$IceGatheringStateChangeCopyWithImpl<$Res>;
  $Res call({IceGatheringState field0});
}

/// @nodoc
class _$IceGatheringStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $IceGatheringStateChangeCopyWith<$Res> {
  _$IceGatheringStateChangeCopyWithImpl(IceGatheringStateChange _value,
      $Res Function(IceGatheringStateChange) _then)
      : super(_value, (v) => _then(v as IceGatheringStateChange));

  @override
  IceGatheringStateChange get _value => super._value as IceGatheringStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(IceGatheringStateChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceGatheringState,
    ));
  }
}

/// @nodoc

class _$IceGatheringStateChange implements IceGatheringStateChange {
  const _$IceGatheringStateChange(this.field0);

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
            other is IceGatheringStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $IceGatheringStateChangeCopyWith<IceGatheringStateChange> get copyWith =>
      _$IceGatheringStateChangeCopyWithImpl<IceGatheringStateChange>(
          this, _$identity);

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
    required TResult Function(PeerCreated value) peerCreated,
    required TResult Function(IceCandidate value) iceCandidate,
    required TResult Function(IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(IceCandidateError value) iceCandidateError,
    required TResult Function(NegotiationNeeded value) negotiationNeeded,
    required TResult Function(SignallingChange value) signallingChange,
    required TResult Function(IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(Track value) track,
  }) {
    return iceGatheringStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
  }) {
    return iceGatheringStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
    required TResult orElse(),
  }) {
    if (iceGatheringStateChange != null) {
      return iceGatheringStateChange(this);
    }
    return orElse();
  }
}

abstract class IceGatheringStateChange implements PeerConnectionEvent {
  const factory IceGatheringStateChange(IceGatheringState field0) =
      _$IceGatheringStateChange;

  IceGatheringState get field0;
  @JsonKey(ignore: true)
  $IceGatheringStateChangeCopyWith<IceGatheringStateChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IceCandidateErrorCopyWith<$Res> {
  factory $IceCandidateErrorCopyWith(
          IceCandidateError value, $Res Function(IceCandidateError) then) =
      _$IceCandidateErrorCopyWithImpl<$Res>;
  $Res call(
      {String address, int port, String url, int errorCode, String errorText});
}

/// @nodoc
class _$IceCandidateErrorCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $IceCandidateErrorCopyWith<$Res> {
  _$IceCandidateErrorCopyWithImpl(
      IceCandidateError _value, $Res Function(IceCandidateError) _then)
      : super(_value, (v) => _then(v as IceCandidateError));

  @override
  IceCandidateError get _value => super._value as IceCandidateError;

  @override
  $Res call({
    Object? address = freezed,
    Object? port = freezed,
    Object? url = freezed,
    Object? errorCode = freezed,
    Object? errorText = freezed,
  }) {
    return _then(IceCandidateError(
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

class _$IceCandidateError implements IceCandidateError {
  const _$IceCandidateError(
      {required this.address,
      required this.port,
      required this.url,
      required this.errorCode,
      required this.errorText});

  @override

  /// Local IP address used to communicate with the STUN or TURN server.
  final String address;
  @override

  /// Port used to communicate with the STUN or TURN server.
  final int port;
  @override

  /// STUN or TURN URL identifying the STUN or TURN server for which the
  /// failure occurred.
  final String url;
  @override

  /// Numeric STUN error code returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If no host candidate can reach the server, it will be set to the
  /// value `701` which is outside the STUN error code range.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  final int errorCode;
  @override

  /// STUN reason text returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If the server could not be reached, it will be set to an
  /// implementation-specific value providing details about the error.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  final String errorText;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceCandidateError(address: $address, port: $port, url: $url, errorCode: $errorCode, errorText: $errorText)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IceCandidateError &&
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
  $IceCandidateErrorCopyWith<IceCandidateError> get copyWith =>
      _$IceCandidateErrorCopyWithImpl<IceCandidateError>(this, _$identity);

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
    required TResult Function(PeerCreated value) peerCreated,
    required TResult Function(IceCandidate value) iceCandidate,
    required TResult Function(IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(IceCandidateError value) iceCandidateError,
    required TResult Function(NegotiationNeeded value) negotiationNeeded,
    required TResult Function(SignallingChange value) signallingChange,
    required TResult Function(IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(Track value) track,
  }) {
    return iceCandidateError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
  }) {
    return iceCandidateError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
    required TResult orElse(),
  }) {
    if (iceCandidateError != null) {
      return iceCandidateError(this);
    }
    return orElse();
  }
}

abstract class IceCandidateError implements PeerConnectionEvent {
  const factory IceCandidateError(
      {required String address,
      required int port,
      required String url,
      required int errorCode,
      required String errorText}) = _$IceCandidateError;

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
  $IceCandidateErrorCopyWith<IceCandidateError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NegotiationNeededCopyWith<$Res> {
  factory $NegotiationNeededCopyWith(
          NegotiationNeeded value, $Res Function(NegotiationNeeded) then) =
      _$NegotiationNeededCopyWithImpl<$Res>;
}

/// @nodoc
class _$NegotiationNeededCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $NegotiationNeededCopyWith<$Res> {
  _$NegotiationNeededCopyWithImpl(
      NegotiationNeeded _value, $Res Function(NegotiationNeeded) _then)
      : super(_value, (v) => _then(v as NegotiationNeeded));

  @override
  NegotiationNeeded get _value => super._value as NegotiationNeeded;
}

/// @nodoc

class _$NegotiationNeeded implements NegotiationNeeded {
  const _$NegotiationNeeded();

  @override
  String toString() {
    return 'PeerConnectionEvent.negotiationNeeded()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is NegotiationNeeded);
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
    required TResult Function(PeerCreated value) peerCreated,
    required TResult Function(IceCandidate value) iceCandidate,
    required TResult Function(IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(IceCandidateError value) iceCandidateError,
    required TResult Function(NegotiationNeeded value) negotiationNeeded,
    required TResult Function(SignallingChange value) signallingChange,
    required TResult Function(IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(Track value) track,
  }) {
    return negotiationNeeded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
  }) {
    return negotiationNeeded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
    required TResult orElse(),
  }) {
    if (negotiationNeeded != null) {
      return negotiationNeeded(this);
    }
    return orElse();
  }
}

abstract class NegotiationNeeded implements PeerConnectionEvent {
  const factory NegotiationNeeded() = _$NegotiationNeeded;
}

/// @nodoc
abstract class $SignallingChangeCopyWith<$Res> {
  factory $SignallingChangeCopyWith(
          SignallingChange value, $Res Function(SignallingChange) then) =
      _$SignallingChangeCopyWithImpl<$Res>;
  $Res call({SignalingState field0});
}

/// @nodoc
class _$SignallingChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $SignallingChangeCopyWith<$Res> {
  _$SignallingChangeCopyWithImpl(
      SignallingChange _value, $Res Function(SignallingChange) _then)
      : super(_value, (v) => _then(v as SignallingChange));

  @override
  SignallingChange get _value => super._value as SignallingChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(SignallingChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as SignalingState,
    ));
  }
}

/// @nodoc

class _$SignallingChange implements SignallingChange {
  const _$SignallingChange(this.field0);

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
            other is SignallingChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $SignallingChangeCopyWith<SignallingChange> get copyWith =>
      _$SignallingChangeCopyWithImpl<SignallingChange>(this, _$identity);

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
    required TResult Function(PeerCreated value) peerCreated,
    required TResult Function(IceCandidate value) iceCandidate,
    required TResult Function(IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(IceCandidateError value) iceCandidateError,
    required TResult Function(NegotiationNeeded value) negotiationNeeded,
    required TResult Function(SignallingChange value) signallingChange,
    required TResult Function(IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(Track value) track,
  }) {
    return signallingChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
  }) {
    return signallingChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
    required TResult orElse(),
  }) {
    if (signallingChange != null) {
      return signallingChange(this);
    }
    return orElse();
  }
}

abstract class SignallingChange implements PeerConnectionEvent {
  const factory SignallingChange(SignalingState field0) = _$SignallingChange;

  SignalingState get field0;
  @JsonKey(ignore: true)
  $SignallingChangeCopyWith<SignallingChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IceConnectionStateChangeCopyWith<$Res> {
  factory $IceConnectionStateChangeCopyWith(IceConnectionStateChange value,
          $Res Function(IceConnectionStateChange) then) =
      _$IceConnectionStateChangeCopyWithImpl<$Res>;
  $Res call({IceConnectionState field0});
}

/// @nodoc
class _$IceConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $IceConnectionStateChangeCopyWith<$Res> {
  _$IceConnectionStateChangeCopyWithImpl(IceConnectionStateChange _value,
      $Res Function(IceConnectionStateChange) _then)
      : super(_value, (v) => _then(v as IceConnectionStateChange));

  @override
  IceConnectionStateChange get _value =>
      super._value as IceConnectionStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(IceConnectionStateChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceConnectionState,
    ));
  }
}

/// @nodoc

class _$IceConnectionStateChange implements IceConnectionStateChange {
  const _$IceConnectionStateChange(this.field0);

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
            other is IceConnectionStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $IceConnectionStateChangeCopyWith<IceConnectionStateChange> get copyWith =>
      _$IceConnectionStateChangeCopyWithImpl<IceConnectionStateChange>(
          this, _$identity);

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
    required TResult Function(PeerCreated value) peerCreated,
    required TResult Function(IceCandidate value) iceCandidate,
    required TResult Function(IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(IceCandidateError value) iceCandidateError,
    required TResult Function(NegotiationNeeded value) negotiationNeeded,
    required TResult Function(SignallingChange value) signallingChange,
    required TResult Function(IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(Track value) track,
  }) {
    return iceConnectionStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
  }) {
    return iceConnectionStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
    required TResult orElse(),
  }) {
    if (iceConnectionStateChange != null) {
      return iceConnectionStateChange(this);
    }
    return orElse();
  }
}

abstract class IceConnectionStateChange implements PeerConnectionEvent {
  const factory IceConnectionStateChange(IceConnectionState field0) =
      _$IceConnectionStateChange;

  IceConnectionState get field0;
  @JsonKey(ignore: true)
  $IceConnectionStateChangeCopyWith<IceConnectionStateChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionStateChangeCopyWith<$Res> {
  factory $ConnectionStateChangeCopyWith(ConnectionStateChange value,
          $Res Function(ConnectionStateChange) then) =
      _$ConnectionStateChangeCopyWithImpl<$Res>;
  $Res call({PeerConnectionState field0});
}

/// @nodoc
class _$ConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $ConnectionStateChangeCopyWith<$Res> {
  _$ConnectionStateChangeCopyWithImpl(
      ConnectionStateChange _value, $Res Function(ConnectionStateChange) _then)
      : super(_value, (v) => _then(v as ConnectionStateChange));

  @override
  ConnectionStateChange get _value => super._value as ConnectionStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(ConnectionStateChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PeerConnectionState,
    ));
  }
}

/// @nodoc

class _$ConnectionStateChange implements ConnectionStateChange {
  const _$ConnectionStateChange(this.field0);

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
            other is ConnectionStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $ConnectionStateChangeCopyWith<ConnectionStateChange> get copyWith =>
      _$ConnectionStateChangeCopyWithImpl<ConnectionStateChange>(
          this, _$identity);

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
    required TResult Function(PeerCreated value) peerCreated,
    required TResult Function(IceCandidate value) iceCandidate,
    required TResult Function(IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(IceCandidateError value) iceCandidateError,
    required TResult Function(NegotiationNeeded value) negotiationNeeded,
    required TResult Function(SignallingChange value) signallingChange,
    required TResult Function(IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(Track value) track,
  }) {
    return connectionStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
  }) {
    return connectionStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
    required TResult orElse(),
  }) {
    if (connectionStateChange != null) {
      return connectionStateChange(this);
    }
    return orElse();
  }
}

abstract class ConnectionStateChange implements PeerConnectionEvent {
  const factory ConnectionStateChange(PeerConnectionState field0) =
      _$ConnectionStateChange;

  PeerConnectionState get field0;
  @JsonKey(ignore: true)
  $ConnectionStateChangeCopyWith<ConnectionStateChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackCopyWith<$Res> {
  factory $TrackCopyWith(Track value, $Res Function(Track) then) =
      _$TrackCopyWithImpl<$Res>;
  $Res call({RtcTrackEvent field0});
}

/// @nodoc
class _$TrackCopyWithImpl<$Res> extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(Track _value, $Res Function(Track) _then)
      : super(_value, (v) => _then(v as Track));

  @override
  Track get _value => super._value as Track;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(Track(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as RtcTrackEvent,
    ));
  }
}

/// @nodoc

class _$Track implements Track {
  const _$Track(this.field0);

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
            other is Track &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $TrackCopyWith<Track> get copyWith =>
      _$TrackCopyWithImpl<Track>(this, _$identity);

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
    required TResult Function(PeerCreated value) peerCreated,
    required TResult Function(IceCandidate value) iceCandidate,
    required TResult Function(IceGatheringStateChange value)
        iceGatheringStateChange,
    required TResult Function(IceCandidateError value) iceCandidateError,
    required TResult Function(NegotiationNeeded value) negotiationNeeded,
    required TResult Function(SignallingChange value) signallingChange,
    required TResult Function(IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(Track value) track,
  }) {
    return track(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
  }) {
    return track?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerCreated value)? peerCreated,
    TResult Function(IceCandidate value)? iceCandidate,
    TResult Function(IceGatheringStateChange value)? iceGatheringStateChange,
    TResult Function(IceCandidateError value)? iceCandidateError,
    TResult Function(NegotiationNeeded value)? negotiationNeeded,
    TResult Function(SignallingChange value)? signallingChange,
    TResult Function(IceConnectionStateChange value)? iceConnectionStateChange,
    TResult Function(ConnectionStateChange value)? connectionStateChange,
    TResult Function(Track value)? track,
    required TResult orElse(),
  }) {
    if (track != null) {
      return track(this);
    }
    return orElse();
  }
}

abstract class Track implements PeerConnectionEvent {
  const factory Track(RtcTrackEvent field0) = _$Track;

  RtcTrackEvent get field0;
  @JsonKey(ignore: true)
  $TrackCopyWith<Track> get copyWith => throw _privateConstructorUsedError;
}
