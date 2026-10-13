#ifndef PULSE_DEVICE_WATCHER_H_
#define PULSE_DEVICE_WATCHER_H_

#if defined(__linux__) && defined(HAVE_LIBPULSE)

#include <cstdint>
#include <functional>

#include <pulse/context.h>
#include <pulse/mainloop-api.h>
#include <pulse/subscribe.h>
#include <pulse/thread-mainloop.h>

namespace flutter_webrtc_plugin {

// Watches PulseAudio (and PipeWire's PulseAudio compatibility server) for
// audio endpoint additions, removals, and default-device changes.
class PulseDeviceWatcher {
 public:
  explicit PulseDeviceWatcher(std::function<void()> on_device_change);
  ~PulseDeviceWatcher();

  PulseDeviceWatcher(const PulseDeviceWatcher&) = delete;
  PulseDeviceWatcher& operator=(const PulseDeviceWatcher&) = delete;

  // Starts the asynchronous monitor. Returns false only when the PulseAudio
  // client objects cannot be created or the connection cannot be initiated.
  bool Start();
  void Stop();

 private:
  static void ContextStateCallback(pa_context* context, void* userdata);
  static void SubscribeCallback(pa_context* context,
                                pa_subscription_event_type_t event_type,
                                uint32_t index,
                                void* userdata);
  static void SubscribeSuccessCallback(pa_context* context,
                                       int success,
                                       void* userdata);
  static void DebounceCallback(pa_mainloop_api* api,
                               pa_time_event* event,
                               const timeval* when,
                               void* userdata);

  void HandleContextState(pa_context* context);
  void HandleSubscriptionEvent(pa_subscription_event_type_t event_type);
  void ScheduleNotification();
  void Notify();

  std::function<void()> on_device_change_;
  pa_threaded_mainloop* mainloop_ = nullptr;
  pa_mainloop_api* mainloop_api_ = nullptr;
  pa_context* context_ = nullptr;
  pa_time_event* debounce_event_ = nullptr;
  bool mainloop_started_ = false;
  bool subscribed_ = false;
};

}  // namespace flutter_webrtc_plugin

#endif  // __linux__ && HAVE_LIBPULSE
#endif  // PULSE_DEVICE_WATCHER_H_
