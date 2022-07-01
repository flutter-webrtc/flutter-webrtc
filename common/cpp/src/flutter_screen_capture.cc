#include "flutter_screen_capture.h"

#include <windows.h>

#include <atlimage.h>

#include <fstream>

namespace flutter_webrtc_plugin {

void FlutterScreenCapture::EnumerateScreens(std::unique_ptr<MethodResult<EncodableValue>> result) {
  SourceList sources;

  sources = base_->desktop_device_->EnumerateScreens();
  
  EncodableList list;
  for (const auto& source : sources.std_vector()) {
    // std::cout << " id: " << source.id.std_string() << " title: " << source.title.std_string() << " type: " << source.type << std::endl;
    EncodableMap info;
    info[EncodableValue("id")] = EncodableValue(source.id.std_string());
    info[EncodableValue("name")] = EncodableValue(source.title.std_string());
    info[EncodableValue("type")] = EncodableValue(source.type);
    list.push_back(EncodableValue(info));
  }

  result->Success(EncodableValue(list));
}

void FlutterScreenCapture::EnumerateWindows(std::unique_ptr<MethodResult<EncodableValue>> result) {
  SourceList sources;

  sources = base_->desktop_device_->EnumerateWindows();
  
  EncodableList list;
  for (const auto& source : sources.std_vector()) {
    // std::cout << " id: " << source.id.std_string() << " title: " << source.title.std_string() << " type: " << source.type << std::endl;
    EncodableMap info;
    info[EncodableValue("id")] = EncodableValue(source.id.std_string());
    info[EncodableValue("name")] = EncodableValue(source.title.std_string());
    info[EncodableValue("type")] = EncodableValue(source.type);
    list.push_back(EncodableValue(info));
  }

  result->Success(EncodableValue(list));
}

void AddSources(const SourceList& from, EncodableList& to) {
  for (const auto& source : from.std_vector()) {
    // std::cout << " id: " << source.id.std_string() << " title: " << source.title.std_string() << " type: " << source.type << std::endl;
    EncodableMap info;
    info[EncodableValue("id")] = EncodableValue(source.id.std_string());
    info[EncodableValue("name")] = EncodableValue(source.title.std_string());
    info[EncodableValue("type")] = EncodableValue(source.type == SourceType::kWindow ? "window" : "screen");
    // TODO "thumbnailSize"
    info[EncodableValue("thumbnailSize")] = EncodableMap { 
      {EncodableValue("width"), EncodableValue(0)}, 
      {EncodableValue("height"), EncodableValue(0)}, 
    };
    to.push_back(EncodableValue(info));
  }
}

void FlutterScreenCapture::GetDesktopSources(const EncodableList &types, std::unique_ptr<MethodResult<EncodableValue>> result) {
  EncodableList sources;

  size_t size = types.size();
  for (size_t i = 0; i < size; i++) {
    std::string type = GetValue<std::string>(types[i]);
    if (type == "window") {
      SourceList windows = base_->desktop_device_->EnumerateWindows();
      // std::cout << " windows: " << windows.size() << std::endl;
      AddSources(windows, sources);
    } else if (type == "screen") {
      SourceList screens = base_->desktop_device_->EnumerateScreens();
      // std::cout << " screens: " << screens.size() << std::endl;
      AddSources(screens, sources);
    } else {
      result->Error("Bad Arguments", "Unknown type " + type);
      return;
    }    
  }
  // std::cout << " sources: " << sources.size() << std::endl;
  result->Success(EncodableValue(EncodableMap{{EncodableValue("sources"), sources}}));
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

void CaptureWindow(uint64_t id, std::unique_ptr<MethodResult<EncodableValue>> result) {
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
  // std::cout << " right,bottom: " << rcClient.right << ":" << rcClient.bottom << std::endl;

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
                rcClient.bottom - rcClient.top, hdcWindow, 0, 0, SRCCOPY | CAPTUREBLT)) {
      result->Error("Failed", "BitBlt has failed");
      return;
    }
    // if (!StretchBlt(hdcMemDC, 0, 0, rcClient.right, rcClient.bottom, hdcWindow,
    //                 rcClient.left, rcClient.top, rcClient.right - rcClient.left,
    //                 rcClient.bottom - rcClient.top, SRCCOPY | CAPTUREBLT)) {
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

void CaptureScreen(uint64_t id, std::unique_ptr<MethodResult<EncodableValue>> result) {
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

void FlutterScreenCapture::GetDesktopSourceThumbnail(uint64_t source_id, int width, int height,
                     std::unique_ptr<MethodResult<EncodableValue>> result) {
  // std::cout << " source_id: " << source_id << " width: " << width << " height: " << height << std::endl;
  
  if (source_id == 0) {
    CaptureScreen(source_id, std::move(result));
  } else {
    CaptureWindow(source_id, std::move(result));
  }

}

void FlutterScreenCapture::GetDisplayMedia(const EncodableMap& constraints,
                    std::unique_ptr<MethodResult<EncodableValue>> result) {

  int window_id = 0;
  libwebrtc::SourceType source_type = libwebrtc::SourceType::kEntireScreen;

  const EncodableMap video = findMap(constraints, "video");
  if (video != EncodableMap()) {
    const EncodableMap deviceId = findMap(video, "deviceId");
    if (deviceId != EncodableMap()) {
      std::string windowId = findString(deviceId, "exact");
      if (windowId.empty()) {
        result->Error("Bad Arguments", "Incorrect video->deviceId->exact");
        return;
      }
      window_id = std::stoi(windowId);
      if (window_id !=0 ) {
        source_type = libwebrtc::SourceType::kWindow;
      }
    }
  }                      
  // std::cout << " window_id: " << window_id  << " source_type: " << (source_type == SourceType::kWindow ? "window" : "screen") << std::endl;
  CreateCapture(source_type, window_id, constraints, std::move(result));                  
}

void FlutterScreenCapture::CreateCapture(libwebrtc::SourceType type, uint64_t id,
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

  scoped_refptr<RTCDesktopCapturer> desktop_capturer;
  if (type == libwebrtc::SourceType::kEntireScreen) {
    desktop_capturer = base_->desktop_device_->CreateScreenCapturer(id);
  } else {
    desktop_capturer = base_->desktop_device_->CreateWindowCapturer(id);
  }

  if (!desktop_capturer.get()) return; // TODO: result->Error()

  const char* video_source_label = "screen_capture_input";

  scoped_refptr<RTCVideoSource> source = base_->factory_->CreateDesktopSource(
      desktop_capturer, video_source_label,
      base_->ParseMediaConstraints(video_constraints));

  // TODO: RTCVideoSource -> RTCVideoTrack
  
  scoped_refptr<RTCVideoTrack> track =
      base_->factory_->CreateVideoTrack(source, uuid.c_str());

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

  result->Success(EncodableValue(params));
}

}