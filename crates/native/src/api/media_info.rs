//! Information about media devices and displays.

/// Possible kinds of media devices.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MediaDeviceKind {
    /// Audio input device (for example, a microphone).
    AudioInput,

    /// Audio output device (for example, a pair of headphones).
    AudioOutput,

    /// Video input device (for example, a webcam).
    VideoInput,
}

/// Information describing a single media input or output device.
#[derive(Debug)]
pub struct MediaDeviceInfo {
    /// Unique identifier for the represented device.
    pub device_id: String,

    /// Kind of the represented device.
    pub kind: MediaDeviceKind,

    /// Label describing the represented device.
    pub label: String,
}

/// Information describing a display.
#[derive(Debug)]
pub struct MediaDisplayInfo {
    /// Unique identifier of the device representing the display.
    pub device_id: String,

    /// Title describing the represented display.
    pub title: Option<String>,
}
