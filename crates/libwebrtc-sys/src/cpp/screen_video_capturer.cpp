// This is a slightly tweaked version of
// https://github.com/shiguredo/momo/blob/b81b51da8e2b823090d6a7f966fc517e047237e6/src/rtc/screen_video_capturer.cpp
//
// Copyright 2015-2021, tnoho (Original Author)
// Copyright 2018-2021, Shiguredo Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "screen_video_capturer.h"
#include "api/video/i420_buffer.h"
#include "modules/desktop_capture/cropped_desktop_frame.h"
#include "modules/desktop_capture/desktop_and_cursor_composer.h"
#include "rtc_base/logging.h"
#include "system_wrappers/include/sleep.h"
#include "third_party/libyuv/include/libyuv.h"

// Maximum allow CPU consumption for the frame capturing thread.
const int maxCpuConsumptionPercentage = 50;

namespace {

// Creates a default `webrtc::DesktopCaptureOptions` and calls
// `webrtc::DesktopCaptureOptions::set_allow_directx_capturer` on it.
webrtc::DesktopCaptureOptions CreateDesktopCaptureOptions() {
  webrtc::DesktopCaptureOptions options =
      webrtc::DesktopCaptureOptions::CreateDefault();

  #ifdef WEBRTC_MAC
    options.set_allow_iosurface(true);
  #endif
  #ifdef WEBRTC_WIN
    options.set_allow_directx_capturer(true);
  #endif

  return options;
}

}

// Fills the provided `SourceList` with all available screens that can be
// used by this `ScreenVideoCapturer`.
bool ScreenVideoCapturer::GetSourceList(
    webrtc::DesktopCapturer::SourceList* sources) {
  std::unique_ptr<webrtc::DesktopCapturer> screen_capturer(
      webrtc::DesktopCapturer::CreateScreenCapturer(
      CreateDesktopCaptureOptions()));

  return screen_capturer->GetSourceList(sources);
}

// Creates a new `ScreenVideoCapturer` with the specified constraints.
ScreenVideoCapturer::ScreenVideoCapturer(
    webrtc::DesktopCapturer::SourceId source_id,
    size_t max_width,
    size_t max_height,
    size_t target_fps)
    : max_width_(max_width),
      max_height_(max_height),
      requested_frame_duration_((int) (1000.0f / target_fps)),
      quit_(false) {
  if (capture_thread_.empty()) {
    capture_thread_ = rtc::PlatformThread::SpawnJoinable(
        [this, source_id] {
          auto options = CreateDesktopCaptureOptions();
          std::unique_ptr<webrtc::DesktopCapturer> screen_capturer(
              webrtc::DesktopCapturer::CreateScreenCapturer(options));
          if (screen_capturer && screen_capturer->SelectSource(source_id)) {
            capturer_.reset(new webrtc::DesktopAndCursorComposer(
                std::move(screen_capturer), options));
          }

          capturer_->Start(this);
          while (CaptureProcess()) {}
        },
        "ScreenCaptureThread",
        rtc::ThreadAttributes().SetPriority(rtc::ThreadPriority::kHigh));
  }
}

ScreenVideoCapturer::~ScreenVideoCapturer() {
  if (!capture_thread_.empty()) {
    quit_ = true;
    capture_thread_.Finalize();
  }
  output_frame_.reset();
  previous_frame_size_.set(0, 0);
  capturer_.reset();
}

// Captures a `webrtc::DesktopFrame`.
bool ScreenVideoCapturer::CaptureProcess() {
  if (quit_) {
    return false;
  }

  #ifdef WEBRTC_MAC
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
  #endif

  int64_t started_time = rtc::TimeMillis();
  capturer_->CaptureFrame();
  int last_capture_duration = (int) (rtc::TimeMillis() - started_time);
  int capture_period =
      std::max((last_capture_duration * 100) / maxCpuConsumptionPercentage,
               requested_frame_duration_);
  int delta_time = capture_period - last_capture_duration;
  if (delta_time > 0) {
    webrtc::SleepMs(delta_time);
  }
  return true;
}

// Propagates a `VideoFrame` to the `AdaptedVideoTrackSource::OnFrame()`.
void ScreenVideoCapturer::OnFrame(const webrtc::VideoFrame& frame) {
  AdaptedVideoTrackSource::OnFrame(frame);
}

// Callback for `webrtc::DesktopCapturer::CaptureFrame`.
//
// Converts a `DesktopFrame` to a `VideoFrame` that is forwarded to
// `ScreenVideoCapturer::OnFrame`.
void ScreenVideoCapturer::OnCaptureResult(
    webrtc::DesktopCapturer::Result result,
    std::unique_ptr<webrtc::DesktopFrame> frame) {
  bool success = result == webrtc::DesktopCapturer::Result::SUCCESS;

  if (!success) {

    RTC_LOG(LS_ERROR) << "The desktop capturer has failed.";
    return;
  }

  if (!previous_frame_size_.equals(frame->size())) {
    output_frame_.reset();
    capture_width_ = frame->size().width();
    capture_height_ = frame->size().height();
    if (capture_width_ > max_width_) {
      capture_width_ = max_width_;
      capture_height_ =
          frame->size().height() * max_width_ / frame->size().width();
    }
    if (capture_height_ > max_height_) {
      capture_width_ =
          frame->size().width() * max_height_ / frame->size().height();
      capture_height_ = max_height_;
    }

    previous_frame_size_ = frame->size();
  }

  webrtc::DesktopSize output_size(capture_width_ & ~1, capture_height_ & ~1);
  if (output_size.is_empty()) {
    output_size.set(2, 2);
  }

  rtc::scoped_refptr<webrtc::I420Buffer> dst_buffer(
      webrtc::I420Buffer::Create(output_size.width(), output_size.height()));
  dst_buffer->InitializeData();

  if (frame->size().width() <= 2 || frame->size().height() <= 1) {
  } else {
    const int32_t frame_width = frame->size().width();
    const int32_t frame_height = frame->size().height();

    if (frame_width & 1 || frame_height & 1) {
      frame = webrtc::CreateCroppedDesktopFrame(
          std::move(frame),
          webrtc::DesktopRect::MakeWH(frame_width & ~1, frame_height & ~1));
    }

    const uint8_t* output_data = nullptr;
    int output_stride = 0;
    if (!frame->size().equals(output_size)) {
      if (!output_frame_) {
        output_frame_.reset(new webrtc::BasicDesktopFrame(output_size));
      }
      webrtc::DesktopRect output_rect;
      if ((float) output_size.width() / (float) output_size.height() <
          (float) frame->size().width() / (float) frame->size().height()) {
        int32_t output_height = frame->size().height() * output_size.width() /
            frame->size().width();
        if (output_height > output_size.height())
          output_height = output_size.height();
        const int32_t margin_y = (output_size.height() - output_height) / 2;
        output_rect = webrtc::DesktopRect::MakeLTRB(
            0, margin_y, output_size.width(), output_height + margin_y);
      } else {
        int32_t output_width = frame->size().width() * output_size.height() /
            frame->size().height();
        if (output_width > output_size.width())
          output_width = output_size.width();
        const int32_t margin_x = (output_size.width() - output_width) / 2;
        output_rect = webrtc::DesktopRect::MakeLTRB(
            margin_x, 0, output_width + margin_x, output_size.height());
      }
      uint8_t* output_rect_data =
          output_frame_->GetFrameDataAtPos(output_rect.top_left());
      libyuv::ARGBScale(frame->data(), frame->stride(), frame->size().width(),
                        frame->size().height(), output_rect_data,
                        output_frame_->stride(), output_rect.width(),
                        output_rect.height(), libyuv::kFilterBox);
      output_data = output_frame_->data();
      output_stride = output_frame_->stride();
    } else {
      output_data = frame->data();
      output_stride = frame->stride();
    }

    if (libyuv::ARGBToI420(
        output_data, output_stride, dst_buffer.get()->MutableDataY(),
        dst_buffer.get()->StrideY(), dst_buffer.get()->MutableDataU(),
        dst_buffer.get()->StrideU(), dst_buffer.get()->MutableDataV(),
        dst_buffer.get()->StrideV(), output_size.width(),
        output_size.height()) < 0) {
      RTC_LOG(LS_ERROR) << "ConvertToI420 Failed";
      return;
    }
  }

  webrtc::VideoFrame captureFrame = webrtc::VideoFrame::Builder()
      .set_video_frame_buffer(dst_buffer)
      .set_timestamp_rtp(0)
      .set_timestamp_ms(rtc::TimeMillis())
      .set_rotation(webrtc::kVideoRotation_0)
      .build();

  OnFrame(captureFrame);
}

// Always returns `true`.
bool ScreenVideoCapturer::is_screencast() const {
  return true;
}

// Always returns `false`.
absl::optional<bool> ScreenVideoCapturer::needs_denoising() const {
  return false;
}

// Returns `SourceState::kLive`.
webrtc::MediaSourceInterface::SourceState ScreenVideoCapturer::state() const {
  return SourceState::kLive;
}

// Always returns `false`.
bool ScreenVideoCapturer::remote() const {
  return false;
}
