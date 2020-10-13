import 'media_stream_track.dart';

typedef MediaTrackCallback = void Function(MediaStreamTrack track);

abstract class MediaStream {
  MediaStream(this._id, this._ownerTag);
  final String _id;
  final String _ownerTag;

  MediaTrackCallback onAddTrack;

  MediaTrackCallback onRemoveTrack;

  String get id => _id;

  String get ownerTag => _ownerTag;

  Future<void> getMediaTracks();

  Future<void> addTrack(MediaStreamTrack track, {bool addToNative = true});

  Future<void> removeTrack(MediaStreamTrack track,
      {bool removeFromNative = true});

  List<MediaStreamTrack> getTracks();

  List<MediaStreamTrack> getAudioTracks();

  List<MediaStreamTrack> getVideoTracks();

  Future<void> dispose() async {
    return Future.value();
  }
}
