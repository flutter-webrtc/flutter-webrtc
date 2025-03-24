// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
 #ifndef PACKAGES_FLUTTER_WEBRTC_TASK_RUNNER_H_
 #define PACKAGES_FLUTTER_WEBRTC_TASK_RUNNER_H_
 
 #include <functional>
 
 using TaskClosure = std::function<void()>;
 
 class TaskRunner {
  public:
   virtual void EnqueueTask(TaskClosure task) = 0;
   virtual ~TaskRunner() = default;
 };
 
 #endif  // PACKAGES_FLUTTER_WEBRTC_TASK_RUNNER_H_