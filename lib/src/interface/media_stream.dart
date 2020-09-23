import 'media_stream_track.dart';

abstract class MediaStream {
  MediaStream(this._id, this._ownerTag);
  final String _id;
  final String _ownerTag;

  String get id => _id;

  String get ownerTag => _ownerTag;

  Future<void> getMediaTracks();

  Future<void> addTrack(MediaStreamTrack track, {bool addToNative = true});

  Future<void> removeTrack(MediaStreamTrack track,
      {bool removeFromNative = true});

  List<MediaStreamTrack> getAudioTracks();

  List<MediaStreamTrack> getVideoTracks();

  Future<void> dispose() async {
    return Future.value();
  }
}
