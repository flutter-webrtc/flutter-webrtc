#include "media_stream_interface.h"
#include "FlutterRTCAudioSink-Interface.h"

class AudioSinkBridge : public webrtc::AudioTrackSinkInterface {
private:
    void* sink;

public:
    AudioSinkBridge(void* sink1) {
        sink = sink1;
    }
    void OnData(const void* audio_data,
                        int bits_per_sample,
                        int sample_rate,
                        size_t number_of_channels,
                        size_t number_of_frames) override
    {
        RTCAudioSinkCallback(sink,
                             audio_data,
                             bits_per_sample,
                             sample_rate,
                             number_of_channels,
                             number_of_frames
        );
    };
    int NumPreferredChannels() const override { return 1; }
};
