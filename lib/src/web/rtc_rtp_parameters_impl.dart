import 'dart:js_util' as jsutil;
import '../interface/rtc_rtcp_parameters.dart';
import '../interface/rtc_rtp_parameters.dart';

class RTCRtpParametersWeb {
  static RTCRtpParameters fromJsObject(Object object) {
    return RTCRtpParameters(
        transactionId: jsutil.getProperty(object, 'transactionId'),
        rtcp: RTCRTCPParametersWeb.fromJsObject(
            jsutil.getProperty(object, 'rtcp')),
        headerExtensions: headerExtensionsFromJsObject(object),
        encodings: encodingsFromJsObject(object),
        codecs: codecsFromJsObject(object));
  }

  static List<RTCHeaderExtension> headerExtensionsFromJsObject(Object object) {
    var headerExtensions = jsutil.getProperty(object, 'headerExtensions');
    var list = <RTCHeaderExtension>[];
    headerExtensions.forEach((e) {
      list.add(RTCHeaderExtensionWeb.fromJsObject(e));
    });
    return list;
  }

  static List<RTCRtpEncoding> encodingsFromJsObject(Object object) {
    var encodings = jsutil.getProperty(object, 'encodings');
    var list = <RTCRtpEncoding>[];
    encodings.forEach((e) {
      list.add(RTCRtpEncodingWeb.fromJsObject(e));
    });
    return list;
  }

  static List<RTCRTPCodec> codecsFromJsObject(Object object) {
    var encodings = jsutil.getProperty(object, 'codecs');
    var list = <RTCRTPCodec>[];
    encodings.forEach((e) {
      list.add(RTCRTPCodecWeb.fromJsObject(e));
    });
    return list;
  }
}

class RTCRTCPParametersWeb {
  static RTCRTCPParameters fromJsObject(Object object) {
    return RTCRTCPParameters.fromMap({
      'cname': jsutil.getProperty(object, 'cname'),
      'reducedSize': jsutil.getProperty(object, 'reducedSize')
    });
  }
}

class RTCHeaderExtensionWeb {
  static RTCHeaderExtension fromJsObject(Object object) {
    return RTCHeaderExtension.fromMap({
      'uri': jsutil.getProperty(object, 'uri'),
      'id': jsutil.getProperty(object, 'id'),
      'encrypted': jsutil.getProperty(object, 'encrypted')
    });
  }
}

class RTCRtpEncodingWeb {
  static RTCRtpEncoding fromJsObject(Object object) {
    return RTCRtpEncoding.fromMap({
      'rid': jsutil.getProperty(object, 'rid'),
      'active': jsutil.getProperty(object, 'active'),
      'maxBitrate': jsutil.getProperty(object, 'maxBitrate'),
      'maxFramerate': jsutil.getProperty(object, 'maxFramerate'),
      'minBitrate': jsutil.getProperty(object, 'minBitrate'),
      'numTemporalLayers': jsutil.getProperty(object, 'numTemporalLayers'),
      'scaleResolutionDownBy':
          jsutil.getProperty(object, 'scaleResolutionDownBy'),
      'ssrc': jsutil.getProperty(object, 'ssrc')
    });
  }
}

class RTCRTPCodecWeb {
  static RTCRTPCodec fromJsObject(Object object) {
    return RTCRTPCodec.fromMap({
      'payloadType': jsutil.getProperty(object, 'payloadType'),
      'name': jsutil.getProperty(object, 'name'),
      'kind': jsutil.getProperty(object, 'kind'),
      'clockRate': jsutil.getProperty(object, 'clockRate'),
      'numChannels': jsutil.getProperty(object, 'numChannels'),
      'parameters': jsutil.getProperty(object, 'parameters')
    });
  }
}
