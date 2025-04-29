/*
 *  Copyright 2012 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

/// Source https://webrtc.googlesource.com/src/+/master/api/media_stream_interface.h

#ifdef __cplusplus
#ifndef API_MEDIA_STREAM_INTERFACE_H_
#define API_MEDIA_STREAM_INTERFACE_H_

#include <stddef.h>
#include <string>
#include <vector>
#include <memory>
#include <utility>

namespace webrtc {

    // Generic observer interface.
    class ObserverInterface {
    public:
        virtual void OnChanged() = 0;
    protected:
        virtual ~ObserverInterface() {}
    };
    class NotifierInterface {
    public:
        virtual void RegisterObserver(ObserverInterface* observer) = 0;
        virtual void UnregisterObserver(ObserverInterface* observer) = 0;
        virtual ~NotifierInterface() {}
    };
    
    enum class RefCountReleaseStatus { kDroppedLastRef, kOtherRefsRemained };
    // Interfaces where refcounting is part of the public api should
    // inherit this abstract interface. The implementation of these
    // methods is usually provided by the RefCountedObject template class,
    // applied as a leaf in the inheritance tree.
    class RefCountInterface {
    public:
        virtual void AddRef() const = 0;
        virtual RefCountReleaseStatus Release() const = 0;
        // Non-public destructor, because Release() has exclusive responsibility for
        // destroying the object.
    protected:
        virtual ~RefCountInterface() {}
    };

    // Base class for sources. A MediaStreamTrack has an underlying source that
    // provides media. A source can be shared by multiple tracks.
    class MediaSourceInterface : public RefCountInterface,
                                 public NotifierInterface {
    public:
        enum SourceState { kInitializing, kLive, kEnded, kMuted };
        virtual SourceState state() const = 0;
        virtual bool remote() const = 0;
    protected:
        ~MediaSourceInterface() override = default;
    };

    // Interface for receiving audio data from a AudioTrack.
    class AudioTrackSinkInterface {
    public:
        virtual void OnData(const void* audio_data,
                            int bits_per_sample,
                            int sample_rate,
                            size_t number_of_channels,
                            size_t number_of_frames) {
            
        };
        virtual void OnData(const void* audio_data,
                            int bits_per_sample,
                            int sample_rate,
                            size_t number_of_channels,
                            size_t number_of_frames,
                            void* absolute_capture_timestamp_ms) {
          // TODO(bugs.webrtc.org/10739): Deprecate the old OnData and make this one
          // pure virtual.
          return OnData(audio_data, bits_per_sample, sample_rate, number_of_channels,
                        number_of_frames);
        }
        virtual int NumPreferredChannels() const { return -1; }
    protected:
        virtual ~AudioTrackSinkInterface() {}
    };
    // AudioSourceInterface is a reference counted source used for AudioTracks.
    // The same source can be used by multiple AudioTracks.
    class AudioSourceInterface : public MediaSourceInterface {
    public:
        class AudioObserver {
        public:
            virtual void OnSetVolume(double volume) = 0;
        protected:
            virtual ~AudioObserver() {}
        };
        // TODO(deadbeef): Makes all the interfaces pure virtual after they're
        // implemented in chromium.
        // Sets the volume of the source. |volume| is in  the range of [0, 10].
        // TODO(tommi): This method should be on the track and ideally volume should
        // be applied in the track in a way that does not affect clones of the track.
        virtual void SetVolume(double volume) {}
        // Registers/unregisters observers to the audio source.
        virtual void RegisterAudioObserver(AudioObserver* observer) {}
        virtual void UnregisterAudioObserver(AudioObserver* observer) {}
        // TODO(tommi): Make pure virtual.
        virtual void AddSink(AudioTrackSinkInterface* sink) {}
        virtual void RemoveSink(AudioTrackSinkInterface* sink) {}
        // Returns options for the AudioSource.
        // (for some of the settings this approach is broken, e.g. setting
        // audio network adaptation on the source is the wrong layer of abstraction).
//        virtual const AudioOptions options() const;
    };
}
namespace rtc {
    
    template <class T>
    class scoped_refptr {
     public:
      typedef T element_type;
      scoped_refptr() : ptr_(nullptr) {}
      scoped_refptr(std::nullptr_t) : ptr_(nullptr) {}  // NOLINT(runtime/explicit)
      explicit scoped_refptr(T* p) : ptr_(p) {
        if (ptr_)
          ptr_->AddRef();
      }
      scoped_refptr(const scoped_refptr<T>& r) : ptr_(r.ptr_) {
        if (ptr_)
          ptr_->AddRef();
      }
      template <typename U>
      scoped_refptr(const scoped_refptr<U>& r) : ptr_(r.get()) {
        if (ptr_)
          ptr_->AddRef();
      }
      // Move constructors.
      scoped_refptr(scoped_refptr<T>&& r) noexcept : ptr_(r.release()) {}
      template <typename U>
      scoped_refptr(scoped_refptr<U>&& r) noexcept : ptr_(r.release()) {}
      ~scoped_refptr() {
        if (ptr_)
          ptr_->Release();
      }
      T* get() const { return ptr_; }
      explicit operator bool() const { return ptr_ != nullptr; }
      T& operator*() const { return *ptr_; }
      T* operator->() const { return ptr_; }
      // Returns the (possibly null) raw pointer, and makes the scoped_refptr hold a
      // null pointer, all without touching the reference count of the underlying
      // pointed-to object. The object is still reference counted, and the caller of
      // release() is now the proud owner of one reference, so it is responsible for
      // calling Release() once on the object when no longer using it.
      T* release() {
        T* retVal = ptr_;
        ptr_ = nullptr;
        return retVal;
      }
      scoped_refptr<T>& operator=(T* p) {
        // AddRef first so that self assignment should work
        if (p)
          p->AddRef();
        if (ptr_)
          ptr_->Release();
        ptr_ = p;
        return *this;
      }
      scoped_refptr<T>& operator=(const scoped_refptr<T>& r) {
        return *this = r.ptr_;
      }
      template <typename U>
      scoped_refptr<T>& operator=(const scoped_refptr<U>& r) {
        return *this = r.get();
      }
      scoped_refptr<T>& operator=(scoped_refptr<T>&& r) noexcept {
        scoped_refptr<T>(std::move(r)).swap(*this);
        return *this;
      }
      template <typename U>
      scoped_refptr<T>& operator=(scoped_refptr<U>&& r) noexcept {
        scoped_refptr<T>(std::move(r)).swap(*this);
        return *this;
      }
      void swap(T** pp) noexcept {
        T* p = ptr_;
        ptr_ = *pp;
        *pp = p;
      }
      void swap(scoped_refptr<T>& r) noexcept { swap(&r.ptr_); }
     protected:
      T* ptr_;
    };
};

#endif  // API_MEDIA_STREAM_INTERFACE_H_
#endif  // __cplusplus
