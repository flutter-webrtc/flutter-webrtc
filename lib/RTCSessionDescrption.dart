

class RTCSessionDescrption {
    String sdp;
    String type;
    RTCSessionDescrption(this.sdp,this.type);

    toJSON() {
      return {sdp: this.sdp, type: this.type};
    }
}