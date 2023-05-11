import 'package:medea_flutter_webrtc/src/model/constraints.dart';
import '/src/model/track.dart';

/// Representation of the `onEnded` callback.
typedef OnEndedCallback = void Function();

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

  /// Subscribes provided callback to the `onEnded` events of this [MediaStreamTrack].
  void onEnded(OnEndedCallback cb);

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
}
