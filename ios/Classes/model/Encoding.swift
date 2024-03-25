import WebRTC

/// Encoding describes a single configuration of a codec for an RTCRtpSender.
class Encoding {
  /// A string which, if set, specifies an RTP stream ID (RID) to be sent using
  /// the RID header extension.
  var rid: String

  /// If true, the described encoding is currently actively being used.
  var active: Bool

  /// Indicates the maximum number of bits per second to allow for this
  /// encoding.
  var maxBitrate: Int?

  /// A value specifying the maximum number of frames per second to allow for
  /// this encoding.
  var maxFramerate: Double?

  /// This is a double-precision floating-point value specifying a factor by
  /// which to scale down the video during encoding.
  var scaleResolutionDownBy: Double?

  /// Scalability mode describing layers within the media stream.
  var scalabilityMode: String?

  /// Initializes a new `Encoding` configuration with the provided data.
  init(
    rid: String, active: Bool, maxBitrate: Int?, maxFramerate: Double?,
    scaleResolutionDownBy: Double?, scalabilityMode: String?
  ) {
    self.rid = rid
    self.active = active
    self.maxBitrate = maxBitrate
    self.maxFramerate = maxFramerate
    self.scaleResolutionDownBy = scaleResolutionDownBy
    self.scalabilityMode = scalabilityMode
  }

  /// Converts this `Encoding` into an `RTCRtpEncodingParameters`.
  func intoWebRtc() -> RTCRtpEncodingParameters {
    let params = RTCRtpEncodingParameters()
    params.rid = self.rid
    params.isActive = self.active
    params.scalabilityMode = self.scalabilityMode

    if let maxBitrate = maxBitrate {
      params.maxBitrateBps = NSNumber(value: maxBitrate)
    }
    if let maxFramerate = maxFramerate {
      params.maxFramerate = NSNumber(value: maxFramerate)
    }
    if let scaleResolutionDownBy = scaleResolutionDownBy {
      params.scaleResolutionDownBy = NSNumber(value: scaleResolutionDownBy)
    }

    return params
  }
}
