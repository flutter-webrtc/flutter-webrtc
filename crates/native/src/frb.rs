//! [`FrbHandler`] implementation which is a custom [`Handler`] based on the
//! [`SimpleHandler`].
//!
//! [`Handler`]: flutter_rust_bridge::Handler

use flutter_rust_bridge::{
    BaseAsyncRuntime, JoinHandle, SimpleThreadPool,
    handler::{NoOpErrorListener, SimpleExecutor, SimpleHandler},
};

use crate::THREADPOOL;

/// [`SimpleHandler`] that uses [`NoOpErrorListener`],
/// [`UnreachableAsyncRuntime`] and [`SimpleThreadPool`].
#[expect(clippy::module_name_repetitions, reason = "avoiding confusion")]
pub type FrbHandler = SimpleHandler<
    SimpleExecutor<
        NoOpErrorListener,
        SimpleThreadPool,
        UnreachableAsyncRuntime,
    >,
    NoOpErrorListener,
>;

/// Creates a new [`FrbHandler`].
#[must_use]
pub fn new_frb_handler() -> FrbHandler {
    SimpleHandler::new(
        SimpleExecutor::new(
            NoOpErrorListener,
            SimpleThreadPool(THREADPOOL.clone()),
            UnreachableAsyncRuntime,
        ),
        NoOpErrorListener,
    )
}

/// [`BaseAsyncRuntime`] that panics on use.
pub struct UnreachableAsyncRuntime;

impl BaseAsyncRuntime for UnreachableAsyncRuntime {
    fn spawn<F>(&self, _: F) -> JoinHandle<F::Output>
    where
        F: Future + Send + 'static,
        F::Output: Send + 'static,
    {
        // TODO: We don't need async runtime but there is no way to turn it off
        //       in `flutter_rust_bridge` (`tokio` runtime is created even when
        //       "rust-async" Cargo feature is disabled).
        unreachable!("no async runtime available")
    }
}
