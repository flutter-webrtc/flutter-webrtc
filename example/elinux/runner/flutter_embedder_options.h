// Copyright 2021 Sony Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef FLUTTER_EMBEDDER_OPTIONS_
#define FLUTTER_EMBEDDER_OPTIONS_

#include <flutter/flutter_view_controller.h>

#include <string>

#include "command_options.h"

class FlutterEmbedderOptions {
 public:
  FlutterEmbedderOptions() {
    options_.AddString("bundle", "b", "Path to Flutter project bundle",
                       "./bundle", true);
    options_.AddWithoutValue("no-cursor", "n", "No mouse cursor/pointer",
                             false);
    options_.AddInt("rotation", "r",
                    "Window rotation(degree) [0(default)|90|180|270]", 0,
                    false);
    options_.AddDouble("text-scaling-factor", "x", "Text scaling factor", 1.0,
                       false);
    options_.AddWithoutValue("enable-high-contrast", "i",
                             "Request that UI be rendered with darker colors.",
                             false);
    options_.AddDouble("force-scale-factor", "s",
                       "Force a scale factor instead using default value", 1.0,
                       false);
    options_.AddWithoutValue(
        "async-vblank", "v",
        "Don't sync to compositor redraw/vblank (eglSwapInterval 0)", false);

#if defined(FLUTTER_TARGET_BACKEND_GBM) || \
    defined(FLUTTER_TARGET_BACKEND_EGLSTREAM)
    // no more options.
#elif defined(FLUTTER_TARGET_BACKEND_X11)
    options_.AddString("title", "t", "Window title", "Flutter", false);
    options_.AddWithoutValue("fullscreen", "f", "Always full-screen display",
                             false);
    options_.AddInt("width", "w", "Window width", 1280, false);
    options_.AddInt("height", "h", "Window height", 720, false);
#else  // FLUTTER_TARGET_BACKEND_WAYLAND
    options_.AddString("title", "t", "Window title", "Flutter", false);
    options_.AddString("app-id", "a", "XDG App ID", "dev.flutter.elinux",
                       false);
    options_.AddWithoutValue("onscreen-keyboard", "k",
                             "Enable on-screen keyboard", false);
    options_.AddWithoutValue("window-decoration", "d",
                             "Enable window decorations", false);
    options_.AddWithoutValue("fullscreen", "f", "Always full-screen display",
                             false);
    options_.AddInt("width", "w", "Window width", 1280, false);
    options_.AddInt("height", "h", "Window height", 720, false);
#endif
  }
  ~FlutterEmbedderOptions() = default;

  bool Parse(int argc, char** argv) {
    if (!options_.Parse(argc, argv)) {
      std::cerr << options_.GetError() << std::endl;
      std::cout << options_.ShowHelp();
      return false;
    }

    bundle_path_ = options_.GetValue<std::string>("bundle");
    use_mouse_cursor_ = !options_.Exist("no-cursor");
    if (options_.Exist("rotation")) {
      switch (options_.GetValue<int>("rotation")) {
        case 90:
          window_view_rotation_ =
              flutter::FlutterViewController::ViewRotation::kRotation_90;
          break;
        case 180:
          window_view_rotation_ =
              flutter::FlutterViewController::ViewRotation::kRotation_180;
          break;
        case 270:
          window_view_rotation_ =
              flutter::FlutterViewController::ViewRotation::kRotation_270;
          break;
        default:
          window_view_rotation_ =
              flutter::FlutterViewController::ViewRotation::kRotation_0;
          break;
      }
    }

    text_scale_factor_ = options_.GetValue<double>("text-scaling-factor");
    enable_high_contrast_ = options_.Exist("enable-high-contrast");

    if (options_.Exist("force-scale-factor")) {
      is_force_scale_factor_ = true;
      scale_factor_ = options_.GetValue<double>("force-scale-factor");
    } else {
      is_force_scale_factor_ = false;
      scale_factor_ = 1.0;
    }

    enable_vsync_ = !options_.Exist("async-vblank");

#if defined(FLUTTER_TARGET_BACKEND_GBM) || \
    defined(FLUTTER_TARGET_BACKEND_EGLSTREAM)
    use_onscreen_keyboard_ = false;
    use_window_decoration_ = false;
    window_view_mode_ = flutter::FlutterViewController::ViewMode::kFullscreen;
#elif defined(FLUTTER_TARGET_BACKEND_X11)
    use_onscreen_keyboard_ = false;
    use_window_decoration_ = false;
    window_title_ = options_.GetValue<std::string>("title");
    window_view_mode_ =
        options_.Exist("fullscreen")
            ? flutter::FlutterViewController::ViewMode::kFullscreen
            : flutter::FlutterViewController::ViewMode::kNormal;
    window_width_ = options_.GetValue<int>("width");
    window_height_ = options_.GetValue<int>("height");
#else  // FLUTTER_TARGET_BACKEND_WAYLAND
    window_title_ = options_.GetValue<std::string>("title");
    window_app_id_ = options_.GetValue<std::string>("app-id");
    use_onscreen_keyboard_ = options_.Exist("onscreen-keyboard");
    use_window_decoration_ = options_.Exist("window-decoration");
    window_view_mode_ =
        options_.Exist("fullscreen")
            ? flutter::FlutterViewController::ViewMode::kFullscreen
            : flutter::FlutterViewController::ViewMode::kNormal;
    window_width_ = options_.GetValue<int>("width");
    window_height_ = options_.GetValue<int>("height");
#endif

    return true;
  }

  std::string BundlePath() const {
    return bundle_path_;
  }
  std::string WindowTitle() const {
    return window_title_;
  }
  std::string WindowAppID() const {
    return window_app_id_;
  }
  bool IsUseMouseCursor() const {
    return use_mouse_cursor_;
  }
  bool IsUseOnscreenKeyboard() const {
    return use_onscreen_keyboard_;
  }
  bool IsUseWindowDecoraation() const {
    return use_window_decoration_;
  }
  flutter::FlutterViewController::ViewMode WindowViewMode() const {
    return window_view_mode_;
  }
  int WindowWidth() const {
    return window_width_;
  }
  int WindowHeight() const {
    return window_height_;
  }
  flutter::FlutterViewController::ViewRotation WindowRotation() const {
    return window_view_rotation_;
  }
  double TextScaleFactor() const {
    return text_scale_factor_;
  }
  bool EnableHighContrast() const {
    return enable_high_contrast_;
  }
  bool IsForceScaleFactor() const {
    return is_force_scale_factor_;
  }
  double ScaleFactor() const {
    return scale_factor_;
  }
  bool EnableVsync() const {
    return enable_vsync_;
  }

 private:
  commandline::CommandOptions options_;

  std::string bundle_path_;
  std::string window_title_;
  std::string window_app_id_;
  bool use_mouse_cursor_ = true;
  bool use_onscreen_keyboard_ = false;
  bool use_window_decoration_ = false;
  flutter::FlutterViewController::ViewMode window_view_mode_ =
      flutter::FlutterViewController::ViewMode::kNormal;
  int window_width_ = 1280;
  int window_height_ = 720;
  flutter::FlutterViewController::ViewRotation window_view_rotation_ =
      flutter::FlutterViewController::ViewRotation::kRotation_0;
  bool is_force_scale_factor_;
  double scale_factor_;
  double text_scale_factor_;
  bool enable_high_contrast_;
  bool enable_vsync_;
};

#endif  // FLUTTER_EMBEDDER_OPTIONS_
