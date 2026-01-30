# Cooked App - Visual Inventory for Art Director

> Reference document showing all screens and UI components that need styling.
> Use this alongside `UI_STYLE_TEMPLATE.md` to understand what you're designing for.

---

## App Overview

**Cooked** is a menu-first recipe app. Users:
1. Import recipes from URLs (Instagram, TikTok, websites)
2. Build a weekly menu from their recipe library
3. Generate a grocery list from the menu
4. Cook and check off items

**Core philosophy:** The Menu is the product, not individual recipes.

---

## Navigation Structure

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   RECIPES   │     │    MENU     │     │    LIST     │
│     📖      │     │     🍳      │     │      ✓      │
│  (library)  │     │  (planning) │     │  (shopping) │
└─────────────┘     └─────────────┘     └─────────────┘
   secondary           PRIMARY            secondary
                    (default tab)
```

**Tab Bar:** 3 tabs, always visible. Menu is center and default.

---

## Screen Inventory

### 1. MENU TAB

#### 1A. Empty Menu State
**When:** User has no active menu

**Elements:**
- Large title: "Menu"
- Illustration: Fork & knife icon (orange)
- Headline: "What do you want to cook?"
- Subtext: "Build your menu for the week"
- Primary CTA button: "+ Add Recipes" (orange, full-width)
- Secondary link: "View past menus"

**Styling notes:**
- This is the first screen new users see
- Should feel inviting, not empty
- CTA button is the hero element

---

#### 1B. Planning Menu State
**When:** User has added recipes but hasn't started cooking

**Elements:**
- Large title: "Menu"
- Recipe count badge: "3 recipes"
- Recipe grid (2 columns) with remove (X) buttons
- "+ Add" button to add more recipes
- Bottom CTA: "Ready to Cook" button

**Styling notes:**
- Recipe cards should show meal thumbnails clearly
- Remove button needs to be accessible but not dominant

---

#### 1C. To Cook Menu State
**When:** User is actively cooking through menu

**Elements:**
- Progress bar: "2 of 5 cooked"
- "Generate Grocery List" button (if no list yet)
- Checklist of recipes with checkboxes
- Each row: checkbox + thumbnail + title + source
- Archive menu button

**Styling notes:**
- Checked items should feel satisfying (strikethrough? fade?)
- Progress bar is key motivational element

---

#### 1D. Menu History Sheet
**When:** User taps "View past menus"

**Elements:**
- Sheet with list of archived menus
- Each row: date, recipe count, completion badge, thumbnail strip
- "Cook This Again" action per menu

---

### 2. RECIPES TAB

#### 2A. Recipe Library (Main)
**Elements:**
- Large title: "Recipes"
- Sort button (top right): arrows icon
- Add button (top right): + icon
- Search bar: "Search recipes"
- Tag filter bar: horizontal scroll of tag chips (dinner, easy, american, etc.)
- Recipe count: "57 recipes"
- Recipe grid: 2 columns of recipe cards

**Recipe Card contains:**
- Square thumbnail image
- Status badge: "Ready" (green checkmark)
- Title (2 lines max)
- Source name (1 line, muted)

**Styling notes:**
- This is the library view - should feel organized, scannable
- Tags are filterable - selected state needs clear visual
- Cards should have consistent image aspect ratio

---

#### 2B. Recipe Detail View
**When:** User taps a saved recipe

**Elements:**
- Back button
- Hero image (full width)
- Title (large)
- Source name with link icon
- Tags row
- Metadata: "Cooked 3 times" / "12 ingredients" / "8 steps"
- **Ingredients section:**
  - Section header
  - List of ingredients with quantities
- **Steps section:**
  - Section header
  - Numbered steps (1, 2, 3...)
- Delete button (destructive)

**Styling notes:**
- This is a reading view - typography is critical
- Steps need clear visual numbering
- Ingredient quantities should be scannable

---

### 3. GROCERY LIST TAB

#### 3A. Empty List State
**When:** No grocery list generated

**Elements:**
- Large title: "Grocery List"
- Illustration: Checklist icon
- Headline: "No Grocery List"
- Subtext: "Generate a list from your menu to start shopping"
- CTA button: "Go to Menu" (orange)

---

#### 3B. Active Grocery List
**When:** List has been generated

**Elements:**
- Large title: "Grocery List"
- Share button (top right)
- Progress bar: "12 of 24 checked"
- **Grouped sections by category:**
  - Produce
  - Meat & Seafood
  - Dairy
  - Pantry
  - etc.
- Each section: header + collapsible item list
- Each item row: checkbox + item name + quantity

**Styling notes:**
- Checkboxes are the main interaction
- Checked items should feel "done" (strikethrough, fade, move to bottom?)
- Category headers help with store navigation

---

#### 3C. Generate List Sheet
**When:** User taps "Generate Grocery List" from menu

**Elements:**
- Sheet title: "Generate List"
- **Staples section:** "I already have..."
  - Chip toggles: Salt, Pepper, Olive Oil, Butter, etc.
- **Preview section:** Items grouped by category
- Generate button

---

### 4. IMPORT FLOW

#### 4A. Import Recipe Sheet
**When:** User taps + on Recipes tab

**Elements:**
- Sheet title: "Import Recipe"
- Cancel button (top left)
- URL input field with placeholder
- "Paste from Clipboard" button
- Import button (disabled until valid URL)

---

#### 4B. Recipe Preview Sheet (Extracting)
**When:** Recipe is being extracted

**Elements:**
- Shimmer/skeleton loading animation
- "Extracting recipe..." text

---

#### 4C. Recipe Preview Sheet (Complete)
**When:** Extraction successful

**Elements:**
- Recipe thumbnail
- Editable title field
- Source attribution
- Status: "Recipe ready — review and save" (green check)
- **Ingredients section** (count in header)
- **Steps section** (count in header)
- **Tags section** (if extracted)
- Save button

---

#### 4D. Recipe Limit Paywall
**When:** Free user hits 15 recipe limit

**Elements:**
- Lock icon (orange)
- Headline: "Recipe Limit Reached"
- Subtext: "You've saved 15 recipes. Upgrade to Pro for unlimited."
- CTA: "Upgrade to Pro" button

---

### 5. PAYWALL / SUBSCRIPTION

#### 5A. Paywall View
**When:** User hits any freemium limit

**Elements:**
- Close/dismiss button
- Hero section with value prop
- **Benefits list:**
  - Unlimited recipes
  - Unlimited video imports
  - Full menu history
- Price display (from RevenueCat)
- Subscribe button
- Restore purchases link
- Terms links

---

### 6. RECIPE PICKER

#### 6A. Recipe Picker Sheet
**When:** User adds recipes to menu

**Elements:**
- Sheet title: "Add to Menu"
- Done button with count: "Done (3)"
- Recipe grid with selection state
- Selected cards: orange border + checkmark overlay

---

## Reusable Components

| Component | Used In | Description |
|-----------|---------|-------------|
| **Recipe Card** | Recipes grid, Menu grid | Thumbnail + title + source + badge |
| **Tag Chip** | Filter bar, Recipe detail | Rounded pill, selected/unselected states |
| **Primary Button** | All CTAs | Orange, full-width, rounded |
| **Secondary Button** | Secondary actions | Outline or ghost style |
| **Checkbox Row** | Grocery list, To Cook list | Checkbox + label + optional meta |
| **Section Header** | Lists | Title + optional count |
| **Empty State** | All tabs | Icon + headline + subtext + CTA |
| **Sheet** | All modals | Drag handle, title bar |
| **Progress Bar** | Grocery list, Menu | Filled bar showing completion |
| **Search Bar** | Recipes | Standard iOS search field |

---

## Current Visual Style (for reference)

The current design uses:
- **Primary color:** Orange (#F5A623 approximate)
- **Background:** White
- **Text:** Dark gray / Light gray for secondary
- **Corners:** Rounded (medium radius)
- **Shadows:** Minimal/none
- **Typography:** System font (SF Pro)

---

## Key Screens to Prioritize

For initial style exploration, focus on these 6 screens:

1. **Menu Tab (Empty)** — First impression, emotional hook
2. **Menu Tab (Planning)** — Core product experience
3. **Recipes Grid** — Library browsing, most time spent here
4. **Recipe Detail** — Reading experience, typography test
5. **Grocery List (Active)** — Utility/productivity feel
6. **Recipe Card** — Appears everywhere, brand carrier

---

## Questions for Art Director

1. Should the app feel more **utility** (clean, efficient) or **lifestyle** (warm, inspiring)?
2. Dark mode: Full dark theme or just respect system setting?
3. Illustrations: Keep minimal icons or add custom illustrations?
4. Photography: How should recipe images be treated? (Rounded? Shadows? Overlays?)
5. Motion: Snappy and responsive or smooth and fluid?
