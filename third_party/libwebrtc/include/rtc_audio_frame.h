#ifndef AUDIO_FRAME_HXX
#define AUDIO_FRAME_HXX

#include "media_manager_types.h"

namespace b2bua {

class AudioFrame {
 public:
  /**
   * @brief Creates a new instance of AudioFrame.
   * @return AudioFrame*: a pointer to the newly created AudioFrame.
   */
  MEDIA_MANAGER_API static AudioFrame* Create();

  /**
   * @brief Creates a new instance of AudioFrame with specified parameters.
   * @param id: the unique identifier of the frame.
   * @param timestamp: the timestamp of the frame.
   * @param data: a pointer to the audio data buffer.
   * @param samples_per_channel: the number of samples per channel.
   * @param sample_rate_hz: the sample rate in Hz.
   * @param num_channels: the number of audio channels.
   * @return AudioFrame*: a pointer to the newly created AudioFrame.
   */
  MEDIA_MANAGER_API static AudioFrame* Create(int id, uint32_t timestamp,
                                              const int16_t* data,
                                              size_t samples_per_channel,
                                              int sample_rate_hz,
                                              size_t num_channels = 1);

  /**
   * @brief Releases the memory of this AudioFrame.
   */
  virtual void Release() = 0;

 public:
  /**
   * @brief Updates the audio frame with specified parameters.
   * @param id: the unique identifier of the frame.
   * @param timestamp: the timestamp of the frame.
   * @param data: a pointer to the audio data buffer.
   * @param samples_per_channel: the number of samples per channel.
   * @param sample_rate_hz: the sample rate in Hz.
   * @param num_channels: the number of audio channels.
   */
  virtual void UpdateFrame(int id, uint32_t timestamp, const int16_t* data,
                           size_t samples_per_channel, int sample_rate_hz,
                           size_t num_channels = 1) = 0;

  /**
   * @brief Copies the contents of another AudioFrame.
   * @param src: the source AudioFrame to copy from.
   */
  virtual void CopyFrom(const AudioFrame& src) = 0;

  /**
   * @brief Adds another AudioFrame to this one.
   * @param frame_to_add: the AudioFrame to add.
   */
  virtual void Add(const AudioFrame& frame_to_add) = 0;

  /**
   * @brief Mutes the audio data in this AudioFrame.
   */
  virtual void Mute() = 0;

  /**
   * @brief Returns a pointer to the audio data buffer.
   * @return const int16_t*: a pointer to the audio data buffer.
   */
  virtual const int16_t* data() = 0;

  /**
   * @brief Returns the number of samples per channel.
   * @return size_t: the number of samples per channel.
   */
  virtual size_t samples_per_channel() = 0;

  /**
   * @brief Returns the sample rate in Hz.
   * @return int: the sample rate in Hz.
   */
  virtual int sample_rate_hz() = 0;

  /**
   * @brief Returns the number of audio channels.
   * @return size_t: the number of audio channels.
   */
  virtual size_t num_channels() = 0;

  /**
   * @brief Returns the timestamp of the AudioFrame.
   * @return uint32_t: the timestamp of the AudioFrame.
   */
  virtual uint32_t timestamp() = 0;

  /**
   * @brief Returns the unique identifier of the AudioFrame.
   * @return int: the unique identifier of the AudioFrame.
   */

  virtual int id() = 0;
};

};  // namespace b2bua

#endif
