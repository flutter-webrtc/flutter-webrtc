import 'rtc_rtcp_parameters.dart';

class RTCRTPCodec {
  RTCRTPCodec(
      {this.payloadType,
      this.name,
      this.kind,
      this.clockRate,
      this.numChannels,
      this.parameters});

  factory RTCRTPCodec.fromMap(Map<dynamic, dynamic> map) {
    return RTCRTPCodec(
        payloadType: map['payloadType'],
        name: map['name'],
        kind: map['kind'],
        clockRate: map['clockRate'],
        numChannels: map['numChannels'] ?? 1,
        parameters: map['parameters']);
  }
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
  Map<dynamic, dynamic> parameters;

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
}

class RTCRtpEncoding {
  RTCRtpEncoding(
      {this.rid,
      this.active,
      this.maxBitrate,
      this.maxFramerate,
      this.minBitrate,
      this.numTemporalLayers,
      this.scaleResolutionDownBy,
      this.ssrc});

  factory RTCRtpEncoding.fromMap(Map<dynamic, dynamic> map) {
    return RTCRtpEncoding(
        rid: map['rid'],
        active: map['active'],
        maxBitrate: map['maxBitrate'],
        maxFramerate: map['maxFramerate'],
        minBitrate: map['minBitrate'],
        numTemporalLayers: map['numTemporalLayers'],
        scaleResolutionDownBy: map['scaleResolutionDownBy'],
        ssrc: map['ssrc']);
  }

  /// If non-null, this represents the RID that identifies this encoding layer.
  /// RIDs are used to identify layers in simulcast.
  String rid;

  /// Set to true to cause this encoding to be sent, and false for it not to
  /// be sent.
  bool active = true;

  /// If non-null, this represents the Transport Independent Application
  /// Specific maximum bandwidth defined in RFC3890. If null, there is no
  /// maximum bitrate.
  int maxBitrate;

  /// The minimum bitrate in bps for video.
  int minBitrate;

  /// The max framerate in fps for video.
  int maxFramerate;

  /// The number of temporal layers for video.
  int numTemporalLayers = 1;

  /// If non-null, scale the width and height down by this factor for video. If null,
  /// implementation default scaling factor will be used.
  double scaleResolutionDownBy = 1.0;

  /// SSRC to be used by this encoding.
  /// Can't be changed between getParameters/setParameters.
  int ssrc;

  Map<String, dynamic> toMap() {
    return {
      if (rid != null) 'rid': rid,
      if (active != null) 'active': active,
      if (maxBitrate != null) 'maxBitrate': maxBitrate,
      if (maxFramerate != null) 'maxFramerate': maxFramerate,
      if (minBitrate != null) 'minBitrate': minBitrate,
      if (numTemporalLayers != null) 'numTemporalLayers': numTemporalLayers,
      if (scaleResolutionDownBy != null)
        'scaleResolutionDownBy': scaleResolutionDownBy,
      if (ssrc != null) 'ssrc': ssrc,
    };
  }
}

class RTCHeaderExtension {
  RTCHeaderExtension({this.uri, this.id, this.encrypted});
  factory RTCHeaderExtension.fromMap(Map<dynamic, dynamic> map) {
    return RTCHeaderExtension(
        uri: map['uri'], id: map['id'], encrypted: map['encrypted']);
  }

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
}

class RTCRtpParameters {
  RTCRtpParameters(this.transactionId, this.rtcp, this.headerExtensions,
      this.encodings, this.codecs);

  factory RTCRtpParameters.fromMap(Map<dynamic, dynamic> map) {
    var encodings = <RTCRtpEncoding>[];
    dynamic encodingsMap = map['encodings'];
    encodingsMap.forEach((params) {
      encodings.add(RTCRtpEncoding.fromMap(params));
    });
    var headerExtensions = <RTCHeaderExtension>[];
    dynamic headerExtensionsMap = map['headerExtensions'];
    headerExtensionsMap.forEach((params) {
      headerExtensions.add(RTCHeaderExtension.fromMap(params));
    });
    var codecs = <RTCRTPCodec>[];
    dynamic codecsMap = map['codecs'];
    codecsMap.forEach((params) {
      codecs.add(RTCRTPCodec.fromMap(params));
    });
    var rtcp = RTCRTCPParameters.fromMap(map['rtcp']);
    return RTCRtpParameters(
        map['transactionId'], rtcp, headerExtensions, encodings, codecs);
  }

  String transactionId;

  RTCRTCPParameters rtcp;

  List<RTCHeaderExtension> headerExtensions;

  List<RTCRtpEncoding> encodings;

  /// Codec parameters can't currently be changed between getParameters and
  /// setParameters. Though in the future it will be possible to reorder them or
  /// remove them.
  List<RTCRTPCodec> codecs;

  Map<String, dynamic> toMap() {
    var headerExtensionsList = <dynamic>[];
    headerExtensions.forEach((params) {
      headerExtensionsList.add(params.toMap());
    });
    var encodingList = <dynamic>[];
    encodings.forEach((params) {
      encodingList.add(params.toMap());
    });
    var codecsList = <dynamic>[];
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
}
