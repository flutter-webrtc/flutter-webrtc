use std::sync::Arc;

use derive_more::{Deref, DerefMut};
use flutter_rust_bridge::{self as frb, support::IntoDart};

/// [`flutter_rust_bridge`]'s [`StreamSink`] wrapper that is automatically
/// closed once [`Drop`]ped.
///
/// [`StreamSink`]: frb::StreamSink
#[derive(Clone, Deref, DerefMut)]
pub struct StreamSink<T: IntoDart>(Arc<frb::StreamSink<T>>);

impl<T: IntoDart> From<frb::StreamSink<T>> for StreamSink<T> {
    fn from(val: frb::StreamSink<T>) -> Self {
        Self(Arc::new(val))
    }
}

impl<T: IntoDart> Drop for StreamSink<T> {
    fn drop(&mut self) {
        if let Some(sink) = Arc::get_mut(&mut self.0) {
            sink.close();
        }
    }
}
