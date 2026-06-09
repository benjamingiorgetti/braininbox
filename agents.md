# Brain Inbox — Agent Operating Manual

> `CLAUDE.md` is *what* to build. This file is *how* to work. Read both before any code.

## Read order (every session)
1. `CLAUDE.md` — product, scope, architecture, data model, conventions.
2. `docs/ai-extraction-contract.md` — the core IP (extraction).
3. `docs/roadmap.md` — current phase + edge cases.
4. `plan.md` (if it exists) — what's approved and what's done.

## Prime directive
Build **only** what validates the north star (habit/pull from the transformation). If you feel the urge to add something, check the OUT list — it's probably there. More features = more friction = the experiment fails.

## Workflow (gated — do not skip the gates)
This mirrors the owner's process. **No code before an approved plan.**

1. **Research** *(only for non-trivial or unfamiliar work)* → write `research.md` → **wait for approval.**
2. **Plan** → write `plan.md` with: approach, exact file paths, key code snippets, trade-offs, edge cases handled, and any new dependency with a one-line justification → **wait for the explicit instruction `implement it all`.**
3. **Fast-track** *(change < 200 lines)* → skip `research.md`, but `plan.md` is still **mandatory**.
4. **Implement** → execute the whole approved plan, do not stop mid-flow, run `flutter analyze` continuously, and mark each item `completed` in `plan.md` as you go.

If a requirement is ambiguous or seems to conflict with scope → **stop and ask.** Do not improvise scope.

## Definition of done
- `flutter analyze` → 0 issues. No `dynamic`, no unsafe casts, strict null-safety.
- Feature does exactly the screen's single job from `CLAUDE.md` — no extra scope.
- AI failures handled: `Error` state + retry; never fabricated items; unclear dates → `null` + `needsReview = true`.
- Secrets and model names come from config (`--dart-define`/env); nothing sensitive committed.
- Relevant unit tests written and passing.
- `plan.md` items marked completed.

## Guardrails — hard NOs
- **Never mock the `AiService`.** The AI is the reward under test; use real OpenAI from day 1.
- **Never add an item type beyond `action` and `idea`.**
- **Never turn Review into a per-item form.** Default-accept, edit-by-exception, one Save button.
- **Never add** (all explicitly out for v0.1): auth, accounts, backend, sync, onboarding flows, calendar/Notion/Gmail/Slack/WhatsApp integrations, collaboration/teams/workspaces, complex tags/folders, AI chat, gamification/streaks, payments/subscriptions, web app, long-form/meeting summaries, push notifications.
- **Never hardcode** API keys or model strings in business logic — config only.
- **Never add a dependency** without recording it (with justification) in `plan.md` first.
- **Never** silently swallow errors or auto-save items the user hasn't seen.

## Commands
```
flutter pub get
flutter analyze
flutter test
flutter run
dart run build_runner build --delete-conflicting-outputs   # if codegen (Drift/Riverpod gen)
```
Run with secrets, e.g.:
```
flutter run --dart-define=OPENAI_API_KEY=sk-... --dart-define=TRANSCRIBE_MODEL=gpt-4o-mini-transcribe --dart-define=EXTRACT_MODEL=gpt-5.4-mini
```

## Working docs
`research.md` and `plan.md` live at repo root, are living documents, and are updated as work proceeds. They are for coordination with the owner — keep them current.