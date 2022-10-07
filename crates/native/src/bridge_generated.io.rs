use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_enable_fake_media(port_: i64) {
    wire_enable_fake_media_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_is_fake_media(port_: i64) {
    wire_is_fake_media_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_enumerate_devices(port_: i64) {
    wire_enumerate_devices_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_enumerate_displays(port_: i64) {
    wire_enumerate_displays_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_create_peer_connection(
    port_: i64,
    configuration: *mut wire_RtcConfiguration,
) {
    wire_create_peer_connection_impl(port_, configuration)
}

#[no_mangle]
pub extern "C" fn wire_create_offer(
    port_: i64,
    peer_id: u64,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) {
    wire_create_offer_impl(
        port_,
        peer_id,
        voice_activity_detection,
        ice_restart,
        use_rtp_mux,
    )
}

#[no_mangle]
pub extern "C" fn wire_create_answer(
    port_: i64,
    peer_id: u64,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) {
    wire_create_answer_impl(
        port_,
        peer_id,
        voice_activity_detection,
        ice_restart,
        use_rtp_mux,
    )
}

#[no_mangle]
pub extern "C" fn wire_set_local_description(
    port_: i64,
    peer_id: u64,
    kind: i32,
    sdp: *mut wire_uint_8_list,
) {
    wire_set_local_description_impl(port_, peer_id, kind, sdp)
}

#[no_mangle]
pub extern "C" fn wire_set_remote_description(
    port_: i64,
    peer_id: u64,
    kind: i32,
    sdp: *mut wire_uint_8_list,
) {
    wire_set_remote_description_impl(port_, peer_id, kind, sdp)
}

#[no_mangle]
pub extern "C" fn wire_add_transceiver(
    port_: i64,
    peer_id: u64,
    media_type: i32,
    direction: i32,
) {
    wire_add_transceiver_impl(port_, peer_id, media_type, direction)
}

#[no_mangle]
pub extern "C" fn wire_get_transceivers(port_: i64, peer_id: u64) {
    wire_get_transceivers_impl(port_, peer_id)
}

#[no_mangle]
pub extern "C" fn wire_set_transceiver_direction(
    port_: i64,
    peer_id: u64,
    transceiver_index: u32,
    direction: i32,
) {
    wire_set_transceiver_direction_impl(
        port_,
        peer_id,
        transceiver_index,
        direction,
    )
}

#[no_mangle]
pub extern "C" fn wire_set_transceiver_recv(
    port_: i64,
    peer_id: u64,
    transceiver_index: u32,
    recv: bool,
) {
    wire_set_transceiver_recv_impl(port_, peer_id, transceiver_index, recv)
}

#[no_mangle]
pub extern "C" fn wire_set_transceiver_send(
    port_: i64,
    peer_id: u64,
    transceiver_index: u32,
    send: bool,
) {
    wire_set_transceiver_send_impl(port_, peer_id, transceiver_index, send)
}

#[no_mangle]
pub extern "C" fn wire_get_transceiver_mid(
    port_: i64,
    peer_id: u64,
    transceiver_index: u32,
) {
    wire_get_transceiver_mid_impl(port_, peer_id, transceiver_index)
}

#[no_mangle]
pub extern "C" fn wire_get_transceiver_direction(
    port_: i64,
    peer_id: u64,
    transceiver_index: u32,
) {
    wire_get_transceiver_direction_impl(port_, peer_id, transceiver_index)
}

#[no_mangle]
pub extern "C" fn wire_get_peer_stats(port_: i64, peer_id: u64) {
    wire_get_peer_stats_impl(port_, peer_id)
}

#[no_mangle]
pub extern "C" fn wire_stop_transceiver(
    port_: i64,
    peer_id: u64,
    transceiver_index: u32,
) {
    wire_stop_transceiver_impl(port_, peer_id, transceiver_index)
}

#[no_mangle]
pub extern "C" fn wire_sender_replace_track(
    port_: i64,
    peer_id: u64,
    transceiver_index: u32,
    track_id: *mut wire_uint_8_list,
) {
    wire_sender_replace_track_impl(port_, peer_id, transceiver_index, track_id)
}

#[no_mangle]
pub extern "C" fn wire_add_ice_candidate(
    port_: i64,
    peer_id: u64,
    candidate: *mut wire_uint_8_list,
    sdp_mid: *mut wire_uint_8_list,
    sdp_mline_index: i32,
) {
    wire_add_ice_candidate_impl(
        port_,
        peer_id,
        candidate,
        sdp_mid,
        sdp_mline_index,
    )
}

#[no_mangle]
pub extern "C" fn wire_restart_ice(port_: i64, peer_id: u64) {
    wire_restart_ice_impl(port_, peer_id)
}

#[no_mangle]
pub extern "C" fn wire_dispose_peer_connection(port_: i64, peer_id: u64) {
    wire_dispose_peer_connection_impl(port_, peer_id)
}

#[no_mangle]
pub extern "C" fn wire_get_media(
    port_: i64,
    constraints: *mut wire_MediaStreamConstraints,
) {
    wire_get_media_impl(port_, constraints)
}

#[no_mangle]
pub extern "C" fn wire_set_audio_playout_device(
    port_: i64,
    device_id: *mut wire_uint_8_list,
) {
    wire_set_audio_playout_device_impl(port_, device_id)
}

#[no_mangle]
pub extern "C" fn wire_microphone_volume_is_available(port_: i64) {
    wire_microphone_volume_is_available_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_set_microphone_volume(port_: i64, level: u8) {
    wire_set_microphone_volume_impl(port_, level)
}

#[no_mangle]
pub extern "C" fn wire_microphone_volume(port_: i64) {
    wire_microphone_volume_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_dispose_track(
    port_: i64,
    track_id: *mut wire_uint_8_list,
    kind: i32,
) {
    wire_dispose_track_impl(port_, track_id, kind)
}

#[no_mangle]
pub extern "C" fn wire_track_state(
    port_: i64,
    track_id: *mut wire_uint_8_list,
    kind: i32,
) {
    wire_track_state_impl(port_, track_id, kind)
}

#[no_mangle]
pub extern "C" fn wire_set_track_enabled(
    port_: i64,
    track_id: *mut wire_uint_8_list,
    kind: i32,
    enabled: bool,
) {
    wire_set_track_enabled_impl(port_, track_id, kind, enabled)
}

#[no_mangle]
pub extern "C" fn wire_clone_track(
    port_: i64,
    track_id: *mut wire_uint_8_list,
    kind: i32,
) {
    wire_clone_track_impl(port_, track_id, kind)
}

#[no_mangle]
pub extern "C" fn wire_register_track_observer(
    port_: i64,
    track_id: *mut wire_uint_8_list,
    kind: i32,
) {
    wire_register_track_observer_impl(port_, track_id, kind)
}

#[no_mangle]
pub extern "C" fn wire_set_on_device_changed(port_: i64) {
    wire_set_on_device_changed_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_create_video_sink(
    port_: i64,
    sink_id: i64,
    track_id: *mut wire_uint_8_list,
    callback_ptr: u64,
) {
    wire_create_video_sink_impl(port_, sink_id, track_id, callback_ptr)
}

#[no_mangle]
pub extern "C" fn wire_dispose_video_sink(port_: i64, sink_id: i64) {
    wire_dispose_video_sink_impl(port_, sink_id)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_StringList_0(len: i32) -> *mut wire_StringList {
    let wrap = wire_StringList {
        ptr: support::new_leak_vec_ptr(
            <*mut wire_uint_8_list>::new_with_null_ptr(),
            len,
        ),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_audio_constraints_0(
) -> *mut wire_AudioConstraints {
    support::new_leak_box_ptr(wire_AudioConstraints::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_media_stream_constraints_0(
) -> *mut wire_MediaStreamConstraints {
    support::new_leak_box_ptr(wire_MediaStreamConstraints::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_rtc_configuration_0(
) -> *mut wire_RtcConfiguration {
    support::new_leak_box_ptr(wire_RtcConfiguration::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_video_constraints_0(
) -> *mut wire_VideoConstraints {
    support::new_leak_box_ptr(wire_VideoConstraints::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_list_rtc_ice_server_0(
    len: i32,
) -> *mut wire_list_rtc_ice_server {
    let wrap = wire_list_rtc_ice_server {
        ptr: support::new_leak_vec_ptr(
            <wire_RtcIceServer>::new_with_null_ptr(),
            len,
        ),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<Vec<String>> for *mut wire_StringList {
    fn wire2api(self) -> Vec<String> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<AudioConstraints> for wire_AudioConstraints {
    fn wire2api(self) -> AudioConstraints {
        AudioConstraints {
            device_id: self.device_id.wire2api(),
        }
    }
}

impl Wire2Api<AudioConstraints> for *mut wire_AudioConstraints {
    fn wire2api(self) -> AudioConstraints {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<AudioConstraints>::wire2api(*wrap).into()
    }
}
impl Wire2Api<MediaStreamConstraints> for *mut wire_MediaStreamConstraints {
    fn wire2api(self) -> MediaStreamConstraints {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<MediaStreamConstraints>::wire2api(*wrap).into()
    }
}
impl Wire2Api<RtcConfiguration> for *mut wire_RtcConfiguration {
    fn wire2api(self) -> RtcConfiguration {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<RtcConfiguration>::wire2api(*wrap).into()
    }
}
impl Wire2Api<VideoConstraints> for *mut wire_VideoConstraints {
    fn wire2api(self) -> VideoConstraints {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<VideoConstraints>::wire2api(*wrap).into()
    }
}

impl Wire2Api<Vec<RtcIceServer>> for *mut wire_list_rtc_ice_server {
    fn wire2api(self) -> Vec<RtcIceServer> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<MediaStreamConstraints> for wire_MediaStreamConstraints {
    fn wire2api(self) -> MediaStreamConstraints {
        MediaStreamConstraints {
            audio: self.audio.wire2api(),
            video: self.video.wire2api(),
        }
    }
}

impl Wire2Api<RtcConfiguration> for wire_RtcConfiguration {
    fn wire2api(self) -> RtcConfiguration {
        RtcConfiguration {
            ice_transport_policy: self.ice_transport_policy.wire2api(),
            bundle_policy: self.bundle_policy.wire2api(),
            ice_servers: self.ice_servers.wire2api(),
        }
    }
}
impl Wire2Api<RtcIceServer> for wire_RtcIceServer {
    fn wire2api(self) -> RtcIceServer {
        RtcIceServer {
            urls: self.urls.wire2api(),
            username: self.username.wire2api(),
            credential: self.credential.wire2api(),
        }
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
impl Wire2Api<VideoConstraints> for wire_VideoConstraints {
    fn wire2api(self) -> VideoConstraints {
        VideoConstraints {
            device_id: self.device_id.wire2api(),
            width: self.width.wire2api(),
            height: self.height.wire2api(),
            frame_rate: self.frame_rate.wire2api(),
            is_display: self.is_display.wire2api(),
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_StringList {
    ptr: *mut *mut wire_uint_8_list,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_AudioConstraints {
    device_id: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_rtc_ice_server {
    ptr: *mut wire_RtcIceServer,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_MediaStreamConstraints {
    audio: *mut wire_AudioConstraints,
    video: *mut wire_VideoConstraints,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_RtcConfiguration {
    ice_transport_policy: i32,
    bundle_policy: i32,
    ice_servers: *mut wire_list_rtc_ice_server,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_RtcIceServer {
    urls: *mut wire_StringList,
    username: *mut wire_uint_8_list,
    credential: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_VideoConstraints {
    device_id: *mut wire_uint_8_list,
    width: u32,
    height: u32,
    frame_rate: u32,
    is_display: bool,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_AudioConstraints {
    fn new_with_null_ptr() -> Self {
        Self {
            device_id: core::ptr::null_mut(),
        }
    }
}

impl NewWithNullPtr for wire_MediaStreamConstraints {
    fn new_with_null_ptr() -> Self {
        Self {
            audio: core::ptr::null_mut(),
            video: core::ptr::null_mut(),
        }
    }
}

impl NewWithNullPtr for wire_RtcConfiguration {
    fn new_with_null_ptr() -> Self {
        Self {
            ice_transport_policy: Default::default(),
            bundle_policy: Default::default(),
            ice_servers: core::ptr::null_mut(),
        }
    }
}

impl NewWithNullPtr for wire_RtcIceServer {
    fn new_with_null_ptr() -> Self {
        Self {
            urls: core::ptr::null_mut(),
            username: core::ptr::null_mut(),
            credential: core::ptr::null_mut(),
        }
    }
}

impl NewWithNullPtr for wire_VideoConstraints {
    fn new_with_null_ptr() -> Self {
        Self {
            device_id: core::ptr::null_mut(),
            width: Default::default(),
            height: Default::default(),
            frame_rate: Default::default(),
            is_display: Default::default(),
        }
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturnStruct(
    val: support::WireSyncReturnStruct,
) {
    unsafe {
        let _ = support::vec_from_leak_ptr(val.ptr, val.len);
    }
}
