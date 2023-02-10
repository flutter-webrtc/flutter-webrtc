import 'player_panel/player_state.dart';
import 'webrtc_error.dart';

enum WebRTCPlayerValueState {
  idle,
  url,
  snapshot,
  error,
  play,
  pause,
  resume,
  fullScreen,
  hd,
  speed,
  record,
  recordUrl,
  audio,
}

class WebRTCPlayerValue {
  final WebRTCPlayerValueState state;
  final String url;
  final String snapshot;
  final WebrtcError error;
  final bool playing; // true is play, false is pause, default true
  final bool fullScreen; // true is fullscreen , false is normal, default false,
  final bool live; // true is live, false is playback, default true
  final bool hd; // true is hd, false is sd, default false
  final PlayerSpeed speed;
  final bool
      record; // true is open two way audio, false is close, default false
  final String recordUrl;
  final bool audio; // true is audio on, false is off, default false

  WebRTCPlayerValue({
    this.state = WebRTCPlayerValueState.idle,
    this.url = '',
    this.snapshot = '',
    this.error = WebrtcError.none,
    this.playing = true,
    this.fullScreen = false,
    this.live = true,
    this.hd = false,
    this.speed = PlayerSpeed.x1,
    this.record = false,
    this.recordUrl = '',
    this.audio = false,
  });

  WebRTCPlayerValue copyWith({
    required WebRTCPlayerValueState state,
    String? url,
    String? snapshot,
    WebrtcError? error,
    bool? playing,
    bool? fullScreen,
    bool? live,
    bool? hd,
    PlayerSpeed? speed,
    bool? record,
    bool? audio,
    String? recordUrl,
    bool? dataChannel,
    String? dataChannelUrl,
    int? bitRate,
  }) {
    return WebRTCPlayerValue(
      state: state,
      url: url ?? this.url,
      snapshot: snapshot ?? this.snapshot,
      error: error ?? this.error,
      playing: playing ?? this.playing,
      fullScreen: fullScreen ?? this.fullScreen,
      live: live ?? this.live,
      hd: hd ?? this.hd,
      speed: speed ?? this.speed,
      record: record ?? this.record,
      audio: audio ?? this.audio,
      recordUrl: recordUrl ?? this.recordUrl,
    );
  }

  @override
  String toString() {
    return "state = $state, url = $url, playOrPause = $playing, fullscreen = $fullScreen, error = $error, isLive = $live, speed = $speed, record = $record, audio = $audio}";
  }
}
