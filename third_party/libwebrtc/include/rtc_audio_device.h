#ifndef LIB_WEBRTC_RTC_AUDIO_DEVICE_HXX
#define LIB_WEBRTC_RTC_AUDIO_DEVICE_HXX

#include "rtc_types.h"

namespace libwebrtc {

/**
 * The RTCAudioDevice class is an abstract class used for managing the audio
 * devices used by WebRTC. It provides methods for device enumeration and
 * selection.
 */
class RTCAudioDevice : public RefCountInterface {
 public:
  typedef fixed_size_function<void()> OnDeviceChangeCallback;

 public:
  static const int kAdmMaxDeviceNameSize = 128;
  static const int kAdmMaxFileNameSize = 512;
  static const int kAdmMaxGuidSize = 128;

 public:
  /**
   * Returns the number of playout devices available.
   *
   * @return int16_t - The number of playout devices available.
   */
  virtual int16_t PlayoutDevices() = 0;

  /**
   * Returns the number of recording devices available.
   *
   * @return int16_t - The number of recording devices available.
   */
  virtual int16_t RecordingDevices() = 0;

  /**
   * Retrieves the name and GUID of the specified playout device.
   *
   * @param index - The index of the device.
   * @param name - The device name.
   * @param guid - The device GUID.
   * @return int32_t - 0 if successful, otherwise an error code.
   */
  virtual int32_t PlayoutDeviceName(uint16_t index,
                                    char name[kAdmMaxDeviceNameSize],
                                    char guid[kAdmMaxGuidSize]) = 0;

  /**
   * Retrieves the name and GUID of the specified recording device.
   *
   * @param index - The index of the device.
   * @param name - The device name.
   * @param guid - The device GUID.
   * @return int32_t - 0 if successful, otherwise an error code.
   */
  virtual int32_t RecordingDeviceName(uint16_t index,
                                      char name[kAdmMaxDeviceNameSize],
                                      char guid[kAdmMaxGuidSize]) = 0;

  /**
   * Sets the playout device to use.
   *
   * @param index - The index of the device.
   * @return int32_t - 0 if successful, otherwise an error code.
   */
  virtual int32_t SetPlayoutDevice(uint16_t index) = 0;

  /**
   * Sets the recording device to use.
   *
   * @param index - The index of the device.
   * @return int32_t - 0 if successful, otherwise an error code.
   */
  virtual int32_t SetRecordingDevice(uint16_t index) = 0;

  /**
   * Registers a listener to be called when audio devices are added or removed.
   *
   * @param listener - The callback function to register.
   * @return int32_t - 0 if successful, otherwise an error code.
   */
  virtual int32_t OnDeviceChange(OnDeviceChangeCallback listener) = 0;

  virtual int32_t SetMicrophoneVolume(uint32_t volume) = 0;

  virtual int32_t MicrophoneVolume(uint32_t& volume) = 0;

  virtual int32_t SetSpeakerVolume(uint32_t volume) = 0;

  virtual int32_t SpeakerVolume(uint32_t& volume) = 0;

 protected:
  virtual ~RTCAudioDevice() {}
};

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_AUDIO_DEVICE_HXX
