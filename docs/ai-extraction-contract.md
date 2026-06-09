# AI Extraction Contract

> This is the most important spec in the repo. The extraction quality **is** the product reward; if it's weak, the habit experiment fails. Implement it precisely.

## Pipeline
`audio file → transcribe → extract structured items → user review`

The `AiService` interface:
```dart
abstract interface class AiService {
  Future<Transcript> transcribe(File audio, {String? languageHint});
  Future<ExtractionResult> extractItems(
    String transcript, {
    required DateTime now,   // reference time for resolving "tomorrow", "4 PM"
    required String tz,      // IANA tz, e.g. "America/Argentina/Buenos_Aires"
  });
}
```
Only the real `OpenAiAiService` exists in v0.1. Do **not** add a mock implementation.

---

## Step 1 — Transcription

- Endpoint: `POST /v1/audio/transcriptions` (file upload).
- Model (from config; values current as of May 2026 — verify before relying):
  - `gpt-4o-mini-transcribe` — cheapest, good enough for short notes (default).
  - `gpt-4o-transcribe` — higher accuracy if mini under-performs.
- Pass a `language` hint when known; pass a `prompt` biasing likely proper nouns / jargon to cut errors (e.g. names, "MAU", "LinkedIn", "creatina", "Notion").
- **Preserve the original language. Do not translate.** (The translations endpoint forces English — do not use it.)
- Store the transcript **verbatim**.

---

## Step 2 — Extraction

- Model (from config; current as of May 2026 — verify): `gpt-5.4-mini` (well-defined, low-latency, cheap). Escalate to `gpt-5.5` only if quality is insufficient.
- Use **Structured Outputs** (`response_format` = `json_schema`) so the shape is enforced by the API, not by prose in the prompt. Do not paste the schema into the prompt text; supply it as the structured-output schema.
- Reasoning effort `low` is likely sufficient; raise only if extraction misses items.
- Always pass `now` + IANA `tz` so the model can resolve relative dates.

### Output schema
```json
{
  "language": "es | en",
  "items": [
    {
      "type": "action | idea",
      "title": "string (short, imperative, user's language)",
      "note": "string | null",
      "dateTime": "ISO 8601 string | null",
      "person": "string | null",
      "confidence": 0.0,
      "needsReview": true
    }
  ]
}
```

### Extraction rules (HARD — these are the product)
1. **Never invent data.** If something wasn't said, the field is `null`.
2. **Dates:** resolve relative/spoken times ("mañana", "antes de las 4", "Monday at 10") using the provided `now` + `tz`. If still ambiguous, or the result would be in the past, set `dateTime = null` and `needsReview = true`.
3. **Language:** keep the user's original language in `title`/`note`. Set `language` to the dominant language of the note.
4. **Type mapping:** `action` for anything to do — this absorbs task/follow-up/reminder/event. Set `person` when it's about contacting someone, `dateTime` when it's time-bound. `idea` only for non-actionable thoughts ("maybe write a post about MAU").
5. **Split compound utterances** into separate items (one sentence can yield several).
6. **No actionable content** (pure venting / filler) → return `items: []`. Do not force items.
7. **confidence** reflects extraction certainty; anything `< ~0.6` → `needsReview = true`.

### Date handling note
The model resolves relative→absolute using the passed `now`. The app then double-checks: any past or impossible `dateTime` is downgraded to `null` + `needsReview = true` before showing it in Review.

---

## Worked examples

**ES input (the canonical brief example), `now` = a Tuesday 10:00 ART:**
> "Mañana tengo que mandarle el mail a Jonathan sobre el newsletter, revisar el Excel de leads antes de las 4, comprar creatina, y capaz escribir un post de LinkedIn sobre MAU."

Expected:
```json
{
  "language": "es",
  "items": [
    {"type":"action","title":"Mandarle el mail a Jonathan sobre el newsletter","note":null,"dateTime":"<tomorrow, time null>","person":"Jonathan","confidence":0.9,"needsReview":true},
    {"type":"action","title":"Revisar el Excel de leads","note":null,"dateTime":"<tomorrow 16:00 ART or today 16:00 — flag if ambiguous>","person":null,"confidence":0.8,"needsReview":true},
    {"type":"action","title":"Comprar creatina","note":null,"dateTime":null,"person":null,"confidence":0.95,"needsReview":false},
    {"type":"idea","title":"Escribir un post de LinkedIn sobre MAU","note":null,"dateTime":null,"person":null,"confidence":0.7,"needsReview":false}
  ]
}
```
Note: "mandar el mail a Jonathan" has a person but only a vague day → `needsReview` true because the time is unset and the day is relative. "antes de las 4" is time-bound but the *day* is ambiguous → flag it. This is the correct behavior: flag, don't guess.

**EN input:**
> "Meeting with Austin on Monday at 10 AM and remind me to buy coffee."

Expected: one `action` with `person="Austin"` + resolved Monday 10:00 `dateTime`, and one `action` "Buy coffee" with `dateTime=null`.

---

## Failure handling
- API error / timeout / invalid JSON → surface `Error` state, offer retry, keep the audio + transcript so nothing is lost. **Never fabricate items to fill the gap.**
- Empty/garbled transcript → treat as no actionable content; show a friendly empty-review state.