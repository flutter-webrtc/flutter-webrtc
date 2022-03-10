package com.cloudwebrtc.webrtc

import android.content.Context
import android.media.AudioManager
import com.cloudwebrtc.webrtc.utils.EglUtils
import org.webrtc.DefaultVideoDecoderFactory
import org.webrtc.DefaultVideoEncoderFactory
import org.webrtc.EglBase
import org.webrtc.PeerConnectionFactory
import org.webrtc.audio.JavaAudioDeviceModule

/**
 * Global context of the `flutter_webrtc` library.
 *
 * Used for creating tracks, peers, and performing `getUserMedia` requests.
 *
 * @property context  Android [Context] used, for example, for `getUserMedia`
 *                    requests.
 */
class State(private val context: Context) {
    /**
     * Module for the controlling audio devices in context of `libwebrtc`.
     */
    private var audioDeviceModule: JavaAudioDeviceModule? = null

    /**
     * Factory for producing `PeerConnection`s and `MediaStreamTrack`s.
     *
     * Will be lazily initialized on the first call of
     * [getPeerConnectionFactory].
     */
    private var factory: PeerConnectionFactory? = null

    init {
        PeerConnectionFactory.initialize(
            PeerConnectionFactory.InitializationOptions.builder(context)
                .setEnableInternalTracer(true)
                .createInitializationOptions()
        )
    }

    /**
     * Initializes a new [factory].
     */
    private fun initPeerConnectionFactory() {
        val audioModule = JavaAudioDeviceModule.builder(context)
            .setUseHardwareAcousticEchoCanceler(true)
            .setUseHardwareNoiseSuppressor(true)
            .createAudioDeviceModule()
        val eglContext: EglBase.Context = EglUtils.rootEglBaseContext!!
        factory = PeerConnectionFactory.builder()
            .setOptions(PeerConnectionFactory.Options())
            .setVideoEncoderFactory(
                DefaultVideoEncoderFactory(eglContext, true, true)
            )
            .setVideoDecoderFactory(DefaultVideoDecoderFactory(eglContext))
            .setAudioDeviceModule(audioModule)
            .createPeerConnectionFactory()
        audioModule.setSpeakerMute(false)
        audioDeviceModule = audioModule
    }

    /**
     * Initializes the [PeerConnectionFactory] if it wasn't initialized before.
     *
     * @return  Current [PeerConnectionFactory] of this [State].
     */
    fun getPeerConnectionFactory(): PeerConnectionFactory {
        if (factory == null) {
            initPeerConnectionFactory()
        }
        return factory!!
    }

    /**
     * @return  Android SDK [Context].
     */
    fun getAppContext(): Context {
        return context
    }

    /**
     * @return  [AudioManager] system service.
     */
    fun getAudioManager(): AudioManager {
        return context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }
}
