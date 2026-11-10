#include "task_runner_linux.h"

#include <glib.h>

namespace flutter_webrtc_plugin {

void TaskRunnerLinux::EnqueueTask(TaskClosure task) {
  {
    std::lock_guard<std::mutex> lock(tasks_mutex_);
    tasks_.push(std::move(task));
  }

  GMainContext* context = g_main_context_default();
  if (context) {
    g_main_context_invoke(
        context,
        [](gpointer user_data)  -> gboolean {
          TaskRunnerLinux* runner = static_cast<TaskRunnerLinux*>(user_data);
          // Hold the lock only to pop, never while a task runs. A task that
          // enqueues another one, such as a result completed on a worker
          // thread whose Success() posts again, would otherwise deadlock on
          // the non-recursive mutex. g_main_context_invoke() runs inline on
          // the main thread, so such a nested call drains the queue in order
          // before this loop continues.
          for (;;) {
            TaskClosure task;
            {
              std::lock_guard<std::mutex> lock(runner->tasks_mutex_);
              if (runner->tasks_.empty())
                break;
              task = std::move(runner->tasks_.front());
              runner->tasks_.pop();
            }
            task();
          }
          return G_SOURCE_REMOVE;
        },
        this);
  }
}

}  // namespace flutter_webrtc_plugin
