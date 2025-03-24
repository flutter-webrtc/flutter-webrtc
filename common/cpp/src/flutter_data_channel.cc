#include "flutter_data_channel.h"

#include <vector>

namespace flutter_webrtc_plugin {

FlutterRTCDataChannelObserver::FlutterRTCDataChannelObserver(
    scoped_refptr<RTCDataChannel> data_channel,
    BinaryMessenger* messenger,
    TaskRunner* task_runner,
    const std::string& channelName)
    : event_channel_(EventChannelProxy::Create(messenger, task_runner, channelName)),
      data_channel_(data_channel) {
  data_channel_->RegisterObserver(this);
}

FlutterRTCDataChannelObserver::~FlutterRTCDataChannelObserver() {}

void FlutterDataChannel::CreateDataChannel(
    const std::string& peerConnectionId,
    const std::string& label,
    const EncodableMap& dataChannelDict,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResultProxy> result) {
  RTCDataChannelInit init;
  init.id = GetValue<int>(dataChannelDict.find(EncodableValue("id"))->second);
  init.ordered =
      GetValue<bool>(dataChannelDict.find(EncodableValue("ordered"))->second);

  if (dataChannelDict.find(EncodableValue("maxRetransmits")) !=
      dataChannelDict.end()) {
    init.maxRetransmits = GetValue<int>(
        dataChannelDict.find(EncodableValue("maxRetransmits"))->second);
  }

  std::string protocol = "sctp";

  if (dataChannelDict.find(EncodableValue("protocol")) ==
      dataChannelDict.end()) {
    protocol = GetValue<std::string>(
        dataChannelDict.find(EncodableValue("protocol"))->second);
  }

  init.protocol = protocol;

  init.negotiated = GetValue<bool>(
      dataChannelDict.find(EncodableValue("negotiated"))->second);

  scoped_refptr<RTCDataChannel> data_channel =
      pc->CreateDataChannel(label.c_str(), &init);

  std::string uuid = base_->GenerateUUID();
  std::string event_channel =
      "FlutterWebRTC/dataChannelEvent" + peerConnectionId + uuid;

  std::unique_ptr<FlutterRTCDataChannelObserver> observer(
      new FlutterRTCDataChannelObserver(data_channel, base_->messenger_, base_->task_runner_,
                                        event_channel));

  base_->lock();
  base_->data_channel_observers_[uuid] = std::move(observer);
  base_->unlock();

  EncodableMap params;
  params[EncodableValue("id")] = EncodableValue(init.id);
  params[EncodableValue("label")] =
      EncodableValue(data_channel->label().std_string());
  params[EncodableValue("flutterId")] = EncodableValue(uuid);
  result->Success(EncodableValue(params));
}

void FlutterDataChannel::DataChannelSend(
    RTCDataChannel* data_channel,
    const std::string& type,
    const EncodableValue& data,
    std::unique_ptr<MethodResultProxy> result) {
  bool is_binary = type == "binary";
  if (is_binary && TypeIs<std::vector<uint8_t>>(data)) {
    std::vector<uint8_t> buffer = GetValue<std::vector<uint8_t>>(data);
    data_channel->Send(buffer.data(), static_cast<uint32_t>(buffer.size()),
                       true);
  } else {
    std::string str = GetValue<std::string>(data);
    data_channel->Send(reinterpret_cast<const uint8_t*>(str.c_str()),
                       static_cast<uint32_t>(str.length()), false);
  }
  result->Success();
}

void FlutterDataChannel::DataChannelGetBufferedAmount(RTCDataChannel* data_channel,
                             std::unique_ptr<MethodResultProxy> result) {
  EncodableMap params;
  params[EncodableValue("bufferedAmount")] = EncodableValue((int64_t)data_channel->buffered_amount());
  result->Success(EncodableValue(params));
}

void FlutterDataChannel::DataChannelClose(
    RTCDataChannel* data_channel,
    const std::string& data_channel_uuid,
    std::unique_ptr<MethodResultProxy> result) {
  data_channel->Close();
  auto it = base_->data_channel_observers_.find(data_channel_uuid);
  if (it != base_->data_channel_observers_.end())
    base_->data_channel_observers_.erase(it);
  result->Success();
}

RTCDataChannel* FlutterDataChannel::DataChannelForId(const std::string& uuid) {
  auto it = base_->data_channel_observers_.find(uuid);

  if (it != base_->data_channel_observers_.end()) {
    FlutterRTCDataChannelObserver* observer = it->second.get();
    scoped_refptr<RTCDataChannel> data_channel = observer->data_channel();
    return data_channel.get();
  }
  return nullptr;
}

static const char* DataStateString(RTCDataChannelState state) {
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
  EncodableMap params;
  params[EncodableValue("event")] = EncodableValue("dataChannelStateChanged");
  params[EncodableValue("id")] = EncodableValue(data_channel_->id());
  params[EncodableValue("state")] = EncodableValue(DataStateString(state));
  auto data = EncodableValue(params);
  event_channel_->Success(data);
}

void FlutterRTCDataChannelObserver::OnMessage(const char* buffer,
                                              int length,
                                              bool binary) {
  EncodableMap params;
  params[EncodableValue("event")] = EncodableValue("dataChannelReceiveMessage");

  params[EncodableValue("id")] = EncodableValue(data_channel_->id());
  params[EncodableValue("type")] = EncodableValue(binary ? "binary" : "text");
  std::string str(buffer, length);
  params[EncodableValue("data")] =
      binary ? EncodableValue(std::vector<uint8_t>(str.begin(), str.end()))
             : EncodableValue(str);

  auto data = EncodableValue(params);
  event_channel_->Success(data);
}
}  // namespace flutter_webrtc_plugin
