import 'dart:html' as HTML;

class RTCIceCandidate {
  String candidate;
  String sdpMid;
  int sdpMlineIndex;

  RTCIceCandidate(this.candidate, this.sdpMid, this.sdpMlineIndex);
  RTCIceCandidate.fromJs(HTML.RtcIceCandidate jsIceCandidate)
      : this(jsIceCandidate.candidate, jsIceCandidate.sdpMid,
            jsIceCandidate.sdpMLineIndex);

  dynamic toMap() {
    return {
      "candidate": candidate,
      "sdpMid": sdpMid,
      "sdpMLineIndex": sdpMlineIndex
    };
  }

  HTML.RtcIceCandidate toJs() => HTML.RtcIceCandidate(toMap());
}
