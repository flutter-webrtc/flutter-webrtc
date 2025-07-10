//! [`Track`] related definitions.

use std::{
    collections::{HashMap, HashSet},
    mem,
    sync::{Arc, OnceLock, RwLock},
};

use derive_more::{
    Deref, DerefMut, Display,
    with_trait::{From, Into},
};
use libwebrtc_sys as sys;

use crate::{
    AudioSource, PeerConnection, VideoSink, VideoSinkId, VideoSource, api,
    frb_generated::StreamSink,
    media::MediaTrackSource,
    next_id,
    pc::{PeerConnectionId, RtpTransceiver},
};

/// Indication whether some [`Track`] is a local one (obtained via
/// [getUserMedia()][1]/[getDisplayMedia()][2] call) or a remote (received in a
/// [ontrack][3] callback).
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediadevices-getusermedia
/// [2]: https://w3.org/TR/screen-capture/#dom-mediadevices-getdisplaymedia
/// [3]: https://w3.org/TR/webrtc/#dom-rtcpeerconnection-ontrack
#[derive(Clone, Copy, Debug, Eq, From, Hash, PartialEq)]
pub enum TrackOrigin {
    /// Local [`Track`].
    Local,

    /// Remote [`Track`].
    Remote(PeerConnectionId),
}

impl From<Option<PeerConnectionId>> for TrackOrigin {
    fn from(value: Option<PeerConnectionId>) -> Self {
        value.map_or(Self::Local, Self::Remote)
    }
}

/// ID of a [`VideoTrack`].
#[derive(Clone, Debug, Display, From, Eq, Hash, Into, PartialEq)]
pub struct VideoTrackId(String);

/// ID of an [`AudioTrack`].
#[derive(Clone, Debug, Display, From, Eq, Hash, Into, PartialEq)]
pub struct AudioTrackId(String);

mod kind {
    //! Different kinds of a [`Track`].

    use std::sync::{Arc, OnceLock, RwLock};

    use derive_more::{Deref, DerefMut};
    use libwebrtc_sys as sys;

    #[cfg(doc)]
    use super::{AudioTrack, Track, VideoTrack};
    use crate::{
        AudioSource, AudioTrackId, VideoSink, VideoSinkId, VideoSource,
        VideoTrackId, api,
        frb_generated::StreamSink,
        media::{
            AudioLevelObserverId, MediaTrackSource,
            source::AudioSourceAudioLevelHandler, track::VideoDimensions,
        },
    };

    /// Representation of a [`sys::VideoTrackInterface`].
    #[derive(Deref, DerefMut)]
    pub struct Video {
        /// ID of this [`VideoTrack`].
        pub id: VideoTrackId,

        /// [`MediaTrackSource`] that is used by this [`VideoTrack`].
        pub source: MediaTrackSource<VideoSource>,

        /// Underlying [`sys::VideoTrackInterface`].
        #[deref]
        #[deref_mut]
        pub inner: sys::VideoTrackInterface,

        /// List of the [`VideoSink`]s attached to this [`VideoTrack`].
        pub sinks: Vec<VideoSinkId>,

        /// [`VideoTrack`]'s changes in video `height` and `width`.
        pub sink: Option<VideoSink>,

        /// Video dimensions.
        pub dimensions: Arc<OnceLock<RwLock<VideoDimensions>>>,
    }

    impl Video {
        /// Adds the provided [`VideoSink`] to this [`VideoTrack`].
        pub fn add_video_sink(&mut self, video_sink: &mut VideoSink) {
            self.inner.add_or_update_sink(video_sink.as_mut());
            self.sinks.push(video_sink.id());
        }

        /// Detaches the provided [`VideoSink`] from this [`VideoTrack`].
        pub fn remove_video_sink(&mut self, mut video_sink: VideoSink) {
            self.sinks.retain(|&sink| sink != video_sink.id());
            self.inner.remove_sink(video_sink.as_mut());
        }
    }

    impl Drop for Video {
        fn drop(&mut self) {
            let sink = self.sink.take().unwrap();
            self.remove_video_sink(sink);
        }
    }

    /// Representation of a [`sys::AudioTrackInterface`].
    #[derive(Deref, DerefMut)]
    pub struct Audio {
        /// ID of this [`AudioTrack`].
        pub id: AudioTrackId,

        /// [`AudioSource`] that is used by this [`AudioTrack`].
        pub source: MediaTrackSource<AudioSource>,

        /// Underlying [`sys::AudioTrackInterface`].
        #[deref]
        #[deref_mut]
        pub inner: sys::AudioTrackInterface,

        /// [`AudioLevelObserverId`] related to this [`AudioTrack`].
        ///
        /// This ID can be used when this [`AudioTrack`] needs to dispose its
        /// observer.
        pub volume_observer_id: Option<AudioLevelObserverId>,
    }

    impl Audio {
        /// Subscribes this [`AudioTrack`] to audio level updates.
        ///
        /// Volume updates will be passed to the `stream_sink` of this
        /// [`AudioTrack`].
        pub fn subscribe_to_audio_level(
            &mut self,
            track_events_tx: Option<StreamSink<api::TrackEvent>>,
        ) {
            if let Some(sink) = track_events_tx {
                match &self.source {
                    MediaTrackSource::Local(src) => {
                        let observer = src.subscribe_on_audio_level(
                            AudioSourceAudioLevelHandler::new(sink),
                        );
                        self.volume_observer_id = Some(observer);
                    }
                    MediaTrackSource::Remote { mid: _, peer: _ } => (),
                }
            }
        }

        /// Unsubscribes this [`AudioTrack`] from audio level updates.
        pub fn unsubscribe_from_audio_level(&self) {
            match &self.source {
                MediaTrackSource::Local(src) => {
                    if let Some(id) = self.volume_observer_id {
                        src.unsubscribe_audio_level(id);
                    }
                }
                MediaTrackSource::Remote { mid: _, peer: _ } => (),
            }
        }
    }

    impl Drop for Audio {
        fn drop(&mut self) {
            self.unsubscribe_from_audio_level();
        }
    }
}

type SendersMap = HashMap<Arc<PeerConnection>, HashSet<Arc<RtpTransceiver>>>;

/// Representation of a generic track interface.
#[derive(Deref, DerefMut)]
pub struct Track<T> {
    /// Indicator whether this is a remote or a local track.
    origin: TrackOrigin,

    /// Kind of this [`Track`].
    #[deref(forward)]
    #[deref_mut(forward)]
    kind: T,

    /// `StreamSink` which can be used by this [`Track`] to emit
    /// [`api::TrackEvent`]s to Flutter side.
    events_tx: Option<StreamSink<api::TrackEvent>>,

    /// Peers and transceivers sending this [`Track`].
    senders: SendersMap,
}

impl<T> Track<T> {
    /// Emits [`api::TrackEvent::Ended`] to the Flutter side.
    pub fn notify_on_ended(&mut self) {
        if let Some(sink) = self.events_tx.take() {
            _ = sink.add(api::TrackEvent::Ended);
        }
    }

    /// Sets the provided `StreamSink` for this [`Track`] to use for
    /// [`api::TrackEvent`]s emitting.
    pub fn set_track_events_tx(&mut self, sink: StreamSink<api::TrackEvent>) {
        drop(self.events_tx.replace(sink));
    }

    /// Adds the provided [`RtpTransceiver`] to senders of this [`Track`].
    pub fn add_transceiver(
        &mut self,
        peer: Arc<PeerConnection>,
        transceiver: Arc<RtpTransceiver>,
    ) {
        self.senders.entry(peer).or_default().insert(transceiver);
    }

    /// Removes the specified [`RtpTransceiver`] from senders of this [`Track`].
    pub fn remove_transceiver(
        &mut self,
        peer: &Arc<PeerConnection>,
        transceiver: &Arc<RtpTransceiver>,
    ) {
        if let Some(transceivers) = self.senders.get_mut(peer) {
            transceivers.retain(|current| current != transceiver);

            if !transceivers.is_empty() {
                return;
            }
        }

        self.senders.remove(peer);
    }

    /// Removes the specified [`PeerConnection`] and its [`RtpTransceiver`]s
    /// from senders of this [`Track`].
    pub fn remove_peer(&mut self, peer: &Arc<PeerConnection>) {
        self.senders.remove(peer);
    }

    /// Takes all the sending [`PeerConnection`]s and [`RtpTransceiver`]s from
    /// this [`Track`].
    // TODO: Replace mutable key type with something else.
    #[expect(clippy::mutable_key_type, reason = "needs refactoring")]
    #[must_use]
    pub fn take_senders(&mut self) -> SendersMap {
        mem::take(&mut self.senders)
    }

    /// Returns all the [`PeerConnection`]s and [`RtpTransceiver`]s sending this
    /// [`Track`].
    // TODO: Replace mutable key type with something else.
    #[expect(clippy::mutable_key_type, reason = "needs refactoring")]
    #[must_use]
    pub const fn senders(&self) -> &SendersMap {
        &self.senders
    }
}

/// Representation of a video [`Track`] interface.
pub type VideoTrack = Track<kind::Video>;

impl VideoTrack {
    /// Returns ID of this [`VideoTrack`].
    #[must_use]
    pub fn id(&self) -> VideoTrackId {
        self.kind.id.clone()
    }

    /// Returns [`VideoSource`] that is used by this [`VideoTrack`].
    #[must_use]
    pub const fn source(&self) -> &MediaTrackSource<VideoSource> {
        &self.kind.source
    }

    /// Returns the [readyState][0] property of the underlying
    /// [`sys::VideoTrackInterface`].
    ///
    /// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
    pub(super) fn state(&self) -> api::TrackState {
        self.kind.inner.state().into()
    }

    /// Changes the [enabled][1] property of the underlying
    /// [`sys::VideoTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub(super) fn set_enabled(&self, enabled: bool) {
        self.kind.inner.set_enabled(enabled);
    }

    /// Creates a new local [`VideoTrack`].
    pub(super) fn create_local(
        pc: &sys::PeerConnectionFactoryInterface,
        src: Arc<VideoSource>,
    ) -> anyhow::Result<Self> {
        let id = VideoTrackId(next_id().to_string());
        let track_origin = TrackOrigin::Local;

        let dimensions = Arc::new(OnceLock::new());
        let mut sink = VideoSink::new(
            i64::from(next_id()),
            sys::VideoSinkInterface::create_forwarding(Box::new(
                VideoFormatSink { dimensions: Arc::clone(&dimensions) },
            )),
            id.clone(),
            track_origin,
        );

        let mut res = Self {
            kind: kind::Video {
                id: id.clone(),
                inner: pc
                    .create_video_track(id.into(), src.as_ref().as_ref())?,
                sinks: Vec::new(),
                dimensions,
                sink: None,
                source: MediaTrackSource::Local(src),
            },
            senders: HashMap::new(),
            events_tx: None,
            origin: track_origin,
        };

        res.add_video_sink(&mut sink);
        res.kind.sink = Some(sink);

        Ok(res)
    }

    /// Wraps the `transceiver.receiver.track()` into a [`VideoTrack`].
    pub(crate) fn wrap_remote(
        transceiver: &sys::RtpTransceiverInterface,
        peer: &Arc<PeerConnection>,
    ) -> Self {
        let receiver = transceiver.receiver();
        let track = receiver.track();
        let track_origin = TrackOrigin::Remote(peer.id());

        let dimensions = Arc::new(OnceLock::new());
        dimensions
            .set(RwLock::from(VideoDimensions { width: 0, height: 0 }))
            .unwrap();
        let mut sink = VideoSink::new(
            i64::from(next_id()),
            sys::VideoSinkInterface::create_forwarding(Box::new(
                VideoFormatSink { dimensions: Arc::clone(&dimensions) },
            )),
            VideoTrackId(track.id()),
            track_origin,
        );

        let mut res = Self {
            kind: kind::Video {
                id: VideoTrackId(track.id()),
                inner: track.try_into().unwrap(),
                sinks: Vec::new(),
                dimensions,
                sink: None,
                // PANIC: Unwrapping is OK here, since the `transceiver` is
                //        guaranteed to be negotiated at this point.
                source: MediaTrackSource::Remote {
                    mid: transceiver.mid().unwrap(),
                    peer: Arc::downgrade(peer),
                },
            },
            senders: HashMap::new(),
            events_tx: None,
            origin: track_origin,
        };

        res.add_video_sink(&mut sink);
        res.kind.sink = Some(sink);

        res
    }

    /// Adds the provided [`VideoSink`] to this [`VideoTrack`].
    pub fn add_video_sink(&mut self, video_sink: &mut VideoSink) {
        self.kind.add_video_sink(video_sink);
    }

    /// Detaches the provided [`VideoSink`] from this [`VideoTrack`].
    pub fn remove_video_sink(&mut self, video_sink: VideoSink) {
        self.kind.remove_video_sink(video_sink);
    }

    /// Returns dimensions of this [`VideoTrack`].
    #[must_use]
    pub fn dimensions(&self) -> VideoDimensions {
        *self.kind.dimensions.wait().read().unwrap()
    }

    /// Returns list of the [`VideoSink`]s attached to this [`VideoTrack`].
    #[must_use]
    pub const fn sinks(&self) -> &Vec<VideoSinkId> {
        &self.kind.sinks
    }
}

impl From<&VideoTrack> for api::MediaStreamTrack {
    fn from(track: &VideoTrack) -> Self {
        Self {
            id: track.id().0,
            device_id: match track.source() {
                MediaTrackSource::Local(src) => src.device_id().to_string(),
                MediaTrackSource::Remote { .. } => "remote".into(),
            },
            kind: api::MediaType::Video,
            enabled: true,
            peer_id: match track.origin {
                TrackOrigin::Local => None,
                TrackOrigin::Remote(peer_id) => Some(peer_id.into()),
            },
        }
    }
}

/// Dimensions of a [`VideoTrack`].
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub struct VideoDimensions {
    /// Video width.
    width: i32,

    /// Video height.
    height: i32,
}

impl VideoDimensions {
    /// Returns width of the [`VideoTrack`].
    #[must_use]
    pub const fn width(self) -> i32 {
        self.width
    }

    /// Returns height of the [`VideoTrack`].
    #[must_use]
    pub const fn height(self) -> i32 {
        self.height
    }
}

/// [`sys::OnFrameCallback`] tracking changes in video's height and width.
struct VideoFormatSink {
    /// Dimensions of the video.
    dimensions: Arc<OnceLock<RwLock<VideoDimensions>>>,
}

impl sys::OnFrameCallback for VideoFormatSink {
    fn on_frame(&mut self, frame: cxx::UniquePtr<sys::VideoFrame>) {
        let dimensions =
            VideoDimensions { width: frame.width(), height: frame.height() };

        if self.dimensions.get().is_none() {
            self.dimensions.set(RwLock::from(dimensions)).unwrap();
        } else {
            *self.dimensions.get().unwrap().write().unwrap() = dimensions;
        }
    }
}

/// Representation of an audio [`Track`] interface.
pub type AudioTrack = Track<kind::Audio>;

impl AudioTrack {
    /// Returns ID of this [`AudioTrack`].
    #[must_use]
    pub fn id(&self) -> AudioTrackId {
        self.kind.id.clone()
    }

    /// Returns [`AudioSource`] that is used by this [`AudioTrack`].
    #[must_use]
    pub const fn source(&self) -> &MediaTrackSource<AudioSource> {
        &self.kind.source
    }

    /// Returns the [readyState][0] property of the underlying
    /// [`sys::AudioTrackInterface`].
    ///
    /// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
    pub(super) fn state(&self) -> api::TrackState {
        self.kind.inner.state().into()
    }

    /// Changes the [enabled][1] property of the underlying
    /// [`sys::AudioTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub(super) fn set_enabled(&self, enabled: bool) {
        self.kind.inner.set_enabled(enabled);
    }

    /// Creates a new [`AudioTrack`].
    ///
    /// # Errors
    ///
    /// Whenever [`sys::PeerConnectionFactoryInterface::create_audio_track()`]
    /// errors.
    pub fn new(
        pc: &sys::PeerConnectionFactoryInterface,
        src: Arc<AudioSource>,
        track_origin: TrackOrigin,
    ) -> anyhow::Result<Self> {
        let id = AudioTrackId(next_id().to_string());
        Ok(Self {
            kind: kind::Audio {
                id: id.clone(),
                inner: pc
                    .create_audio_track(id.into(), src.as_ref().as_ref())?,
                volume_observer_id: None,
                source: MediaTrackSource::Local(src),
            },
            senders: HashMap::new(),
            origin: track_origin,
            events_tx: None,
        })
    }

    /// Subscribes this [`AudioTrack`] to audio level updates.
    ///
    /// Volume updates will be passed to the `stream_sink` of this
    /// [`AudioTrack`].
    pub fn subscribe_to_audio_level(&mut self) {
        self.kind.subscribe_to_audio_level(self.events_tx.clone());
    }

    /// Unsubscribes this [`AudioTrack`] from audio level updates.
    pub fn unsubscribe_from_audio_level(&self) {
        self.kind.unsubscribe_from_audio_level();
    }

    /// Wraps the `transceiver.receiver.track()` into an [`AudioTrack`].
    pub(crate) fn wrap_remote(
        transceiver: &sys::RtpTransceiverInterface,
        peer: &Arc<PeerConnection>,
    ) -> Self {
        let receiver = transceiver.receiver();
        let track = receiver.track();
        Self {
            kind: kind::Audio {
                id: AudioTrackId(track.id()),
                inner: track.try_into().unwrap(),
                volume_observer_id: None,
                // PANIC: Unwrapping is OK here, since the `transceiver` is
                //        guaranteed to be negotiated at this point.
                source: MediaTrackSource::Remote {
                    mid: transceiver.mid().unwrap(),
                    peer: Arc::downgrade(peer),
                },
            },
            senders: HashMap::new(),
            origin: TrackOrigin::Remote(peer.id()),
            events_tx: None,
        }
    }
}
impl From<&AudioTrack> for api::MediaStreamTrack {
    fn from(track: &AudioTrack) -> Self {
        Self {
            id: track.id().0,
            device_id: match track.source() {
                MediaTrackSource::Local(local) => local.device_id().to_string(),
                MediaTrackSource::Remote { mid: _, peer: _ } => "remote".into(),
            },
            kind: api::MediaType::Audio,
            enabled: true,
            peer_id: match track.origin {
                TrackOrigin::Local => None,
                TrackOrigin::Remote(peer_id) => Some(peer_id.into()),
            },
        }
    }
}

/// Wrapper around a [`TrackObserverInterface`] implementing a
/// [`sys::TrackEventCallback`].
pub struct TrackEventHandler(StreamSink<api::TrackEvent>);

impl TrackEventHandler {
    /// Creates a new [`TrackEventHandler`] with the provided [`StreamSink`].
    ///
    /// Sends an [`api::TrackEvent::TrackCreated`] to the provided
    /// [`StreamSink`].
    pub fn new(cb: StreamSink<api::TrackEvent>) -> Self {
        _ = cb.add(api::TrackEvent::TrackCreated);
        Self(cb)
    }
}

impl sys::TrackEventCallback for TrackEventHandler {
    fn on_ended(&mut self) {
        _ = self.0.add(api::TrackEvent::Ended);
    }
}
