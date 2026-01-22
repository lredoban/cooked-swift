# Product Requirements Document (PRD)

## Recipe Menu App

**Version:** 1.0 (MVP)  
**Date:** January 2026  
**Context:** RevenueCat Shipyard Contest — Eitan Bernath Brief

---

## 1. Executive Summary

### Vision
An app that helps people turn food inspiration into a real plan — and actually cook it.

### Problem Statement
People are inundated with recipes from social media, cookbooks, and websites. They save hundreds of recipes but rarely cook them. The gap between "I want to make this" and "I made this" is where most recipe apps fail. They optimize for collection, not execution.

### Solution
A menu-first app that treats cooking commitment as the core product. Instead of building a recipe library, users build a menu — a small selection of recipes they will actually cook this week. The app guides them from inspiration → planning → shopping → cooking.

### Target User
People who:
- Save recipes from TikTok, Instagram, YouTube, blogs
- Own cookbooks they underuse
- Want to cook more but struggle with planning
- Need a grocery list that actually works

### Success Metric
Users who complete the full loop: add recipes → generate list → mark recipes as cooked.

---

## 2. Core Principles

### Principle 1: Features must help users cook this week
Every feature passes through this filter: "Does this help the user cook this week?" If not, it doesn't exist.

### Principle 2: Menus are the product, recipes are support material
The app is not a recipe collection tool. Recipes only exist to be added to menus. The menu is where commitment happens.

### Principle 3: Bias toward commitment over convenience
Design should create friction that forces decisions (add to menu) over convenience that enables avoidance (save for later). "Save for later" exists but is never celebrated.

### Principle 4: One obvious action per screen
If a user ever wonders "what should I do?", the design has failed. Every screen has one primary action that is visually dominant.

### Principle 5: The app always asks the same question
"What are you cooking next?" — This is the soul of the app. Every screen should pull the user back to this question.

---

## 3. Core Concepts

### The Menu
A Menu is a selection of recipes the user commits to cooking together. It is the central object of the app.

**Menu States:**

| State | Description | User Actions Available |
|-------|-------------|----------------------|
| **Empty** | No active menu | Add recipes |
| **Planning** | Recipes selected, not yet shopped | Add/remove recipes, generate grocery list |
| **To Cook** | Grocery list generated, ready to cook | Mark recipes as cooked, view list, start new menu |
| **Archived** | Completed or replaced | View history, reuse menu |

**State Transitions:**

```
EMPTY ──[add recipe]──▶ PLANNING ──[generate list]──▶ TO COOK ──[all cooked OR new menu]──▶ ARCHIVED
                            ▲                            │
                            │                            │
                            └────[clear menu]────────────┘
```

**Rules:**
- Only ONE menu can be in "To Cook" state at a time
- Generating a new grocery list automatically archives the current "To Cook" menu
- User must confirm before archiving: "This will archive your current menu. Continue?"
- Archived menus are accessible in history but not prominent

### Recipes
Recipes are the building blocks. They exist to be added to menus.

**Recipe Sources:**
- Video import (TikTok, Instagram, YouTube)
- URL import (recipe blogs, websites)
- Manual entry (cookbooks, personal recipes)

**Recipe Data:**
- Title (required)
- Source (optional: URL, cookbook name + page, author)
- Ingredients (list with quantities)
- Steps (ordered list)
- Tags (optional: Quick, Asian, Vegetarian, etc.)
- Image (optional)

### Grocery List
The grocery list is generated from a menu. It is the bridge between planning and action.

**List Features:**
- Consolidated ingredients from all menu recipes
- Grouped by category (Produce, Meat, Dairy, Pantry, Other)
- Quantities combined across recipes
- "Check You Have" section for common staples
- Checkable items (strikethrough when checked)
- Shareable (text format)

**"Check You Have" Logic:**
At list generation, the app identifies common staples in the ingredients and asks the user to confirm they have them. Checked items are excluded from the main list.

Default staples:
- Salt
- Black pepper
- Olive oil
- Vegetable oil
- Butter
- Sugar
- Flour
- Garlic (sometimes)
- Onion (sometimes)

---

## 4. Information Architecture

### Navigation Structure

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│   ┌─────────┐     ┌─────────────┐     ┌─────────┐  │
│   │ RECIPES │     │    MENU     │     │  LIST   │  │
│   │   📖    │     │     🍳      │     │    ✓    │  │
│   └─────────┘     └─────────────┘     └─────────┘  │
│    secondary          PRIMARY          secondary   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Visual Hierarchy:**
- MENU tab is center and visually larger/elevated
- RECIPES and LIST are smaller, supporting tabs
- App opens to MENU by default

### Tab Purposes

| Tab | Purpose | User Mindset |
|-----|---------|--------------|
| **MENU** | Commitment hub. The app lives here. | "What am I cooking?" |
| **RECIPES** | Utility drawer. Find or add recipes. | "I need to find something" |
| **LIST** | Shopping companion. Use at the store. | "I'm shopping" |

---

## 5. Feature Specifications

### 5.1 MENU Tab

#### 5.1.1 Menu - Empty State

**Purpose:** Prompt user to start planning

**Components:**
- Headline: "What do you want to cook?"
- Primary CTA: "+ ADD RECIPES" button
- Quick import: Paste link input field
- Secondary link: "View past menus"

**Actions:**
- "+ ADD RECIPES" → Add to Menu screen
- Paste link → Processing → Recipe Preview
- "View past menus" → Menu History

---

#### 5.1.2 Menu - Planning State

**Purpose:** Show current menu, enable list generation

**Components:**
- Header: "YOUR MENU"
- Subheader: "Planning • [X] recipes"
- Recipe grid (thumbnails + titles)
- [+] card to add more recipes
- Primary CTA: "GENERATE GROCERY LIST"
- Secondary link: "Clear menu"

**Actions:**
- Tap recipe → Recipe Detail
- Swipe/long-press recipe → Remove from menu
- Tap [+] → Add to Menu screen
- "GENERATE GROCERY LIST" → List Generation Modal
- "Clear menu" → Confirmation → Empty state

---

#### 5.1.3 Menu - To Cook State

**Purpose:** Track cooking progress

**Components:**
- Header: "YOUR MENU"
- Subheader: "To Cook • [X] of [Y] done"
- Recipe list (vertical) with checkboxes
- Checked recipes show strikethrough/checkmark
- Primary CTA: "START NEW MENU"
- Secondary links: "View grocery list", "Archive menu"

**Actions:**
- Tap recipe → Recipe Detail
- Tap checkbox → Mark as cooked (visual feedback)
- "START NEW MENU" → Confirmation → Archives current, Empty state
- "View grocery list" → List tab
- "Archive menu" → Confirmation → Archives, Empty state

---

#### 5.1.4 Add to Menu Screen

**Purpose:** Select recipes for the menu (premium feel)

**Components:**
- Header: "Add to your menu"
- Search bar: "Search your recipes..."
- Section: "YOUR RECIPES"
  - Sort toggle (Recent / A-Z / Tags)
  - Recipe grid (multi-select mode)
  - Visual indicator for selected recipes
- Divider: "Don't see it?"
- Button: "Paste a link" → Link Import
- Button: "Enter manually" → Manual Entry
- Bottom bar (when recipes selected): "[X] selected" + "ADD TO MENU"

**Behavior:**
- Tap recipe → Toggle selection
- Tap again → Deselect
- "ADD TO MENU" → Adds selected, returns to Menu

---

#### 5.1.5 Link Import Flow

**Screens:**
1. **Import Screen**
   - Input field for URL
   - "IMPORT" button
   
2. **Processing Screen**
   - Loading indicator
   - "Extracting recipe..."
   
3. **Recipe Preview**
   - Extracted recipe data (editable)
   - Primary CTA: "ADD TO MENU"
   - Secondary: "Just save for later"

**Supported Sources:**
- TikTok video URLs
- Instagram video/post URLs
- YouTube video URLs
- Recipe blog URLs (any)

---

#### 5.1.6 Manual Entry Screen

**Purpose:** Add recipe by hand (for cookbooks, personal recipes)

**Components:**
- Title input (required)
- Source input (optional): "Salt Fat Acid Heat, p.142"
- Ingredients textarea (one per line)
- Steps textarea (one per line)
- Tags selector (optional)
- Primary CTA: "SAVE & ADD TO MENU"
- Secondary: "Just save for later"

---

#### 5.1.7 List Generation Modal

**Purpose:** Create grocery list with staple check

**Components:**
- Header: "Generate your grocery list"
- Summary: "[X] ingredients from [Y] recipes"
- Section: "CHECK WHAT YOU ALREADY HAVE"
  - Explanation text
  - Checklist of detected staples (pre-checked)
  - Unchecked = will appear on list
- CTA: "CREATE LIST"

**Behavior:**
- "CREATE LIST" → Creates list, changes menu to "To Cook", navigates to List tab

---

#### 5.1.8 Menu History

**Purpose:** Access archived menus (not prominent)

**Components:**
- List of archived menus
- Each shows: date range, recipe count, completion status
- Tap → Archived Menu Detail

**Archived Menu Detail:**
- Recipe list
- CTA: "COOK THIS AGAIN" → Copies to new Planning menu

---

### 5.2 RECIPES Tab

#### 5.2.1 Recipes Main

**Purpose:** Browse and search saved recipes

**Components:**
- Header: "Recipes"
- Search bar: "Search recipes..."
- Tag filter row (horizontal scroll)
- Recipe count + sort dropdown
- Recipe grid
- Floating button: "+ ADD RECIPE"

**Actions:**
- Search → Filters recipe list
- Tap tag → Filters by tag
- Tap recipe → Recipe Detail
- "+ ADD RECIPE" → Add Recipe screen

---

#### 5.2.2 Recipe Detail

**Purpose:** View recipe, add to menu

**Components:**
- Hero image
- Title
- Source line
- Tags
- **Primary CTA: "+ ADD TO MENU"** (always visible, always prominent)
  - Changes to "IN MENU ✓" if already in current menu
- Ingredients section
- Steps section
- "I MADE THIS" button (only if recipe is in To Cook menu)

**"..." Menu:**
- Edit Recipe
- Share
- Delete

---

#### 5.2.3 Add Recipe Screen (from Recipes tab)

**Purpose:** Add new recipe to library

**Components:**
- "Paste a link" → Link Import flow
- "Enter manually" → Manual Entry

**Difference from Menu flow:**
- After save, returns to Recipes tab (not Menu)
- "Save & Add to Menu" vs "Just save" options still available

---

### 5.3 LIST Tab

#### 5.3.1 List - Empty State

**Components:**
- Icon
- "No list yet"
- Explanation text
- CTA: "GO TO MENU"

---

#### 5.3.2 List - Active

**Components:**
- Header: "Grocery List"
- Subheader: "For [X] recipes" (tap to expand recipe list)
- Grouped ingredients:
  - PRODUCE
  - MEAT
  - DAIRY
  - PANTRY
  - OTHER
- Each item: checkbox + name + quantity
- Collapsed section: "CHECK YOU HAVE" (staples)
- Actions: "+ Add item", "Share"

**Behavior:**
- Tap checkbox → Strikethrough item
- Tap "For [X] recipes" → Expand to show recipe names
- "+ Add item" → Add Item modal
- "Share" → Native share (text format)

---

## 6. User Flows

### Flow 1: First-Time User
```
Open app 
→ Menu (Empty) 
→ "+ ADD RECIPES" 
→ Add to Menu screen 
→ "Enter manually" 
→ Manual Entry 
→ "SAVE & ADD TO MENU" 
→ Menu (Planning) with 1 recipe
```

### Flow 2: Import and Cook
```
Menu (Empty) 
→ Paste TikTok link 
→ Processing 
→ Recipe Preview 
→ "ADD TO MENU" 
→ Menu (Planning) 
→ Add more recipes 
→ "GENERATE GROCERY LIST" 
→ List Generation 
→ "CREATE LIST" 
→ List tab 
→ Shop, check items 
→ Menu tab (To Cook) 
→ Tap recipe 
→ Recipe Detail 
→ "I MADE THIS" 
→ Done
```

### Flow 3: Browse and Add
```
Recipes tab 
→ Scroll/search 
→ Tap recipe 
→ Recipe Detail 
→ "+ ADD TO MENU" 
→ (recipe added) 
→ Menu tab 
→ Menu (Planning)
```

### Flow 4: Reuse Past Menu
```
Menu (any state) 
→ "View past menus" 
→ Menu History 
→ Tap old menu 
→ Archived Menu Detail 
→ "COOK THIS AGAIN" 
→ Menu (Planning) with recipes
```

### Flow 5: Start Fresh Mid-Cook
```
Menu (To Cook) 
→ "START NEW MENU" 
→ Confirmation modal 
→ "YES, START NEW" 
→ Current menu archived 
→ Menu (Empty)
```

---

## 7. Monetization

### Model: Freemium Subscription

**Integration:** RevenueCat (required for contest)

### Tiers

| Feature | Free | Pro |
|---------|------|-----|
| Recipes saved | 15 | Unlimited |
| Video imports/month | 5 | Unlimited |
| Menu history | Last 3 | Unlimited |
| "Check You Have" customization | Default list only | Custom staples |
| Share list | ✓ | ✓ |
| Multiple devices | — | ✓ |

### Pricing
- **Pro Monthly:** $4.99/month
- **Pro Annual:** $39.99/year (33% savings)

### Upgrade Triggers
- Hit recipe limit → Soft paywall
- Hit import limit → "Upgrade for unlimited"
- Try to access old menu history → Paywall
- Premium features shown but locked

---

## 8. Out of Scope (MVP)

The following features are explicitly NOT included in MVP:

| Feature | Reason |
|---------|--------|
| Collections/Folders | Organizational comfort, doesn't help cook |
| Cookbook shelf browsing | Inventory management, not execution |
| Meal calendar/week view | Rigid planning creates guilt, not action |
| Pantry inventory | Unreliable, adds friction without value |
| Social features | Distraction from core loop |
| Meal suggestions/AI recommendations | Complexity, can add later |
| Nutritional information | Not core to "actually cooking" |
| Recipe scaling | Nice-to-have, not MVP |
| Cook mode (step-by-step) | Polish feature, not core |
| Multiple simultaneous menus | Edge case, adds complexity |

---

## 9. Technical Requirements

### Platforms
- iOS (TestFlight for contest submission)
- Android (Play Internal Testing for contest submission)

### Required Integrations
- **RevenueCat:** Subscription management (contest requirement)
- **Recipe extraction:** Video (TikTok, IG, YouTube) and URL parsing

### Performance Targets
- Recipe import: < 15 seconds
- App launch: < 2 seconds
- List generation: < 1 second

### Offline Behavior
- Saved recipes available offline
- Grocery list available offline
- Import requires connection

---

## 10. Success Criteria

### Contest Success (Shipyard)

| Criteria | Weight | How We Win |
|----------|--------|------------|
| Audience Fit | 30% | Directly solves Eitan's stated problem |
| User Experience | 25% | Single clear flow, one action per screen |
| Monetization | 20% | Clean freemium with natural upgrade moments |
| Innovation | 15% | Menu-first model is novel in recipe space |
| Technical Quality | 10% | Fast, stable, polished |

### Product Success (Post-Contest)

| Metric | Target |
|--------|--------|
| Menu completion rate | >60% of menus reach "all cooked" |
| Weekly active users | Users return weekly to plan |
| Recipe → Menu conversion | >40% of saved recipes get added to a menu |
| List generation rate | >80% of Planning menus generate a list |

---

## 11. Open Questions

1. **Onboarding:** Do we need a tutorial, or is the empty state enough?
2. **Notifications:** Should we nudge users who have a "To Cook" menu but haven't cooked?
3. **Recipe editing:** How much can users edit imported recipes?
4. **Ingredient parsing:** How do we handle ambiguous quantities ("some", "to taste")?
5. **Duplicate recipes:** What happens if user imports same recipe twice?

---

## Appendix A: Screen Inventory

| Screen | Tab | Priority |
|--------|-----|----------|
| Menu - Empty | Menu | P0 |
| Menu - Planning | Menu | P0 |
| Menu - To Cook | Menu | P0 |
| Add to Menu | Menu | P0 |
| Link Import | Menu | P0 |
| Processing | Menu | P0 |
| Recipe Preview | Menu | P0 |
| Manual Entry | Menu | P0 |
| List Generation Modal | Menu | P0 |
| Recipes Main | Recipes | P0 |
| Recipe Detail | Shared | P0 |
| List - Active | List | P0 |
| List - Empty | List | P1 |
| Menu History | Menu | P1 |
| Archived Menu Detail | Menu | P1 |
| Add Item Modal | List | P1 |
| Made It Confirmation | Shared | P1 |
| Confirmation Modals | Shared | P1 |

---

## Appendix B: Data Model (Simplified)

```
User
├── id
├── email
└── subscription_status

Recipe
├── id
├── user_id
├── title
├── source_type (video | url | manual)
├── source_url
├── source_name (cookbook name, author)
├── ingredients[] { text, quantity, unit }
├── steps[]
├── tags[]
├── image_url
├── created_at
└── times_cooked

Menu
├── id
├── user_id
├── status (planning | to_cook | archived)
├── created_at
├── archived_at
└── recipes[] { recipe_id, is_cooked }

GroceryList
├── id
├── menu_id
├── items[] { text, quantity, category, is_checked }
├── staples_confirmed[]
└── created_at
```

---

## Appendix C: Tag Taxonomy

**Meal Type:** Breakfast, Lunch, Dinner, Snack, Dessert

**Speed:** Quick (<30min), Weeknight, Project

**Cuisine:** Asian, Italian, Mexican, Japanese, Indian, American, Mediterranean, French

**Protein:** Chicken, Beef, Pork, Fish, Seafood, Vegetarian, Vegan

**Style:** Healthy, Comfort, Light, Hearty

**Method:** One-Pot, Sheet Pan, Grill, No-Cook, Slow Cooker, Instant Pot
