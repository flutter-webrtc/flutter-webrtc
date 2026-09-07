import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'native/event_channel.dart';
import 'native/utils.dart' if (dart.library.js_interop) 'web/utils.dart';

enum RTCPictureInPictureState {
  willStart,
  started,
  willStop,
  stopped,
  failed,
  restoreUserInterface,
}

class RTCPictureInPictureEvent {
  const RTCPictureInPictureEvent(this.state, {this.error});

  final RTCPictureInPictureState state;

  /// Set when [state] is [RTCPictureInPictureState.failed].
  final String? error;
}

/// Controls native picture-in-picture for a video call.
///
/// On Android the whole Flutter view is shown in the picture-in-picture
/// window, so the app should render a reduced layout while [value] is true
/// (see [RTCPictureInPictureBuilder]). On iOS the system shows only the video
/// track passed to [configure]; the Flutter UI is not visible while active.
///
/// The value of this notifier is whether picture-in-picture is currently
/// active.
class RTCPictureInPictureController extends ValueNotifier<bool> {
  RTCPictureInPictureController() : super(false) {
    if (!kIsWeb) {
      _subscription = FlutterWebRTCEventChannel.instance.handleEvents.stream
          .listen(_onEvent);
    }
  }

  StreamSubscription<Map<String, dynamic>>? _subscription;
  final _events = StreamController<RTCPictureInPictureEvent>.broadcast();
  bool _disposed = false;

  Stream<RTCPictureInPictureEvent> get events => _events.stream;

  bool get isInPictureInPicture => value;

  static Future<bool> isSupported() async {
    if (kIsWeb) return false;
    return await WebRTC.invokeMethod<bool, dynamic>('pipIsSupported') ?? false;
  }

  /// The global rect of the widget attached to [key], in logical pixels.
  /// Useful as the `sourceRect` of [configure].
  static Rect? globalRectOf(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  /// Configures the picture-in-picture session. Can be called again to change
  /// the video track, the source rect or the aspect ratio while active.
  ///
  /// [stream] and [trackId] select the video rendered on iOS; when [stream] is
  /// omitted the current track is kept. On Android they are ignored: pass
  /// [aspectRatio] (for example `renderer.value.aspectRatio`) so the window
  /// matches the video.
  ///
  /// [sourceRect] is the on-screen rect of the video view, in logical pixels,
  /// used by the system for the enter/exit animation.
  ///
  /// [autoEnter] enters picture-in-picture when the app goes to the
  /// background. On Android 8 to 11 this requires forwarding
  /// `Activity.onUserLeaveHint` to `FlutterWebRTCPlugin.onUserLeaveHint()`.
  ///
  /// [platformViewId] (iOS only) is the `textureId` of an
  /// `RTCVideoPlatformViewController`, used as the animation source instead of
  /// [sourceRect].
  Future<void> configure({
    MediaStream? stream,
    String? trackId,
    Rect? sourceRect,
    double? aspectRatio,
    bool autoEnter = true,
    bool seamlessResize = true,
    RTCVideoViewObjectFit objectFit =
        RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    int? platformViewId,
  }) async {
    _checkDisposed();
    final devicePixelRatio =
        ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0;
    await WebRTC.invokeMethod('pipConfigure', <String, dynamic>{
      'streamId': stream?.id ?? '',
      'ownerTag': stream?.ownerTag ?? '',
      'trackId': trackId ?? '0',
      if (sourceRect != null)
        'sourceRect': <String, double>{
          'left': sourceRect.left,
          'top': sourceRect.top,
          'right': sourceRect.right,
          'bottom': sourceRect.bottom,
        },
      'devicePixelRatio': devicePixelRatio,
      if (aspectRatio != null && aspectRatio > 0) 'aspectRatio': aspectRatio,
      'autoEnter': autoEnter,
      'seamlessResize': seamlessResize,
      'objectFit':
          objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitCover
              ? 'cover'
              : 'contain',
      if (platformViewId != null) 'platformViewId': platformViewId,
    });
  }

  /// Enters picture-in-picture now. Returns false when the request was
  /// refused, for example because the activity is not visible or the app
  /// does not declare `android:supportsPictureInPicture`.
  Future<bool> start() async {
    _checkDisposed();
    return await WebRTC.invokeMethod<bool, dynamic>('pipStart') ?? false;
  }

  /// Leaves picture-in-picture. Android has no API for this; the window is
  /// closed by the user or by bringing the activity to the front.
  Future<void> stop() async {
    _checkDisposed();
    await WebRTC.invokeMethod('pipStop');
  }

  Future<bool> isActive() async {
    _checkDisposed();
    return await WebRTC.invokeMethod<bool, dynamic>('pipIsActive') ?? false;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _subscription?.cancel();
    _subscription = null;
    await _events.close();
    if (!kIsWeb) {
      await WebRTC.invokeMethod('pipDispose');
    }
    super.dispose();
  }

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('RTCPictureInPictureController is disposed');
    }
  }

  void _onEvent(Map<String, dynamic> event) {
    final map = event['pictureInPictureStateChanged'];
    if (map is! Map || _disposed) return;
    final state = _stateFromString(map['state'] as String?);
    if (state == null) return;
    switch (state) {
      case RTCPictureInPictureState.started:
        value = true;
        break;
      case RTCPictureInPictureState.stopped:
      case RTCPictureInPictureState.failed:
        value = false;
        break;
      default:
        break;
    }
    _events.add(RTCPictureInPictureEvent(state, error: map['error'] as String?));
  }

  static RTCPictureInPictureState? _stateFromString(String? state) {
    switch (state) {
      case 'willStart':
        return RTCPictureInPictureState.willStart;
      case 'started':
        return RTCPictureInPictureState.started;
      case 'willStop':
        return RTCPictureInPictureState.willStop;
      case 'stopped':
        return RTCPictureInPictureState.stopped;
      case 'failed':
        return RTCPictureInPictureState.failed;
      case 'restoreUserInterface':
        return RTCPictureInPictureState.restoreUserInterface;
    }
    return null;
  }
}

/// Rebuilds when the picture-in-picture state of [controller] changes.
class RTCPictureInPictureBuilder extends StatelessWidget {
  const RTCPictureInPictureBuilder({
    super.key,
    required this.controller,
    required this.builder,
    this.child,
  });

  final RTCPictureInPictureController controller;
  final Widget Function(
      BuildContext context, bool isInPictureInPicture, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller,
      builder: builder,
      child: child,
    );
  }
}
