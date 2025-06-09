package com.instrumentisto.medea_flutter_webrtc

import android.content.Context
import android.media.AudioManager
import com.instrumentisto.medea_flutter_webrtc.utils.EglUtils
import org.webrtc.PeerConnectionFactory
import org.webrtc.VideoDecoderFactory
import org.webrtc.VideoEncoderFactory
import org.webrtc.audio.JavaAudioDeviceModule

/**
 * Global context of the `flutter_webrtc` library.
 *
 * Used for creating tracks, peers, and performing `getUserMedia` requests.
 *
 * @property context Android [Context] used, for example, for `getUserMedia` requests.
 */
class State(val context: Context) {
  /** [VideoEncoderFactory] used by the [PeerConnectionFactory]. */
  var encoder: WebrtcVideoEncoderFactory

  /** [VideoDecoderFactory] used by the [PeerConnectionFactory]. */
  var decoder: WebrtcVideoDecoderFactory

  /**
   * Factory for producing `PeerConnection`s and `MediaStreamTrack`s.
   *
   * Will be lazily initialized on the first call of [getPeerConnectionFactory].
   */
  private var factory: PeerConnectionFactory? = null

  init {
    PeerConnectionFactory.initialize(
        PeerConnectionFactory.InitializationOptions.builder(context)
            .setEnableInternalTracer(BuildConfig.DEBUG)
            .createInitializationOptions())

    encoder =
        WebrtcVideoEncoderFactory(
            EglUtils.rootEglBaseContext, enableIntelVp8Encoder = true, enableH264HighProfile = true)
    decoder = WebrtcVideoDecoderFactory(EglUtils.rootEglBaseContext)
  }

  /**
   * Initializes the [PeerConnectionFactory] in this [State] if it wasn't initialized before.
   *
   * @return Current [PeerConnectionFactory] of this [State].
   */
  fun getPeerConnectionFactory(): PeerConnectionFactory {
    if (factory == null || factory!!.nativeOwnedFactoryAndThreads == 0L) {
      var audioDeviceModule =
          JavaAudioDeviceModule.builder(context)
              .setUseHardwareAcousticEchoCanceler(true)
              .setUseHardwareNoiseSuppressor(true)
              .createAudioDeviceModule()

      factory =
          PeerConnectionFactory.builder()
              .setOptions(PeerConnectionFactory.Options())
              .setVideoEncoderFactory(encoder)
              .setVideoDecoderFactory(decoder)
              .setAudioDeviceModule(audioDeviceModule)
              .createPeerConnectionFactory()
      audioDeviceModule.release()
    }

    return factory!!
  }

  /** @return [AudioManager] system service. */
  fun getAudioManager(): AudioManager {
    return context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
  }
}
