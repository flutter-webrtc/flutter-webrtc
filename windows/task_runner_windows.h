// Copyright 2024 The Flutter Authors. All rights reserved.
 // Use of this source code is governed by a BSD-style license that can be
 // found in the LICENSE file.
 #ifndef PACKAGES_FLUTTER_WEBRTC_WINDOWS_TASK_RUNNER_WINDOW_H_
 #define PACKAGES_FLUTTER_WEBRTC_WINDOWS_TASK_RUNNER_WINDOW_H_
 
 #include <windows.h>
 
 #include <chrono>
 #include <memory>
 #include <mutex>
 #include <queue>
 #include <string>
 
 #include "task_runner.h"
 
 namespace flutter_webrtc_plugin {
 
 // Hidden HWND responsible for processing camera tasks on main thread
 // Adapted from Flutter Engine, see:
 //   https://github.com/flutter/flutter/issues/134346#issuecomment-2141023146
 // and:
 //   https://github.com/flutter/engine/blob/d7c0bcfe7a30408b0722c9d47d8b0b1e4cdb9c81/shell/platform/windows/task_runner_window.h
 class TaskRunnerWindows : public TaskRunner {
  public:
   virtual void EnqueueTask(TaskClosure task);
 
   TaskRunnerWindows();
   ~TaskRunnerWindows();
 
  private:
   void ProcessTasks();
 
   WNDCLASS RegisterWindowClass();
 
   LRESULT
   HandleMessage(UINT const message, WPARAM const wparam,
                 LPARAM const lparam) noexcept;
 
   static LRESULT CALLBACK WndProc(HWND const window, UINT const message,
                                   WPARAM const wparam,
                                   LPARAM const lparam) noexcept;
 
   HWND window_handle_;
   std::wstring window_class_name_;
   std::mutex tasks_mutex_;
   std::queue<TaskClosure> tasks_;
 
   // Prevent copying.
   TaskRunnerWindows(TaskRunnerWindows const&) = delete;
   TaskRunnerWindows& operator=(TaskRunnerWindows const&) = delete;
 };
 }  // namespace flutter_webrtc_plugin
 
 #endif  // PACKAGES_FLUTTER_WEBRTC_WINDOWS_TASK_RUNNER_WINDOW_H_