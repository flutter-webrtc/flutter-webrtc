import 'dart:async';

import 'package:flutter/material.dart';

import '../webrtc_player_controller.dart';
import '../webrtc_player_value.dart';
import 'player_connecting_view.dart';
import 'player_live_badge.dart';
import 'player_settings.dart';
import 'player_state.dart';
import 'player_view_widget.dart';

class WebrtcPlayerPanel extends StatefulWidget {
  final PlayerSettings settings;
  final PlayerSettings? fullscreenSettings;

  final WebRTCPlayerController controller;
  final Rect texturePos;

  final PlayerViewWidgetBuilder builder;
  final PlayerViewWidgetBuilder? fullscreenBuilder;

  const WebrtcPlayerPanel({
    super.key,
    required this.controller,
    required this.texturePos,
    required this.settings,
    this.fullscreenSettings,
    required this.builder,
    this.fullscreenBuilder,
  });

  @override
  _WebrtcPlayerPanelState createState() => _WebrtcPlayerPanelState();
}

class _WebrtcPlayerPanelState extends State<WebrtcPlayerPanel> {
  PlayerState _state = PlayerState.connecting;
  String? _exception;
  bool _playing = true;

  Timer? timer;
  bool _hidden = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    print("====== WebrtcPlayerPanel dispose");
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _state = widget.controller.state;
      _hidden = widget.controller.state.isConnected;
      _playing = widget.controller.isPlaying;
    });
  }

  /// listener
  void _onControllerChanged() async {
    final value = widget.controller.value;
    final state = widget.controller.state;
    switch (value.state) {
      case WebRTCPlayerValueState.pause:
      case WebRTCPlayerValueState.play:
      case WebRTCPlayerValueState.resume:
        setState(() {
          _hidden = false;
          _playing = value.playing;
          _state = state;
        });
        break;
      case WebRTCPlayerValueState.error:
        if (value.error.isNotNone) {
          setState(() {
            _hidden = false;
            _exception = value.error.em;
            _playing = value.playing;
            _state = state;
          });
        } else {
          setState(() {
            _exception = null;
            _hidden = false;
            _playing = value.playing;
            _state = state;
          });
        }
        break;
      case WebRTCPlayerValueState.fullScreen:
      case WebRTCPlayerValueState.audio:
      case WebRTCPlayerValueState.record:
      case WebRTCPlayerValueState.hd:
        setState(() {
          _hidden = false;
          _state = state;
        });
        break;
      default:
        setState(() {
          _state = state;
        });
        break;
    }
    startTimer();
  }

  /// auto hidden panel logic
  void revertPanel() {
    if (_hidden) startTimer();
    setState(() {
      _hidden = !_hidden;
    });
  }

  void startTimer() {
    final settings = widget.controller.fullscreen
        ? widget.fullscreenSettings ?? widget.settings
        : widget.settings;
    if (settings.canAutoHidden == false) {
      setState(() {
        _hidden = false;
      });
      return;
    }

    timer?.cancel();
    timer = Timer(
      Duration(seconds: settings.autoHiddenInterval),
      () {
        if (_state.isConnected && mounted) {
          setState(() {
            _hidden = true;
          });
        } else {
          startTimer();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.controller.fullscreen
        ? widget.fullscreenSettings ?? widget.settings
        : widget.settings;
    final builder = widget.controller.fullscreen
        ? widget.fullscreenBuilder ?? widget.builder
        : widget.builder;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          /// snapshot
          // Visibility(
          //   visible: !_state.isConnected,
          //   child: Expanded(
          //     child: Container(color: Colors.black),
          //   ),
          // ),

          /// live badge
          Visibility(
            visible: _state.isConnected && widget.settings.liveBadge,
            child: Positioned(
              top: 12,
              right: widget.texturePos.left + 12,
              child: const PlayerLiveBadge(),
            ),
          ),

          GestureDetector(
            onTap: () {
              widget.controller.onSelected.add(null);
              settings.canAutoHidden ? revertPanel() : () {};
            },
            onDoubleTap: settings.canDoubleTap && _state.isConnected
                ? _toggleFullScreen
                : () {},
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              child: _state.isConnecting
                  // connecting
                  ? const PlayerConnectingView()
                  // non-connecting
                  : Visibility(
                      visible: settings.canAutoHidden ? !_hidden : true,
                      child: builder.call(context)
                        ..settings = settings
                        ..onTapPlay = _togglePlayOrPause
                        ..playing = _playing
                        ..onTapFullScreen = _toggleFullScreen
                        ..fullscreen = widget.controller.fullscreen
                        ..onTapHd = _toggleSwitchHD
                        ..hd = false
                        ..onTapRecord = _toggleSwitchRecord
                        ..record = widget.controller.record
                        ..onTapAudio = _toggleSwitchAudio
                        ..audio = widget.controller.audio
                        ..onTapPtz = _togglePtz
                        ..description = widget.controller.description
                        ..state = _state
                        ..live = widget.controller.value.live,
                    ),
            ),
          ),

          /// back button
          Visibility(
            visible: widget.controller.fullscreen
                ? settings.canAutoHidden
                    ? !_hidden
                    : true
                : false,
            child: Positioned(
              child: Container(
                height: 44,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.black12],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.only(left: 10),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _toggleFullScreen,
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        Text("Cameras",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// error
          if (_exception != null)
            Positioned(
              child: Container(
                color: Colors.red,
                height: 30,
                child: Center(
                  child: Text(_state.label,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            )
        ],
      ),
    );
  }

  /// toggle action
  void _togglePlayOrPause() => _playing
      ? widget.controller.setPause()
      : widget.controller.resetDataSource();

  void _toggleFullScreen() => widget.controller.fullscreen
      ? widget.controller.setExistFullScreen()
      : widget.controller.setEnterFullScreen();

  void _toggleSwitchHD() => widget.controller.switchHD();

  void _togglePtz() => widget.controller.onTapPtz();

  void _toggleSwitchAudio() => widget.controller.switchAudio();

  void _toggleSwitchRecord() {}
  // void _toggleSwitchRecord() => widget.controller.record
  //     ? widget.controller.setRecordOff()
  //     : PermissionHelper().requestMicrophonePermission().then((granted) =>
  //         granted
  //             ? widget.controller.setRecordOn()
  //             : showDataDialog(context, microphonePermissionDeniedDialog));
}
