// Copyright 2013 The Flutter Authors. All rights reserved.
 // Use of this source code is governed by a BSD-style license that can be
 // found in the LICENSE file.
 
 #include "task_runner_windows.h"
 
 #include <algorithm>
 #include <iostream>
 
 namespace flutter_webrtc_plugin {
 
 TaskRunnerWindows::TaskRunnerWindows() {
   WNDCLASS window_class = RegisterWindowClass();
   window_handle_ =
       CreateWindowEx(0, window_class.lpszClassName, L"", 0, 0, 0, 0, 0,
                      HWND_MESSAGE, nullptr, window_class.hInstance, nullptr);
 
   if (window_handle_) {
     SetWindowLongPtr(window_handle_, GWLP_USERDATA,
                      reinterpret_cast<LONG_PTR>(this));
   } else {
     auto error = GetLastError();
     LPWSTR message = nullptr;
     FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM |
                        FORMAT_MESSAGE_IGNORE_INSERTS,
                    NULL, error, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                    reinterpret_cast<LPWSTR>(&message), 0, NULL);
     OutputDebugString(message);
     LocalFree(message);
   }
 }
 
 TaskRunnerWindows::~TaskRunnerWindows() {
   if (window_handle_) {
     DestroyWindow(window_handle_);
     window_handle_ = nullptr;
   }
   UnregisterClass(window_class_name_.c_str(), nullptr);
 }
 
 void TaskRunnerWindows::EnqueueTask(TaskClosure task) {
   {
     std::lock_guard<std::mutex> lock(tasks_mutex_);
     tasks_.push(task);
   }
   if (!PostMessage(window_handle_, WM_NULL, 0, 0)) {
     DWORD error_code = GetLastError();
     std::cerr << "Failed to post message to main thread; error_code: "
               << error_code << std::endl;
   }
 }
 
 void TaskRunnerWindows::ProcessTasks() {
   // Even though it would usually be sufficient to process only a single task
   // whenever we receive the message, if the message queue happens to be full,
   // we might not receive a message for each individual task.
   for (;;) {
     std::lock_guard<std::mutex> lock(tasks_mutex_);
     if (tasks_.empty()) break;
     TaskClosure task = tasks_.front();
     tasks_.pop();
     task();
   }
 }
 
 WNDCLASS TaskRunnerWindows::RegisterWindowClass() {
   window_class_name_ = L"FlutterWebRTCWindowsTaskRunnerWindow";
 
   WNDCLASS window_class{};
   window_class.hCursor = nullptr;
   window_class.lpszClassName = window_class_name_.c_str();
   window_class.style = 0;
   window_class.cbClsExtra = 0;
   window_class.cbWndExtra = 0;
   window_class.hInstance = GetModuleHandle(nullptr);
   window_class.hIcon = nullptr;
   window_class.hbrBackground = 0;
   window_class.lpszMenuName = nullptr;
   window_class.lpfnWndProc = WndProc;
   RegisterClass(&window_class);
   return window_class;
 }
 
 LRESULT
 TaskRunnerWindows::HandleMessage(UINT const message, WPARAM const wparam,
                                 LPARAM const lparam) noexcept {
   switch (message) {
     case WM_NULL:
       ProcessTasks();
       return 0;
   }
   return DefWindowProcW(window_handle_, message, wparam, lparam);
 }
 
 LRESULT TaskRunnerWindows::WndProc(HWND const window, UINT const message,
                                   WPARAM const wparam,
                                   LPARAM const lparam) noexcept {
   if (auto* that = reinterpret_cast<TaskRunnerWindows*>(
           GetWindowLongPtr(window, GWLP_USERDATA))) {
     return that->HandleMessage(message, wparam, lparam);
   } else {
     return DefWindowProc(window, message, wparam, lparam);
   }
 }
 
 }  // namespace flutter_webrtc_plugin