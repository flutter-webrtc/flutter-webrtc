//! Bridge for native platforms.

#![deny(nonstandard_style, rustdoc::all, trivial_casts, trivial_numeric_casts)]
#![forbid(non_ascii_idents)]
#![warn(
    clippy::absolute_paths,
    clippy::allow_attributes,
    clippy::allow_attributes_without_reason,
    clippy::as_conversions,
    clippy::as_pointer_underscore,
    clippy::as_ptr_cast_mut,
    clippy::assertions_on_result_states,
    clippy::branches_sharing_code,
    clippy::cfg_not_test,
    clippy::clear_with_drain,
    clippy::clone_on_ref_ptr,
    clippy::collection_is_never_read,
    clippy::create_dir,
    clippy::dbg_macro,
    clippy::debug_assert_with_mut_call,
    clippy::decimal_literal_representation,
    clippy::default_union_representation,
    clippy::derive_partial_eq_without_eq,
    clippy::doc_include_without_cfg,
    clippy::empty_drop,
    clippy::empty_structs_with_brackets,
    clippy::equatable_if_let,
    clippy::empty_enum_variants_with_brackets,
    clippy::exit,
    clippy::expect_used,
    clippy::fallible_impl_from,
    clippy::filetype_is_file,
    clippy::float_cmp_const,
    clippy::fn_to_numeric_cast_any,
    clippy::format_push_string,
    clippy::get_unwrap,
    clippy::if_then_some_else_none,
    clippy::imprecise_flops,
    clippy::infinite_loop,
    clippy::iter_on_empty_collections,
    clippy::iter_on_single_items,
    clippy::iter_over_hash_type,
    clippy::iter_with_drain,
    clippy::large_include_file,
    clippy::large_stack_frames,
    clippy::let_underscore_untyped,
    clippy::literal_string_with_formatting_args,
    clippy::lossy_float_literal,
    clippy::map_err_ignore,
    clippy::map_with_unused_argument_over_ranges,
    clippy::mem_forget,
    clippy::missing_assert_message,
    clippy::missing_asserts_for_indexing,
    clippy::missing_const_for_fn,
    clippy::missing_docs_in_private_items,
    clippy::module_name_repetitions,
    clippy::multiple_inherent_impl,
    clippy::multiple_unsafe_ops_per_block,
    clippy::mutex_atomic,
    clippy::mutex_integer,
    clippy::needless_collect,
    clippy::needless_pass_by_ref_mut,
    clippy::needless_raw_strings,
    clippy::non_zero_suggestions,
    clippy::nonstandard_macro_braces,
    clippy::option_if_let_else,
    clippy::or_fun_call,
    clippy::panic_in_result_fn,
    clippy::partial_pub_fields,
    clippy::pathbuf_init_then_push,
    clippy::pedantic,
    clippy::print_stderr,
    clippy::print_stdout,
    clippy::pub_without_shorthand,
    clippy::rc_buffer,
    clippy::rc_mutex,
    clippy::read_zero_byte_vec,
    clippy::redundant_clone,
    clippy::redundant_type_annotations,
    clippy::renamed_function_params,
    clippy::ref_patterns,
    clippy::rest_pat_in_fully_bound_structs,
    clippy::same_name_method,
    clippy::semicolon_inside_block,
    clippy::set_contains_or_insert,
    clippy::shadow_unrelated,
    clippy::significant_drop_in_scrutinee,
    clippy::significant_drop_tightening,
    clippy::str_to_string,
    clippy::string_add,
    clippy::string_lit_as_bytes,
    clippy::string_lit_chars_any,
    clippy::string_slice,
    clippy::string_to_string,
    clippy::suboptimal_flops,
    clippy::suspicious_operation_groupings,
    clippy::suspicious_xor_used_as_pow,
    clippy::tests_outside_test_module,
    clippy::todo,
    clippy::too_long_first_doc_paragraph,
    clippy::trailing_empty_array,
    clippy::transmute_undefined_repr,
    clippy::trivial_regex,
    clippy::try_err,
    clippy::undocumented_unsafe_blocks,
    clippy::unimplemented,
    clippy::uninhabited_references,
    clippy::unnecessary_safety_comment,
    clippy::unnecessary_safety_doc,
    clippy::unnecessary_self_imports,
    clippy::unnecessary_struct_initialization,
    clippy::unused_peekable,
    clippy::unused_result_ok,
    clippy::unused_trait_names,
    clippy::unwrap_in_result,
    clippy::unwrap_used,
    clippy::use_debug,
    clippy::use_self,
    clippy::useless_let_if_seq,
    clippy::verbose_file_reads,
    clippy::while_float,
    clippy::wildcard_enum_match_arm,
    ambiguous_negative_literals,
    closure_returning_async_block,
    future_incompatible,
    impl_trait_redundant_captures,
    let_underscore_drop,
    macro_use_extern_crate,
    meta_variable_misuse,
    missing_abi,
    missing_copy_implementations,
    missing_debug_implementations,
    missing_docs,
    redundant_lifetimes,
    rust_2018_idioms,
    single_use_lifetimes,
    unit_bindings,
    unnameable_types,
    unreachable_pub,
    unstable_features,
    unused,
    variant_size_differences
)]
// TODO: Revisit and apply granular.
#![expect( // needs refactoring
    clippy::as_conversions,
    clippy::missing_errors_doc,
    clippy::missing_docs_in_private_items,
    clippy::missing_panics_doc,
    clippy::multiple_inherent_impl,
    clippy::partial_pub_fields,
    clippy::undocumented_unsafe_blocks,
    clippy::unwrap_in_result,
    clippy::unwrap_used,
    missing_copy_implementations,
    missing_debug_implementations,
    unnameable_types,
    unreachable_pub,
    reason = "needs refactoring"
)]

pub mod api;
#[expect( // codegen
    clippy::absolute_paths,
    clippy::allow_attributes_without_reason,
    clippy::as_conversions,
    clippy::cast_lossless,
    clippy::cast_possible_truncation,
    clippy::cast_possible_wrap,
    clippy::redundant_else,
    clippy::semicolon_if_nothing_returned,
    clippy::significant_drop_tightening,
    clippy::too_many_lines,
    clippy::undocumented_unsafe_blocks,
    clippy::unimplemented,
    clippy::uninlined_format_args,
    clippy::unreadable_literal,
    clippy::unused_trait_names,
    clippy::use_self,
    clippy::wildcard_imports,
    unit_bindings,
    reason = "codegen"
)]
#[rustfmt::skip]
mod frb_generated;
mod devices;
pub mod frb;
mod pc;
mod renderer;
mod user_media;
pub mod video_sink;

use std::{
    collections::HashMap,
    sync::{
        Arc, LazyLock,
        atomic::{AtomicU32, Ordering},
    },
};

use dashmap::DashMap;
use libwebrtc_sys as sys;
use threadpool::ThreadPool;

#[doc(inline)]
pub use crate::{
    devices::DevicesState,
    pc::{
        PeerConnection, RtpEncodingParameters, RtpParameters, RtpTransceiver,
    },
    user_media::{
        AudioDeviceId, AudioDeviceModule, AudioSource, AudioTrack,
        AudioTrackId, MediaStreamId, VideoDeviceId, VideoDeviceInfo,
        VideoSource, VideoTrack, VideoTrackId,
    },
    video_sink::VideoSink,
};
use crate::{user_media::TrackOrigin, video_sink::Id as VideoSinkId};

/// Main [`ThreadPool`] used by [`flutter_rust_bridge`] when calling
/// synchronous Rust code to avoid locking [`libwebrtc`] threads.
///
/// [`libwebrtc`]: libwebrtc_sys
pub(crate) static THREADPOOL: LazyLock<ThreadPool> =
    LazyLock::new(|| ThreadPool::with_name("fltr-wbrtc-pool".into(), 4));

/// Counter used to generate unique IDs.
static ID_COUNTER: AtomicU32 = AtomicU32::new(1);

/// Returns a next unique ID.
pub(crate) fn next_id() -> u32 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

/// Global context for an application.
pub struct Webrtc {
    video_device_info: VideoDeviceInfo,
    video_sources: HashMap<VideoDeviceId, Arc<VideoSource>>,
    video_tracks: Arc<DashMap<(VideoTrackId, TrackOrigin), VideoTrack>>,
    audio_sources: HashMap<AudioDeviceId, Arc<AudioSource>>,
    audio_tracks: Arc<DashMap<(AudioTrackId, TrackOrigin), AudioTrack>>,
    video_sinks: HashMap<VideoSinkId, VideoSink>,
    ap: sys::AudioProcessing,
    devices_state: DevicesState,

    /// `peer_connection_factory` must be dropped before [`Thread`]s.
    peer_connection_factory: sys::PeerConnectionFactoryInterface,
    _task_queue_factory: sys::TaskQueueFactory,
    audio_device_module: AudioDeviceModule,
    worker_thread: sys::Thread,
    signaling_thread: sys::Thread,
}

impl Webrtc {
    /// Creates a new [`Webrtc`] context.
    fn new() -> anyhow::Result<Self> {
        let mut task_queue_factory =
            sys::TaskQueueFactory::create_default_task_queue_factory();

        let mut worker_thread = sys::Thread::create(false)?;
        worker_thread.start()?;

        let mut signaling_thread = sys::Thread::create(false)?;
        signaling_thread.start()?;

        let ap = sys::AudioProcessing::new()?;
        let mut config = ap.config();
        config.set_gain_controller_enabled(true);
        ap.apply_config(&config);

        let audio_device_module = AudioDeviceModule::new(
            &mut worker_thread,
            sys::AudioLayer::kPlatformDefaultAudio,
            &mut task_queue_factory,
            Some(&ap),
        )?;

        let peer_connection_factory =
            sys::PeerConnectionFactoryInterface::create(
                None,
                Some(&worker_thread),
                Some(&signaling_thread),
                Some(audio_device_module.as_ref()),
                Some(&ap),
            )?;

        let mut this = Self {
            _task_queue_factory: task_queue_factory,
            worker_thread,
            signaling_thread,
            ap,
            devices_state: DevicesState::default(),
            audio_device_module,
            video_device_info: VideoDeviceInfo::new()?,
            peer_connection_factory,
            video_sources: HashMap::new(),
            video_tracks: Arc::new(DashMap::new()),
            audio_sources: HashMap::new(),
            audio_tracks: Arc::new(DashMap::new()),
            video_sinks: HashMap::new(),
        };

        this.devices_state.audio_inputs =
            this.enumerate_audio_input_devices()?;
        this.devices_state.audio_outputs =
            this.enumerate_audio_output_devices()?;
        this.devices_state.video_inputs =
            this.enumerate_video_input_devices()?;

        devices::init_on_device_change();

        Ok(this)
    }
}

/// Compares strings in `const` context.
///
/// As there is no `const impl Trait` and `l == r` calls [`Eq`], we have to
/// write custom comparison function.
///
/// [`Eq`]: trait@Eq
// TODO: Remove once `Eq` trait is allowed in `const` context.
const fn str_eq(l: &str, r: &str) -> bool {
    if l.len() != r.len() {
        return false;
    }

    let (l, r) = (l.as_bytes(), r.as_bytes());
    let mut i = 0;
    while i < l.len() {
        if l[i] != r[i] {
            return false;
        }
        i += 1;
    }

    true
}
