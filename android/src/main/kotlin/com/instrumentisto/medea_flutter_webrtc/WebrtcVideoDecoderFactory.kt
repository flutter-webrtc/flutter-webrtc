package com.instrumentisto.medea_flutter_webrtc

import org.webrtc.EglBase
import org.webrtc.HardwareVideoDecoderFactory
import org.webrtc.PlatformSoftwareVideoDecoderFactory
import org.webrtc.SoftwareVideoDecoderFactory
import org.webrtc.VideoCodecInfo
import org.webrtc.VideoDecoder
import org.webrtc.VideoDecoderFactory
import org.webrtc.VideoDecoderFallback

class WebrtcVideoDecoderFactory
/** Creates decoder factory using default hardware decoder factory. */
(eglContext: EglBase.Context?) : VideoDecoderFactory {

  /** [HardwareVideoDecoderFactory] capable of creating hardware-accelerated [VideoDecoder]s. */
  private val hwFactory: HardwareVideoDecoderFactory

  /**
   * [VideoDecoderFactory] used as a fallback for codecs that are not supported by the
   * [HardwareVideoDecoderFactory].
   *
   * Uses `libwebrtc`'s `BuiltinVideoDecoderFactory` underneath.
   */
  private val swFactory: SoftwareVideoDecoderFactory = SoftwareVideoDecoderFactory()

  /**
   * [VideoDecoderFactory] used as a last resort when neither [HardwareVideoDecoderFactory] nor
   * [SoftwareVideoDecoderFactory] could not be used.
   *
   * Backed by Android MediaCodec API.
   *
   * []Android MediaCodec API]: https://developer.android.com/reference/android/media/MediaCodec
   */
  private val platformSWFactory: PlatformSoftwareVideoDecoderFactory

  init {
    hwFactory = HardwareVideoDecoderFactory(eglContext)
    platformSWFactory = PlatformSoftwareVideoDecoderFactory(eglContext)
  }

  override fun createDecoder(codecType: VideoCodecInfo): VideoDecoder? {
    var sw = swFactory.createDecoder(codecType)
    val wh = hwFactory.createDecoder(codecType)
    if (sw == null) {
      sw = platformSWFactory.createDecoder(codecType)
    }

    return if (wh != null && sw != null) {
      // Both hardware and software supported, wrap it in a software fallback.
      VideoDecoderFallback(sw, wh)
    } else wh ?: sw
  }

  override fun getSupportedCodecs(): Array<VideoCodecInfo> {
    val codecs = LinkedHashSet<VideoCodecInfo>()

    codecs.addAll(getSWCodecs())
    codecs.addAll(getHWCodecs())

    return codecs.toTypedArray()
  }

  /** Enumerates the list of video codecs that can be hardware-accelerated. */
  fun getHWCodecs(): Array<VideoCodecInfo> {
    return hwFactory.supportedCodecs
  }

  /** Enumerates the list of video codecs that only have software implementation. */
  fun getSWCodecs(): Array<VideoCodecInfo> {
    val codecs = LinkedHashSet<VideoCodecInfo>()

    codecs.addAll(swFactory.supportedCodecs)
    codecs.addAll(platformSWFactory.supportedCodecs)

    return codecs.toTypedArray()
  }
}
