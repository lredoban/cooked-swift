# UI_VISUAL_INVENTORY_Curated_Kitchen.md

## Philosophy
This aesthetic treats the app as a digital sanctuary—a "Kinfolk magazine" for utility. It balances "Modern Minimalism" with warmth, utilizing high-legibility editorial typography and earth tones to reduce cognitive load and kitchen anxiety.

## Visual Identity

| Attribute | Value / Description |
| :--- | :--- |
| **Primary Color** | **Terracotta** `#E07A5F` (Actions/CTAs) |
| **Secondary Color** | **Sage Green** `#8DA399` (Success/Progress) |
| **Background** | **Oatmeal** `#F9F8F4` (Canvas) / **White** `#FFFFFF` (Cards) |
| **Text Color** | **Charcoal** `#2D2D2D` (Primary) / **Warm Grey** `#666666` (Secondary) |
| **Corner Radius** | `12px` (Cards), `24px` (Buttons) - "Soft Geometry" |
| **Shadows** | Diffused, warm ambient shadows (e.g., `0 4px 20px rgba(0,0,0,0.05)`) |

## Component Styling

### Recipe Card (Inventory Ref: Reusable Components)
* **Container:** White card with `12px` radius and subtle elevation.
* **Image:** 4:3 aspect ratio, fills top of card. No gradient overlay; clean cut.
* **Typography:** Title in **Serif** (Bold), Source in **Sans-Serif** (Uppercase, tracking +1px, muted).
* **Badge:** Minimalist pill shape, transparent background with Sage Green border and text.

### Buttons (Inventory Ref: Reusable Components)
* **Primary CTA:** Full pill shape. Terracotta background, White text. Lowercase or Sentence case (friendly, not shouting).
* **Secondary:** Ghost button. Terracotta border (1px), transparent fill.
* **Icons:** Fine-line stroke icons (1.5px stroke width), rounded caps.

### Progress Bar (Inventory Ref: 1C, 3B)
* **Track:** Very light beige (`#EBE9E4`).
* **Fill:** Sage Green (`#8DA399`). Rounded ends.
* **Height:** `6px` (slim and elegant).

## Screen Adaptations

### 1A. Empty Menu State (The "Invite")
* **Background:** Oatmeal `#F9F8F4`.
* **Illustration:** Instead of a generic icon, use a fine-line aesthetic illustration of a table setting or fresh produce (single color: Warm Grey).
* **Typography:**
    * Headline: "What do you want to cook?" in Large Serif Display.
    * Subtext: "Build your menu for the week" in small Sans-Serif.
* **CTA:** Centered, Terracotta, "Start Planning" (inviting phrasing).

### 2B. Recipe Detail View (The "Editorial Spread")
* **Hero:** Image is not full bleed; it sits within margins with rounded corners, resembling a photo pasted in a scrapbook.
* **Header:** Title is huge, Serif, Black. Centered alignment.
* **Metadata:** displayed in a horizontal row using small icons and sans-serif text divided by vertical hairlines.
* **Ingredients:**
    * Background: White paper texture or plain white block against the Oatmeal background.
    * Text: High readability Sans-Serif.
* **Steps:**
    * Numbers: Large, Serif, Sage Green color (e.g., "1", "2").
    * Text: Serif for the instruction body to differentiate from ingredients.

### 4D. Recipe Limit Paywall (The "Membership")
* **Vibe:** Less "Error/Stop" and more "Exclusive Club Invitation."
* **Visual:** blurred background of the user's current view.
* **Card:** Centered white modal.
* **Icon:** A subtle star or key icon in Terracotta (instead of a lock).
* **Copy:** "Unlock the full kitchen."