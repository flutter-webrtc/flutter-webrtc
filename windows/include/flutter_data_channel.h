#ifndef FLUTTER_WEBRTC_RTC_DATA_CHANNEL_HXX
#define FLUTTER_WEBRTC_RTC_DATA_CHANNEL_HXX

#include "flutter_webrtc_base.h"

namespace flutter_webrtc_plugin {

class FlutterRTCDataChannelObserver : public RTCDataChannelObserver {
 public:
  FlutterRTCDataChannelObserver(scoped_refptr<RTCDataChannel> data_channel,
                                BinaryMessenger *messenger,
                                const std::string &channel_name);
  virtual ~FlutterRTCDataChannelObserver();

  virtual void OnStateChange(RTCDataChannelState state) override;

  virtual void OnMessage(const char *buffer, int length, bool binary) override;

  scoped_refptr<RTCDataChannel> data_channel() { return data_channel_; }

 private:
  std::unique_ptr<EventChannel<EncodableValue>> event_channel_;
  std::unique_ptr<EventSink<EncodableValue>> event_sink_;
  scoped_refptr<RTCDataChannel> data_channel_;
};

class FlutterDataChannel {
 public:
  FlutterDataChannel(FlutterWebRTCBase *base) : base_(base) {}

  void CreateDataChannel(const std::string &label,
                         const EncodableMap &dataChannelDict,
                         RTCPeerConnection *pc,
                         std::unique_ptr<MethodResult<EncodableValue>>);

  void DataChannelSend(RTCDataChannel *data_channel, const std::string &type,
                       const EncodableValue &data,
                       std::unique_ptr<MethodResult<EncodableValue>>);

  void DataChannelClose(RTCDataChannel *data_channel,
                        std::unique_ptr<MethodResult<EncodableValue>>);

  RTCDataChannel *DataChannelFormId(int id);

 private:
  FlutterWebRTCBase *base_;
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_DATA_CHANNEL_HXX