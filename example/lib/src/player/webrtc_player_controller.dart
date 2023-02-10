import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import 'player_panel/player_state.dart';
import 'webrtc_error.dart';
import 'webrtc_player_value.dart';

class WebRTCPlayerController extends ChangeNotifier {
  WebRTCPlayerController();

  WebRTCPlayerValue _value = WebRTCPlayerValue();
  PlayerState _state = PlayerState.connecting;

  WebRTCPlayerValue get value => _value;
  PlayerState get state => _state;

  String _description = '';
  String? _stream;

  Timer? _timer;

  _startTimer(PlayerState state) {
    if (!state.isConnected) {
      stopTimer();
      return;
    }

    final bool isActive = _timer?.isActive ?? false;
    if (!isActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        onCurrentPosition.add(timer.tick);
      });
    }
  }

  stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// state
  setPlayerState(PlayerState state, [bool notify = true]) {
    _state = state;
    if (!onPlayerStateUpdate.isClosed) {
      onPlayerStateUpdate.add(state);
      state.isConnected ? _startTimer(state) : stopTimer();
    }
    if (notify) notifyListeners();
  }

  /// Public - get value
  String get dataSource => value.url;
  bool get record => _value.record;
  String get snapshot => value.snapshot;
  WebrtcError get error => value.error;
  bool get fullscreen => value.fullScreen;
  bool get hd => _value.hd;
  bool get audio => _value.audio;
  String get description => _description;
  String? get stream => _stream;
  PlayerSpeed get speed => _value.speed;

  bool get isPlaying => value.playing && _state.isConnected;
  bool get isPaused => !value.playing && _state.isPaused;
  bool get isError => _state.isError;

  /// data source
  setDataSource({
    required String url,
    bool live = true,
  }) {
    _value = value.copyWith(
      state: WebRTCPlayerValueState.url,
      url: url,
      playing: true,
      live: live,
    );
    setPlayerState(PlayerState.connecting, false);
    notifyListeners();
  }

  /// set record data source
  setRecordDataSource({required String recordUrl}) {
    _value = value.copyWith(
      state: WebRTCPlayerValueState.recordUrl,
      recordUrl: recordUrl,
      record: true,
    );
    notifyListeners();
  }

  /// record on
  setRecordOn() {
    _value = value.copyWith(
      state: WebRTCPlayerValueState.record,
      record: true,
    );
    notifyListeners();
    onSwitchRecord.add(true);
  }

  /// record off
  setRecordOff({bool onRecord = true}) {
    _value = value.copyWith(
      state: WebRTCPlayerValueState.record,
      record: false,
    );
    notifyListeners();
    if (onRecord) onSwitchRecord.add(false);
  }

  /// reset data source
  resetDataSource() {
    onTapResetDataSource.add(null);
    setPlayerState(PlayerState.connecting);
  }

  /// tap ptz
  onTapPtz() {
    if (fullscreen) setExistFullScreen();
    onTapPtzControl.add(null);
  }

  /// snapshot
  setSnapshot(String? snapshot) {
    _value = value.copyWith(
      state: WebRTCPlayerValueState.snapshot,
      snapshot: snapshot,
    );
    notifyListeners();
  }

  /// turing error
  setTuringError(WebrtcError error) {
    _value = value.copyWith(
      state: WebRTCPlayerValueState.error,
      error: error,
      playing: error.isNotNone ? false : null,
    );
    final state = error.isNotNone ? PlayerState.error : PlayerState.connecting;
    setPlayerState(state, false);
    notifyListeners();
  }

  /// play or pause
  setPlay() {
    _value = value.copyWith(
      state: WebRTCPlayerValueState.play,
      playing: true,
    );
    setPlayerState(PlayerState.connected, false);
    notifyListeners();
  }

  /// resume stream from pause
  setResume() {
    if (!_state.isPaused) return; // if not paused, return
    _value = value.copyWith(
      state: WebRTCPlayerValueState.resume,
      playing: true,
    );
    setPlayerState(PlayerState.resumed, false);
    notifyListeners();
  }

  /// pause stream
  setPause() {
    if (!_state.isConnected) return; // if not connected, return
    _value = value.copyWith(
      state: WebRTCPlayerValueState.pause,
      playing: false,
    );
    setPlayerState(PlayerState.paused, false);
    notifyListeners();
  }

  /// enter full screen
  setEnterFullScreen() {
    _value = value.copyWith(
        state: WebRTCPlayerValueState.fullScreen, fullScreen: true);
    notifyListeners();
  }

  /// exist full screen
  setExistFullScreen() {
    _value = value.copyWith(
        state: WebRTCPlayerValueState.fullScreen, fullScreen: false);
    notifyListeners();
  }

  /// switch hd
  void switchHD() {
    _value = value.copyWith(state: WebRTCPlayerValueState.hd, hd: false);
    notifyListeners();
    onSwitchHD.add(true);
  }

  void setHdOff() {
    _value = value.copyWith(state: WebRTCPlayerValueState.hd, hd: false);
    notifyListeners();
  }

  /// switch audio
  void switchAudio() {
    _value = value.copyWith(
      state: WebRTCPlayerValueState.audio,
      audio: !_value.audio,
    );
    notifyListeners();
    onSwitchAudio.add(_value.audio);
  }

  void setAudioOff() {
    _value = value.copyWith(state: WebRTCPlayerValueState.audio, audio: false);
    notifyListeners();
  }

  // showAudio() {
  //   _value = value.copyWith(
  //       state: WebRTCPlayerValueState.enableAudio, enableAudio: true);
  //   notifyListeners();
  // }
  //
  // hideAudio() {
  //   _value = value.copyWith(
  //       state: WebRTCPlayerValueState.enableAudio, enableAudio: false);
  //   notifyListeners();
  // }

  // showMic() {
  //   _value = value.copyWith(
  //       state: WebRTCPlayerValueState.enableMic, enableMic: true);
  //   notifyListeners();
  // }
  //
  // hideMic() {
  //   _value = value.copyWith(
  //       state: WebRTCPlayerValueState.enableMic, enableMic: false);
  //   notifyListeners();
  // }

  /// set camera name
  setDescription(String text) => _description = text;

  /// set stream
  setStream(String text) => _stream = text;

  /// set player speed
  setPlayerSpeed(PlayerSpeed speed) {
    _value = value.copyWith(state: WebRTCPlayerValueState.speed, speed: speed);
    notifyListeners();
  }

  /// update panel

  /// publish subject
  final PublishSubject onSelected = PublishSubject();
  final PublishSubject onTapForward = PublishSubject();
  final PublishSubject onTapRewind = PublishSubject();
  final PublishSubject onTapPtzZoomIn = PublishSubject();
  final PublishSubject onTapPtzZoomOut = PublishSubject();
  final PublishSubject onTapPtzTop = PublishSubject();
  final PublishSubject onTapPtzTopLeft = PublishSubject();
  final PublishSubject onTapPtzTopRight = PublishSubject();
  final PublishSubject onTapPtzLeft = PublishSubject();
  final PublishSubject onTapPtzRight = PublishSubject();
  final PublishSubject onTapPtzBottom = PublishSubject();
  final PublishSubject onTapPtzBottomLeft = PublishSubject();
  final PublishSubject onTapPtzBottomRight = PublishSubject();
  final PublishSubject onTapPtzStop = PublishSubject();
  final PublishSubject<int> onCurrentPosition = PublishSubject<int>();
  final PublishSubject<PlayerState> onPlayerStateUpdate =
      PublishSubject<PlayerState>();
  final PublishSubject onTapPlayerHistory = PublishSubject();
  final PublishSubject onTapPlayerReplace = PublishSubject();
  final PublishSubject onTapResetDataSource = PublishSubject();
  final PublishSubject onTapPtzControl = PublishSubject();
  final PublishSubject onMessage = PublishSubject();
  final PublishSubject<bool> onSwitchHD = PublishSubject();
  final PublishSubject<bool> onSwitchAudio = PublishSubject();
  final PublishSubject<PlayerSpeed> onPlayerSpeed = PublishSubject();
  final PublishSubject<bool> onSwitchRecord = PublishSubject();

  @override
  void dispose() {
    onSelected.close();
    onTapForward.close();
    onTapRewind.close();
    onTapPtzControl.close();
    onTapPtzZoomIn.close();
    onTapPtzZoomOut.close();
    onTapPtzTop.close();
    onTapPtzTopLeft.close();
    onTapPtzTopRight.close();
    onTapPtzBottom.close();
    onTapPtzBottomLeft.close();
    onTapPtzBottomRight.close();
    onTapPtzStop.close();
    onCurrentPosition.close();
    onPlayerStateUpdate.close();
    onTapPlayerHistory.close();
    onTapPlayerReplace.close();
    onTapResetDataSource.close();
    onMessage.close();
    onSwitchHD.close();
    onSwitchAudio.close();
    onSwitchRecord.close();
    onTapPtzLeft.close();
    onTapPtzRight.close();
    onPlayerSpeed.close();
    stopTimer();
    super.dispose();
  }
}
