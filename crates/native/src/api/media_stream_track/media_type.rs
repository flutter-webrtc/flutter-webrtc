//! Media types of a [`MediaStreamTrack`].

use libwebrtc_sys as sys;

#[cfg(doc)]
use crate::api::MediaStreamTrack;

/// Possible media types of a [`MediaStreamTrack`].
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MediaType {
    /// Audio [`MediaStreamTrack`].
    Audio,

    /// Video [`MediaStreamTrack`].
    Video,
}

impl From<MediaType> for sys::MediaType {
    fn from(state: MediaType) -> Self {
        match state {
            MediaType::Audio => Self::MEDIA_TYPE_AUDIO,
            MediaType::Video => Self::MEDIA_TYPE_VIDEO,
        }
    }
}

impl From<sys::MediaType> for MediaType {
    fn from(state: sys::MediaType) -> Self {
        match state {
            sys::MediaType::MEDIA_TYPE_AUDIO => Self::Audio,
            sys::MediaType::MEDIA_TYPE_VIDEO => Self::Video,
            _ => unreachable!(),
        }
    }
}
