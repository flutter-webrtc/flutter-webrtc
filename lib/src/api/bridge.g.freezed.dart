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
abstract class _$$AudioCopyWith<$Res> implements $GetMediaErrorCopyWith<$Res> {
  factory _$$AudioCopyWith(_$Audio value, $Res Function(_$Audio) then) =
      __$$AudioCopyWithImpl<$Res>;
  @override
  $Res call({String field0});
}

/// @nodoc
class __$$AudioCopyWithImpl<$Res> extends _$GetMediaErrorCopyWithImpl<$Res>
    implements _$$AudioCopyWith<$Res> {
  __$$AudioCopyWithImpl(_$Audio _value, $Res Function(_$Audio) _then)
      : super(_value, (v) => _then(v as _$Audio));

  @override
  _$Audio get _value => super._value as _$Audio;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$Audio(
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
            other is _$Audio &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$AudioCopyWith<_$Audio> get copyWith =>
      __$$AudioCopyWithImpl<_$Audio>(this, _$identity);

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
  const factory Audio(final String field0) = _$Audio;

  @override
  String get field0 => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$AudioCopyWith<_$Audio> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VideoCopyWith<$Res> implements $GetMediaErrorCopyWith<$Res> {
  factory _$$VideoCopyWith(_$Video value, $Res Function(_$Video) then) =
      __$$VideoCopyWithImpl<$Res>;
  @override
  $Res call({String field0});
}

/// @nodoc
class __$$VideoCopyWithImpl<$Res> extends _$GetMediaErrorCopyWithImpl<$Res>
    implements _$$VideoCopyWith<$Res> {
  __$$VideoCopyWithImpl(_$Video _value, $Res Function(_$Video) _then)
      : super(_value, (v) => _then(v as _$Video));

  @override
  _$Video get _value => super._value as _$Video;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$Video(
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
            other is _$Video &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$VideoCopyWith<_$Video> get copyWith =>
      __$$VideoCopyWithImpl<_$Video>(this, _$identity);

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
  const factory Video(final String field0) = _$Video;

  @override
  String get field0 => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$VideoCopyWith<_$Video> get copyWith => throw _privateConstructorUsedError;
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
abstract class _$$OkCopyWith<$Res> {
  factory _$$OkCopyWith(_$Ok value, $Res Function(_$Ok) then) =
      __$$OkCopyWithImpl<$Res>;
  $Res call({List<MediaStreamTrack> field0});
}

/// @nodoc
class __$$OkCopyWithImpl<$Res> extends _$GetMediaResultCopyWithImpl<$Res>
    implements _$$OkCopyWith<$Res> {
  __$$OkCopyWithImpl(_$Ok _value, $Res Function(_$Ok) _then)
      : super(_value, (v) => _then(v as _$Ok));

  @override
  _$Ok get _value => super._value as _$Ok;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$Ok(
      field0 == freezed
          ? _value._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<MediaStreamTrack>,
    ));
  }
}

/// @nodoc

class _$Ok implements Ok {
  const _$Ok(final List<MediaStreamTrack> field0) : _field0 = field0;

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
            other is _$Ok &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @JsonKey(ignore: true)
  @override
  _$$OkCopyWith<_$Ok> get copyWith =>
      __$$OkCopyWithImpl<_$Ok>(this, _$identity);

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
  const factory Ok(final List<MediaStreamTrack> field0) = _$Ok;

  List<MediaStreamTrack> get field0 => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$OkCopyWith<_$Ok> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrCopyWith<$Res> {
  factory _$$ErrCopyWith(_$Err value, $Res Function(_$Err) then) =
      __$$ErrCopyWithImpl<$Res>;
  $Res call({GetMediaError field0});

  $GetMediaErrorCopyWith<$Res> get field0;
}

/// @nodoc
class __$$ErrCopyWithImpl<$Res> extends _$GetMediaResultCopyWithImpl<$Res>
    implements _$$ErrCopyWith<$Res> {
  __$$ErrCopyWithImpl(_$Err _value, $Res Function(_$Err) _then)
      : super(_value, (v) => _then(v as _$Err));

  @override
  _$Err get _value => super._value as _$Err;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$Err(
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
            other is _$Err &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$ErrCopyWith<_$Err> get copyWith =>
      __$$ErrCopyWithImpl<_$Err>(this, _$identity);

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
  const factory Err(final GetMediaError field0) = _$Err;

  GetMediaError get field0 => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$ErrCopyWith<_$Err> get copyWith => throw _privateConstructorUsedError;
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
abstract class _$$PeerCreatedCopyWith<$Res> {
  factory _$$PeerCreatedCopyWith(
          _$PeerCreated value, $Res Function(_$PeerCreated) then) =
      __$$PeerCreatedCopyWithImpl<$Res>;
  $Res call({int id});
}

/// @nodoc
class __$$PeerCreatedCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerCreatedCopyWith<$Res> {
  __$$PeerCreatedCopyWithImpl(
      _$PeerCreated _value, $Res Function(_$PeerCreated) _then)
      : super(_value, (v) => _then(v as _$PeerCreated));

  @override
  _$PeerCreated get _value => super._value as _$PeerCreated;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(_$PeerCreated(
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
            other is _$PeerCreated &&
            const DeepCollectionEquality().equals(other.id, id));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(id));

  @JsonKey(ignore: true)
  @override
  _$$PeerCreatedCopyWith<_$PeerCreated> get copyWith =>
      __$$PeerCreatedCopyWithImpl<_$PeerCreated>(this, _$identity);

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
  const factory PeerCreated({required final int id}) = _$PeerCreated;

  /// ID of the created [`PeerConnection`].
  int get id => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$PeerCreatedCopyWith<_$PeerCreated> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$IceCandidateCopyWith<$Res> {
  factory _$$IceCandidateCopyWith(
          _$IceCandidate value, $Res Function(_$IceCandidate) then) =
      __$$IceCandidateCopyWithImpl<$Res>;
  $Res call({String sdpMid, int sdpMlineIndex, String candidate});
}

/// @nodoc
class __$$IceCandidateCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$IceCandidateCopyWith<$Res> {
  __$$IceCandidateCopyWithImpl(
      _$IceCandidate _value, $Res Function(_$IceCandidate) _then)
      : super(_value, (v) => _then(v as _$IceCandidate));

  @override
  _$IceCandidate get _value => super._value as _$IceCandidate;

  @override
  $Res call({
    Object? sdpMid = freezed,
    Object? sdpMlineIndex = freezed,
    Object? candidate = freezed,
  }) {
    return _then(_$IceCandidate(
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
            other is _$IceCandidate &&
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
  _$$IceCandidateCopyWith<_$IceCandidate> get copyWith =>
      __$$IceCandidateCopyWithImpl<_$IceCandidate>(this, _$identity);

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
      {required final String sdpMid,
      required final int sdpMlineIndex,
      required final String candidate}) = _$IceCandidate;

  /// Media stream "identification-tag" defined in [RFC 5888] for the
  /// media component the discovered [RTCIceCandidate][1] is associated
  /// with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5888]: https://tools.ietf.org/html/rfc5888
  String get sdpMid => throw _privateConstructorUsedError;

  /// Index (starting at zero) of the media description in the SDP this
  /// [RTCIceCandidate][1] is associated with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  int get sdpMlineIndex => throw _privateConstructorUsedError;

  /// Candidate-attribute as defined in Section 15.1 of [RFC 5245].
  ///
  /// If this [RTCIceCandidate][1] represents an end-of-candidates
  /// indication or a peer reflexive remote candidate, candidate is an
  /// empty string.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5245]: https://tools.ietf.org/html/rfc5245
  String get candidate => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$IceCandidateCopyWith<_$IceCandidate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$IceGatheringStateChangeCopyWith<$Res> {
  factory _$$IceGatheringStateChangeCopyWith(_$IceGatheringStateChange value,
          $Res Function(_$IceGatheringStateChange) then) =
      __$$IceGatheringStateChangeCopyWithImpl<$Res>;
  $Res call({IceGatheringState field0});
}

/// @nodoc
class __$$IceGatheringStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$IceGatheringStateChangeCopyWith<$Res> {
  __$$IceGatheringStateChangeCopyWithImpl(_$IceGatheringStateChange _value,
      $Res Function(_$IceGatheringStateChange) _then)
      : super(_value, (v) => _then(v as _$IceGatheringStateChange));

  @override
  _$IceGatheringStateChange get _value =>
      super._value as _$IceGatheringStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$IceGatheringStateChange(
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
            other is _$IceGatheringStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$IceGatheringStateChangeCopyWith<_$IceGatheringStateChange> get copyWith =>
      __$$IceGatheringStateChangeCopyWithImpl<_$IceGatheringStateChange>(
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
  const factory IceGatheringStateChange(final IceGatheringState field0) =
      _$IceGatheringStateChange;

  IceGatheringState get field0 => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$IceGatheringStateChangeCopyWith<_$IceGatheringStateChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$IceCandidateErrorCopyWith<$Res> {
  factory _$$IceCandidateErrorCopyWith(
          _$IceCandidateError value, $Res Function(_$IceCandidateError) then) =
      __$$IceCandidateErrorCopyWithImpl<$Res>;
  $Res call(
      {String address, int port, String url, int errorCode, String errorText});
}

/// @nodoc
class __$$IceCandidateErrorCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$IceCandidateErrorCopyWith<$Res> {
  __$$IceCandidateErrorCopyWithImpl(
      _$IceCandidateError _value, $Res Function(_$IceCandidateError) _then)
      : super(_value, (v) => _then(v as _$IceCandidateError));

  @override
  _$IceCandidateError get _value => super._value as _$IceCandidateError;

  @override
  $Res call({
    Object? address = freezed,
    Object? port = freezed,
    Object? url = freezed,
    Object? errorCode = freezed,
    Object? errorText = freezed,
  }) {
    return _then(_$IceCandidateError(
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
            other is _$IceCandidateError &&
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
  _$$IceCandidateErrorCopyWith<_$IceCandidateError> get copyWith =>
      __$$IceCandidateErrorCopyWithImpl<_$IceCandidateError>(this, _$identity);

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
      {required final String address,
      required final int port,
      required final String url,
      required final int errorCode,
      required final String errorText}) = _$IceCandidateError;

  /// Local IP address used to communicate with the STUN or TURN server.
  String get address => throw _privateConstructorUsedError;

  /// Port used to communicate with the STUN or TURN server.
  int get port => throw _privateConstructorUsedError;

  /// STUN or TURN URL identifying the STUN or TURN server for which the
  /// failure occurred.
  String get url => throw _privateConstructorUsedError;

  /// Numeric STUN error code returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If no host candidate can reach the server, it will be set to the
  /// value `701` which is outside the STUN error code range.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  int get errorCode => throw _privateConstructorUsedError;

  /// STUN reason text returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If the server could not be reached, it will be set to an
  /// implementation-specific value providing details about the error.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  String get errorText => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$IceCandidateErrorCopyWith<_$IceCandidateError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NegotiationNeededCopyWith<$Res> {
  factory _$$NegotiationNeededCopyWith(
          _$NegotiationNeeded value, $Res Function(_$NegotiationNeeded) then) =
      __$$NegotiationNeededCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NegotiationNeededCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$NegotiationNeededCopyWith<$Res> {
  __$$NegotiationNeededCopyWithImpl(
      _$NegotiationNeeded _value, $Res Function(_$NegotiationNeeded) _then)
      : super(_value, (v) => _then(v as _$NegotiationNeeded));

  @override
  _$NegotiationNeeded get _value => super._value as _$NegotiationNeeded;
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
        (other.runtimeType == runtimeType && other is _$NegotiationNeeded);
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
abstract class _$$SignallingChangeCopyWith<$Res> {
  factory _$$SignallingChangeCopyWith(
          _$SignallingChange value, $Res Function(_$SignallingChange) then) =
      __$$SignallingChangeCopyWithImpl<$Res>;
  $Res call({SignalingState field0});
}

/// @nodoc
class __$$SignallingChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$SignallingChangeCopyWith<$Res> {
  __$$SignallingChangeCopyWithImpl(
      _$SignallingChange _value, $Res Function(_$SignallingChange) _then)
      : super(_value, (v) => _then(v as _$SignallingChange));

  @override
  _$SignallingChange get _value => super._value as _$SignallingChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$SignallingChange(
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
            other is _$SignallingChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$SignallingChangeCopyWith<_$SignallingChange> get copyWith =>
      __$$SignallingChangeCopyWithImpl<_$SignallingChange>(this, _$identity);

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
  const factory SignallingChange(final SignalingState field0) =
      _$SignallingChange;

  SignalingState get field0 => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$SignallingChangeCopyWith<_$SignallingChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$IceConnectionStateChangeCopyWith<$Res> {
  factory _$$IceConnectionStateChangeCopyWith(_$IceConnectionStateChange value,
          $Res Function(_$IceConnectionStateChange) then) =
      __$$IceConnectionStateChangeCopyWithImpl<$Res>;
  $Res call({IceConnectionState field0});
}

/// @nodoc
class __$$IceConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$IceConnectionStateChangeCopyWith<$Res> {
  __$$IceConnectionStateChangeCopyWithImpl(_$IceConnectionStateChange _value,
      $Res Function(_$IceConnectionStateChange) _then)
      : super(_value, (v) => _then(v as _$IceConnectionStateChange));

  @override
  _$IceConnectionStateChange get _value =>
      super._value as _$IceConnectionStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$IceConnectionStateChange(
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
            other is _$IceConnectionStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$IceConnectionStateChangeCopyWith<_$IceConnectionStateChange>
      get copyWith =>
          __$$IceConnectionStateChangeCopyWithImpl<_$IceConnectionStateChange>(
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
  const factory IceConnectionStateChange(final IceConnectionState field0) =
      _$IceConnectionStateChange;

  IceConnectionState get field0 => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$IceConnectionStateChangeCopyWith<_$IceConnectionStateChange>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConnectionStateChangeCopyWith<$Res> {
  factory _$$ConnectionStateChangeCopyWith(_$ConnectionStateChange value,
          $Res Function(_$ConnectionStateChange) then) =
      __$$ConnectionStateChangeCopyWithImpl<$Res>;
  $Res call({PeerConnectionState field0});
}

/// @nodoc
class __$$ConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$ConnectionStateChangeCopyWith<$Res> {
  __$$ConnectionStateChangeCopyWithImpl(_$ConnectionStateChange _value,
      $Res Function(_$ConnectionStateChange) _then)
      : super(_value, (v) => _then(v as _$ConnectionStateChange));

  @override
  _$ConnectionStateChange get _value => super._value as _$ConnectionStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$ConnectionStateChange(
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
            other is _$ConnectionStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$ConnectionStateChangeCopyWith<_$ConnectionStateChange> get copyWith =>
      __$$ConnectionStateChangeCopyWithImpl<_$ConnectionStateChange>(
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
  const factory ConnectionStateChange(final PeerConnectionState field0) =
      _$ConnectionStateChange;

  PeerConnectionState get field0 => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$ConnectionStateChangeCopyWith<_$ConnectionStateChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrackCopyWith<$Res> {
  factory _$$TrackCopyWith(_$Track value, $Res Function(_$Track) then) =
      __$$TrackCopyWithImpl<$Res>;
  $Res call({RtcTrackEvent field0});
}

/// @nodoc
class __$$TrackCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$TrackCopyWith<$Res> {
  __$$TrackCopyWithImpl(_$Track _value, $Res Function(_$Track) _then)
      : super(_value, (v) => _then(v as _$Track));

  @override
  _$Track get _value => super._value as _$Track;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$Track(
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
            other is _$Track &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$TrackCopyWith<_$Track> get copyWith =>
      __$$TrackCopyWithImpl<_$Track>(this, _$identity);

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
  const factory Track(final RtcTrackEvent field0) = _$Track;

  RtcTrackEvent get field0 => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$TrackCopyWith<_$Track> get copyWith => throw _privateConstructorUsedError;
}
