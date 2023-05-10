import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart' as sdp_transform;

void setPreferredCodec(RTCSessionDescription description,
    {String audio = 'opus', String video = 'vp8'}) {
  var capSel = CodecCapabilitySelector(description.sdp!);
  var acaps = capSel.getCapabilities('audio');
  if (acaps != null) {
    acaps.codecs = acaps.codecs
        .where((e) => (e['codec'] as String).toLowerCase() == audio)
        .toList();
    acaps.setCodecPreferences('audio', acaps.codecs);
    capSel.setCapabilities(acaps);
  }

  var vcaps = capSel.getCapabilities('video');
  if (vcaps != null) {
    vcaps.codecs = vcaps.codecs
        .where((e) => (e['codec'] as String).toLowerCase() == video)
        .toList();
    vcaps.setCodecPreferences('video', vcaps.codecs);
    capSel.setCapabilities(vcaps);
  }
  description.sdp = capSel.sdp();
}

class CodecCapability {
  CodecCapability(
      this.kind, this.payloads, this.codecs, this.fmtp, this.rtcpFb) {
    codecs.forEach((element) {
      element['orign_payload'] = element['payload'];
    });
  }
  String kind;
  List<dynamic> rtcpFb;
  List<dynamic> fmtp;
  List<String> payloads;
  List<dynamic> codecs;
  bool setCodecPreferences(String kind, List<dynamic>? newCodecs) {
    if (newCodecs == null) {
      return false;
    }
    var newRtcpFb = <dynamic>[];
    var newFmtp = <dynamic>[];
    var newPayloads = <String>[];
    newCodecs.forEach((element) {
      var orign_payload = element['orign_payload'] as int;
      var payload = element['payload'] as int;
      // change payload type
      if (payload != orign_payload) {
        newRtcpFb.addAll(rtcpFb.where((e) {
          if (e['payload'] == orign_payload) {
            e['payload'] = payload;
            return true;
          }
          return false;
        }).toList());
        newFmtp.addAll(fmtp.where((e) {
          if (e['payload'] == orign_payload) {
            e['payload'] = payload;
            return true;
          }
          return false;
        }).toList());
        if (payloads.contains('$orign_payload')) {
          newPayloads.add('$payload');
        }
      } else {
        newRtcpFb.addAll(rtcpFb.where((e) => e['payload'] == payload).toList());
        newFmtp.addAll(fmtp.where((e) => e['payload'] == payload).toList());
        newPayloads.addAll(payloads.where((e) => e == '$payload').toList());
      }
    });
    rtcpFb = newRtcpFb;
    fmtp = newFmtp;
    payloads = newPayloads;
    codecs = newCodecs;
    return true;
  }
}

class CodecCapabilitySelector {
  CodecCapabilitySelector(String sdp) {
    _sdp = sdp;
    _session = sdp_transform.parse(_sdp);
  }
  late String _sdp;
  late Map<String, dynamic> _session;
  Map<String, dynamic> get session => _session;
  String sdp() => sdp_transform.write(_session, null);

  CodecCapability? getCapabilities(String kind) {
    var mline = _mline(kind);
    if (mline == null) {
      return null;
    }
    var rtcpFb = mline['rtcpFb'] ?? <dynamic>[];
    var fmtp = mline['fmtp'] ?? <dynamic>[];
    var payloads = (mline['payloads'] as String).split(' ');
    var codecs = mline['rtp'] ?? <dynamic>[];
    return CodecCapability(kind, payloads, codecs, fmtp, rtcpFb);
  }

  bool setCapabilities(CodecCapability? caps) {
    if (caps == null) {
      return false;
    }
    var mline = _mline(caps.kind);
    if (mline == null) {
      return false;
    }
    mline['payloads'] = caps.payloads.join(' ');
    mline['rtp'] = caps.codecs;
    mline['fmtp'] = caps.fmtp;
    mline['rtcpFb'] = caps.rtcpFb;
    return true;
  }

  Map<String, dynamic>? _mline(String kind) {
    var mlist = _session['media'] as List<dynamic>;
    return mlist.firstWhere((element) => element['type'] == kind,
        orElse: () => null);
  }
}
