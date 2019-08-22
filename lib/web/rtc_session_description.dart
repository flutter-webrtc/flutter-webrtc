// ignore: uri_does_not_exist
import 'dart:js' as JS;
// ignore: uri_does_not_exist
import 'dart:html' as HTML;

class RTCSessionDescription {
    String sdp;
    String type;
    RTCSessionDescription(this.sdp,this.type);
    RTCSessionDescription.fromJs(HTML.RtcSessionDescription rsd): this(rsd.sdp, rsd.type);
    RTCSessionDescription.fromJsObj(JS.JsObject js) : this(js['sdp'], js['type']);

    dynamic toMap() {
      return { "sdp": this.sdp, "type": this.type};
    }
}
