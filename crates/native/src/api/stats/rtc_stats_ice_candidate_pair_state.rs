//! State of a candidate from a checklist.

use libwebrtc_sys as sys;

/// Each candidate pair in the check list has a foundation and a state.
///
/// The foundation is the combination of the foundations of the local and remote
/// candidates in the pair. The state is assigned once the check list for each
/// media stream has been computed. There are five potential values that the
/// state can have.
pub enum RtcStatsIceCandidatePairState {
    /// Check for this pair hasn't been performed, and it can't yet be performed
    /// until some other check succeeds, allowing this pair to unfreeze and move
    /// into the [`RtcStatsIceCandidatePairState::Waiting`] state.
    Frozen,

    /// Check has not been performed for this pair, and can be performed as soon
    /// as it is the highest-priority Waiting pair on the check list.
    Waiting,

    /// Check has been sent for this pair, but the transaction is in progress.
    InProgress,

    /// Check for this pair was already done and failed, either never producing
    /// any response or producing an unrecoverable failure response.
    Failed,

    /// Check for this pair was already done and produced a successful result.
    Succeeded,
}

impl From<sys::RTCStatsIceCandidatePairState>
    for RtcStatsIceCandidatePairState
{
    fn from(state: sys::RTCStatsIceCandidatePairState) -> Self {
        match state {
            sys::RTCStatsIceCandidatePairState::kFrozen => Self::Frozen,
            sys::RTCStatsIceCandidatePairState::kWaiting => Self::Waiting,
            sys::RTCStatsIceCandidatePairState::kInProgress => Self::InProgress,
            sys::RTCStatsIceCandidatePairState::kFailed => Self::Failed,
            sys::RTCStatsIceCandidatePairState::kSucceeded => Self::Succeeded,
            _ => unreachable!(),
        }
    }
}
