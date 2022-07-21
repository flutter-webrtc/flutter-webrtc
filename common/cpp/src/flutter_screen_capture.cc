#include "flutter_screen_capture.h"

#include <windows.h>

#include <atlimage.h>

#include <fstream>

namespace flutter_webrtc_plugin {

FlutterScreenCapture::FlutterScreenCapture(FlutterWebRTCBase* base)
    : base_(base) {
  std::string event_channel = "FlutterWebRTC/desktopSourcesEvent";
  event_channel_.reset(new EventChannel<EncodableValue>(
      base_->messenger_, event_channel, &StandardMethodCodec::GetInstance()));

  auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
      [&](const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        event_sink_ = std::move(events);
        return nullptr;
      },
      [&](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        event_sink_ = nullptr;
        return nullptr;
      });

  event_channel_->SetStreamHandler(std::move(handler));
}

bool FlutterScreenCapture::BuildDesktopSourcesList(const EncodableList& types, bool force_reload) {
      size_t size = types.size();
  sources_.clear();
  for (size_t i = 0; i < size; i++) {
    std::string type_str = GetValue<std::string>(types[i]);
    DesktopType desktop_type = DesktopType::kScreen;
    if (type_str == "screen") {
      desktop_type = DesktopType::kScreen;
    } else if (type_str == "window") {
      desktop_type = DesktopType::kWindow;
    } else {
      //std::cout << "Unknown type " << type_str << std::endl;
      return false;
    }
    scoped_refptr<RTCDesktopMediaList> source_list;
    auto it = medialist_.find(desktop_type);
    if (it != medialist_.end()) {
      source_list = (*it).second;
    } else {
      source_list = base_->desktop_device_->GetDesktopMediaList(desktop_type);
      source_list->RegisterMediaListObserver(this);
      medialist_[desktop_type] = source_list;
    }
    source_list->UpdateSourceList(force_reload);
    int count = source_list->GetSourceCount();
    for (int j = 0; j < count; j++) {
      sources_.push_back(source_list->GetSource(j));
    }
  }
  return true;
}

void FlutterScreenCapture::GetDesktopSources(
    const EncodableList& types,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  if(!BuildDesktopSourcesList(types, true)) {
    result->Error("Failed to get desktop sources");
    return;
  }

  EncodableList sources;
  for (auto source : sources_) {
    EncodableMap info;
    info[EncodableValue("id")] = EncodableValue(source->id().std_string());
    info[EncodableValue("name")] = EncodableValue(source->name().std_string());
    info[EncodableValue("type")] =
        EncodableValue(source->type() == kWindow ? "window" : "screen");
    info[EncodableValue("thumbnail")] =
        EncodableValue(source->thumbnail().std_vector());
    // TODO "thumbnailSize"
    info[EncodableValue("thumbnailSize")] = EncodableMap{
        {EncodableValue("width"), EncodableValue(0)},
        {EncodableValue("height"), EncodableValue(0)},
    };
    sources.push_back(EncodableValue(info));
  }

  std::cout << " sources: " << sources.size() << std::endl;
  result->Success(
      EncodableValue(EncodableMap{{EncodableValue("sources"), sources}}));
}

void FlutterScreenCapture::UpdateDesktopSources(
    const EncodableList& types,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  if(!BuildDesktopSourcesList(types, false)) {
    result->Error("Failed to update desktop sources");
    return;
  }
  result->Success(
      EncodableValue(EncodableMap{{EncodableValue("result"), true}}));
}

void FlutterScreenCapture::OnMediaSourceAdded(
    scoped_refptr<MediaSource> source) {
  std::cout << " OnMediaSourceAdded: " << source->id().std_string()
            << std::endl;

  if (event_sink_) {
    EncodableMap info;
    info[EncodableValue("event")] = "desktopSourceAdded";
    info[EncodableValue("id")] = EncodableValue(source->id().std_string());
    info[EncodableValue("name")] = EncodableValue(source->name().std_string());
    info[EncodableValue("type")] =
        EncodableValue(source->type() == kWindow ? "window" : "screen");
    info[EncodableValue("thumbnail")] =
        EncodableValue(source->thumbnail().std_vector());
    // TODO "thumbnailSize"
    info[EncodableValue("thumbnailSize")] = EncodableMap{
        {EncodableValue("width"), EncodableValue(0)},
        {EncodableValue("height"), EncodableValue(0)},
    };
    event_sink_->Success(EncodableValue(info));
  }
}

void FlutterScreenCapture::OnMediaSourceRemoved(
    scoped_refptr<MediaSource> source) {
  std::cout << " OnMediaSourceRemoved: " << source->id().std_string()
            << std::endl;
  if (event_sink_) {
    EncodableMap info;
    info[EncodableValue("event")] = "desktopSourceRemoved";
    info[EncodableValue("id")] = EncodableValue(source->id().std_string());
    event_sink_->Success(EncodableValue(info));
  }
}

void FlutterScreenCapture::OnMediaSourceNameChanged(
    scoped_refptr<MediaSource> source) {
  std::cout << " OnMediaSourceNameChanged: " << source->id().std_string()
            << std::endl;
  if (event_sink_) {
    EncodableMap info;
    info[EncodableValue("event")] = "desktopSourceNameChanged";
    info[EncodableValue("id")] = EncodableValue(source->id().std_string());
    info[EncodableValue("name")] = EncodableValue(source->name().std_string());
    event_sink_->Success(EncodableValue(info));
  }
}

void FlutterScreenCapture::OnMediaSourceThumbnailChanged(
    scoped_refptr<MediaSource> source) {
  std::cout << " OnMediaSourceThumbnailChanged: " << source->id().std_string()
            << std::endl;
  if (event_sink_) {
    EncodableMap info;
    info[EncodableValue("event")] = "desktopSourceThumbnailChanged";
    info[EncodableValue("id")] = EncodableValue(source->id().std_string());
    info[EncodableValue("thumbnail")] =
        EncodableValue(source->thumbnail().std_vector());
    event_sink_->Success(EncodableValue(info));
  }
}

void FlutterScreenCapture::OnStart(scoped_refptr<RTCDesktopCapturer> capturer) {
}

void FlutterScreenCapture::OnPaused(
    scoped_refptr<RTCDesktopCapturer> capturer) {}

void FlutterScreenCapture::OnStop(scoped_refptr<RTCDesktopCapturer> capturer) {}

void FlutterScreenCapture::OnError(scoped_refptr<RTCDesktopCapturer> capturer) {
}

bool SaveHbitmapToVector(HBITMAP hbitmap, std::vector<BYTE>& buf) {
  if (hbitmap != NULL) {
    IStream* stream = NULL;
    CreateStreamOnHGlobal(0, TRUE, &stream);

    CImage image;
    ULARGE_INTEGER liSize;

    // screenshot to png and save to stream
    image.Attach(hbitmap);
    image.Save(stream, Gdiplus::ImageFormatJPEG);
    IStream_Size(stream, &liSize);
    DWORD len = liSize.LowPart;
    IStream_Reset(stream);
    buf.resize(len);
    IStream_Read(stream, &buf[0], len);
    stream->Release();

    return true;
  }
  return false;
}

void CaptureWindow(uint64_t id,
                   std::unique_ptr<MethodResult<EncodableValue>> result) {
  HWND hwnd = reinterpret_cast<HWND>(id);

  HDC hdcWindow;
  HDC hdcMemDC = NULL;
  HBITMAP hbitmap = NULL;

  // Retrieve the handle to a display device context for the client
  // area of the window.
  // hdcWindow = GetDC(hwnd);
  hdcWindow = GetWindowDC(hwnd);

  // Create a compatible DC, which is used in a BitBlt from the window DC.
  hdcMemDC = CreateCompatibleDC(hdcWindow);

  if (!hdcMemDC) {
    result->Error("Failed", "CreateCompatibleDC has failed");
    return;
  }

  // Get the client area for size calculation.
  RECT rcClient;
  // GetClientRect(hwnd, &rcClient);
  GetWindowRect(hwnd, &rcClient);
  // std::cout << " left,top: " << rcClient.left << ":" << rcClient.top;
  // std::cout << " right,bottom: " << rcClient.right << ":" << rcClient.bottom
  // << std::endl;

  // This is the best stretch mode.
  SetStretchBltMode(hdcWindow, COLORONCOLOR);

  // Create a compatible bitmap from the Window DC.
  hbitmap = CreateCompatibleBitmap(hdcWindow, rcClient.right - rcClient.left,
                                   rcClient.bottom - rcClient.top);

  if (!hbitmap) {
    result->Error("Failed", "CreateCompatibleBitmap Failed");
    return;
  }

  // Select the compatible bitmap into the compatible memory DC.
  SelectObject(hdcMemDC, hbitmap);

  BOOL res = FALSE;
  const UINT flags = PW_RENDERFULLCONTENT;

  res = PrintWindow(hwnd, hdcMemDC, flags);

  if (!res) {
    res = PrintWindow(hwnd, hdcMemDC, 0);
  }

  if (!res) {
    // Bit block transfer into our compatible memory DC.
    if (!BitBlt(hdcMemDC, 0, 0, rcClient.right - rcClient.left,
                rcClient.bottom - rcClient.top, hdcWindow, 0, 0,
                SRCCOPY | CAPTUREBLT)) {
      result->Error("Failed", "BitBlt has failed");
      return;
    }
    // if (!StretchBlt(hdcMemDC, 0, 0, rcClient.right, rcClient.bottom,
    // hdcWindow,
    //                 rcClient.left, rcClient.top, rcClient.right -
    //                 rcClient.left, rcClient.bottom - rcClient.top, SRCCOPY |
    //                 CAPTUREBLT)) {
    //   result->Error("Failed", "StretchBlt has failed");
    //   return;
    // }
  }

  std::vector<BYTE> thumb;
  bool saved = SaveHbitmapToVector(hbitmap, thumb);

  if (saved) {
    result->Success(EncodableValue(thumb));
  } else {
    result->Error("CaptureWindow error", "Error save bitmap");
  }

  DeleteObject(hbitmap);
  DeleteObject(hdcMemDC);
  ReleaseDC(hwnd, hdcWindow);
}

void CaptureScreen(uint64_t id,
                   std::unique_ptr<MethodResult<EncodableValue>> result) {
  HWND hwnd = GetDesktopWindow();

  HDC hdcScreen;
  HDC hdcWindow;
  HDC hdcMemDC = NULL;
  HBITMAP hbitmap = NULL;

  // Retrieve the handle to a display device context for the client
  // area of the window.
  hdcScreen = GetDC(NULL);
  hdcWindow = GetDC(hwnd);

  // Create a compatible DC, which is used in a BitBlt from the window DC.
  hdcMemDC = CreateCompatibleDC(hdcWindow);

  if (!hdcMemDC) {
    result->Error("Failed", "CreateCompatibleDC has failed");
    return;
  }

  // Get the client area for size calculation.
  RECT rcClient;
  GetClientRect(hwnd, &rcClient);

  // This is the best stretch mode.
  SetStretchBltMode(hdcWindow, HALFTONE);

  // The source DC is the entire screen, and the destination DC is the current
  // window (HWND).
  if (!StretchBlt(hdcWindow, 0, 0, rcClient.right, rcClient.bottom, hdcScreen,
                  0, 0, GetSystemMetrics(SM_CXSCREEN),
                  GetSystemMetrics(SM_CYSCREEN), SRCCOPY)) {
    result->Error("Failed", "StretchBlt has failed");
    return;
  }

  // Create a compatible bitmap from the Window DC.
  hbitmap = CreateCompatibleBitmap(hdcWindow, rcClient.right - rcClient.left,
                                   rcClient.bottom - rcClient.top);

  if (!hbitmap) {
    result->Error("Failed", "CreateCompatibleBitmap Failed");
    return;
  }

  // Select the compatible bitmap into the compatible memory DC.
  HGDIOBJ old = SelectObject(hdcMemDC, hbitmap);

  // Bit block transfer into our compatible memory DC.
  if (!BitBlt(hdcMemDC, 0, 0, rcClient.right - rcClient.left,
              rcClient.bottom - rcClient.top, hdcWindow, 0, 0, SRCCOPY)) {
    result->Error("Failed", "BitBlt has failed");
    return;
  }

  std::vector<BYTE> thumb;
  bool saved = SaveHbitmapToVector(hbitmap, thumb);

  if (saved) {
    result->Success(EncodableValue(thumb));
  } else {
    result->Error("CaptureScreen error", "Error save bitmap");
  }

  SelectObject(hdcMemDC, old);

  DeleteObject(hbitmap);
  DeleteObject(hdcMemDC);
  ReleaseDC(NULL, hdcScreen);
  ReleaseDC(hwnd, hdcWindow);
}

void FlutterScreenCapture::GetDesktopSourceThumbnail(
    uint64_t source_id,
    int width,
    int height,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  // std::cout << " source_id: " << source_id << " width: " << width << "
  // height: " << height << std::endl;

  if (source_id == 0) {
    CaptureScreen(source_id, std::move(result));
  } else {
    CaptureWindow(source_id, std::move(result));
  }
}

void FlutterScreenCapture::GetDisplayMedia(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  std::string window_id = "0";
  DesktopType source_type = kScreen;

  const EncodableMap video = findMap(constraints, "video");
  if (video != EncodableMap()) {
    const EncodableMap deviceId = findMap(video, "deviceId");
    if (deviceId != EncodableMap()) {
      window_id = findString(deviceId, "exact");
      if (window_id.empty()) {
        result->Error("Bad Arguments", "Incorrect video->deviceId->exact");
        return;
      }
      if (window_id != "0") {
        source_type = DesktopType::kWindow;
      }
    }
  }
  // std::cout << " window_id: " << window_id  << " source_type: " <<
  // (source_type == SourceType::kWindow ? "window" : "screen") << std::endl;
  CreateCapture(source_type, window_id, constraints, std::move(result));
}

void FlutterScreenCapture::CreateCapture(
    DesktopType type,
    std::string id,
    const EncodableMap& constraints,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  std::string uuid = base_->GenerateUUID();

  scoped_refptr<RTCMediaStream> stream =
      base_->factory_->CreateStream(uuid.c_str());

  EncodableMap params;
  params[EncodableValue("streamId")] = EncodableValue(uuid);

  // AUDIO

  params[EncodableValue("audioTracks")] = EncodableValue(EncodableList());

  // VIDEO

  EncodableMap video_constraints;
  auto it = constraints.find(EncodableValue("video"));
  if (it != constraints.end() && TypeIs<EncodableMap>(it->second)) {
    video_constraints = GetValue<EncodableMap>(it->second);
  }

  scoped_refptr<MediaSource> source;
  for (auto src : sources_) {
    if (src->id().std_string() == id) {
      source = src;
    }
  }

  if (!source.get()) {
    result->Error("Bad Arguments", "source not found!");
    return;
  }

  scoped_refptr<RTCDesktopCapturer> desktop_capturer =
      base_->desktop_device_->CreateDesktopCapturer(source);

  if (!desktop_capturer.get()) {
    result->Error("Bad Arguments", "CreateDesktopCapturer failed!");
    return;
  }

  desktop_capturer->RegisterDesktopCapturerObserver(this);

  const char* video_source_label = "screen_capture_input";

  scoped_refptr<RTCVideoSource> video_source =
      base_->factory_->CreateDesktopSource(
          desktop_capturer, video_source_label,
          base_->ParseMediaConstraints(video_constraints));

  // TODO: RTCVideoSource -> RTCVideoTrack

  scoped_refptr<RTCVideoTrack> track =
      base_->factory_->CreateVideoTrack(video_source, uuid.c_str());

  EncodableList videoTracks;
  EncodableMap info;
  info[EncodableValue("id")] = EncodableValue(track->id().std_string());
  info[EncodableValue("label")] = EncodableValue(track->id().std_string());
  info[EncodableValue("kind")] = EncodableValue(track->kind().std_string());
  info[EncodableValue("enabled")] = EncodableValue(track->enabled());
  videoTracks.push_back(EncodableValue(info));
  params[EncodableValue("videoTracks")] = EncodableValue(videoTracks);

  stream->AddTrack(track);

  base_->local_tracks_[track->id().std_string()] = track;

  base_->local_streams_[uuid] = stream;

  desktop_capturer->Start(30);

  result->Success(EncodableValue(params));
}

}  // namespace flutter_webrtc_plugin