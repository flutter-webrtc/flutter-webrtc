#include <map>
#include <mutex>
#include <optional>

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include "include/medea_flutter_webrtc/medea_flutter_webrtc_plugin.h"
#include <medea_flutter_webrtc_native.h>
#include <video_texture.h>

const char* kChannelName = "FlutterWebRtc/VideoRendererFactory/0";

#define MEDEA_FLUTTER_WEBRTC_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), medea_flutter_webrtc_plugin_get_type(), \
                              MedeaFlutterWebrtcPlugin))

// Renderer of `VideoFrame`s on a Flutter texture.
class TextureVideoRenderer {
 public:
  // Creates a new `TextureVideoRenderer`.
  TextureVideoRenderer(FlTextureRegistrar* registrar,
                       FlBinaryMessenger* messenger)
      : registrar_(registrar) {

    texture_ = video_texture_new();

    fl_texture_registrar_register_texture(registrar, FL_TEXTURE(texture_));

    texture_->texture_id =
        reinterpret_cast<int64_t>(FL_TEXTURE(texture_));

    texture_id_ = texture_->texture_id;
  }

  void ResetRenderer() {
    const std::lock_guard<std::mutex> lock(texture_->mutex);

    texture_->frame_.reset();
  }

  // Called when a new `VideoFrame` is produced by the underlying source.
  void OnFrame(VideoFrame frame) {
    texture_->mutex.lock();
    texture_->frame_.emplace(std::move(frame));
    texture_->mutex.unlock();

    fl_texture_registrar_mark_texture_frame_available(registrar_,
                                                      FL_TEXTURE(texture_));
  }

  // Returns an ID of the Flutter texture associated with this renderer.
  int64_t texture_id() {
    return texture_id_;
  }

  // Returns the Flutter texture associated with this renderer.
  VideoTexture* texture() { return texture_; }

 private:
  // Pointer to the `VideoTexture` that is passed to the Flutter texture.
  VideoTexture* texture_ = 0;

  // Object keeping track of external textures.
  FlTextureRegistrar* registrar_ = 0;

  // ID of the Flutter texture.
  int64_t texture_id_ = -1;
};

class FrameHandler : public OnFrameCallbackInterface {
 public:
  // Creates a new `FrameHandler`.
  FrameHandler(std::shared_ptr<TextureVideoRenderer> renderer)
      : renderer_(std::move(renderer)) {}

  // `OnFrameCallbackInterface` implementation.
  void OnFrame(VideoFrame frame) { renderer_->OnFrame(std::move(frame)); }

 private:
  // `TextureVideoRenderer` that the `VideoFrame`s will be passed to.
  std::shared_ptr<TextureVideoRenderer> renderer_;
};

// Manager storing and managing all the `TextureVideoRenderer`s.
class FlutterVideoRendererManager {
 public:
  FlutterVideoRendererManager(FlTextureRegistrar* registrar,
                              FlBinaryMessenger* messenger)
      : registrar_(registrar), messenger_(messenger) {}

  // Creates a new `FlutterVideoRendererManager`.
  void CreateVideoRendererTexture(FlMethodResponse** response) {
    std::shared_ptr<TextureVideoRenderer> renderer =
        std::make_shared<TextureVideoRenderer>(registrar_, messenger_);

    auto texture_id = renderer->texture_id();
    renderers_[texture_id] = renderer;

    g_autoptr(FlValue) map = fl_value_new_map();
    fl_value_set_string_take(map, "textureId",
                             fl_value_new_int((int64_t)texture_id));
    (*response) = FL_METHOD_RESPONSE(fl_method_success_response_new(map));
  }

  // Changes a media source of the specific `TextureVideoRenderer`.
  void CreateFrameHandler(FlMethodResponse** response,
                          FlMethodCall* method_call) {
    auto arguments = fl_method_call_get_args(method_call);
    if (fl_value_get_type(arguments) == FL_VALUE_TYPE_NULL) {
      (*response) = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "Bad Arguments", "Null constraints arguments received", NULL));
      return;
    }
    int64_t texture_id =
        fl_value_get_int(fl_value_lookup_string(arguments, "textureId"));
    auto renderer = renderers_[texture_id];
    renderer->ResetRenderer();

    FrameHandler* handler_ptr = new FrameHandler(renderer);
    g_autoptr(FlValue) map = fl_value_new_map();
    fl_value_set_string_take(map, "handler_ptr",
                             fl_value_new_int((int64_t)handler_ptr));
    (*response) = FL_METHOD_RESPONSE(fl_method_success_response_new(map));
  }

  // Disposes the specific `TextureVideoRenderer`.
  void VideoRendererDispose(FlMethodResponse** response,
                            FlMethodCall* method_call) {
    auto arguments = fl_method_call_get_args(method_call);
    if (fl_value_get_type(arguments) == FL_VALUE_TYPE_NULL) {
      (*response) = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "Bad Arguments", "Null constraints arguments received", NULL));
      return;
    }
    int64_t texture_id =
        fl_value_get_int(fl_value_lookup_string(arguments, "textureId"));

    auto it = renderers_.find(texture_id);
    if (it != renderers_.end()) {
      fl_texture_registrar_unregister_texture(
          registrar_, FL_TEXTURE(it->second->texture()));
      renderers_.erase(it);
      (*response) = FL_METHOD_RESPONSE(fl_method_success_response_new(NULL));
      return;
    }
    (*response) = FL_METHOD_RESPONSE(fl_method_error_response_new(
        "VideoRendererDisposeFailed",
        "VideoRendererDispose() texture not found!", NULL));
  }

 private:
  // Object keeping track of external textures.
  FlTextureRegistrar* registrar_;

  // Channel to the Flutter side renderers.
  FlBinaryMessenger* messenger_;

  // Map containing all the `TextureVideoRenderer`s.
  std::map<int64_t, std::shared_ptr<TextureVideoRenderer>> renderers_;
};

struct _MedeaFlutterWebrtcPlugin {
  GObject parent_instance;
  std::unique_ptr<FlutterVideoRendererManager> video_renderer_manager;
};

G_DEFINE_TYPE(MedeaFlutterWebrtcPlugin,
              medea_flutter_webrtc_plugin,
              g_object_get_type())

// Called when a method call is received from Flutter.
static void medea_flutter_webrtc_plugin_handle_method_call(
    MedeaFlutterWebrtcPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;
  const gchar* method = fl_method_call_get_name(method_call);
  if (strcmp(method, "create") == 0) {
    self->video_renderer_manager->CreateVideoRendererTexture(&response);
  } else if (strcmp(method, "dispose") == 0) {
    self->video_renderer_manager->VideoRendererDispose(&response, method_call);
  } else if (strcmp(method, "createFrameHandler") == 0) {
    self->video_renderer_manager->CreateFrameHandler(&response, method_call);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void medea_flutter_webrtc_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(medea_flutter_webrtc_plugin_parent_class)->dispose(object);
}

static void medea_flutter_webrtc_plugin_class_init(
    MedeaFlutterWebrtcPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = medea_flutter_webrtc_plugin_dispose;
}

static void medea_flutter_webrtc_plugin_init(MedeaFlutterWebrtcPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  MedeaFlutterWebrtcPlugin* plugin = MEDEA_FLUTTER_WEBRTC_PLUGIN(user_data);
  medea_flutter_webrtc_plugin_handle_method_call(plugin, method_call);
}

void medea_flutter_webrtc_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  MedeaFlutterWebrtcPlugin* plugin = MEDEA_FLUTTER_WEBRTC_PLUGIN(
      g_object_new(medea_flutter_webrtc_plugin_get_type(), nullptr));

  plugin->video_renderer_manager =
      std::make_unique<FlutterVideoRendererManager>(
          fl_plugin_registrar_get_texture_registrar(registrar),
          fl_plugin_registrar_get_messenger(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            kChannelName, FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
