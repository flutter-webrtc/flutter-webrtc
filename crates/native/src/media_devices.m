#include "media_devices.h"

#ifdef __APPLE__
// Registers the provided function to be called when `NSNotificationCenter`
// detects that an `AVCaptureDevice` was connected or disconnected.
void set_on_device_change_mac(void(*cb)()) {
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
