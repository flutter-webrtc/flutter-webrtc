#if defined(__linux__) && defined(HAVE_LIBPULSE)

#include "pulse_device_watcher.h"

#include <pulse/timeval.h>

#include <iostream>
#include <utility>

namespace flutter_webrtc_plugin {

namespace {

// A physical audio device can add both a sink and a source. Wait for the
// short burst of PulseAudio events to finish so Dart enumerates the final list
// only once.
constexpr pa_usec_t kDeviceChangeDebounceUsec = 250 * PA_USEC_PER_MSEC;

bool IsEndpointSetChange(pa_subscription_event_type_t event_type) {
  const auto facility = static_cast<pa_subscription_event_type_t>(
      event_type & PA_SUBSCRIPTION_EVENT_FACILITY_MASK);
  const auto operation = static_cast<pa_subscription_event_type_t>(
      event_type & PA_SUBSCRIPTION_EVENT_TYPE_MASK);

  const bool endpoint_added_or_removed =
      (facility == PA_SUBSCRIPTION_EVENT_SINK ||
       facility == PA_SUBSCRIPTION_EVENT_SOURCE) &&
      (operation == PA_SUBSCRIPTION_EVENT_NEW ||
       operation == PA_SUBSCRIPTION_EVENT_REMOVE);
  const bool default_endpoint_changed =
      facility == PA_SUBSCRIPTION_EVENT_SERVER &&
      operation == PA_SUBSCRIPTION_EVENT_CHANGE;
  return endpoint_added_or_removed || default_endpoint_changed;
}

}  // namespace

PulseDeviceWatcher::PulseDeviceWatcher(std::function<void()> on_device_change)
    : on_device_change_(std::move(on_device_change)) {}

PulseDeviceWatcher::~PulseDeviceWatcher() {
  Stop();
}

bool PulseDeviceWatcher::Start() {
  if (mainloop_) {
    return true;
  }

  mainloop_ = pa_threaded_mainloop_new();
  if (!mainloop_) {
    std::cerr << "[PulseDeviceWatcher] Could not create main loop.\n";
    return false;
  }

  mainloop_api_ = pa_threaded_mainloop_get_api(mainloop_);
  context_ = pa_context_new(mainloop_api_, "flutter_webrtc_device_watcher");
  if (!context_) {
    std::cerr << "[PulseDeviceWatcher] Could not create context.\n";
    Stop();
    return false;
  }

  pa_context_set_state_callback(context_, ContextStateCallback, this);
  if (pa_threaded_mainloop_start(mainloop_) < 0) {
    std::cerr << "[PulseDeviceWatcher] Could not start main loop.\n";
    Stop();
    return false;
  }
  mainloop_started_ = true;

  pa_threaded_mainloop_lock(mainloop_);
  const int connect_result =
      pa_context_connect(context_, nullptr, PA_CONTEXT_NOFLAGS, nullptr);
  pa_threaded_mainloop_unlock(mainloop_);
  if (connect_result < 0) {
    std::cerr << "[PulseDeviceWatcher] Could not connect to PulseAudio.\n";
    Stop();
    return false;
  }

  return true;
}

void PulseDeviceWatcher::Stop() {
  if (!mainloop_) {
    return;
  }

  if (mainloop_started_) {
    pa_threaded_mainloop_lock(mainloop_);
  }
  if (debounce_event_) {
    mainloop_api_->time_free(debounce_event_);
    debounce_event_ = nullptr;
  }
  if (context_) {
    pa_context_set_subscribe_callback(context_, nullptr, nullptr);
    pa_context_set_state_callback(context_, nullptr, nullptr);
    pa_context_disconnect(context_);
    pa_context_unref(context_);
    context_ = nullptr;
  }
  if (mainloop_started_) {
    pa_threaded_mainloop_unlock(mainloop_);
    pa_threaded_mainloop_stop(mainloop_);
  }

  pa_threaded_mainloop_free(mainloop_);
  mainloop_ = nullptr;
  mainloop_api_ = nullptr;
  mainloop_started_ = false;
  subscribed_ = false;
}

void PulseDeviceWatcher::ContextStateCallback(pa_context* context,
                                              void* userdata) {
  static_cast<PulseDeviceWatcher*>(userdata)->HandleContextState(context);
}

void PulseDeviceWatcher::SubscribeCallback(
    pa_context* /*context*/,
    pa_subscription_event_type_t event_type,
    uint32_t /*index*/,
    void* userdata) {
  static_cast<PulseDeviceWatcher*>(userdata)->HandleSubscriptionEvent(
      event_type);
}

void PulseDeviceWatcher::SubscribeSuccessCallback(pa_context* /*context*/,
                                                  int success,
                                                  void* /*userdata*/) {
  if (!success) {
    std::cerr << "[PulseDeviceWatcher] Device subscription failed.\n";
  }
}

void PulseDeviceWatcher::DebounceCallback(pa_mainloop_api* api,
                                          pa_time_event* event,
                                          const timeval* /*when*/,
                                          void* userdata) {
  auto* watcher = static_cast<PulseDeviceWatcher*>(userdata);
  api->time_free(event);
  watcher->debounce_event_ = nullptr;
  watcher->Notify();
}

void PulseDeviceWatcher::HandleContextState(pa_context* context) {
  if (pa_context_get_state(context) != PA_CONTEXT_READY || subscribed_) {
    return;
  }

  subscribed_ = true;
  pa_context_set_subscribe_callback(context, SubscribeCallback, this);
  constexpr pa_subscription_mask_t kDeviceMask =
      static_cast<pa_subscription_mask_t>(PA_SUBSCRIPTION_MASK_SINK |
                                          PA_SUBSCRIPTION_MASK_SOURCE |
                                          PA_SUBSCRIPTION_MASK_SERVER);
  pa_operation* operation = pa_context_subscribe(
      context, kDeviceMask, SubscribeSuccessCallback, this);
  if (!operation) {
    subscribed_ = false;
    std::cerr << "[PulseDeviceWatcher] Could not start device subscription.\n";
    return;
  }
  pa_operation_unref(operation);
}

void PulseDeviceWatcher::HandleSubscriptionEvent(
    pa_subscription_event_type_t event_type) {
  if (IsEndpointSetChange(event_type)) {
    ScheduleNotification();
  }
}

void PulseDeviceWatcher::ScheduleNotification() {
  timeval deadline;
  pa_gettimeofday(&deadline);
  pa_timeval_add(&deadline, kDeviceChangeDebounceUsec);

  if (debounce_event_) {
    mainloop_api_->time_restart(debounce_event_, &deadline);
  } else {
    debounce_event_ = mainloop_api_->time_new(mainloop_api_, &deadline,
                                              DebounceCallback, this);
  }
}

void PulseDeviceWatcher::Notify() {
  if (on_device_change_) {
    on_device_change_();
  }
}

}  // namespace flutter_webrtc_plugin

#endif  // __linux__ && HAVE_LIBPULSE
