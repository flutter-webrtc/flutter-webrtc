#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <flutter_webrtc/flutter_web_r_t_c_plugin.h>

#include <cstring>

#include "flutter/generated_plugin_registrant.h"
#include "video_processor_sample.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  // Attaches video processors to flutter_webrtc tracks; see
  // lib/src/video_processor_sample.dart.
  VideoProcessorSample* video_processor_sample;
  FlMethodChannel* video_processor_channel;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Forwards the "flutter_webrtc_example/video_processor" method channel to the
// VideoProcessorSample shared with the Windows and eLinux runners.
static void video_processor_method_call_cb(FlMethodChannel* channel,
                                           FlMethodCall* method_call,
                                           gpointer user_data) {
  auto* sample = static_cast<VideoProcessorSample*>(user_data);
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);
  FlValue* track_id = nullptr;
  if (args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP)
    track_id = fl_value_lookup_string(args, "trackId");

  g_autoptr(FlMethodResponse) response = nullptr;
  if (!track_id || fl_value_get_type(track_id) != FL_VALUE_TYPE_STRING) {
    response = FL_METHOD_RESPONSE(fl_method_error_response_new(
        "bad_args", "trackId is required", nullptr));
  } else if (strcmp(method, "setGrayscale") == 0) {
    FlValue* enabled = fl_value_lookup_string(args, "enabled");
    if (!enabled || fl_value_get_type(enabled) != FL_VALUE_TYPE_BOOL) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "bad_args", "enabled is required", nullptr));
    } else if (!sample->SetGrayscale(fl_value_get_string(track_id),
                                     fl_value_get_bool(enabled))) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "no_track", "not a local video track of flutter_webrtc", nullptr));
    } else {
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    }
  } else if (strcmp(method, "remove") == 0) {
    g_autoptr(FlValue) removed =
        fl_value_new_bool(sample->Remove(fl_value_get_string(track_id)));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(removed));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  fl_method_call_respond(method_call, response, nullptr);
}

// Detaches the processors while the flutter_webrtc plugin is still alive.
static void video_processor_teardown(MyApplication* self) {
  if (self->video_processor_channel) {
    fl_method_channel_set_method_call_handler(self->video_processor_channel,
                                              nullptr, nullptr, nullptr);
    g_clear_object(&self->video_processor_channel);
  }
  delete self->video_processor_sample;
  self->video_processor_sample = nullptr;
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "flutter_webrtc_example");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "flutter_webrtc_example");
  }

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  self->video_processor_sample =
      new VideoProcessorSample(&flutter_webrtc_plugin_get_shared_instance);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->video_processor_channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)),
      "flutter_webrtc_example/video_processor", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      self->video_processor_channel, video_processor_method_call_cb,
      self->video_processor_sample, nullptr);
  // The plugin goes away with the view, so tear the sample down first.
  g_signal_connect_swapped(view, "destroy",
                           G_CALLBACK(video_processor_teardown), self);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  video_processor_teardown(self);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
