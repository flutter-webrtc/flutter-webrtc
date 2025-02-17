import '/src/api/peer.dart';
import 'bridge/api.dart' as ffi;
import 'bridge/lib.dart';

/// Encoding describing a single configuration of a codec for an [RTCRtpSender].
///
/// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
abstract class SendEncodingParameters {
  /// Creates new [SendEncodingParameters].
  static SendEncodingParameters create(
    String rid,
    bool active, {
    int? maxBitrate,
    double? maxFramerate,
    String? scalabilityMode,
    double? scaleResolutionDownBy,
  }) {
    if (isDesktop) {
      return _SendEncodingParametersFFI(
        rid,
        active,
        maxBitrate: maxBitrate,
        scalabilityMode: scalabilityMode,
        maxFramerate: maxFramerate,
        scaleResolutionDownBy: scaleResolutionDownBy,
      );
    } else {
      return _SendEncodingParametersChannel(
        rid,
        active,
        maxBitrate: maxBitrate,
        scalabilityMode: scalabilityMode,
        maxFramerate: maxFramerate,
        scaleResolutionDownBy: scaleResolutionDownBy,
      );
    }
  }

  /// Create new [SendEncodingParameters] from the provided
  /// [ffi.RtcRtpEncodingParameters].
  static SendEncodingParameters fromFFI(
    ffi.RtcRtpEncodingParameters e,
    ArcRtpEncodingParameters sysEncoding,
  ) {
    return _SendEncodingParametersFFI(
      e.rid,
      e.active,
      maxBitrate: e.maxBitrate,
      maxFramerate: e.maxFramerate,
      scalabilityMode: e.scalabilityMode,
      scaleResolutionDownBy: e.scaleResolutionDownBy,
      encoding: sysEncoding,
    );
  }

  /// Creates [SendEncodingParameters] basing on the [Map] received from the
  /// native side.
  static SendEncodingParameters fromMap(dynamic e) {
    return _SendEncodingParametersChannel(
      e['rid'],
      e['active'],
      maxBitrate: e['maxBitrate'],
      maxFramerate: (e['maxFramerate'] as int?)?.toDouble(),
      scaleResolutionDownBy: e['scaleResolutionDownBy'],
      scalabilityMode: e['scalabilityMode'],
    );
  }

  /// [RTP stream ID (RID)][0] to be sent using the RID header extension.
  ///
  /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodingparameters-rid
  late String rid;

  /// Indicator whether the described encoding is currently actively being used.
  late bool active;

  /// Maximum number of bits per second to allow for this encoding.
  int? maxBitrate;

  /// Maximum number of frames per second to allow for this encoding.
  double? maxFramerate;

  /// Factor for scaling down the video during encoding.
  double? scaleResolutionDownBy;

  /// Scalability mode describing layers within the media stream.
  String? scalabilityMode;

  /// Converts these [SendEncodingParameters] into the [Map] expected by
  /// Flutter.
  Map<String, dynamic> toMap();

  /// Tries to convert these [SendEncodingParameters] into
  /// [ffi.ArcRtpEncodingParameters].
  (ffi.RtcRtpEncodingParameters, ArcRtpEncodingParameters?) toFFI();
}

/// [MethodChannel]-based implementation of [SendEncodingParameters].
class _SendEncodingParametersChannel extends SendEncodingParameters {
  _SendEncodingParametersChannel(
    String rid,
    bool active, {
    int? maxBitrate,
    double? maxFramerate,
    double? scaleResolutionDownBy,
    String? scalabilityMode,
  }) {
    this.rid = rid;
    this.active = active;
    this.maxBitrate = maxBitrate;
    this.maxFramerate = maxFramerate;
    this.scaleResolutionDownBy = scaleResolutionDownBy;
    this.scalabilityMode = scalabilityMode;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'rid': rid,
      'active': active,
      'maxBitrate': maxBitrate,
      'maxFramerate': maxFramerate?.toInt(),
      'scaleResolutionDownBy': scaleResolutionDownBy,
      'scalabilityMode': scalabilityMode,
    };
  }

  @override
  (ffi.RtcRtpEncodingParameters, ArcRtpEncodingParameters?) toFFI() {
    throw UnimplementedError();
  }
}

/// FFI-based implementation of [SendEncodingParameters].
class _SendEncodingParametersFFI extends SendEncodingParameters {
  _SendEncodingParametersFFI(
    String rid,
    bool active, {
    int? maxBitrate,
    double? maxFramerate,
    double? scaleResolutionDownBy,
    String? scalabilityMode,
    ArcRtpEncodingParameters? encoding,
  }) {
    this.rid = rid;
    this.active = active;
    this.maxBitrate = maxBitrate;
    this.maxFramerate = maxFramerate;
    this.scaleResolutionDownBy = scaleResolutionDownBy;
    this.scalabilityMode = scalabilityMode;
    _encoding = encoding;
  }

  /// Underlying [ffi.ArcRtpEncodingParameters].
  ArcRtpEncodingParameters? _encoding;

  @override
  (ffi.RtcRtpEncodingParameters, ArcRtpEncodingParameters?) toFFI() {
    return (
      ffi.RtcRtpEncodingParameters(
        rid: rid,
        active: active,
        maxBitrate: maxBitrate,
        maxFramerate: maxFramerate,
        scaleResolutionDownBy: scaleResolutionDownBy,
        scalabilityMode: scalabilityMode,
      ),
      _encoding,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}
