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

## The Import Flow (Step by Step)

### Phase 1: URL Submission (0-2s)

**In-app path:**
User pastes URL → taps "Import Recipe"

**Share extension path:**
URL arrives automatically → show confirmation → dismiss

**Immediately on submission:**
1. Validate URL format (client-side)
2. Fire a lightweight **metadata fetch** (separate fast endpoint: title, thumbnail, creator name, platform) — target < 1s response
3. Simultaneously fire the **full extraction** (ingredients, steps, tags) — this is the slow one (5-30s+)

> **Design decision — two API calls instead of one.** The current flow sends one request and waits for everything. Splitting into a fast metadata call and a slow extraction call lets us show meaningful content almost instantly. The metadata endpoint should return in under 1 second by just scraping Open Graph / oEmbed data.

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
                    ┌──────────┐
     URL received → │ FETCHING │ (metadata call)
                    │ METADATA │
                    └────┬─────┘
                         │ metadata arrives
                         ▼
                    ┌──────────┐
                    │EXTRACTING│ (full extraction running)
                    │          │ user can edit title/tags
                    └────┬─────┘
                    ┌────┴─────┐
            < 15s   │          │  > 15s
                    ▼          ▼
              ┌──────────┐  ┌────────────┐
              │  READY   │  │ BACKGROUND │
              │(edit mode│  │ PROCESSING │
              │  inline) │  └─────┬──────┘
              └────┬─────┘        │ extraction completes
                   │              ▼
                   │        ┌───────────┐
                   │        │  PENDING  │ (waiting for user)
                   │        │  REVIEW   │
                   │        └─────┬─────┘
                   │              │ user opens
                   │              ▼
                   │        ┌───────────┐
                   └───────►│   EDIT    │
                            │   MODE    │
                            └─────┬─────┘
                                  │ save / cook now
                                  ▼
                            ┌───────────┐
                            │   SAVED   │
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
- Auto-dismiss after 1.5s
- No text fields, no options, no friction

**Data flow:**
1. Share extension receives URL
2. Writes URL to App Group shared `UserDefaults` (or a shared Core Data / file)
3. Main app picks it up on next launch (or immediately if running)
4. Main app triggers the two-call import flow

**Why not call the API from the extension?**
Share extensions have tight memory and time limits (~120MB, ~30s). The metadata call could work, but the full extraction definitely won't. Better to hand off to the main app.

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
| "Show title, source, creator, image while extracting" | This requires a separate fast metadata endpoint that doesn't exist yet | Build a lightweight `/api/recipes/metadata` endpoint that returns OG/oEmbed data in <1s |
| "Edit title while waiting" | Good, but editing ingredients/steps mid-extraction would create merge conflicts | Only allow title + tags editing during extraction. Full edit after completion. |
| "15s timeout then background message" | 15s is reasonable for video. For websites it should be faster (~5s). | Use source-aware timeouts: 8s for websites, 20s for video platforms |
| "Come back later in edit mode" | Need persistent state for in-progress imports | Add `importing` and `pending_review` recipe statuses to the data model |
| "Go shopping this lonely recipe" | Great shortcut. Naming it "Cook Now" makes intent clearer. | "Cook Now" creates a solo menu + grocery list in one action |

---

## Implementation Priority

1. **Split API into metadata + extraction** — unlocks the entire fast-preview experience
2. **Recipe status model** (`importing` / `pending_review` / `active`) — enables background processing
3. **Shimmer loading states** — replaces the current blocking spinner
4. **Background processing + local notifications** — handles the long-wait case
5. **"Cook Now" action** — high-value shortcut from import to cooking
6. **Share extension** — highest-intent entry point, but more engineering effort
7. **Offline queuing** — nice-to-have, handles edge cases gracefully
