import 'media_stream_track.dart';

typedef MediaTrackCallback = void Function(MediaStreamTrack track);

///https://w3c.github.io/mediacapture-main/#mediastream
abstract class MediaStream {
  MediaStream(this._id, this._ownerTag);
  final String _id;
  final String _ownerTag;

  /// The event type of this event handler is addtrack.
  MediaTrackCallback onAddTrack;

  /// The event type of this event handler is removetrack.
  MediaTrackCallback onRemoveTrack;

  String get id => _id;

  String get ownerTag => _ownerTag;

  /// The active attribute return true if this [MediaStream] is active and false otherwise.
  /// [MediaStream] is considered active if at least one of its [MediaStreamTracks] is not in the [MediaStreamTrack.ended] state.
  /// Once every track has ended, the stream's active property becomes false.
  bool get active;

  @deprecated
  Future<void> getMediaTracks();

  /// Adds the given [MediaStreamTrack] to this [MediaStream].
  Future<void> addTrack(MediaStreamTrack track, {bool addToNative = true});

  /// Removes the given [MediaStreamTrack] object from this [MediaStream].
  Future<void> removeTrack(MediaStreamTrack track,
      {bool removeFromNative = true});

  /// Returns a List [MediaStreamTrack] objects representing all the tracks in this stream.
  List<MediaStreamTrack> getTracks();

  /// Returns a List [MediaStreamTrack] objects representing the audio tracks in this stream.
  /// The list represents a snapshot of all the [MediaStreamTrack]  objects in this stream's track set whose kind is equal to 'audio'.
  List<MediaStreamTrack> getAudioTracks();

  /// Returns a List [MediaStreamTrack] objects representing the video tracks in this stream.
  /// The list represents a snapshot of all the [MediaStreamTrack]  objects in this stream's track set whose kind is equal to 'video'.
  List<MediaStreamTrack> getVideoTracks();

  /// Returns either a [MediaStreamTrack] object from this stream's track set whose id is equal to trackId, or null, if no such track exists.
  MediaStreamTrack getTrackById(String trackId) {
    return getTracks().firstWhere(
      (element) => element.id == trackId,
      orElse: () => null,
    );
  }

  /// Clones the given [MediaStream] and all its tracks.
  MediaStream clone();

  Future<void> dispose() async {
    return Future.value();
  }
}
