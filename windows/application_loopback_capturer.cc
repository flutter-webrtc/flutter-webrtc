#ifdef _WIN32

#include "application_loopback_capturer.h"

#include <avrt.h>
#include <cstring>
#include <iostream>

// ---------------------------------------------------------------------------
// ApplicationLoopbackAudio API types
// These structs were introduced in Windows SDK 10.0.20348.0.  We define them
// here so the file compiles against older SDKs as well; the feature is
// detected at runtime via a probe activation attempt.
// ---------------------------------------------------------------------------
#ifndef AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK

typedef enum AUDIOCLIENT_ACTIVATION_TYPE {
  AUDIOCLIENT_ACTIVATION_TYPE_DEFAULT = 0,
  AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK = 1,
} AUDIOCLIENT_ACTIVATION_TYPE;

typedef enum PROCESS_LOOPBACK_MODE {
  PROCESS_LOOPBACK_MODE_INCLUDE_TARGET_PROCESS_TREE = 0,
  PROCESS_LOOPBACK_MODE_EXCLUDE_TARGET_PROCESS_TREE = 1,
} PROCESS_LOOPBACK_MODE;

typedef struct AUDIOCLIENT_PROCESS_LOOPBACK_PARAMS {
  DWORD TargetProcessId;
  PROCESS_LOOPBACK_MODE ProcessLoopbackMode;
} AUDIOCLIENT_PROCESS_LOOPBACK_PARAMS;

typedef struct AUDIOCLIENT_ACTIVATION_PARAMS {
  AUDIOCLIENT_ACTIVATION_TYPE ActivationType;
  union {
    AUDIOCLIENT_PROCESS_LOOPBACK_PARAMS ProcessLoopbackParams;
  };
} AUDIOCLIENT_ACTIVATION_PARAMS;

// Special device string that routes to the system render mix.
#define VIRTUAL_AUDIO_DEVICE_PROCESS_LOOPBACK L"VAD\\Process_Loopback"

#endif  // AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK

namespace flutter_webrtc_plugin {

// ---------------------------------------------------------------------------
// COM completion handler for ActivateAudioInterfaceAsync
// ---------------------------------------------------------------------------
class ActivationCompletionHandler
    : public IActivateAudioInterfaceCompletionHandler {
 public:
  HANDLE event_ = CreateEvent(nullptr, FALSE, FALSE, nullptr);
  IAudioClient* client_ = nullptr;
  HRESULT activation_result_ = E_FAIL;

  // IActivateAudioInterfaceCompletionHandler
  HRESULT STDMETHODCALLTYPE ActivateCompleted(
      IActivateAudioInterfaceAsyncOperation* op) override {
    IUnknown* unk = nullptr;
    op->GetActivateResult(&activation_result_, &unk);
    if (SUCCEEDED(activation_result_) && unk) {
      unk->QueryInterface(IID_PPV_ARGS(&client_));
      unk->Release();
    }
    SetEvent(event_);
    return S_OK;
  }

  // IUnknown
  ULONG STDMETHODCALLTYPE AddRef() override {
    return InterlockedIncrement(&ref_);
  }
  ULONG STDMETHODCALLTYPE Release() override {
    ULONG r = InterlockedDecrement(&ref_);
    if (r == 0) delete this;
    return r;
  }
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid,
                                           void** ppv) override {
    if (riid == IID_IUnknown ||
        riid == __uuidof(IActivateAudioInterfaceCompletionHandler)) {
      *ppv = static_cast<IActivateAudioInterfaceCompletionHandler*>(this);
      AddRef();
      return S_OK;
    }
    *ppv = nullptr;
    return E_NOINTERFACE;
  }

 private:
  volatile ULONG ref_ = 1;
};

// ---------------------------------------------------------------------------
// ApplicationLoopbackCapturer
// ---------------------------------------------------------------------------

ApplicationLoopbackCapturer::ApplicationLoopbackCapturer() = default;

ApplicationLoopbackCapturer::~ApplicationLoopbackCapturer() {
  Stop();
}

bool ApplicationLoopbackCapturer::Start(
    scoped_refptr<RTCAudioSource> source) {
  if (running_) return true;

  source_ = source;

  // Try the modern ApplicationLoopback path first, then the classic one.
  audio_client_ = TryInitApplicationLoopback();
  if (!audio_client_) {
    audio_client_ = TryInitClassicLoopback();
  }
  if (!audio_client_) {
    std::cerr << "[LoopbackCapturer] Failed to initialise any capture path.\n";
    return false;
  }

  buffer_ready_event_ = CreateEvent(nullptr, FALSE, FALSE, nullptr);
  if (buffer_ready_event_ == INVALID_HANDLE_VALUE) {
    audio_client_->Release();
    audio_client_ = nullptr;
    return false;
  }

  HRESULT hr = audio_client_->SetEventHandle(buffer_ready_event_);
  if (FAILED(hr)) {
    std::cerr << "[LoopbackCapturer] SetEventHandle failed: 0x" << std::hex
              << hr << "\n";
    audio_client_->Release();
    audio_client_ = nullptr;
    CloseHandle(buffer_ready_event_);
    buffer_ready_event_ = INVALID_HANDLE_VALUE;
    return false;
  }

  hr = audio_client_->GetService(IID_PPV_ARGS(&capture_client_));
  if (FAILED(hr)) {
    std::cerr << "[LoopbackCapturer] GetService(IAudioCaptureClient) failed: 0x"
              << std::hex << hr << "\n";
    audio_client_->Release();
    audio_client_ = nullptr;
    CloseHandle(buffer_ready_event_);
    buffer_ready_event_ = INVALID_HANDLE_VALUE;
    return false;
  }

  hr = audio_client_->Start();
  if (FAILED(hr)) {
    std::cerr << "[LoopbackCapturer] IAudioClient::Start failed: 0x"
              << std::hex << hr << "\n";
    capture_client_->Release();
    capture_client_ = nullptr;
    audio_client_->Release();
    audio_client_ = nullptr;
    CloseHandle(buffer_ready_event_);
    buffer_ready_event_ = INVALID_HANDLE_VALUE;
    return false;
  }

  running_ = true;
  capture_thread_ = std::thread(&ApplicationLoopbackCapturer::CaptureThread, this);
  std::cout << "[LoopbackCapturer] Capture started ("
            << mix_format_->nSamplesPerSec << " Hz, "
            << mix_format_->nChannels << " ch, "
            << mix_format_->wBitsPerSample << "-bit).\n";
  return true;
}

void ApplicationLoopbackCapturer::Stop() {
  if (!running_) return;
  running_ = false;

  // Wake the capture thread so it can exit the WaitForSingleObject loop.
  if (buffer_ready_event_ != INVALID_HANDLE_VALUE) {
    SetEvent(buffer_ready_event_);
  }
  if (capture_thread_.joinable()) {
    capture_thread_.join();
  }

  if (audio_client_) {
    audio_client_->Stop();
    audio_client_->Release();
    audio_client_ = nullptr;
  }
  if (capture_client_) {
    capture_client_->Release();
    capture_client_ = nullptr;
  }
  if (mix_format_) {
    CoTaskMemFree(mix_format_);
    mix_format_ = nullptr;
  }
  if (buffer_ready_event_ != INVALID_HANDLE_VALUE) {
    CloseHandle(buffer_ready_event_);
    buffer_ready_event_ = INVALID_HANDLE_VALUE;
  }
  source_ = nullptr;
  std::cout << "[LoopbackCapturer] Capture stopped.\n";
}

// ---------------------------------------------------------------------------
// TryInitApplicationLoopback
// Attempts to create an IAudioClient via the ApplicationLoopback activation
// path (Win10 20H1+).  Returns nullptr on failure.
// ---------------------------------------------------------------------------
IAudioClient* ApplicationLoopbackCapturer::TryInitApplicationLoopback() {
  // We call ActivateAudioInterfaceAsync on the capture thread (MTA).
  // Use a completion handler + event to synchronise the async activation.
  auto* handler = new ActivationCompletionHandler();

  AUDIOCLIENT_ACTIVATION_PARAMS activation_params = {};
  activation_params.ActivationType =
      AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK;
  // TargetProcessId=0 + EXCLUDE captures ALL system audio.
  activation_params.ProcessLoopbackParams.TargetProcessId = 0;
  activation_params.ProcessLoopbackParams.ProcessLoopbackMode =
      PROCESS_LOOPBACK_MODE_EXCLUDE_TARGET_PROCESS_TREE;

  PROPVARIANT pv;
  PropVariantInit(&pv);
  pv.vt = VT_BLOB;
  pv.blob.cbSize = sizeof(activation_params);
  pv.blob.pBlobData =
      reinterpret_cast<BYTE*>(&activation_params);

  IActivateAudioInterfaceAsyncOperation* async_op = nullptr;
  HRESULT hr = ActivateAudioInterfaceAsync(
      VIRTUAL_AUDIO_DEVICE_PROCESS_LOOPBACK,
      __uuidof(IAudioClient),
      &pv,
      handler,
      &async_op);

  if (FAILED(hr)) {
    std::cerr << "[LoopbackCapturer] ActivateAudioInterfaceAsync failed: 0x"
              << std::hex << hr << " – falling back to classic loopback.\n";
    handler->Release();
    return nullptr;
  }

  // Wait up to 5 s for the activation to complete.
  DWORD wait_result = WaitForSingleObject(handler->event_, 5000);
  if (async_op) async_op->Release();

  if (wait_result != WAIT_OBJECT_0 || FAILED(handler->activation_result_)) {
    std::cerr << "[LoopbackCapturer] ApplicationLoopback activation failed"
                 " – falling back to classic loopback.\n";
    handler->Release();
    return nullptr;
  }

  IAudioClient* client = handler->client_;
  handler->Release();

  if (!client) return nullptr;

  WAVEFORMATEX* fmt = nullptr;
  hr = client->GetMixFormat(&fmt);
  if (FAILED(hr)) {
    client->Release();
    return nullptr;
  }

  // Request event-driven shared mode.
  hr = client->Initialize(
      AUDCLNT_SHAREMODE_SHARED,
      AUDCLNT_STREAMFLAGS_LOOPBACK | AUDCLNT_STREAMFLAGS_EVENTCALLBACK,
      /*hnsBufferDuration=*/0,
      /*hnsPeriodicity=*/0,
      fmt,
      nullptr);

  if (FAILED(hr)) {
    std::cerr << "[LoopbackCapturer] IAudioClient::Initialize (AppLoopback) "
                 "failed: 0x"
              << std::hex << hr << "\n";
    CoTaskMemFree(fmt);
    client->Release();
    return nullptr;
  }

  mix_format_ = fmt;
  std::cout << "[LoopbackCapturer] Using ApplicationLoopbackAudio path.\n";
  return client;
}

// ---------------------------------------------------------------------------
// TryInitClassicLoopback
// Falls back to the classic WASAPI loopback on the default render endpoint.
// Available on all supported Windows versions.
// ---------------------------------------------------------------------------
IAudioClient* ApplicationLoopbackCapturer::TryInitClassicLoopback() {
  IMMDeviceEnumerator* enumerator = nullptr;
  HRESULT hr = CoCreateInstance(
      __uuidof(MMDeviceEnumerator), nullptr, CLSCTX_ALL,
      IID_PPV_ARGS(&enumerator));
  if (FAILED(hr)) {
    std::cerr << "[LoopbackCapturer] CoCreateInstance(MMDeviceEnumerator) "
                 "failed: 0x"
              << std::hex << hr << "\n";
    return nullptr;
  }

  IMMDevice* device = nullptr;
  hr = enumerator->GetDefaultAudioEndpoint(eRender, eConsole, &device);
  enumerator->Release();
  if (FAILED(hr)) {
    std::cerr << "[LoopbackCapturer] GetDefaultAudioEndpoint failed: 0x"
              << std::hex << hr << "\n";
    return nullptr;
  }

  IAudioClient* client = nullptr;
  hr = device->Activate(__uuidof(IAudioClient), CLSCTX_ALL, nullptr,
                        reinterpret_cast<void**>(&client));
  device->Release();
  if (FAILED(hr)) {
    std::cerr << "[LoopbackCapturer] IMMDevice::Activate(IAudioClient) "
                 "failed: 0x"
              << std::hex << hr << "\n";
    return nullptr;
  }

  WAVEFORMATEX* fmt = nullptr;
  hr = client->GetMixFormat(&fmt);
  if (FAILED(hr)) {
    client->Release();
    return nullptr;
  }

  hr = client->Initialize(
      AUDCLNT_SHAREMODE_SHARED,
      AUDCLNT_STREAMFLAGS_LOOPBACK | AUDCLNT_STREAMFLAGS_EVENTCALLBACK,
      /*hnsBufferDuration=*/0,
      /*hnsPeriodicity=*/0,
      fmt,
      nullptr);

  if (FAILED(hr)) {
    std::cerr << "[LoopbackCapturer] IAudioClient::Initialize (classic) "
                 "failed: 0x"
              << std::hex << hr << "\n";
    CoTaskMemFree(fmt);
    client->Release();
    return nullptr;
  }

  mix_format_ = fmt;
  std::cout << "[LoopbackCapturer] Using classic WASAPI loopback path.\n";
  return client;
}

// ---------------------------------------------------------------------------
// CaptureThread
// Runs on a dedicated thread. Reads WASAPI frames and forwards them to the
// RTCAudioSource via CaptureFrame().
// ---------------------------------------------------------------------------
void ApplicationLoopbackCapturer::CaptureThread() {
  CoInitializeEx(nullptr, COINIT_MULTITHREADED);

  // Elevate thread priority for audio work.
  DWORD task_index = 0;
  HANDLE task = AvSetMmThreadCharacteristicsW(L"Audio", &task_index);

  const int sample_rate = static_cast<int>(mix_format_->nSamplesPerSec);
  const size_t channels = mix_format_->nChannels;
  const int bits = mix_format_->wBitsPerSample;

  // Determine whether the device produces IEEE float samples.
  bool is_float = (mix_format_->wFormatTag == WAVE_FORMAT_IEEE_FLOAT);
  if (mix_format_->wFormatTag == WAVE_FORMAT_EXTENSIBLE) {
    auto* ext = reinterpret_cast<WAVEFORMATEXTENSIBLE*>(mix_format_);
    // KSDATAFORMAT_SUBTYPE_IEEE_FLOAT GUID
    static const GUID kSubtypeFloat = {
        0x00000003, 0x0000, 0x0010,
        {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}};
    is_float = (ext->SubFormat == kSubtypeFloat);
  }

  while (running_) {
    DWORD wait_result =
        WaitForSingleObject(buffer_ready_event_, /*dwMilliseconds=*/200);
    if (!running_) break;
    if (wait_result == WAIT_TIMEOUT) continue;
    if (wait_result != WAIT_OBJECT_0) break;

    UINT32 packet_size = 0;
    while (SUCCEEDED(capture_client_->GetNextPacketSize(&packet_size)) &&
           packet_size > 0) {
      BYTE* data = nullptr;
      UINT32 num_frames = 0;
      DWORD flags = 0;

      HRESULT hr = capture_client_->GetBuffer(&data, &num_frames, &flags,
                                              nullptr, nullptr);
      if (FAILED(hr)) break;

      if (!(flags & AUDCLNT_BUFFERFLAGS_SILENT) && source_ && num_frames > 0) {
        if (is_float && bits == 32) {
          // Convert float32 → int16 before passing to WebRTC.
          size_t total_samples =
              static_cast<size_t>(num_frames) * channels;
          if (conv_buf_.size() < total_samples)
            conv_buf_.resize(total_samples);
          F32ToI16(reinterpret_cast<const float*>(data), conv_buf_.data(),
                   total_samples);
          source_->CaptureFrame(conv_buf_.data(), /*bits_per_sample=*/16,
                                sample_rate, channels, num_frames);
        } else {
          // Pass through for 16-bit PCM or other formats; WebRTC will handle.
          source_->CaptureFrame(data, bits, sample_rate, channels, num_frames);
        }
      }

      capture_client_->ReleaseBuffer(num_frames);
    }
  }

  if (task) AvRevertMmThreadCharacteristics(task);
  CoUninitialize();
}

// ---------------------------------------------------------------------------
// F32ToI16 — convert IEEE-float [-1.0, 1.0] to int16_t PCM
// ---------------------------------------------------------------------------
/*static*/ void ApplicationLoopbackCapturer::F32ToI16(const float* src,
                                                       int16_t* dst,
                                                       size_t count) {
  for (size_t i = 0; i < count; ++i) {
    float v = src[i];
    if (v > 1.0f) v = 1.0f;
    if (v < -1.0f) v = -1.0f;
    dst[i] = static_cast<int16_t>(v * 32767.0f);
  }
}

}  // namespace flutter_webrtc_plugin

#endif  // _WIN32
