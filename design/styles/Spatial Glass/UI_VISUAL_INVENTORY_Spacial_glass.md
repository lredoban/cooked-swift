# Cooked App - Visual Inventory: Spatial Glass Style

> **Style Philosophy:** "The Culinary Operating System."
> This design treats the UI as a floating Heads-Up Display (HUD) layered over the physical world (content). It replaces solid screens with immersive depth, using frosted glass, motion, and light to guide the user. It is premium, futuristic, and content-forward.

---

## 1. Visual Identity System

| Attribute | Specification | usage |
| :--- | :--- | :--- |
| **Theme** | **Immersive Dark / Video-Pass-Through** | Backgrounds are never solid; they are blurred video or dark gradients. |
| **Primary Material** | `rgba(255, 255, 255, 0.08)` + `backdrop-filter: blur(24px)` | Used for sheets, cards, and navigation bars. |
| **Borders** | `1px solid rgba(255, 255, 255, 0.15)` | High-light borders to define edges on glass. |
| **Primary Accent** | **Holographic Orange** `linear-gradient(135deg, #FF9966 0%, #FF5E62 100%)` | Used for primary CTAs and active states. |
| **Text Colors** | Primary: `#FFFFFF` <br> Secondary: `rgba(255, 255, 255, 0.65)` | High contrast essential for readability on glass. |
| **Corner Radius** | `24px` (Superellipse) | Smooth, organic curves to feel tactile. |
| **Shadows** | **Ambient Glow** `0px 10px 40px rgba(0,0,0,0.5)` | Deep shadows to create Z-axis separation between layers. |

---

## 2. Component Styling

### Navigation (Tab Bar)
* **Structure:** Floating capsule (pill shape) suspended 20px from the bottom edge, not attached to the screen bottom.
* **Material:** Heavy frosted glass (`blur(30px)`).
* **Active State:** Icons glow with an "inner light" effect; no solid color fills. A subtle gradient reflection appears beneath the active icon.

### Recipe Cards (Grid View)
* **Container:** No visible container box. The image is the card.
* **Typography:** Title and metadata sit on a "frosted gradient" overlay at the bottom of the image (`linear-gradient(to top, rgba(0,0,0,0.8), transparent)`).
* **Interaction:** On press, the card scales down slightly (0.98x) and the border glows.

### Primary Buttons (CTAs)
* **Style:** "Luminous Glass."
* **Background:** Semi-transparent gradient (`rgba(255, 153, 102, 0.8)`).
* **Effect:** Inner shadow `inset 0 1px 0 rgba(255,255,255,0.4)` to create a bevel/3D feel.
* **Motion:** Parallax effect on the text inside the button when tilting the device (optional).

### Progress Bars
* **Track:** Deep groove (`rgba(0,0,0,0.3)`).
* **Fill:** Neon gradient bar with a "glow" blur effect (`box-shadow: 0 0 10px #FF9966`).

---

## 3. Screen Adaptations

### 1A. Empty Menu State (The Dashboard)
* **Background:** A slow-motion, dark cinematic loop of steam rising or ingredients falling (muted).
* **Illustration:** Replaced by a 3D Glass Icon of a Fork & Knife rendered in a metallic/glass texture, slowly rotating or floating.
* **Typography:** Large "Menu" title uses the **Display Font** (Wide Sans).
* **CTA:** The "+ Add Recipes" button is a bright, glowing pill floating in the center of the dark space.

### 2B. Recipe Detail View (The HUD)
* **Header:** The Hero Video plays full screen behind everything.
* **Navigation:** Back button is a circular glass blur element.
* **Content:** The recipe content (Title, Ingredients, Steps) lives in a "Sheet" that slides up from the bottom, covering 70% of the screen.
    * **Sheet Material:** High blur glass. You can vaguely see the cooking video playing behind the text.
* **Ingredients:**
    * List items are separated by very thin white dividers (`opacity: 0.1`).
    * Checkboxes are neon outlines that fill with light when tapped.
* **Typography:** "Cooked 3 times" / "12 ingredients" metadata is styled in **Monospace** font to look like technical specs.

### 3B. Active Grocery List (The Checklist)
* **Structure:** Sections (Produce, Meat) are floating glass panels stacked vertically with vertical spacing (gap: 16px).
* **Checked Items:** Instead of a strikethrough, checked items dim significantly (`opacity: 0.3`) and the glass panel behind them darkens, pushing them "back" in Z-space.
* **Visuals:** Category headers use small, glowing neon icons.

### 4C. Recipe Preview Sheet (Import)
* **Loading State:** A "scanning" animation. A horizontal laser line scans the recipe URL card.
* **Success:** The extracted recipe card "pops" forward in 3D space with a glass shimmer effect.