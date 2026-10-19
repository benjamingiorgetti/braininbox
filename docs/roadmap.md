# Roadmap & Edge Cases

## v0.1 — Validation build ✅ done

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

## v0.2 — Go-to-market build (current phase)

**Goal:** ship 1.0 to the App Store and acquire paying US users through short-form video (TikTok/IG) — "one input → instant visual AI result → hard paywall". Target $1k MRR; solo, ~1h/day, $500 budget, EOY 2026. Scope and rules: `CLAUDE.md` §12–13.

Ordered steps:
1. **OpenAI proxy + CI secrets** — Cloudflare Worker holds the OpenAI key; Xcode Cloud injects dart-defines.
2. **Result card + share image** — shareable visual of the extracted result.
3. **Hard paywall + free-capture counter + Terms** — 3 free saves, then 3-day trial → paywall; Terms of Use page.
4. **TestFlight** — 10 users for 7 days.
5. **Creatives** — short-form videos for TikTok/IG.

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