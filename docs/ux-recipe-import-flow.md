# Recipe Import UX Flow

## Overview

This document defines the UX flow for importing recipes into Cooked — from video platforms (TikTok, Instagram, YouTube) and recipe websites. The goal: make the wait feel invisible and the result feel instant.

---

## Entry Points

### 1. In-App Import (tap "+" in Recipes tab)

Current behavior. User taps "+", gets the import sheet, pastes a URL.

### 2. Share Extension (share a link TO Cooked)

User is watching a TikTok/YouTube/Instagram video or browsing a recipe site. They tap "Share" → "Cooked". This is the highest-intent entry point — the user found something they want to cook *right now*.

**Share extension behavior:**
- Receives the URL
- Shows a compact confirmation card (app icon + "Sending to Cooked..." + checkmark animation)
- Dismisses after ~1.5s
- Triggers background extraction immediately
- No login wall in the share extension — queue the URL and process on next app open if needed

> **Why this matters:** The share extension must be *fast and invisible*. The user is in another app. Don't make them context-switch mentally. Just confirm receipt and get out of the way.

---

## API Architecture: Trigger + Subscribe

The import uses a **trigger + subscribe** pattern instead of a blocking request or two parallel calls.

### `POST /api/recipes/import` — Trigger endpoint

The client sends the URL. The server:
1. Scrapes lightweight metadata (OG tags / oEmbed) — fast, <1s
2. Creates the recipe in the database with status `importing`
3. Kicks off the full extraction as a background job
4. Returns immediately with:

```json
{
  "recipe_id": "uuid",
  "status": "importing",
  "title": "Creamy Garlic Pasta",
  "source_name": "@cookingwithmaria",
  "source_url": "https://youtube.com/watch?v=...",
  "image_url": "https://i.ytimg.com/vi/.../hqdefault.jpg",
  "platform": "youtube"
}
```

This is the only call the **share extension** needs to make. Hit the endpoint, get the recipe ID back, show the checkmark, done. The recipe now exists server-side — the user can close the extension, close the app, whatever. The extraction will finish regardless.

### `GET /api/recipes/{id}/stream` — SSE subscription

The client opens a Server-Sent Events connection to receive extraction progress:

```
event: progress
data: {"stage": "downloading_video", "message": "Downloading video..."}

event: progress
data: {"stage": "transcribing", "message": "Transcribing audio..."}

event: progress
data: {"stage": "extracting", "message": "Extracting recipe..."}

event: complete
data: {"ingredients": [...], "steps": [...], "tags": [...]}
```

**Why SSE over WebSocket?** SSE is simpler — unidirectional, auto-reconnects, works over HTTP/2, no special server infrastructure. We only need server→client updates here.

**Why this pattern wins:**
- **One source of truth.** The recipe lives in the database from the moment the user submits the URL. No local-only partial state to manage.
- **Share extension is trivial.** One POST, one response, done. No App Group file passing, no "pick it up on next launch" logic.
- **Resilient to disconnects.** If the SSE connection drops (user backgrounds the app, network blip), the client just polls `GET /api/recipes/{id}` on reconnect to see if extraction finished.
- **Progress updates for free.** The server can emit stages ("downloading video...", "transcribing...", "extracting recipe...") which make the wait feel active instead of stalled.
- **Works for queued jobs.** If extraction is handled by a job queue (which it should be for video), SSE naturally fits — the API subscribes to the job's progress and forwards events.

### Fallback: Polling

If SSE isn't feasible initially, the client can poll `GET /api/recipes/{id}` every 3s. The recipe's `status` field transitions from `importing` → `pending_review` when extraction completes. Less elegant but works.

---

## The Import Flow (Step by Step)

### Phase 1: URL Submission (0-2s)

**In-app path:**
User pastes URL → taps "Import Recipe"

**Share extension path:**
URL arrives automatically → show confirmation → dismiss

**Immediately on submission:**
1. Validate URL format (client-side)
2. `POST /api/recipes/import` with the URL and user auth token
3. Server returns recipe ID + metadata instantly
4. Client opens SSE connection to `/api/recipes/{id}/stream`

> **Design decision — trigger + subscribe.** The server owns the recipe from the moment the URL is submitted. The client just subscribes to updates. This means the share extension only needs one API call, and the app can reconnect to an in-progress extraction at any time.

### Phase 2: Instant Preview Card (1-3s)

As soon as metadata arrives, present the **Recipe Card** view:

```
┌─────────────────────────────────┐
│  [thumbnail image]              │
│                                 │
│  Creamy Garlic Pasta            │  ← editable title
│  by @cookingwithmaria           │  ← creator/source
│  youtube.com                    │  ← platform
│                                 │
│  ┌─────────────────────────┐    │
│  │ ◻ Extracting recipe...  │    │  ← shimmer/pulse animation
│  │   ingredients · steps   │    │
│  └─────────────────────────┘    │
│                                 │
│  [ Edit Title ]                 │  ← available immediately
│  [ Add Tags ]                   │  ← available immediately
└─────────────────────────────────┘
```

**What the user can do while waiting:**
- Edit the recipe title
- Add/edit tags
- View the thumbnail
- See who created it

**What's happening in the background:**
- Full extraction is running
- Shimmer animation on the ingredients/steps sections signals progress without a spinner

**Why shimmer, not a spinner:** A spinner says "you're blocked." Shimmer says "content is loading into this space." It sets the expectation that *this area* will fill in, while the rest of the card is already usable.

### Phase 3: Content Arrives (3-15s typical)

When extraction completes:

1. Shimmer stops
2. Ingredients and steps fade in with a subtle animation
3. A gentle haptic tap confirms completion
4. The view transitions to full edit mode

```
┌─────────────────────────────────┐
│  [thumbnail image]              │
│                                 │
│  Creamy Garlic Pasta            │
│  by @cookingwithmaria           │
│  youtube.com                    │
│                                 │
│  INGREDIENTS (7)         [edit] │
│  ──────────────────────────     │
│  2 tbsp olive oil               │
│  4 cloves garlic, minced        │
│  1 cup heavy cream              │
│  ...                            │
│                                 │
│  STEPS (5)               [edit] │
│  ──────────────────────────     │
│  1. Heat olive oil in a pan...  │
│  2. Add garlic and sauté...     │
│  ...                            │
│                                 │
│  ┌──────────┐  ┌──────────────┐ │
│  │  Save 📖 │  │ Cook Now 🍳  │ │
│  └──────────┘  └──────────────┘ │
└─────────────────────────────────┘
```

**Two primary actions:**
- **Save** — saves to recipe library
- **Cook Now** — saves + adds to current menu (or creates a solo menu) + generates grocery list. This is the "I want to cook this tonight" path.

### Phase 4: The Long Wait (15s+ timeout)

If extraction takes longer than **15 seconds**, transition to a background state:

```
┌─────────────────────────────────┐
│                                 │
│  Still working on it...         │
│                                 │
│  Video recipes take a bit       │
│  longer to process. We'll       │
│  notify you when it's ready.    │
│                                 │
│  ┌────────────────────────┐     │
│  │  Continue Browsing →   │     │
│  └────────────────────────┘     │
│                                 │
│  ┌────────────────────────┐     │
│  │  Keep Waiting          │     │
│  └────────────────────────┘     │
│                                 │
└─────────────────────────────────┘
```

**If user taps "Continue Browsing":**
- Dismiss the sheet
- Show a subtle pill/badge on the Recipes tab: "1 importing..."
- Send a local notification when extraction completes
- Save the partial recipe (metadata) to Supabase with status `importing`

**If user taps "Keep Waiting":**
- Stay on the card
- Show an animated cooking illustration or tip ("Did you know? You can share recipes directly from TikTok to Cooked.")

### Phase 5: Return to Completed Import

When the user comes back to a recipe that finished importing in the background:

1. Tap the "1 importing..." badge or the notification
2. Land directly in **edit mode** on the full recipe card
3. A banner at the top: "Recipe ready — review and save"
4. Same two actions: **Save** or **Cook Now**

> This is critical — the first time a user sees the full extracted result, they should be in edit mode. AI extraction isn't perfect. Let them correct things before committing.

---

## State Machine

```
     URL submitted
          │
          ▼
   ┌──────────────┐
   │   TRIGGER    │  POST /api/recipes/import
   │  (server)    │  → creates recipe, returns metadata + ID
   └──────┬───────┘
          │
     ┌────┴──────────────────────┐
     │                           │
  In-App                    Share Extension
     │                           │
     ▼                           ▼
┌──────────┐              ┌────────────┐
│ SUBSCRIBE│ SSE stream   │   DONE     │ show checkmark
│ (client) │              │ (dismiss)  │ server handles rest
└────┬─────┘              └────────────┘
     │
     │ user sees metadata card,
     │ can edit title/tags
     │ SSE sends progress stages
     │
     ├────────────────────────────┐
     │ extraction completes      │ timeout (8-20s)
     │ < timeout                 │
     ▼                           ▼
┌──────────┐              ┌────────────┐
│  READY   │              │ BACKGROUND │ user taps
│(edit mode│              │ PROCESSING │ "Continue Browsing"
│  inline) │              └─────┬──────┘
└────┬─────┘                    │ extraction completes
     │                          │ (local notification)
     │                          ▼
     │                    ┌───────────┐
     │                    │  PENDING  │ recipe in list
     │                    │  REVIEW   │ with badge
     │                    └─────┬─────┘
     │                          │ user taps recipe
     │                          ▼
     │                    ┌───────────┐
     └───────────────────►│   EDIT    │
                          │   MODE    │
                          └─────┬─────┘
                                │ save / cook now
                                ▼
                          ┌───────────┐
                          │   SAVED   │ status = active
                          └───────────┘
```

---

## Recipe Status Model

Add a `status` field to the Recipe model:

| Status | Meaning |
|--------|---------|
| `importing` | Metadata saved, extraction in progress |
| `pending_review` | Extraction complete, user hasn't reviewed yet |
| `active` | User has saved/confirmed the recipe |

Recipes with `importing` or `pending_review` status show a badge in the recipe list.

---

## Share Extension Technical Notes

**Minimal share extension UI:**
- App icon + "Saving to Cooked..." + animated checkmark
- Auto-dismiss after ~1.5s
- No text fields, no options, no friction

**Data flow:**
1. Share extension receives URL
2. Calls `POST /api/recipes/import` with the URL + auth token from Keychain (shared via App Group)
3. Server returns recipe ID + metadata — recipe now exists server-side
4. Extension shows checkmark, dismisses
5. Extraction runs entirely on the server — no app involvement needed

**Offline fallback:**
If the network call fails, write the URL to App Group shared `UserDefaults`. Main app picks it up on next launch and retries the import.

**Why this works now:** The trigger endpoint is fast and lightweight (<1s response). It fits comfortably within the share extension's time/memory limits. No need to hand off to the main app — the server owns the job.

**Auth in the extension:**
Store the Supabase auth token in Keychain with an App Group access group. The share extension reads it directly. If the token is missing or expired, fall back to queuing the URL locally.

---

## Error States

| Error | UX |
|-------|-----|
| Invalid URL | Inline error under text field: "This doesn't look like a recipe link" |
| Metadata fetch fails | Skip to extraction-only flow, show URL domain as fallback title |
| Extraction fails | Show error with retry button + option to create recipe manually |
| Network offline | "You're offline. We'll import this recipe when you're back online." Queue the URL. |
| Unsupported source | "We can't extract from this source yet. Want to add it manually?" |

---

## Micro-Interactions

| Moment | Interaction |
|--------|-------------|
| URL pasted | Brief green flash on the text field |
| Metadata arrives | Card slides up with spring animation |
| Extraction completes | Ingredients/steps fade in top-to-bottom, light haptic |
| Save tapped | Card shrinks into the recipes tab icon |
| Cook Now tapped | Card shrinks into the menu tab icon |
| Background transition | Card slides down with "we'll notify you" |

---

## Challenges to the Original Proposal

| Original idea | Challenge | Resolution |
|---------------|-----------|------------|
| "Show title, source, creator, image while extracting" | Needs fast metadata before extraction finishes | `POST /api/recipes/import` scrapes OG/oEmbed metadata and returns it in <1s, before kicking off extraction |
| "Edit title while waiting" | Good, but editing ingredients/steps mid-extraction would create merge conflicts | Only allow title + tags editing during extraction. Full edit after completion. |
| "15s timeout then background message" | 15s is reasonable for video. For websites it should be faster (~5s). | Use source-aware timeouts: 8s for websites, 20s for video platforms |
| "Come back later in edit mode" | Need persistent state for in-progress imports | Server owns the recipe from submission. Status field (`importing` → `pending_review` → `active`) handles this natively. |
| "Share extension triggers extraction" | Share extensions have tight resource limits | Trigger endpoint is fast enough (<1s) to call directly from the extension. Server handles the rest. |
| "Go shopping this lonely recipe" | Great shortcut. Naming it "Cook Now" makes intent clearer. | "Cook Now" creates a solo menu + grocery list in one action |

---

## Implementation Priority

1. **`POST /api/recipes/import` trigger endpoint** — returns metadata + recipe ID, kicks off background extraction. This is the foundation everything else builds on.
2. **Recipe status model** (`importing` / `pending_review` / `active`) — enables background processing and return-to-recipe flows
3. **SSE stream endpoint** (`GET /api/recipes/{id}/stream`) — real-time progress updates to the client
4. **Shimmer loading + progress stages UI** — replaces the current blocking spinner, shows extraction stages
5. **Background-to-foreground reconnection** — app re-subscribes to SSE or polls on return, local notification on completion
6. **"Cook Now" action** — high-value shortcut from import to cooking
7. **Share extension** — now simple: one POST call, auth via shared Keychain, offline fallback to local queue
8. **Offline queuing** — nice-to-have, handles edge cases for share extension and in-app import
