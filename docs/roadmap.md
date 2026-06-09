# Roadmap & Edge Cases

## v0.1 — Validation build (current phase)

**Goal:** ship a thin but *real* app good enough to run a 7–14 day habit test with 5–10 target users (founders / operators / advanced students / freelancers / sales).

**Includes:**
- Capture → transcribe → extract → **minimal** review → local Inbox.
- Two item types only: `action`, `idea`.
- Real OpenAI transcription + extraction (no mock).
- Local-first storage (Drift), no auth, no backend, no sync.
- Trigger: home-screen widget + share-sheet target (no push).
- Local instrumentation for repeat-capture (D1/D7) and capture-to-action.

**Success signal:** users come back and capture again across days without being prompted, and they actually keep most proposed items. If they capture once and never return, the reward isn't strong enough — that's the learning.

**Explicitly excludes:** everything in the OUT list in `AGENTS.md`.

---

## v0.2 — If the habit signal is positive

Decide each of these *with data from v0.1*, not by default:
- Re-expand item types toward the original 5 **only if** review data shows users actually re-classify `action`s and want the distinction.
- Reminders / local notifications (does a nudge lift return rate?).
- Better date parsing + a calendar-style view.
- Capture Detail screen (transcript + items + audio playback).
- **First integration** (likely Calendar export) — but only if v0.1 shows items "die" in the inbox and need to land where work happens. The "second inbox / graveyard" risk is the thing this would address.

---

## v1.0 — Productize

- Auth + sync (multi-device).
- Real analytics (PostHog or similar) replacing the local event log.
- The one integration the data says matters most.
- UX polish + a monetization experiment.

---

## Edge cases (handle in v0.1)

- **Silent / empty / <2s recording** → no items, friendly empty state, no crash.
- **Recording > 2 min** → warn or cap; not the use case.
- **No network during processing** → `Error` + retry; keep audio + transcript.
- **Code-switching / mixed ES-EN in one note** → keep the dominant language; never translate.
- **Mic permission denied** → clear prompt to enable; don't dead-end.
- **Ambiguous / relative / past dates** → `dateTime = null` + `needsReview = true`.
- **Duplicate items in one note** → allow them; user deletes in review.
- **App killed mid-recording** → recover or discard cleanly; no corrupt state.
- **Mis-transcribed proper nouns / jargon** → mitigate via the transcription `prompt`; user can fix the title in review.
- **Pure venting / zero actionable content** → `items: []`; don't force items.
- **Audio files accumulating** → cap retention or make audio backup off by default (`audioPath` nullable already supports this).
- **Invalid JSON from extraction** → `Error` + retry; never fabricate.