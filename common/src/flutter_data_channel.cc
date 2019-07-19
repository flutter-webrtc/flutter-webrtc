#include "flutter_data_channel.h"

namespace flutter_webrtc_plugin {

FlutterRTCDataChannelObserver::FlutterRTCDataChannelObserver(
    scoped_refptr<RTCDataChannel> data_channel, BinaryMessenger *messenger,
    const std::string &name)
    : event_channel_(new EventChannel<EncodableValue>(
          messenger, name, &StandardMethodCodec::GetInstance())),
      data_channel_(data_channel) {
  StreamHandler<EncodableValue> stream_handler = {
      [&](const EncodableValue *arguments,
          const EventSink<EncodableValue> *events)
          -> MethodResult<EncodableValue> * {
        event_sink_ = events;
        return nullptr;
      },
      [&](const EncodableValue *arguments) -> MethodResult<EncodableValue> * {
        event_sink_ = nullptr;
        return nullptr;
      }};
  event_channel_->SetStreamHandler(stream_handler);
  data_channel_->RegisterObserver(this);
}

FlutterRTCDataChannelObserver::~FlutterRTCDataChannelObserver() {}

void FlutterDataChannel::CreateDataChannel(
    const std::string &label, const EncodableMap &dataChannelDict,
    RTCPeerConnection *pc,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  RTCDataChannelInit init;
  init.id = dataChannelDict.find(EncodableValue("id"))->second.IntValue();
  init.ordered =
      dataChannelDict.find(EncodableValue("ordered"))->second.BoolValue();
  init.maxRetransmitTime =
      dataChannelDict.find(EncodableValue("maxRetransmitTime"))
          ->second.IntValue();
  init.maxRetransmits =
      dataChannelDict.find(EncodableValue("maxRetransmits"))->second.IntValue();
  std::string protocol = {
      dataChannelDict.find(EncodableValue("protocol"))->second.IsNull()
          ? "sctp"
          : dataChannelDict.find(EncodableValue("protocol"))
                ->second.StringValue()};

  strncpy(init.protocol, protocol.c_str(), protocol.size());

  init.negotiated =
      dataChannelDict.find(EncodableValue("negotiated"))->second.BoolValue();

  scoped_refptr<RTCDataChannel> data_channel =
      pc->CreateDataChannel(label.c_str(), &init);

  std::string event_channel =
      "FlutterWebRTC/dataChannelEvent" + std::to_string(data_channel->id());

  std::unique_ptr<FlutterRTCDataChannelObserver> observer(
      new FlutterRTCDataChannelObserver(data_channel, base_->messenger_,
                                        event_channel));

  base_->data_channel_observers_[data_channel->id()] = std::move(observer);

  EncodableMap params;
  params[EncodableValue("id")] = data_channel->id();
  params[EncodableValue("label")] = data_channel->label();
  result->Success(&EncodableValue(params));
}

void FlutterDataChannel::DataChannelSend(
    RTCDataChannel *data_channel, const std::string &type,
    const std::string &data,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  data_channel->Send(data.data(), (int)data.size(), type == "binary");
  result->Success(nullptr);
}

void FlutterDataChannel::DataChannelClose(
    RTCDataChannel *data_channel,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  int id = data_channel->id();
  data_channel->Close();
  auto it = base_->data_channel_observers_.find(id);
  if (it != base_->data_channel_observers_.end())
    base_->data_channel_observers_.erase(it);
  result->Success(nullptr);
}

RTCDataChannel *FlutterDataChannel::DataChannelFormId(int id) {
  auto it = base_->data_channel_observers_.find(id);

  if (it != base_->data_channel_observers_.end()) {
    FlutterRTCDataChannelObserver *observer = it->second.get();
    scoped_refptr<RTCDataChannel> data_channel = observer->data_channel();
    return data_channel.get();
  }
  return nullptr;
}

static const char *DataStateString(RTCDataChannelState state) {
  switch (state) {
    case RTCDataChannelConnecting:
      return "connecting";
    case RTCDataChannelOpen:
      return "open";
    case RTCDataChannelClosing:
      return "closing";
    case RTCDataChannelClosed:
      return "closed";
  }
  return "";
}

void FlutterRTCDataChannelObserver::OnStateChange(RTCDataChannelState state) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "dataChannelReceiveMessage";
    params[EncodableValue("id")] = data_channel_->id();
    params[EncodableValue("state")] = DataStateString(state);
    event_sink_->Success(&EncodableValue(params));
  }
}

void FlutterRTCDataChannelObserver::OnMessage(const char *buffer, int length,
                                              bool binary) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "dataChannelReceiveMessage";
    params[EncodableValue("id")] = data_channel_->id();
    params[EncodableValue("type")] = binary ? "binary" : "text";
    params[EncodableValue("data")] = std::string(buffer, length);
    event_sink_->Success(&EncodableValue(params));
  }
}
}  // namespace flutter_webrtc_plugin
