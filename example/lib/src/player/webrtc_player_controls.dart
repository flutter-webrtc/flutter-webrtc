import 'dart:async';
import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:flutter_webrtc_example/src/player/player_panel/player_state.dart';

import '../utils/hit_test_blocker.dart';
import '../utils/orientation_helper.dart';
import '../utils/screen_helper.dart';
import 'webrtc_error.dart';
import 'webrtc_player.dart';
import 'webrtc_player_controller.dart';
import 'webrtc_player_publisher.dart';
import 'webrtc_player_state.dart';
import 'webrtc_player_value.dart';

typedef WebRTCPlayerPanelBuilder = Widget Function(
  BuildContext context,
  Rect texturePos,
);

class WebRTCPlayerControls extends StatefulWidget {
  final WebRTCPlayerController controller;
  final WebRTCPlayerPanelBuilder? panelBuilder;
  final WebrtcCodeType code;

  const WebRTCPlayerControls({
    Key? key,
    required this.controller,
    this.panelBuilder,
    this.code = WebrtcCodeType.h264,
  }) : super(key: key);

  @override
  _WebRTCPlayerControlsState createState() => _WebRTCPlayerControlsState();
}

class _WebRTCPlayerControlsState extends State<WebRTCPlayerControls>
    with AfterLayoutMixin {
  final webrtc.RTCVideoRenderer _video = webrtc.RTCVideoRenderer();
  final WebRTCPlayer _player = WebRTCPlayer();
  final WebRTCPublisher _publisher = WebRTCPublisher();
  late WebrtcCodeType code;

  StateSetter? fullStateSetter;

  bool hasBeenInitialized = false;

  @override
  void initState() {
    super.initState();
    print("============== webrtc controls init state, id = $hashCode");
    code = widget.code;
  }

  @override
  void didUpdateWidget(covariant WebRTCPlayerControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (code != widget.code) code = widget.code;
    print('code = ${code.name}');
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    _player.initState();
    _publisher.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _player.dispose();
    _publisher.dispose();
    _video.dispose();
    print("============== webrtc controls dispose, id = $hashCode");
    super.dispose();
  }

  void _onControllerChanged() async {
    final value = widget.controller.value;
    final state = widget.controller.state;
    // info(" player controls value = $value, state = $state, id = $hashCode");
    switch (value.state) {
      case WebRTCPlayerValueState.url:
        final url = value.url;
        if (url.isValidUri) {
          ensureInitialize().then((_) => autoPlay(url));
        } else {
          _player.dispose();
          _publisher.dispose();
          if (value.record) widget.controller.setRecordOff();
          if (value.audio) widget.controller.setAudioOff();
          if (value.hd) widget.controller.setHdOff();
        }
        break;
      case WebRTCPlayerValueState.recordUrl:
        final url = value.recordUrl;
        if (url.isValidUri) twoWayAudio(url);
        break;

      case WebRTCPlayerValueState.audio:
        if (widget.controller.stream != null) {
          _video.srcObject?.getAudioTracks()[0].enabled = value.audio;
        }
        break;
      case WebRTCPlayerValueState.play:
      case WebRTCPlayerValueState.resume:
        break;
      case WebRTCPlayerValueState.pause:
        _player.dispose();
        _publisher.dispose();
        if (value.record) widget.controller.setRecordOff();
        if (value.audio) widget.controller.setAudioOff();
        if (value.hd) widget.controller.setHdOff();
        break;
      case WebRTCPlayerValueState.fullScreen:
        value.fullScreen
            ? _pushFullScreenWidget(context)
            : Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        color: Colors.black,
        child: _build(context,
            Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight)),
      );
    });
  }

  Widget _build(BuildContext context, Rect texturePos) {
    List ws = <Widget>[
      InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: webrtc.RTCVideoView(_video),
      ),
    ];

    if (widget.panelBuilder != null) {
      final panel = widget.panelBuilder!(context, texturePos);
      ws.add(HitTestBlocker(child: panel));
    }

    return Stack(children: ws as List<Widget>);
  }

  Future<bool> ensureInitialize() async {
    if (hasBeenInitialized) return hasBeenInitialized;

    await _video.initialize();

    hasBeenInitialized = true;
    return hasBeenInitialized;
  }

  void autoPlay(String url) async {
    _video.onDidFirstRendered = () {
      // debug("=============== on did render video, id = $hashCode");
      widget.controller.setPlay();
    };

    _video.onResize = () {
      // info("========= video width = ${_video.videoWidth}");
      // info("========= video height = ${_video.videoHeight}");
    };

    // Render stream when got remote stream.
    _player.onRemoteStream = (webrtc.MediaStream stream) {
      stream.getAudioTracks()[0].enabled = false;
      // @remark It's very important to use setState to set the srcObject and notify render.
      // info('============= stream = ${stream.id}, hashcode = $hashCode');
      widget.controller.setStream(stream.id);
      // info('${stream.getVideoTracks().map((e) => e.id)}');
      setState(() {
        _video.srcObject = stream;
      });
      fullStateSetter?.call(() {
        _video.srcObject = stream;
      });
    };

    _player.onConnectionState = (webrtc.RTCPeerConnectionState s) {
      final newState = s.playerState;
      widget.controller.setTuringError(
          newState.isError ? webRTCConnectionError : WebrtcError.none);
      widget.controller.setPlayerState(newState);
    };

    // Auto start play WebRTC streaming.
    // info("============= webrtc player url = $url, hashcode = $hashCode");
    final uri = '$url?codec=${widget.code.name}';
    await _player.play(uri);
  }

  void twoWayAudio(String audioUrl) async {
    try {
      final stream = await webrtc.navigator.mediaDevices.getUserMedia({
        'video': false,
        'audio': true,
      });
      await _publisher.publish(audioUrl, stream);
    } catch (e) {
      print(e.toString());
    }
  }

  /// full screen
  AnimatedWidget _defaultRoutePageBuilder(
    BuildContext context,
    Animation<double> animation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: WillPopScope(onWillPop: () async {
            widget.controller.setExistFullScreen();
            return true;
          }, child: StatefulBuilder(
            builder: (context, setState) {
              fullStateSetter = setState;
              return LayoutBuilder(builder: (context, constraints) {
                final maxHeight =
                    min(constraints.maxHeight, ScreenHelper.heightOfLogical);
                final newConstraints =
                    BoxConstraints.loose(Size(constraints.maxWidth, maxHeight));
                final Size childSize = getTxSize(newConstraints);
                final Offset offset = getTxOffset(newConstraints, childSize);
                final Rect pos = Rect.fromLTWH(
                    offset.dx, offset.dy, childSize.width, childSize.height);
                return _build(context, pos);
              });
            },
          )),
        );
      },
    );
  }

  Widget _fullScreenRoutePageBuilder(BuildContext context,
      Animation<double> animation, Animation<double> secondaryAnimation) {
    return _defaultRoutePageBuilder(context, animation);
  }

  Future<dynamic> _pushFullScreenWidget(BuildContext context) async {
    final TransitionRoute<void> route = PageRouteBuilder<void>(
      settings: const RouteSettings(),
      pageBuilder: _fullScreenRoutePageBuilder,
    );

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []);
    await OrientationHelper.setPreferredOrientations(
        [DeviceOrientation.landscapeRight]);

    var orientation = MediaQuery.of(context).orientation;
    print("start enter fullscreen. orientation:$orientation");
    OrientationHelper.forceOrientation(DeviceOrientation.landscapeRight);
    print("screen orientation changed");

    await Navigator.of(context).push(route);
    print("=============== exist full screen");
    fullStateSetter = null;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    await OrientationHelper.setPreferredOrientations(
        [DeviceOrientation.portraitUp]);
    OrientationHelper.forceOrientation(DeviceOrientation.portraitUp);
  }

  /// calculate size

  Size getTxSize(BoxConstraints constraints) {
    Size childSize = applyAspectRatio(constraints, getAspectRatio(constraints));
    double sizeFactor = 1.0;
    if (-1.0 < sizeFactor && sizeFactor < -0.0) {
      sizeFactor = max(constraints.maxWidth / childSize.width,
          constraints.maxHeight / childSize.height);
    } else if (-2.0 < sizeFactor && sizeFactor < -1.0) {
      sizeFactor = constraints.maxWidth / childSize.width;
    } else if (-3.0 < sizeFactor && sizeFactor < -2.0) {
      sizeFactor = constraints.maxHeight / childSize.height;
    } else if (sizeFactor < 0) {
      sizeFactor = 1.0;
    }
    childSize = childSize * sizeFactor;
    return childSize;
  }

  Size applyAspectRatio(BoxConstraints constraints, double aspectRatio) {
    assert(constraints.hasBoundedHeight && constraints.hasBoundedWidth);
    constraints = constraints.loosen();

    double width = constraints.maxWidth;
    double height = width;

    if (width.isFinite) {
      height = width / aspectRatio;
    } else {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    if (width > constraints.maxWidth) {
      width = constraints.maxWidth;
      height = width / aspectRatio;
    }

    if (height > constraints.maxHeight) {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    if (width < constraints.minWidth) {
      width = constraints.minWidth;
      height = width / aspectRatio;
    }

    if (height < constraints.minHeight) {
      height = constraints.minHeight;
      width = height * aspectRatio;
    }

    return constraints.constrain(Size(width, height));
  }

  Offset getTxOffset(BoxConstraints constraints, Size childSize) {
    final Offset diff = (constraints.biggest - childSize) as Offset;
    return Alignment.center.alongOffset(diff);
  }

  double getAspectRatio(BoxConstraints constraints) {
    return _video.videoWidth / _video.videoHeight;
  }
}
