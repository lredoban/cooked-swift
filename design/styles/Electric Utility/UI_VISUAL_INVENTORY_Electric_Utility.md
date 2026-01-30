# UI_VISUAL_INVENTORY_Electric_Utility.md

## 0. Philosophy
**"The Nintendo Approach."** A system that merges high-function utility with joyful, tactile aesthetics. It utilizes a "Bento Box" grid structure where every element lives in a distinct, rounded container, using color-blocking to separate logic (e.g., Ingredients vs. Steps) rather than whitespace alone.

---

## 1. Visual Identity System

| Attribute | Value | Description |
|-----------|-------|-------------|
| **Primary Brand** | `#FF4D00` (Hyper Orange) | Used for primary CTAs and active states. |
| **Secondary Accents** | `#FFD600` (Yolk), `#4A5AF7` (Cobalt) | Used for section backgrounds (Color Blocking). |
| **Base Background** | `#F2F2F0` (Warm Concrete) | Not stark white; easier on the eyes, feels premium. |
| **Surface Color** | `#FFFFFF` (White) | Used for cards to pop off the grey background. |
| **Text Colors** | `#1A1C20` (Ink), `#6B6E75` (Graphite) | High contrast, accessible. |
| **Corner Radius** | `24px` | Heavily rounded, friendly, "touchable." |
| **Shadows** | `0 8px 20px rgba(0,0,0,0.06)` | Soft, diffused, elevating the "Bento" blocks. |

---

## 2. Component Styling

### Recipe Card (The "Bento Tile")
*Used in Screens 1B, 2A, 6A*
- **Structure:** Full-bleed image with a `24px` radius.
- **Overlay:** No scrim. Text sits in a "floating pill" (white background) at the bottom of the card.
- **Micro-interaction:** Card scales up 1.02x on press; the "Ready" badge is a 3D-style sticker icon (check mark) floating on the top right.

### Buttons & Controls
*Used in All Screens*
- **Primary CTA:** Full width, `56px` height, `#FF4D00` background. Text is uppercase and bold.
- **Secondary Buttons:** Heavily stroked (`2px` border) pills in `#1A1C20` or translucent fills.
- **Tags/Chips:** Large, touch-friendly pills. Selected state turns the chip `#FFD600` (Yellow) with black text.

### Progress Bars
*Used in Screens 1C, 3B*
- **Style:** "Health Bar." A thick track (`12px` height) with a rounded capsule fill.
- **Color:** Gradient fill from Orange to Yellow.

---

## 3. Screen Adaptations

### 1A. Empty Menu State (The Hook)
- **Layout:** The "Fork & Knife" illustration is replaced by a large, 3D-rendered mascot or kinetic typography floating in the center.
- **Typography:** "What do you want to cook?" is set in the display font (huge, tight leading).
- **Action:** The "+ Add Recipes" button is not just a button, but a floating card at the bottom with a subtle bounce animation to encourage the first tap.

### 1B. Planning Menu State (The Grid)
- **Grid:** A masonry layout (staggered heights) to feel organic rather than rigid.
- **Badges:** The "3 recipes" count isn't plain text; it's inside a pill-shaped tag next to the header.
- **Remove Action:** Instead of a small "X", the remove button is a distinctive circle button on the card corner that turns red on long-press.

### 2B. Recipe Detail View (Color Blocked)
- **Header:** Hero image has a curved bottom edge (`border-bottom-left-radius: 40px`).
- **Ingredients Section:** Sits inside a specific background container (e.g., soft yellow `#FFF9C4`). Each ingredient is a row separated by white hairlines.
- **Steps Section:** Sits inside a contrasting container (e.g., soft blue `#E8EAF6`). The step numbers are large, circled integers in the primary brand color.
- **Typography:** Ingredient quantities are bolded heavily (e.g., **2 cups**) for scannability.

### 3B. Active Grocery List (Gamified)
- **Checkboxes:** Large, distinct squares (`28px`). When checked, the item doesn't just cross out; it dims significantly and moves to a "Done" section at the bottom called "In the Cart."
- **Headers:** Category headers (Produce, Dairy) use big emoji icons as visual anchors.