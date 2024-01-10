package com.instrumentisto.medea_flutter_webrtc

import org.webrtc.EglBase
import org.webrtc.HardwareVideoEncoderFactory
import org.webrtc.SoftwareVideoEncoderFactory
import org.webrtc.VideoCodecInfo
import org.webrtc.VideoEncoder
import org.webrtc.VideoEncoderFactory
import org.webrtc.VideoEncoderFallback

class WebrtcVideoEncoderFactory
/** Creates encoder factory using default hardware encoder factory. */
(eglContext: EglBase.Context?, enableIntelVp8Encoder: Boolean, enableH264HighProfile: Boolean) :
    VideoEncoderFactory {

  /** [VideoEncoderFactory] capable of creating hardware-accelerated [VideoEncoder]s. */
  private val hwFactory: HardwareVideoEncoderFactory

  /**
   * [VideoEncoderFactory] used as a fallback for codecs that are not supported by
   * [HardwareVideoEncoderFactory].
   */
  private val swFactory: SoftwareVideoEncoderFactory = SoftwareVideoEncoderFactory()

  init {
    hwFactory =
        HardwareVideoEncoderFactory(eglContext, enableIntelVp8Encoder, enableH264HighProfile)
  }

  override fun createEncoder(info: VideoCodecInfo): VideoEncoder? {
    val sw = swFactory.createEncoder(info)
    val hw = hwFactory.createEncoder(info)

    return if (hw != null && sw != null) {
      // Both hardware and software supported, wrap it in a software fallback.
      VideoEncoderFallback(sw, hw)
    } else hw ?: sw
  }

  override fun getSupportedCodecs(): Array<VideoCodecInfo> {
    val codecs = LinkedHashSet<VideoCodecInfo>()

    codecs.addAll(getHWCodecs())
    codecs.addAll(getSWCodecs())

    return codecs.toTypedArray()
  }

  /** Enumerates the list of video codecs that can be hardware-accelerated. */
  fun getHWCodecs(): Array<VideoCodecInfo> {
    return hwFactory.supportedCodecs
  }

  /** Enumerates the list of video codecs that only have software implementation. */
  fun getSWCodecs(): Array<VideoCodecInfo> {
    return swFactory.supportedCodecs
  }
}
