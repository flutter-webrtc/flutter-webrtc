#pragma once

#ifdef __OBJC__
#import <AVFoundation/AVFoundation.h>
#endif

#ifdef __APPLE__
void set_on_device_change_mac(void(*cb)());
#endif