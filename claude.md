# Brain Inbox — Project Context (source of truth)

> Read this file fully before writing any code. `AGENTS.md` defines *how* to work.
> `docs/ai-extraction-contract.md` defines the core IP. `docs/roadmap.md` defines phases + edge cases.

---

## 1. Mission

Brain Inbox is a mobile app (Flutter) that turns messy spoken thoughts into clear, actionable items. The user records a short voice note while their head is full; the app transcribes it, extracts structured items, the user does a *light* review, and saves them to an inbox.

Promise: **"Speak messy. Get clear actions."**

It is **not** a notes app, voice recorder, task manager, or audio-summarizer. It is a *mental inbox* that captures intent before it's lost.

---

## 2. North star — what v0.1 is validating (read this twice)

We are **not** validating "can the AI extract well" as a number. We are validating:

> **Does the transformation (messy speech → clean actions) create enough pull for the user to come back and capture again tomorrow?**

This is a **habit / retention** bet, not an extraction-accuracy bet. The reward that drives the habit IS the transformation. Two consequences that govern every decision in this repo:

1. **Friction kills the habit.** Capture must be near-zero friction, and *review must be minimized*, not maximized. Default-accept, edit-by-exception.
2. **The AI is the reward, so it must be real from day 1.** Never mock the AI service — mocking it means running the experiment without the variable under test.

Primary metric: **repeat-capture rate (D1 / D7 return-and-capture).**
Secondary metric (quality): **capture-to-action rate** = items saved / items proposed.

---

## 3. Core loop

`Open → Record → Transcribe → Extract → Light review → Save → Inbox`

Rules baked into the loop:
- The AI proposes; the user confirms. Never auto-save without the user seeing items.
- The app never invents data. Missing date/time → `null` + `needsReview = true`.
- Concrete actions beat pretty summaries.
- Notes are short: 10s–2min. Not lectures, not meetings, not podcasts.
- Support EN and ES; preserve the user's original language. App UI is in English.

---

## 4. Item taxonomy — COLLAPSED to two types (do not expand)

The original brief had 5 types (task / follow-up / reminder / event / idea). For v0.1 we collapse to **two**, because more types = inconsistent classification = more taps in review = more friction (the thing we're trying to remove).

| type     | meaning                              | nuance encoded via optional fields |
|----------|--------------------------------------|------------------------------------|
| `action` | something the user has to do         | `person` set → it's a follow-up; `dateTime` set → it's event/time-bound; neither → it's a reminder |
| `idea`   | a thought that isn't actionable yet  | usually no person/date             |

**Do not add a third type.** task/follow-up/reminder/event all map to `action` + optional fields. Re-expanding the taxonomy is a v0.2 decision gated on real review data.

---

## 5. Data model

```
VoiceNote
  id: String (uuid)
  audioPath: String?      // local backup only, may be null/off by default
  transcript: String      // verbatim, original language
  language: String        // "es" | "en" (as spoken)
  durationMs: int
  createdAt: DateTime

Item
  id: String (uuid)
  voiceNoteId: String      // FK -> VoiceNote.id
  type: ItemType           // enum { action, idea }  <-- only these two
  title: String
  note: String?            // optional detail
  dateTime: DateTime?      // null if unclear -> needsReview = true
  person: String?          // who to contact, if any
  confidence: double       // 0.0..1.0 from extraction
  needsReview: bool        // true if date/intent ambiguous or low confidence
  isDone: bool             // toggled in Inbox
  isSaved: bool            // user kept it in review (feeds capture-to-action)
  createdAt: DateTime

AppEvent                   // minimal local instrumentation for the habit test
  id: String
  type: String             // "app_open" | "capture_started" | "capture_saved" | ...
  timestamp: DateTime
  metaJson: String?        // e.g. itemsProposed/itemsSaved counts
```

No backend, no auth, no sync in v0.1. Everything local. `AppEvent` is local-only and exportable; no third-party analytics SDK yet.

---

## 6. Screens (each has ONE job — don't bloat them)

1. **Home / Capture** — *job: push the user to capture.* App name, a prompt line ("What's on your mind?"), a big record button, pending-actions count, short list of recent captures, entry to Inbox. Not a dashboard.
2. **Recording** — *job: record without friction.* Timer + recording state + stop. After stop, show processing state.
3. **Review** — *job: confirm fast.* **This is minimized, not a form.** Items grouped by `action` / `idea`, one line each, **all selected to save by default**. Tap an item to quick-edit title/date/person; swipe to delete. Transcript is secondary (collapsed, tap to expand). One primary button: **Save to Brain Inbox.** The feeling target: "it understood my chaos and ordered it" — achieved by *not* making me fill forms.
4. **Actions Inbox** — *job: see what's pending.* Saved items; filters: Today / Upcoming / No date / Done; mark done; edit; tap to view source capture.
5. **Capture Detail** *(optional in v0.1)* — transcript + items + audio (if saved) + capture date.

---

## 7. Recording / processing state machine

Model as a sealed class, not loose bools:

`Idle → Recording → Transcribing → Extracting → Review → (Saved)`
plus `Error` reachable from Transcribing/Extracting (with retry, keeping audio + transcript).

---

## 8. Trigger (decided: in scope for v0.1)

A daily capture habit needs a trigger; a pure-pull app tests habit on hard mode. v0.1 includes:
- **Home-screen widget** (one tap → opens straight into Recording), and
- **Share-sheet target** ("share to Brain Inbox" for text/voice).

**No push notifications** in v0.1 (out of scope, revisit in v0.2).

---

## 9. Architecture & stack

- **Flutter** (stable), **Dart 3**, strict null-safety.
- **State management: Riverpod** (`flutter_riverpod`). Reactive providers fed by DB streams.
- **Local DB: Drift** (SQLite). Chosen for typed, reactive `.watch()` queries so the Inbox updates automatically when items change. (Fallback only if codegen friction blocks: `sqflite` + manual DAOs — note it in `plan.md` before switching.)
- **Audio recording:** `record`. **Playback:** `just_audio`.
- **AI:** an abstract `AiService` interface with two methods — `transcribe(File audio, {String? languageHint})` and `extractItems(String transcript, {required DateTime now, required String tz})`. The **only** implementation in v0.1 is the real `OpenAiAiService`. See `docs/ai-extraction-contract.md`. Keep a thin HTTP client (`dio`) over the documented OpenAI endpoints; do not depend on the AI being swappable to a mock.
- **Config:** API key + model names via `--dart-define` / env. **Never** hardcode or commit secrets or model strings into business logic — they live in one config file.

Suggested layout (feature-first):
```
lib/
  app/            // app entry, routing, theme stub
  core/           // config, result types, errors, uuid, datetime helpers
  data/
    db/           // Drift database + tables + DAOs
    models/       // VoiceNote, Item, ItemType, processing state
    ai/           // AiService interface + OpenAiAiService + DTOs/parsing
    repositories/ // CaptureRepository, InboxRepository, AnalyticsRepository
  features/
    capture/      // home + recording + processing controllers/widgets
    review/       // review screen + controller
    inbox/        // actions inbox + filters
```

---

## 10. Metrics / instrumentation (for the habit test)

Derive what you can from data; log the rest as `AppEvent`:
- repeat-capture: count distinct days with ≥1 capture per user (D1/D7 return).
- capture-to-action: `itemsSaved / itemsProposed` per VoiceNote (store both counts in the `capture_saved` event meta).
- time-to-first-capture and capture duration (friction signals).
No dashboards needed in v0.1 — local log that can be exported.

---

## 11. Coding conventions (owner's rules)

- Strict null-safety. **Avoid `dynamic`** and unsafe casts; model states with enums/sealed classes.
- `flutter analyze` must be clean (0 issues) before anything is "done".
- **No throwaway comments.** Code should be self-documenting; comment only non-obvious *why*.
- Errors are surfaced to the UI, never silently swallowed. AI failure → `Error` state + retry, **never** fabricated items.
- Small, typed functions over clever one-liners.
- Tests: at minimum, unit tests for AI response parsing + repository logic.

---

## 12. Current phase

**v0.1 — validation build.** Build only what's needed to run a 7–14 day habit test with 5–10 target users (founders/operators/students/freelancers/sales). Anything not on the v0.1 list in `docs/roadmap.md` is out. When in doubt, it's out.