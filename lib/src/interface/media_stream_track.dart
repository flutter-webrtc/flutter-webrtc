abstract class MediaStreamTrack {
  MediaStreamTrack();

  bool get enabled;

  String get label;

  String get kind;

  String get id;

  ///Future contains isFrontCamera
  ///Throws error if switching camera failed
  Future<bool> switchCamera();

  Future<void> adaptRes(int width, int height);

  void setVolume(double volume);

  void setMicrophoneMute(bool mute);

  void enableSpeakerphone(bool enable);

  Future<dynamic> captureFrame([String filePath]);

  Future<bool> hasTorch();
  Future<void> setTorch(bool torch);

  Future<void> dispose() {
    return Future.value();
  }
}
