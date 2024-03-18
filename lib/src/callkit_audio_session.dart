import '../flutter_webrtc.dart';

Future<void> callKitConfigureAudioSession() async {
  WebRTC.invokeMethod('callKitConfigureAudioSession');
}

Future<void> callKitReleaseAudioSession() async {
   WebRTC.invokeMethod('callKitReleaseAudioSession');
}

Future<void> callKitStartAudio() async {
  WebRTC.invokeMethod('callKitStartAudio');
}

Future<void> callKitStopAudio() async {
  WebRTC.invokeMethod('callKitStopAudio');
}
