#if __APPLE__
#include "device_info_mac.h"

// Creates a new `DeviceInfoMac`.
DeviceInfoMac::DeviceInfoMac() : DeviceInfoImpl() {
  this->device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

// Does nothing.
int32_t DeviceInfoMac::Init() {
  return 0;
}

DeviceInfoMac::~DeviceInfoMac() {}

uint32_t DeviceInfoMac::NumberOfDevices() {
  NSArray<AVCaptureDevice*>* devices =
      [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  return [devices count];
}

// Returns the unique ID and the user-friendly name of the specified endpoint
// device.
//
// Example: "{0.0.1.00000000}.{8db6020f-18e3-4f25-b6f5-7726c9122574}", and
//          "Microphone (Realtek High Definition Audio)".
int32_t DeviceInfoMac::GetDeviceName(uint32_t deviceNumber,
                                     char* deviceNameUTF8,
                                     uint32_t deviceNameLength,
                                     char* deviceUniqueIdUTF8,
                                     uint32_t deviceUniqueIdUTF8Length,
                                     char* /*productUniqueIdUTF8*/,
                                     uint32_t /*productUniqueIdUTF8Length*/) {
  NSArray<AVCaptureDevice*>* devices =
      [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  AVCaptureDevice* device = devices[deviceNumber];
  deviceNameLength = [device.localizedName length];
  memset(deviceNameUTF8, 0, deviceNameLength);
  strcpy(deviceNameUTF8, [device.localizedName UTF8String]);
  deviceUniqueIdUTF8Length = [device.uniqueID length];
  memset(deviceUniqueIdUTF8, 0, deviceUniqueIdUTF8Length);
  strcpy(deviceUniqueIdUTF8, [device.uniqueID UTF8String]);
  return 0;
}

// Unsupported. Always returns `-1`.
int32_t DeviceInfoMac::CreateCapabilityMap(const char* /*deviceUniqueIdUTF8*/) {
  return -1;
}

// Unsupported. Always returns `-1`.
int32_t DeviceInfoMac::DisplayCaptureSettingsDialogBox(const char* /*deviceUniqueIdUTF8*/,
                                                       const char* /*dialogTitleUTF8*/,
                                                       void* /*parentWindow*/,
                                                       uint32_t /*positionX*/,
                                                       uint32_t /*positionY*/) {
  return -1;
}

// Creates a new `DeviceInfo`.
std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> create_device_info_mac() {
  std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> ptr(new DeviceInfoMac());

  return ptr;
}
#endif
