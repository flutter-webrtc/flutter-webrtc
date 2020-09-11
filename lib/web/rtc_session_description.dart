import 'dart:js' as js;
import 'dart:html' as html;

class RTCSessionDescription {
  final String sdp;
  final String type;
  RTCSessionDescription(this.sdp, this.type);
  RTCSessionDescription.fromJs(html.RtcSessionDescription rsd)
      : this(rsd.sdp, rsd.type);
  RTCSessionDescription.fromJsObj(js.JsObject js) : this(js['sdp'], js['type']);

  dynamic toMap() {
    return {'sdp': sdp, 'type': type};
  }
}
