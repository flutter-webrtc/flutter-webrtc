#ifndef FLUTTER_RTC_AUDIO_SINK_INTERFACE_H
#define FLUTTER_RTC_AUDIO_SINK_INTERFACE_H

void RTCAudioSinkCallback (void *object,
                           const void *audio_data,
                           int bits_per_sample,
                           int sample_rate,
                           size_t number_of_channels,
                           size_t number_of_frames);

#endif // FLUTTER_RTC_AUDIO_SINK_INTERFACE_H