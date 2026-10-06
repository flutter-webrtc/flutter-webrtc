#ifndef FLUTTER_SCRREN_CAPTURE_HXX
#define FLUTTER_SCRREN_CAPTURE_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

#include <condition_variable>
#include <deque>
#include <functional>
#include <memory>
#include <mutex>
#include <thread>
#include <vector>

#include "loopback_capturer.h"
#include "rtc_audio_source.h"
#include "rtc_audio_track.h"
#include "rtc_desktop_capturer.h"
#include "rtc_desktop_media_list.h"

namespace flutter_webrtc_plugin {

class FlutterScreenCapture : public MediaListObserver,
                             public DesktopCapturerObserver {
 public:
  FlutterScreenCapture(FlutterWebRTCBase* base);
  virtual ~FlutterScreenCapture();

  void GetDisplayMedia(const EncodableMap& constraints,
                       std::unique_ptr<MethodResultProxy> result);

  void GetDesktopSources(const EncodableList& types,
                         std::unique_ptr<MethodResultProxy> result);

  void UpdateDesktopSources(const EncodableList& types,
                            std::unique_ptr<MethodResultProxy> result);

  void GetDesktopSourceThumbnail(std::string source_id,
                                 int width,
                                 int height,
                                 std::unique_ptr<MethodResultProxy> result);

 protected:
  void OnMediaSourceAdded(scoped_refptr<MediaSource> source) override;

  void OnMediaSourceRemoved(scoped_refptr<MediaSource> source) override;

  void OnMediaSourceNameChanged(scoped_refptr<MediaSource> source) override;

  void OnMediaSourceThumbnailChanged(
      scoped_refptr<MediaSource> source) override;

  void OnStart(scoped_refptr<RTCDesktopCapturer> capturer) override;

  void OnPaused(scoped_refptr<RTCDesktopCapturer> capturer) override;

  void OnStop(scoped_refptr<RTCDesktopCapturer> capturer) override;

  void OnError(scoped_refptr<RTCDesktopCapturer> capturer) override;

 private:
  bool BuildDesktopSourcesList(const EncodableList& types, bool force_reload);

  // Copies of `sources_` and a lookup in it, taken under `sources_mutex_`.
  std::vector<scoped_refptr<MediaSource>> SourcesSnapshot();
  scoped_refptr<MediaSource> FindSource(const std::string& source_id);

  // Runs `task` on `worker_thread_`, in order with the other queued tasks.
  void PostToWorker(std::function<void()> task);
  void WorkerLoop();

  // Answers a method call on the platform thread. The Windows plugin hands
  // over results without a task runner, so a result must not be completed
  // from the worker thread directly.
  void PostResult(std::function<void()> reply);

 private:
  FlutterWebRTCBase* base_;

  // Building the source list blocks the calling thread until libwebrtc has
  // enumerated every window. On Windows that enumeration skips windows whose
  // message loop does not answer within 50 ms, and reads window titles with
  // GetWindowText, which waits on the owning thread. If the calling thread
  // were the platform thread, which runs the message loop of the host app's
  // own windows, those windows would always be skipped (or the call would
  // deadlock). So getDesktopSources, updateDesktopSources and
  // getDesktopSourceThumbnail run on this worker thread instead, one at a
  // time, and the platform thread never waits on it.
  std::thread worker_thread_;
  std::mutex worker_mutex_;
  std::condition_variable worker_cv_;
  std::deque<std::function<void()>> worker_tasks_;
  bool worker_stopping_ = false;

  // Serializes BuildDesktopSourcesList, which owns `medialist_` and the
  // libwebrtc media lists. Never taken on the platform thread on Windows.
  std::mutex build_mutex_;
  std::map<DesktopType, scoped_refptr<RTCDesktopMediaList>> medialist_;

  // The last built source list. Held only briefly, never while enumerating,
  // so the platform thread can take it without waiting on the enumeration.
  std::mutex sources_mutex_;
  std::vector<scoped_refptr<MediaSource>> sources_;

  // Capturers started by GetDisplayMedia, kept so the last reference to each
  // one is dropped on the worker thread. Dropping it joins the capturer's
  // thread, which may be inside PrintWindow on a window owned by this
  // process. If that join ran on the platform thread, or on a thread the
  // platform thread is blocked on, it could deadlock.
  std::mutex capturers_mutex_;
  std::vector<scoped_refptr<RTCDesktopCapturer>> active_capturers_;

  // Loopback audio capturer active during a screen-share session.
  // Null when not capturing or on platforms without loopback support.
  std::unique_ptr<LoopbackCapturer> loopback_capturer_;
  // The custom audio source fed by the loopback capturer.
  scoped_refptr<RTCAudioSource> loopback_audio_source_;
};

}  // namespace flutter_webrtc_plugin

#endif  // FLUTTER_SCRREN_CAPTURE_HXX