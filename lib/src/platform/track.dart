import 'dart:async';

import 'package:medea_flutter_webrtc/src/model/constraints.dart';
import '/src/model/track.dart';

/// Representation of the `onEnded` callback.
typedef OnEndedCallback = void Function();

/// Representation of an `onAudioLevelChanged` callback.
///
/// The provided values will be in [0; 100] range.
typedef OnAudioLevelChangedCallback = void Function(int);

/// Abstract representation of a single media unit on native or web side.
abstract class MediaStreamTrack {
  /// Returns unique identifier of this [MediaStreamTrack].
  String id();

  /// Returns the [MediaKind] of this [MediaStreamTrack].
  MediaKind kind();

  /// Returns unique ID of the device from which this [MediaStreamTrack] was
  /// created.
  String deviceId();

  /// Returns enabled state of the [MediaStreamTrack].
  ///
  /// If it's `false` then blank (black screen for video and `0dB` for audio)
  /// media will be transmitted.
  bool isEnabled();

  /// Returns [MediaStreamTrackState] of the [MediaStreamTrack].
  Future<MediaStreamTrackState> state();

  /// Sets enabled state of the [MediaStreamTrack].
  ///
  /// If `false` is provided then blank (black screen for video and `0dB` for
  /// audio) media will be transmitted.
  Future<void> setEnabled(bool enabled);

  /// Stops this [MediaStreamTrack].
  ///
  /// After this action [MediaStreamTrack] will stop transmitting its media data
  /// to the remote and local renderers.
  ///
  /// This action will unheld the device in case of the last local
  /// [MediaStreamTrack]s of some device.
  Future<void> stop();

  /// Sets the provided [OnEndedCallback] for this [MediaStreamTrack].
  ///
  /// It's called when a playback or streaming has stopped because the end of
  /// the media was reached or because no further data is available.
  ///
  /// This is a terminate state.
  void onEnded(OnEndedCallback cb);

  /// Indicates whether [MediaStreamTrack.onAudioLevelChanged] callback is
  /// supported for this [MediaStreamTrack].
  ///
  /// Currently, it's only supported for local audio tracks on desktop
  /// platforms.
  bool isOnAudioLevelAvailable() {
    // TODO: Might be implemented on web using audio level in media-source
    //       `rtc=stats` or audio node and `AnalyserNode`:
    //       https://webrtc.github.io/samples/src/content/getusermedia/volume
    return false;
  }

  /// Sets the provided [OnEndedCallback] for this [MediaStreamTrack].
  ///
  /// It's called for live tracks when audio level of this track changes.
  ///
  /// [MediaStreamTrack.isOnAudioLevelAvailable] should be called to ensure
  /// [MediaStreamTrack.onAudioLevelChanged] is supported on the current
  /// platform.
  void onAudioLevelChanged(OnAudioLevelChangedCallback? cb) {
    throw 'onAudioLevelChanged callback is only support for local audio tracks '
        'on desktop platforms. isOnAudioLevelAvailable() should be called '
        'before trying to set onAudioLevelChanged callback';
  }

  /// Indicates whether the following function are supported for this
  /// [MediaStreamTrack]:
  /// - [MediaStreamTrack.setNoiseSuppressionEnabled]
  /// - [MediaStreamTrack.setNoiseSuppressionLevel]
  /// - [MediaStreamTrack.setHighPassFilterEnabled]
  /// - [MediaStreamTrack.setEchoCancellationEnabled]
  /// - [MediaStreamTrack.setAutoGainControlEnabled]
  ///
  /// Only supported for local audio [MediaStreamTrack]s on desktop platforms.
  bool isAudioProcessingAvailable() {
    return false;
  }

  Future<void> setNoiseSuppressionEnabled(bool enabled) {
    throw 'setNoiseSuppressionEnabled is only support for local audio tracks '
        'on desktop platforms. isAudioProcessingAvailable() should be called '
        'before trying to call setNoiseSuppressionEnabled';
  }

  Future<void> setNoiseSuppressionLevel(NoiseSuppressionLevel level) {
    throw 'setNoiseSuppressionEnabled is only support for local audio tracks '
        'on desktop platforms. isAudioProcessingAvailable() should be called '
        'before trying to call setNoiseSuppressionEnabled';
  }

  Future<void> setHighPassFilterEnabled(bool enabled) {
    throw 'setHighPassFilterEnabled is only support for local audio tracks '
        'on desktop platforms. isAudioProcessingAvailable() should be called '
        'before trying to call setHighPassFilterEnabled';
  }

  Future<void> setEchoCancellationEnabled(bool enabled) {
    throw 'setEchoCancellationEnabled is only support for local audio tracks '
        'on desktop platforms. isAudioProcessingAvailable() should be called '
        'before trying to call setEchoCancellationEnabled';
  }

  Future<void> setAutoGainControlEnabled(bool enabled) {
    throw 'setAutoGainControlEnabled is only support for local audio tracks '
        'on desktop platforms. isAudioProcessingAvailable() should be called '
        'before trying to call setAutoGainControlEnabled';
  }

  /// Creates a new instance of [MediaStreamTrack], which will depend on the same
  /// media source as this [MediaStreamTrack].
  ///
  /// If the parent or child [MediaStreamTrack] will be stopped then another
  /// [MediaStreamTrack] will continue to work normally, but when all the
  /// [MediaStreamTrack] dependent on the same device are stopped, then the
  /// media device will be unheld.
  Future<MediaStreamTrack> clone();

  /// Disposes this [MediaStreamTrack] instance.
  Future<void> dispose();

  /// Returns [FacingMode] of this [MediaStreamTrack].
  FacingMode? facingMode();

  /// Returns [width] of this [MediaStreamTrack].
  ///
  /// [width]: https://w3.org/TR/mediacapture-streams#dfn-width
  FutureOr<int?> width();

  /// Returns [height] of this [MediaStreamTrack].
  ///
  /// [height]: https://w3.org/TR/mediacapture-streams#dfn-height
  FutureOr<int?> height();
}
