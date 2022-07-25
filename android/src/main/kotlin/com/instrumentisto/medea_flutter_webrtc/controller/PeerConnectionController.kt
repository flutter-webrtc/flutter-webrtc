package com.instrumentisto.medea_flutter_webrtc.controller

import com.instrumentisto.medea_flutter_webrtc.model.*
import com.instrumentisto.medea_flutter_webrtc.proxy.MediaStreamTrackProxy
import com.instrumentisto.medea_flutter_webrtc.proxy.PeerConnectionProxy
import com.instrumentisto.medea_flutter_webrtc.proxy.RtpTransceiverProxy
import com.instrumentisto.medea_flutter_webrtc.utils.AnyThreadSink
import com.instrumentisto.medea_flutter_webrtc.utils.resultUnhandledException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

/**
 * Controller of [PeerConnectionProxy] functional.
 *
 * @property messenger Messenger used for creating new [MethodChannel]s.
 * @property peer Underlying [MediaStreamTrackProxy] to perform [MethodCall]s on.
 */
class PeerConnectionController(
    private val messenger: BinaryMessenger,
    private val peer: PeerConnectionProxy
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler, IdentifiableController {
  /** Unique ID of the [MethodChannel] of this controller. */
  private val channelId = nextChannelId()

  /** Channel listened for the [MethodCall]s. */
  private val chan: MethodChannel =
      MethodChannel(messenger, ChannelNameGenerator.name("PeerConnection", channelId))

  /** Event channel into which all [PeerConnectionProxy] events are sent. */
  private val eventChannel: EventChannel =
      EventChannel(messenger, ChannelNameGenerator.name("PeerConnectionEvent", channelId))

  /** Event sink into which all [PeerConnectionProxy] events are sent. */
  private var eventSink: AnyThreadSink? = null

  /** [PeerConnectionProxy] events observer which sends all events to the [eventSink]. */
  private val eventObserver =
      object : PeerConnectionProxy.Companion.EventObserver {
        override fun onTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy) {
          eventSink?.success(
              mapOf(
                  "event" to "onTrack",
                  "track" to MediaStreamTrackController(messenger, track).asFlutterResult(),
                  "transceiver" to
                      RtpTransceiverController(messenger, transceiver).asFlutterResult()))
        }

        override fun onIceConnectionStateChange(iceConnectionState: IceConnectionState) {
          eventSink?.success(
              mapOf("event" to "onIceConnectionStateChange", "state" to iceConnectionState.value))
        }

        override fun onSignalingStateChange(signalingState: SignalingState) {
          eventSink?.success(
              mapOf("event" to "onSignalingStateChange", "state" to signalingState.value))
        }

        override fun onConnectionStateChange(peerConnectionState: PeerConnectionState) {
          eventSink?.success(
              mapOf("event" to "onConnectionStateChange", "state" to peerConnectionState.value))
        }

        override fun onIceGatheringStateChange(iceGatheringState: IceGatheringState) {
          eventSink?.success(
              mapOf("event" to "onIceGatheringStateChange", "state" to iceGatheringState.value))
        }

        override fun onIceCandidate(candidate: IceCandidate) {
          eventSink?.success(
              mapOf("event" to "onIceCandidate", "candidate" to candidate.asFlutterResult()))
        }

        override fun onNegotiationNeeded() {
          eventSink?.success(mapOf("event" to "onNegotiationNeeded"))
        }
      }

  init {
    chan.setMethodCallHandler(this)
    eventChannel.setStreamHandler(this)
    peer.addEventObserver(eventObserver)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "createOffer" -> {
        GlobalScope.launch(Dispatchers.Main) {
          try {
            result.success(peer.createOffer().asFlutterResult())
          } catch (e: Exception) {
            resultUnhandledException(result, e)
          }
        }
      }
      "createAnswer" -> {
        GlobalScope.launch(Dispatchers.Main) {
          try {
            result.success(peer.createAnswer().asFlutterResult())
          } catch (e: Exception) {
            resultUnhandledException(result, e)
          }
        }
      }
      "setLocalDescription" -> {
        val descriptionArg: Map<String, Any>? = call.argument("description")
        val description =
            if (descriptionArg == null) {
              null
            } else {
              SessionDescription.fromMap(descriptionArg)
            }
        GlobalScope.launch(Dispatchers.Main) {
          try {
            peer.setLocalDescription(description)
            result.success(null)
          } catch (e: Exception) {
            resultUnhandledException(result, e)
          }
        }
      }
      "setRemoteDescription" -> {
        val descriptionArg: Map<String, Any> = call.argument("description")!!
        GlobalScope.launch(Dispatchers.Main) {
          try {
            peer.setRemoteDescription(SessionDescription.fromMap(descriptionArg))
            result.success(null)
          } catch (e: Exception) {
            resultUnhandledException(result, e)
          }
        }
      }
      "addIceCandidate" -> {
        val candidate: Map<String, Any> = call.argument("candidate")!!
        GlobalScope.launch(Dispatchers.Main) {
          try {
            peer.addIceCandidate(IceCandidate.fromMap(candidate))
            result.success(null)
          } catch (e: Exception) {
            resultUnhandledException(result, e)
          }
        }
      }
      "addTransceiver" -> {
        val mediaType = MediaType.fromInt(call.argument("mediaType")!!)
        val transceiverInitArg: Map<String, Any>? = call.argument("init")
        val transceiver =
            if (transceiverInitArg == null) {
              peer.addTransceiver(mediaType, null)
            } else {
              peer.addTransceiver(mediaType, RtpTransceiverInit.fromMap(transceiverInitArg))
            }
        val transceiverController = RtpTransceiverController(messenger, transceiver)
        result.success(transceiverController.asFlutterResult())
      }
      "getTransceivers" -> {
        result.success(
            peer.getTransceivers().map {
              RtpTransceiverController(messenger, it).asFlutterResult()
            })
      }
      "restartIce" -> {
        peer.restartIce()
        result.success(null)
      }
      "dispose" -> {
        dispose()
        result.success(null)
      }
    }
  }

  override fun onListen(obj: Any?, sink: EventChannel.EventSink?) {
    if (sink != null) {
      eventSink = AnyThreadSink(sink)
    }
  }

  override fun onCancel(obj: Any?) {
    peer.removeEventObserver(eventObserver)
    eventChannel.setStreamHandler(null)
    eventSink?.endOfStream()
    eventSink = null
  }

  /**
   * Converts this [PeerConnectionController] to the Flutter's method call result.
   *
   * @return [Map] generated from this controller which can be returned to the Flutter side.
   */
  fun asFlutterResult(): Map<String, Any> =
      mapOf<String, Any>("channelId" to channelId, "id" to peer.id)

  /**
   * Closes method and event channels of this [PeerConnectionController].
   *
   * Disposes underlying [PeerConnectionProxy].
   */
  private fun dispose() {
    peer.dispose()
    chan.setMethodCallHandler(null)
  }
}
