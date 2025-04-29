#ifndef FLUTTER_WEBRTC_RTC_DATA_CHANNEL_HXX
#define FLUTTER_WEBRTC_RTC_DATA_CHANNEL_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

namespace flutter_webrtc_plugin {

class FlutterRTCDataChannelObserver : public RTCDataChannelObserver {
 public:
  FlutterRTCDataChannelObserver(scoped_refptr<RTCDataChannel> data_channel,
                                BinaryMessenger* messenger,
                                TaskRunner* task_runner,
                                const std::string& channel_name);
  virtual ~FlutterRTCDataChannelObserver();

  virtual void OnStateChange(RTCDataChannelState state) override;

  virtual void OnMessage(const char* buffer, int length, bool binary) override;

  scoped_refptr<RTCDataChannel> data_channel() { return data_channel_; }

 private:
  std::unique_ptr<EventChannelProxy> event_channel_;
  scoped_refptr<RTCDataChannel> data_channel_;
};

class FlutterDataChannel {
 public:
  FlutterDataChannel(FlutterWebRTCBase* base) : base_(base) {}

  void CreateDataChannel(const std::string& peerConnectionId,
                         const std::string& label,
                         const EncodableMap& dataChannelDict,
                         RTCPeerConnection* pc,
                         std::unique_ptr<MethodResultProxy>);

  void DataChannelSend(RTCDataChannel* data_channel,
                       const std::string& type,
                       const EncodableValue& data,
                       std::unique_ptr<MethodResultProxy>);

  void DataChannelGetBufferedAmount(RTCDataChannel* data_channel,
                       std::unique_ptr<MethodResultProxy> result);

  void DataChannelClose(RTCDataChannel* data_channel,
                        const std::string& data_channel_uuid,
                        std::unique_ptr<MethodResultProxy>);

  RTCDataChannel* DataChannelForId(const std::string& id);

 private:
  FlutterWebRTCBase* base_;
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_DATA_CHANNEL_HXX