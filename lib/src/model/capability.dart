import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';
import '/src/api/bridge/api.dart' as ffi;

/// Representation of the static capabilities of an endpoint.
///
/// Applications can use these capabilities to construct [RtpParameters].
class RtpCapabilities {
  RtpCapabilities(this.codecs, this.headerExtensions);

  static RtpCapabilities fromFFI(ffi.RtpCapabilities capabilities) {
    return RtpCapabilities(
      capabilities.codecs.map((v) => RtpCodecCapability.fromFFI(v)).toList(),
      capabilities.headerExtensions
          .map((v) => RtpHeaderExtensionCapability.fromFFI(v))
          .toList(),
    );
  }

  static RtpCapabilities fromMap(dynamic map) {
    var codecs =
        (map['codecs'] as List<Object?>)
            .where((element) => element != null)
            .map((c) => RtpCodecCapability.fromMap(c))
            .toList();

    var headerExtensions =
        (map['headerExtensions'] as List<Object?>)
            .where((element) => element != null)
            .map((h) => RtpHeaderExtensionCapability.fromMap(h))
            .toList();
    return RtpCapabilities(codecs, headerExtensions);
  }

  /// Supported codecs.
  List<RtpCodecCapability> codecs;

  /// Supported [RTP] header extensions.
  ///
  /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
  List<RtpHeaderExtensionCapability> headerExtensions;
}

/// Representation of capabilities/preferences of an implementation for a header
/// extension of [RtpCapabilities].
class RtpHeaderExtensionCapability {
  RtpHeaderExtensionCapability(this.uri, this.direction);

  static RtpHeaderExtensionCapability fromFFI(
    ffi.RtpHeaderExtensionCapability headerExtension,
  ) {
    return RtpHeaderExtensionCapability(
      headerExtension.uri,
      TransceiverDirection.values[headerExtension.direction.index],
    );
  }

  static RtpHeaderExtensionCapability fromMap(dynamic map) {
    var direction =
        map['direction'] == null
            ? TransceiverDirection.sendRecv
            : TransceiverDirection.values[map['direction']];
    return RtpHeaderExtensionCapability(map['uri'], direction);
  }

  /// [URI] of this extension, as defined in [RFC 8285].
  ///
  /// [RFC 8285]: https://tools.ietf.org/html/rfc8285
  /// [URI]: https://en.wikipedia.org/wiki/Uniform_Resource_Identifier
  String uri;

  /// Direction of the extension.
  TransceiverDirection direction;
}

/// Representation of static capabilities of an endpoint's implementation of a
/// codec.
class RtpCodecCapability {
  RtpCodecCapability(
    this.mimeType,
    this.clockRate,
    this.parameters,
    this.kind,
    this.name,
    this.numChannels,
    this.preferredPayloadType,
  );

  static RtpCodecCapability fromFFI(ffi.RtpCodecCapability capability) {
    Map<String, String> parameters = {};
    for (var element in capability.parameters) {
      parameters.addAll({element.$1: element.$2});
    }

    return RtpCodecCapability(
      capability.mimeType,
      capability.clockRate,
      parameters,
      MediaKind.values[capability.kind.index],
      capability.name,
      capability.numChannels,
      capability.preferredPayloadType,
    );
  }

  static RtpCodecCapability fromMap(dynamic map) {
    Map<String, String> parameters = {};
    for (var e in (map['parameters'] as Map<Object?, Object?>).entries) {
      if (e.key != null) {
        parameters.addAll({e.key! as String: (e.value as String?) ?? ''});
      }
    }
    return RtpCodecCapability(
      map['mimeType'],
      map['clockRate'],
      parameters,
      MediaKind.values[map['kind']],
      map['name'],
      map['numChannels'],
      map['preferredPayloadType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mimeType': mimeType,
      'clockRate': clockRate ?? 0,
      'parameters': parameters,
      'preferredPayloadType': preferredPayloadType ?? 0,
      'name': name,
      'kind': kind.index,
      'numChannels': numChannels,
    };
  }

  /// Built [MIME "type/subtype"] string from [name] and [kind].
  ///
  /// [MIME "type/subtype"]: https://en.wikipedia.org/wiki/Media_type
  String mimeType;

  /// If unset, the implementation default is used.
  int? clockRate;

  /// Default payload type for the codec.
  ///
  /// Mainly needed for codecs that have statically assigned payload types.
  int? preferredPayloadType;

  /// Used to identify the codec. Equivalent to [MIME subtype][0].
  ///
  /// [0]: https://en.wikipedia.org/wiki/Media_type#Subtypes
  String name;

  /// [MediaKind] of this codec. Equivalent to [MIME] top-level type.
  ///
  /// [MIME]: https://en.wikipedia.org/wiki/Media_type
  MediaKind kind;

  /// Number of audio channels used.
  ///
  /// Unset for video codecs.
  ///
  /// If unset for audio, the implementation default is used.
  int? numChannels;

  /// Codec-specific parameters that must be signaled to the remote party.
  ///
  /// Corresponds to `a=fmtp` parameters in [SDP].
  ///
  /// Contrary to ORTC, these parameters are named using all lowercase strings.
  /// This helps make the mapping to [SDP] simpler, if an application is using
  /// [SDP]. Boolean values are represented by the string "1".
  ///
  /// [SDP]: https://en.wikipedia.org/wiki/Session_Description_Protocol
  Map<String, String> parameters;
}
