import 'package:flutter/services.dart';

import 'bridge/api/rtc_rtp_send_parameters.dart' as ffi;
import 'bridge/lib.dart' as ffi_ty;
import 'send_encoding_parameters.dart';

/// [RTCRtpParameters][0] implementation.
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtpparameters
abstract class RtpParameters {
  /// Creates new [RtpParameters] from the provided [ffi.RtcRtpSendParameters].
  static fromFFI(ffi.RtcRtpSendParameters params) {
    return _RtpParametersFFI(params);
  }

  /// Creates new [RtpParameters] from the provided [MethodChannel].
  static fromMap(dynamic map) {
    return _RtpParametersChannel.fromMap(map);
  }

  /// [SendEncodingParameters] which has been set.
  late List<SendEncodingParameters> encodings;

  /// Tries to convert these [RtpParameters] into [ffi.ArcRtpParameters].
  ffi.RtcRtpSendParameters toFFI();

  /// Converts these [RtpParameters] into the [Map] expected by Flutter.
  Map<String, dynamic> toMap();
}

/// [MethodChannel]-based implementation of [RtpParameters].
class _RtpParametersChannel extends RtpParameters {
  _RtpParametersChannel.fromMap(dynamic map) {
    encodings = List.unmodifiable(
      map!['encodings'].map((e) => SendEncodingParameters.fromMap(e)).toList(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'encodings': encodings.map((e) => e.toMap()).toList()};
  }

  @override
  ffi.RtcRtpSendParameters toFFI() {
    throw UnimplementedError();
  }
}

/// FFI-based implementation of [RtpParameters].
class _RtpParametersFFI extends RtpParameters {
  _RtpParametersFFI(ffi.RtcRtpSendParameters params) {
    _inner = params.inner;
    encodings = List.unmodifiable(
      params.encodings
          .map((e) => SendEncodingParameters.fromFFI(e.$1, e.$2))
          .toList(),
    );
  }

  /// Reference to the Rust side [RtpParameters].
  late ffi_ty.ArcRtpParameters _inner;

  @override
  ffi.RtcRtpSendParameters toFFI() {
    return ffi.RtcRtpSendParameters(
      encodings: encodings.map((e) {
        var r = e.toFFI();
        return (r.$1, r.$2!);
      }).toList(),
      inner: _inner,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}
