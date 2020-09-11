import 'dart:html' as html;
import 'dart:js' as js;

class RTCSessionDescription {
  RTCSessionDescription(this.sdp, this.type);
  RTCSessionDescription.fromJs(html.RtcSessionDescription rsd)
      : this(rsd.sdp, rsd.type);
  RTCSessionDescription.fromJsObj(js.JsObject js) : this(js['sdp'], js['type']);

  final String sdp;
  final String type;

  Map<String, dynamic> toMap() {
    return {'sdp': sdp, 'type': type};
  }
}
