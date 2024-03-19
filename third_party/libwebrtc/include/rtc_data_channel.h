#ifndef LIB_WEBRTC_RTC_DATA_CHANNEL_HXX
#define LIB_WEBRTC_RTC_DATA_CHANNEL_HXX

#include "rtc_types.h"

namespace libwebrtc {

/**
 * The RTCDataChannelState enum represents the possible states of a WebRTC data
 * channel. Data channels are used to transmit non-audio/video data over a
 * WebRTC peer connection. The possible states are: connecting, open, closing,
 * and closed.
 */
enum RTCDataChannelState {
  RTCDataChannelConnecting,
  RTCDataChannelOpen,
  RTCDataChannelClosing,
  RTCDataChannelClosed,
};

/**
 * The RTCDataChannelInit struct represents the configuration options for a
 * WebRTC data channel. These options include whether the channel is ordered and
 * reliable, the maximum retransmit time and number of retransmits, the protocol
 * to use (sctp or quic), whether the channel is negotiated, and the channel ID.
 */
struct RTCDataChannelInit {
  bool ordered = true;
  bool reliable = true;
  int maxRetransmitTime = -1;
  int maxRetransmits = -1;
  string protocol = {"sctp"};  // sctp | quic
  bool negotiated = false;
  int id = 0;
};

/**
 * The RTCDataChannelObserver class is an interface for receiving events related
 * to a WebRTC data channel. These events include changes in the channel's state
 * and incoming messages.
 */
class RTCDataChannelObserver {
 public:
  /**
   * Called when the state of the data channel changes.
   * The new state is passed as a parameter.
   */
  virtual void OnStateChange(RTCDataChannelState state) = 0;

  /**
   * Called when a message is received on the data channel.
   * The message buffer, its length, and a boolean indicating whether the
   * message is binary are passed as parameters.
   */
  virtual void OnMessage(const char* buffer, int length, bool binary) = 0;

 protected:
  /**
   * The destructor for the RTCDataChannelObserver class.
   */
  virtual ~RTCDataChannelObserver() = default;
};

/**
 * The RTCDataChannel class represents a data channel in WebRTC.
 * Data channels are used to transmit non-audio/video data over a WebRTC peer
 * connection. This class provides a base interface for data channels to
 * implement, allowing them to be used with WebRTC's data channel mechanisms.
 */
class RTCDataChannel : public RefCountInterface {
 public:
  /**
   * Sends data over the data channel.
   * The data buffer, its size, and a boolean indicating whether the data is
   * binary are passed as parameters.
   */
  virtual void Send(const uint8_t* data, uint32_t size,
                    bool binary = false) = 0;

  /**
   * Closes the data channel.
   */
  virtual void Close() = 0;

  /**
   * Registers an observer for events related to the data channel.
   * The observer object is passed as a parameter.
   */
  virtual void RegisterObserver(RTCDataChannelObserver* observer) = 0;

  /**
   * Unregisters the current observer for the data channel.
   */
  virtual void UnregisterObserver() = 0;

  /**
   * Returns the label of the data channel.
   */
  virtual const string label() const = 0;

  /**
   * Returns the ID of the data channel.
   */
  virtual int id() const = 0;

  /**
   * Returns the state of the data channel.
   */
  virtual RTCDataChannelState state() = 0;

 protected:
  virtual ~RTCDataChannel() {}
};

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_DATA_CHANNEL_HXX
