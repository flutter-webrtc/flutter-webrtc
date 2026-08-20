#include "flutter_common.h"
#include "task_runner.h"

#include <memory>

#if defined(_WIN32)
#include <flutter_messenger.h>
#endif

// See SetEventChannelHostMessenger() in flutter_common.h. Only ever written
// from plugin registration, which happens on the platform thread before any
// event channel exists.
static void* g_host_messenger = nullptr;

void SetEventChannelHostMessenger(void* messenger_ref) {
  g_host_messenger = messenger_ref;
}

class MethodCallProxyImpl : public MethodCallProxy {
 public:
  explicit MethodCallProxyImpl(const MethodCall& method_call)
      : method_call_(method_call) {}

  ~MethodCallProxyImpl() {}

  // The name of the method being called.

  const std::string& method_name() const override {
    return method_call_.method_name();
  }

  // The arguments to the method call, or NULL if there are none.
  const EncodableValue* arguments() const override {
    return method_call_.arguments();
  }

 private:
  const MethodCall& method_call_;
};

std::unique_ptr<MethodCallProxy> MethodCallProxy::Create(
    const MethodCall& call) {
  return std::make_unique<MethodCallProxyImpl>(call);
}

class MethodResultProxyImpl : public MethodResultProxy {
 public:
  MethodResultProxyImpl(std::unique_ptr<MethodResult> method_result,
                        TaskRunner* task_runner)
      : method_result_(std::move(method_result)), task_runner_(task_runner) {}
  ~MethodResultProxyImpl() {}

  void Success() override {
    if (!method_result_)
      return;
    if (task_runner_) {
      std::shared_ptr<MethodResult> result(std::move(method_result_));
      task_runner_->EnqueueTask([result]() { result->Success(); });
    } else {
      method_result_->Success();
    }
  }

  void Success(const EncodableValue& val) override {
    if (!method_result_)
      return;
    if (task_runner_) {
      std::shared_ptr<MethodResult> result(std::move(method_result_));
      task_runner_->EnqueueTask([result, val]() { result->Success(val); });
    } else {
      method_result_->Success(val);
    }
  }

  void Error(const std::string& error_code,
             const std::string& error_message,
             const EncodableValue& error_details) override {
    if (!method_result_)
      return;
    if (task_runner_) {
      std::shared_ptr<MethodResult> result(std::move(method_result_));
      task_runner_->EnqueueTask(
          [result, error_code, error_message, error_details]() {
            result->Error(error_code, error_message, error_details);
          });
    } else {
      method_result_->Error(error_code, error_message, error_details);
    }
  }

  void Error(const std::string& error_code,
             const std::string& error_message = "") override {
    if (!method_result_)
      return;
    if (task_runner_) {
      std::shared_ptr<MethodResult> result(std::move(method_result_));
      task_runner_->EnqueueTask([result, error_code, error_message]() {
        result->Error(error_code, error_message);
      });
    } else {
      method_result_->Error(error_code, error_message);
    }
  }

  void NotImplemented() override {
    if (!method_result_)
      return;
    if (task_runner_) {
      std::shared_ptr<MethodResult> result(std::move(method_result_));
      task_runner_->EnqueueTask([result]() { result->NotImplemented(); });
    } else {
      method_result_->NotImplemented();
    }
  }

 private:
  std::unique_ptr<MethodResult> method_result_;
  TaskRunner* task_runner_;
};

std::unique_ptr<MethodResultProxy> MethodResultProxy::Create(
    std::unique_ptr<MethodResult> method_result,
    TaskRunner* task_runner) {
  return std::make_unique<MethodResultProxyImpl>(std::move(method_result),
                                                 task_runner);
}

class EventChannelProxyImpl : public EventChannelProxy {
  public:
   EventChannelProxyImpl(BinaryMessenger* messenger,
                         TaskRunner* task_runner,
                         const std::string& channelName)
       : channel_(std::make_unique<EventChannel>(
             messenger,
             channelName,
             &flutter::StandardMethodCodec::GetInstance())),
             task_runner_(task_runner) {
#if defined(_WIN32)
     // Each proxy keeps its own reference so that the handle outlives the
     // engine it belongs to and the Release() below stays balanced.
     if (g_host_messenger) {
       host_messenger_ = FlutterDesktopMessengerAddRef(
           static_cast<FlutterDesktopMessengerRef>(g_host_messenger));
     }
#endif
     auto handler = std::make_unique<
         flutter::StreamHandlerFunctions<EncodableValue>>(
         [&](const EncodableValue* arguments,
             std::unique_ptr<flutter::EventSink<EncodableValue>>&& events)
             -> std::unique_ptr<flutter::StreamHandlerError<EncodableValue>> {
           sink_ = std::move(events);
           std::weak_ptr<EventSink> weak_sink = sink_;
           for (auto& event : event_queue_) {
            PostEvent(event);
           }
           event_queue_.clear();
           on_listen_called_ = true;
           return nullptr;
         },
         [&](const EncodableValue* arguments)
             -> std::unique_ptr<flutter::StreamHandlerError<EncodableValue>> {
           on_listen_called_ = false;
           return nullptr;
         });
 
     channel_->SetStreamHandler(std::move(handler));
   }

   virtual ~EventChannelProxyImpl() {
     // Unregister the stream handler only while the messenger still
     // references a running engine. This destructor also runs from
     // PluginRegistrar::ClearPlugins() during FlutterWindowsEngine teardown,
     // after the engine has detached itself from the FlutterDesktopMessenger;
     // an unconditional SetStreamHandler(nullptr) then reaches
     // FlutterDesktopMessengerSetCallback, which dereferences the detached
     // engine (its FML_DCHECK is compiled out in release builds): access
     // violation on the platform thread. The registration dies with the
     // engine anyway.
#if defined(_WIN32)
     if (host_messenger_) {
       FlutterDesktopMessengerLock(host_messenger_);
       if (FlutterDesktopMessengerIsAvailable(host_messenger_)) {
         channel_->SetStreamHandler(nullptr);
       }
       FlutterDesktopMessengerUnlock(host_messenger_);
       FlutterDesktopMessengerRelease(host_messenger_);
       return;
     }
#endif
     channel_->SetStreamHandler(nullptr);
   }

   void Success(const EncodableValue& event, bool cache_event = true) override {
     if (on_listen_called_) {
       PostEvent(event);
     } else {
       if (cache_event) {
         event_queue_.push_back(event);
       }
     }
   }

   void PostEvent(const EncodableValue& event) {
     if(task_runner_) {
      std::weak_ptr<EventSink> weak_sink = sink_;
       task_runner_->EnqueueTask([weak_sink, event]() {
        auto sink = weak_sink.lock();
        if (sink) {
          sink->Success(event);
        }
      });
     } else {
      sink_->Success(event);
     }
   }
 
  private:
   std::unique_ptr<EventChannel> channel_;
   std::shared_ptr<flutter::EventSink<flutter::EncodableValue>> sink_;
   std::list<EncodableValue> event_queue_;
   bool on_listen_called_ = false;
   TaskRunner* task_runner_;
#if defined(_WIN32)
   FlutterDesktopMessengerRef host_messenger_ = nullptr;
#endif
 };

std::unique_ptr<EventChannelProxy> EventChannelProxy::Create(
    BinaryMessenger* messenger,
    TaskRunner* task_runner,
    const std::string& channelName) {
  return std::make_unique<EventChannelProxyImpl>(messenger, task_runner, channelName);
}