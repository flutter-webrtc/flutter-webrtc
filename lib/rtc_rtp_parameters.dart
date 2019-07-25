import 'rtc_rtcp_parameters.dart';

class RTCRTPCodec {
  // Payload type used to identify this codec in RTP packets.
  int payloadType;

  /// Name used to identify the codec. Equivalent to MIME subtype.
  String name;

  /// The media type of this codec. Equivalent to MIME top-level type.
  String kind;

  /// Clock rate in Hertz.
  int clockRate;

  /// The number of audio channels used. Set to null for video codecs.
  int numChannels;

  /// The "format specific parameters" field from the "a=fmtp" line in the SDP
  Map<String, String> parameters;

  Map<String, dynamic> toMap() {
    return {
      'payloadType': payloadType,
      'name': name,
      'kind': kind,
      'clockRate': clockRate,
      'numChannels': numChannels,
      'parameters': parameters,
    };
  }

  factory RTCRTPCodec.fromMap(Map<String, dynamic> map) {
    return new RTCRTPCodec(map['payloadType'], map['name'], map['kind'],
        map['clockRate'], map['numChannels'], map['parameters']);
  }

  RTCRTPCodec(this.payloadType, this.name, this.kind, this.clockRate,
      this.numChannels, this.parameters);
}

class RTCRtpEncoding {
  /// If non-null, this represents the RID that identifies this encoding layer.
  /// RIDs are used to identify layers in simulcast.
  String rid;

  /// Set to true to cause this encoding to be sent, and false for it not to
  /// be sent.
  bool active = true;

  /// If non-null, this represents the Transport Independent Application
  /// Specific maximum bandwidth defined in RFC3890. If null, there is no
  /// maximum bitrate.
  int maxBitrateBps;

  /// The minimum bitrate in bps for video.
  int minBitrateBps;

  /// The max framerate in fps for video.
  int maxFramerate;

  /// The number of temporal layers for video.
  int numTemporalLayers;

  /// If non-null, scale the width and height down by this factor for video. If null,
  /// implementation default scaling factor will be used.
  double scaleResolutionDownBy;

  /// SSRC to be used by this encoding.
  /// Can't be changed between getParameters/setParameters.
  int ssrc;

  Map<String, dynamic> toMap() {
    return {
      'rid': rid,
      'active': active,
      'maxBitrateBps': maxBitrateBps,
      'maxFramerate': maxFramerate,
      'minBitrateBps': minBitrateBps,
      'numTemporalLayers': numTemporalLayers,
      'scaleResolutionDownBy': scaleResolutionDownBy,
      'ssrc': ssrc,
    };
  }

  factory RTCRtpEncoding.fromMap(Map<String, dynamic> map) {
    return new RTCRtpEncoding(
        map['rid'],
        map['active'],
        map['maxBitrateBps'],
        map['maxFramerate'],
        map['minBitrateBps'],
        map['numTemporalLayers'],
        map['scaleResolutionDownBy'],
        map['ssrc']);
  }

  RTCRtpEncoding(
      this.rid,
      this.active,
      this.maxBitrateBps,
      this.maxFramerate,
      this.minBitrateBps,
      this.numTemporalLayers,
      this.scaleResolutionDownBy,
      this.ssrc);
}

class RTCHeaderExtension {
  /// The URI of the RTP header extension, as defined in RFC5285.
  String uri;

  /// The value put in the RTP packet to identify the header extension.
  int id;

  /// Whether the header extension is encrypted or not.
  bool encrypted;

  Map<String, dynamic> toMap() {
    return {
      'uri': uri,
      'id': id,
      'encrypted': encrypted,
    };
  }

  factory RTCHeaderExtension.fromMap(Map<String, dynamic> map) {
    return new RTCHeaderExtension(map['uri'], map['id'], map['encrypted']);
  }

  RTCHeaderExtension(this.uri, this.id, this.encrypted);
}

class RTCRtpParameters {
  String transactionId;

  RTCRTCPParameters rtcp;

  List<RTCHeaderExtension> headerExtensions;

  List<RTCRtpEncoding> encodings;

  /// Codec parameters can't currently be changed between getParameters and
  /// setParameters. Though in the future it will be possible to reorder them or
  /// remove them.
  List<RTCRTPCodec> codecs;

  Map<String, dynamic> toMap() {
    List<dynamic> headerExtensionsList = [];
    headerExtensions.forEach((params) {
      headerExtensionsList.add(params.toMap());
    });
    List<dynamic> encodingList = [];
    encodings.forEach((params) {
      encodingList.add(params.toMap());
    });
    List<dynamic> codecsList = [];
    codecs.forEach((params) {
      codecsList.add(params.toMap());
    });
    return {
      'transactionId': transactionId,
      'rtcp': rtcp.toMap(),
      'headerExtensions': headerExtensionsList,
      'encodings': encodingList,
      'codecs': codecsList,
    };
  }

  factory RTCRtpParameters.fromMap(Map<String, dynamic> map) {
    List<RTCRtpEncoding> encodings = [];
    dynamic encodingsMap = map['encodings'];
    encodingsMap.forEach((params) {
      encodings.add(RTCRtpEncoding.fromMap(params));
    });
    List<RTCHeaderExtension> headerExtensions = [];
    dynamic headerExtensionsMap = map['headerExtensions'];
    headerExtensionsMap.forEach((params) {
      headerExtensions.add(RTCHeaderExtension.fromMap(params));
    });
    List<RTCRTPCodec> codecs = [];
    dynamic codecsMap = map['codecs'];
    codecsMap.forEach((params) {
      codecs.add(RTCRTPCodec.fromMap(params));
    });
    RTCRTCPParameters rtcp = RTCRTCPParameters.fromMap(map['rtcp']);
    return new RTCRtpParameters(
        map['transactionId'], rtcp, headerExtensions, encodings, codecs);
  }

  RTCRtpParameters(this.transactionId, this.rtcp, this.headerExtensions,
      this.encodings, this.codecs);
}
