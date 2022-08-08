#pragma once

#ifdef __OBJC__
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#endif

void set_on_device_change(void (*cb)());