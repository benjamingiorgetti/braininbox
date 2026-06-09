# Brain Inbox v0.1 — Implementation Plan

> Context: v0.1 is a habit-validation build. The north star is **repeat-capture rate**, not extraction accuracy. Every decision below serves two constraints: (1) near-zero friction, and (2) the AI reward must be real from day 1. This plan covers the full thin loop: Record → Transcribe → Extract → minimal Review → local Inbox.

## Bootstrap commands (run once, in order)

```bash
# 1. Scaffold the Flutter project (generates android/, ios/, test/ stub)
flutter create . --org com.braininbox --platforms ios,android

# 2. Get dependencies
flutter pub get

# 3. Generate Drift tables + Riverpod providers
dart run build_runner build --delete-conflicting-outputs

# 4. Verify
flutter analyze      # must be 0 issues
flutter test         # extraction parsing + repository tests

# 5. Run with secrets
flutter run \
  --dart-define=OPENAI_API_KEY=sk-... \
  --dart-define=TRANSCRIBE_MODEL=gpt-4o-mini-transcribe \
  --dart-define=EXTRACT_MODEL=gpt-5.4-mini
```

---

## 1. Project scaffold + dependency list

### pubspec.yaml — runtime dependencies

| Package | Version | Justification |
|---|---|---|
| `flutter_riverpod` | `^2.6.1` | Reactive state management; providers fed by Drift streams |
| `riverpod_annotation` | `^2.4.1` | `@riverpod` codegen for type-safe provider families |
| `drift` | `^2.21.0` | Typed SQLite ORM; `.watch()` gives reactive Inbox without manual refresh |
| `drift_flutter` | `^0.2.4` | Flutter-specific Drift setup (replaces manual sqlite3 native lib config) |
| `record` | `^5.2.0` | Cross-platform audio recording to file (m4a/wav) |
| `just_audio` | `^0.9.43` | Audio playback — wired now for future Capture Detail; no UI in v0.1 |
| `dio` | `^5.7.0` | Thin HTTP client; handles multipart/form-data (transcription) and JSON (extraction) |
| `uuid` | `^4.5.1` | RFC 4122 UUID for all entity IDs |
| `path_provider` | `^2.1.5` | Resolves app documents directory for audio file storage |
| `flutter_timezone` | `^1.0.4` | **FLAGGED** — only cross-platform way to get IANA timezone string; needed for extraction `tz` param |
| `home_widget` | `^0.7.0` | **FLAGGED** — home-screen widget bridge (Android + iOS); in scope per CLAUDE.md §8 |
| `receive_sharing_intent` | `^2.0.0` | **FLAGGED** — share-sheet target for text/file; in scope per CLAUDE.md §8 |

### pubspec.yaml — dev dependencies

| Package | Justification |
|---|---|
| `build_runner` | Code generation runner for Drift tables + Riverpod providers |
| `drift_dev` | Drift schema codegen |
| `riverpod_generator` | `@riverpod` annotation processor |
| `flutter_test` | Unit tests (parsing + repository logic) |
| `mocktail` | **FLAGGED** — mock for repository tests only; AiService is NEVER mocked |
| `flutter_lints` | Enforces linting rules; paired with analysis_options.yaml |

---

## 2. Folder structure (exact, per CLAUDE.md §9)

```
braininbox/
├── lib/
│   ├── app/
│   │   ├── app.dart                    # MaterialApp, routes, theme wiring
│   │   ├── router.dart                 # Named routes: home, review, inbox
│   │   └── theme.dart                  # Theme stub (dark, minimal)
│   ├── core/
│   │   ├── config.dart                 # dart-define reads (API key, model names)
│   │   ├── result.dart                 # Result<T, E> sealed class
│   │   ├── errors.dart                 # AiServiceError sealed class
│   │   ├── uuid_factory.dart           # Uuid().v4() wrapper
│   │   └── datetime_helpers.dart       # isPastDate(), startOfDay(), endOfDay()
│   ├── data/
│   │   ├── db/
│   │   │   ├── app_database.dart       # @DriftDatabase declaration + migrations
│   │   │   ├── tables/
│   │   │   │   ├── voice_notes.dart
│   │   │   │   ├── items.dart          # includes ItemTypeConverter
│   │   │   │   └── app_events.dart
│   │   │   └── daos/
│   │   │       ├── voice_note_dao.dart
│   │   │       ├── item_dao.dart
│   │   │       └── analytics_dao.dart
│   │   ├── models/
│   │   │   ├── voice_note.dart
│   │   │   ├── item.dart               # ItemType enum
│   │   │   └── processing_state.dart   # sealed class + ReviewItem
│   │   ├── ai/
│   │   │   ├── ai_service.dart         # abstract interface AiService
│   │   │   ├── openai_ai_service.dart  # Only implementation in v0.1
│   │   │   └── dtos/
│   │   │       ├── transcription_response.dart
│   │   │       └── extraction_response.dart
│   │   └── repositories/
│   │       ├── capture_repository.dart
│   │       ├── inbox_repository.dart
│   │       └── analytics_repository.dart
│   └── features/
│       ├── capture/
│       │   ├── home_screen.dart
│       │   ├── recording_screen.dart
│       │   └── capture_controller.dart
│       ├── review/
│       │   ├── review_screen.dart
│       │   └── review_controller.dart
│       └── inbox/
│           ├── inbox_screen.dart
│           ├── inbox_controller.dart
│           └── inbox_filter.dart
├── test/
│   ├── ai/
│   │   └── extraction_parsing_test.dart
│   └── repositories/
│       └── capture_repository_test.dart
├── plan.md                   ← this file
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 3. Data layer

Drift tables with `.watch()` reactive queries. TypeConverter maps `ItemType` enum ↔ string.
DAOs expose typed streams that Riverpod `StreamProvider.family` wraps for the Inbox.

---

## 4. AiService

`abstract interface class AiService` with `transcribe()` and `extractItems()`.
Only `OpenAiAiService` implements it — no mock ever.
Config from `--dart-define` only (never hardcoded).
Post-parse enforcement: past dates → null + needsReview; confidence < 0.6 → needsReview; unknown type → ParseError.

---

## 5. Processing state machine

```
Idle → Recording → Transcribing → Extracting → ReviewReady
                                              ↘ ProcessingError (retryable, with savedTranscript)
```

`CaptureController` manages the full flow. `ReviewController` initializes from `captureControllerProvider` state.

---

## 6. Review screen

- Items grouped: Actions section / Ideas section
- All checked by default (`isSelected = true`)
- Tap → quick-edit bottom sheet (title, date, person only)
- Swipe left → delete (no undo)
- Sticky "Save to Brain Inbox" button
- Empty state: "Nothing actionable found" + Capture Again

---

## 7. Local instrumentation

`AppEvent` table: `app_open`, `capture_started`, `capture_saved` (with proposed/saved counts), `capture_discarded`.

---

## 8. Edge cases

All handled — see §8 of the approved plan in `~/.claude/plans/`.

---

## 9. Open questions resolved

1. Audio backup: **hardcoded off** (`audioPath = null`) for v0.1.
2. Language hint: **always null** (auto-detect).
3. Home-screen widget: **Dart-side wiring included**; native AppWidgetProvider/WidgetKit setup annotated in code but needs manual Xcode/Android Studio step.
4. Jargon bias: **static list** in `AppConfig.transcriptionBiasPrompt`.
5. Extract model: `gpt-5.4-mini` via `--dart-define`; verify exact ID before first run.
6. Reasoning effort: **omitted from API call** (not all chat models support it; quality comes from structured outputs + prompt).

---

## Progress tracker

## Scope update — Onboarding + RevenueCat

Approved change: add a new aha-first onboarding and monetization through RevenueCat,
superseding the earlier v0.1 exclusion for onboarding/payments.

New dependencies:
- `purchases_flutter` — RevenueCat purchase, customer info, offerings, and entitlement SDK.
- `purchases_ui_flutter` — hosted RevenueCat Paywalls and Customer Center UI.

RevenueCat configuration:
- Entitlement id: `premium` (`Brain Inbox Premium` in the dashboard).
- Offering strategy: use the current/default offering from RevenueCat.
- Product package identifiers expected in RevenueCat: `monthly`, `yearly`, `lifetime`.
- API key comes from `REVENUECAT_API_KEY`, with the provided test key as a temporary fallback.

- [ ] pubspec.yaml
- [ ] analysis_options.yaml
- [ ] lib/main.dart
- [ ] lib/app/app.dart, router.dart, theme.dart
- [ ] lib/core/* (5 files)
- [ ] lib/data/db/tables/* (3 files)
- [ ] lib/data/db/daos/* (3 files)
- [ ] lib/data/db/app_database.dart
- [ ] lib/data/models/* (3 files)
- [ ] lib/data/ai/ai_service.dart
- [ ] lib/data/ai/openai_ai_service.dart
- [ ] lib/data/ai/dtos/* (2 files)
- [ ] lib/data/repositories/* (3 files)
- [ ] lib/features/capture/* (3 files)
- [ ] lib/features/review/* (2 files)
- [ ] lib/features/inbox/* (3 files)
- [ ] test/ai/extraction_parsing_test.dart
- [ ] test/repositories/capture_repository_test.dart
- [ ] Native: AndroidManifest.xml additions (mic, widget, share)
- [ ] Native: Info.plist additions (mic, share)
- [ ] flutter analyze → 0 issues
- [ ] flutter test → passing
