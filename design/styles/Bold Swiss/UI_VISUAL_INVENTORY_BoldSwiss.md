# UI_VISUAL_INVENTORY_BoldSwiss.md

> Style Variant: High Contrast Editorial / Swiss International Style
> Keywords: Precise, Grid-based, Monochrome, Typographic, Brutalist-Lite

---

## 1. Design Philosophy
**"The Kitchen Manifesto."**
The interface treats meal planning with the precision of a Swiss train schedule. It rejects decoration in favor of clarity. The grid is visible, the type is massive, and the only color comes from the food itself. It feels like a high-end architectural magazine or a nutrition label—utilitarian yet undeniably stylish.

---

## 2. Visual Identity

| Element | Value | Notes |
| :--- | :--- | :--- |
| **Primary Color** | `#000000` (Black) | Used for text, borders, and primary CTAs. |
| **Background** | `#FFFFFF` (White) | Stark, clinical white. No off-whites. |
| **Accent Color** | `#FF3300` (Swiss Red) | Used sparingly for errors or "Active" notification dots only. |
| **Typography** | Sans-Serif (Grotesque) | Massive headers, tight letter-spacing. |
| **Corner Radius** | `0px` | Sharp corners everywhere. No rounding. |
| **Shadows** | None | Depth is created via borders and layout, not drop shadows. |
| **Borders** | `1px Solid Black` | Used to separate all content sections. |

---

## 3. Component Styling

### A. Recipe Card
* **Container:** 1px solid black border. No shadow.
* **Image:** Strictly square or 4:3. No border radius.
* **Typography:** Title is Uppercase, Bold, aligned left.
* **Metadata:** Separated by a horizontal line below the title.
* **Status Badge:** A solid black square with white text (e.g., "READY") positioned in the top-left corner of the image.

### B. Buttons (Primary & Secondary)
* **Primary CTA:** Solid Black rectangle (`#000000`). White text (`#FFFFFF`). Sharp corners. Text is Uppercase and tracked out (letter-spacing: 1px).
* **Secondary CTA:** White background. 1px Solid Black border. Black text.
* **Icons:** Simple, geometric line icons. 2px stroke width.

### C. Progress Bar
* **Container:** 1px black border. Transparent background.
* **Fill:** Solid black bar. Hard edge (no rounding).
* **Text:** "2/5" displayed as large numbers outside the bar.

### D. Navigation / Tabs
* **Style:** Text-based or minimalist geometric icons.
* **Active State:** Inverted colors (Black box, White icon) or a thick 4px underline.
* **Separators:** Vertical lines separating tab items.

---

## 4. Screen Adaptations

### Screen 1A: Empty Menu State (The Manifesto)
* **Layout:** Layout feels like a poster.
* **Headline:** "WHAT DO YOU \nWANT TO COOK?" set in Massive font size (e.g., 48pt+), flush left.
* **Illustration:** Replaced by a large, graphic icon (Fork/Knife) executed in thick black lines, no fill.
* **CTA:** The "+ Add Recipes" button spans the full width of the screen at the bottom, anchored to the safe area.
* **Subtext:** Small, monospaced text describing the function, placed in a defined grid column.

### Screen 2B: Recipe Detail (The Nutrition Label)
* **Header:** Hero image at the top with a hard line separating it from the content.
* **Title:** Huge, spanning multiple lines if necessary.
* **Metadata:** A grid row titled "SPECS" containing: "Time | Ingredients | Calories" separated by vertical black lines.
* **Ingredients:** Styled like a nutrition label.
    * Heavy black separator lines between items.
    * Quantity is bolded on the left; Item name is standard weight on the right.
* **Steps:**
    * Large, bold numbers (01, 02, 03) in the left margin.
    * Text aligned to a strict grid on the right.

### Screen 3B: Active Grocery List (The Checklist)
* **Checkbox:** Square box, 2px black border. When checked, it gets filled with a solid black "X" or solid black fill.
* **Grouping:** Section Headers (Produce, Dairy) are white text on Black Bars (inverted headers).
* **Completed Items:** No strikethrough. They simply dim to 30% opacity or move to a "Completed" section separated by a double thick line.