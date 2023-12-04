use anyhow::anyhow;
use cxx::UniquePtr;
use derive_more::{AsMut, AsRef};
use libwebrtc_sys as sys;

use crate::{
    renderer::FrameHandler, user_media::TrackOrigin, VideoTrackId, Webrtc,
};

impl Webrtc {
    /// Creates a new [`VideoSink`].
    pub fn create_video_sink(
        &mut self,
        sink_id: i64,
        track_id: String,
        track_origin: TrackOrigin,
        handler: FrameHandler,
    ) -> anyhow::Result<()> {
        self.dispose_video_sink(sink_id);

        let track_id = VideoTrackId::from(track_id);
        let mut sink = VideoSink {
            id: Id(sink_id),
            inner: sys::VideoSinkInterface::create_forwarding(Box::new(
                OnFrameCallback(handler),
            )),
            track_id: track_id.clone(),
            track_origin,
        };

        let mut track = self
            .video_tracks
            .get_mut(&(track_id.clone(), track_origin))
            .ok_or_else(|| anyhow!("Cannot find track with ID `{track_id}`"))?;
        track.add_video_sink(&mut sink);

        self.video_sinks.insert(Id(sink_id), sink);

        Ok(())
    }

    /// Destroys a [`VideoSink`] by the given ID.
    pub fn dispose_video_sink(&mut self, sink_id: i64) {
        if let Some(sink) = self.video_sinks.remove(&Id(sink_id)) {
            if let Some(mut track) = self
                .video_tracks
                .get_mut(&(sink.track_id.clone(), sink.track_origin))
            {
                track.remove_video_sink(sink);
            }
        }
    }
}

/// ID of a [`VideoSink`].
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub struct Id(i64);

/// Wrapper around a [`sys::VideoSink`] attaching a unique ID to it.
#[derive(AsRef, AsMut)]
pub struct VideoSink {
    /// ID of this [`VideoSink`].
    id: Id,

    /// Underlying [`sys::VideoSinkInterface`].
    #[as_ref]
    #[as_mut]
    inner: sys::VideoSinkInterface,

    /// ID of the [`VideoTrack`] attached to this [`VideoSink`].
    track_id: VideoTrackId,

    /// Origin (local or remote) of the [`VideoTrack`] attached to this
    /// [`VideoSink`].
    track_origin: TrackOrigin,
}

impl VideoSink {
    /// Creates a new [`VideoSink`].
    #[must_use]
    pub fn new(
        id: i64,
        sink: sys::VideoSinkInterface,
        track_id: VideoTrackId,
        track_origin: TrackOrigin,
    ) -> Self {
        Self {
            id: Id(id),
            inner: sink,
            track_id,
            track_origin,
        }
    }

    /// Returns an [`Id`] of this [`VideoSink`].
    #[must_use]
    pub fn id(&self) -> Id {
        self.id
    }
}

/// Wrapper around an [`internal::OnFrameCallbackInterface`] implementing the
/// required interfaces.
struct OnFrameCallback(FrameHandler);

impl libwebrtc_sys::OnFrameCallback for OnFrameCallback {
    fn on_frame(&mut self, frame: UniquePtr<sys::VideoFrame>) {
        self.0.on_frame(frame);
    }
}
