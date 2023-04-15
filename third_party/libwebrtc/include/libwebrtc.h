#ifndef LIB_WEBRTC_HXX
#define LIB_WEBRTC_HXX

#include "rtc_peerconnection_factory.h"
#include "rtc_types.h"

namespace libwebrtc {

/**
 * @class LibWebRTC
 * @brief Provides static methods for initializing, creating and terminating
 * the WebRTC PeerConnectionFactory and threads.
 *
 * This class provides static methods for initializing, creating and terminating
 * the WebRTC PeerConnectionFactory and threads. These methods are thread-safe
 * and can be called from any thread. This class is not meant to be
 * instantiated.
 *
 */
class LibWebRTC {
 public:
  /**
   * @brief Initializes the WebRTC PeerConnectionFactory and threads.
   *
   * Initializes the WebRTC PeerConnectionFactory and threads. This method is
   * thread-safe and can be called from any thread. It initializes SSL and
   * creates three threads: worker_thread, signaling_thread and network_thread.
   *
   * @return true if initialization is successful, false otherwise.
   */
  LIB_WEBRTC_API static bool Initialize();

  /**
   * @brief Creates a new WebRTC PeerConnectionFactory.
   *
   * Creates a new WebRTC PeerConnectionFactory. This method is thread-safe and
   * can be called from any thread. It creates a new instance of the
   * RTCPeerConnectionFactoryImpl class and initializes it.
   *
   * @return A scoped_refptr object that points to the newly created
   * RTCPeerConnectionFactory.
   */
  LIB_WEBRTC_API static scoped_refptr<RTCPeerConnectionFactory>
  CreateRTCPeerConnectionFactory();

  /**
   * @brief Terminates the WebRTC PeerConnectionFactory and threads.
   *
   * Terminates the WebRTC PeerConnectionFactory and threads. This method is
   * thread-safe and can be called from any thread. It cleans up SSL and stops
   * and destroys the three threads: worker_thread, signaling_thread and
   * network_thread.
   *
   */
  LIB_WEBRTC_API static void Terminate();
};

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_HXX
