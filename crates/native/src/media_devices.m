#include "media_devices.h"

#ifdef __APPLE__
// Callback for default output audio device changes.
//
// Just calls `onDeviceChange` callback.
OSStatus callbackFunction(AudioObjectID inObjectID,
                            UInt32 inNumberAddresses,
                            const AudioObjectPropertyAddress inAddresses[],
                            void *inClientData) {
    void (*callback)() = (void (*)())inClientData;
    callback();
    return 0;
}

// Registers the provided function to be called when `NSNotificationCenter`
// detects that an `AVCaptureDevice` was connected or disconnected or default
// output audio device was changed.
void set_on_device_change_mac(void(*cb)()) {
  AudioObjectPropertyAddress outputDeviceAddress = {
    kAudioHardwarePropertyDefaultOutputDevice,
    kAudioObjectPropertyScopeGlobal,
    kAudioObjectPropertyElementMaster
  };
  AudioObjectAddPropertyListener(kAudioObjectSystemObject,
                                 &outputDeviceAddress,
                                 &callbackFunction, cb);
  
  AudioObjectPropertyAddress inputDeviceAddress = {
    kAudioHardwarePropertyDefaultInputDevice,
    kAudioObjectPropertyScopeGlobal,
    kAudioObjectPropertyElementMaster
  };
  AudioObjectAddPropertyListener(kAudioObjectSystemObject,
                                 &inputDeviceAddress,
                                 &callbackFunction, cb);
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification
      object:nil
      queue:[NSOperationQueue mainQueue]
      usingBlock:^(NSNotification *note) {
        cb();
      }];
  [notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification
      object:nil
      queue:[NSOperationQueue mainQueue]
      usingBlock:^(NSNotification *note) {
        cb();
      }];
}
#endif
