

class RTCSessionDescrption {
    String sdp;
    String type;
    RTCSessionDescrption(this.sdp,this.type);

    dynamic toMap() {
      return { "sdp": this.sdp, "type": this.type};
    }
}