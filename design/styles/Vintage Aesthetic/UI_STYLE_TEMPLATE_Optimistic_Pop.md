# UI Style Direction Template for Cooked

> Fill out one copy of this template per style direction.
> The developer will implement each style as a complete theme.

---

## Style Name
**Name:** Sunshine Editorial

**Mood in 3-5 words:** Optimistic, Retro-Modern, Energetic, Warm

---

## Color Palette

| Role | Light Mode | Dark Mode (optional) |
|------|------------|----------------------|
| **Primary** (buttons, links, key actions) | `#FF5A36` (Tangerine Pop) | `#FF7050` |
| **Secondary** (accents, tags, highlights) | `#FFC800` (Marigold Yellow) | `#FFD54F` |
| **Background Main** | `#FFF9F0` (Warm Cream) | `#2D2520` (Warm Charcoal) |
| **Background Card/Elevated** | `#FFFFFF` (Crisp White) | `#3E3430` (Coffee) |
| **Text Primary** | `#2D2520` (Dark Coffee) | `#FFF9F0` |
| **Text Secondary/Muted** | `#8D6E63` (Muted Cocoa) | `#D7CCC8` |
| **Success** (cooked, completed) | `#66BB6A` (Leafy Green) | `#81C784` |
| **Destructive** (delete, remove) | `#D84315` (Burnt Orange) | `#FF8A65` |

---

## Typography

**Font Family:**
- [ ] System Default (SF Pro)
- [x] Custom: **Bebas Neue** (Headlines), **DM Sans** (Body), **Playfair Display** (Accents)

**Weight Usage:**
| Element | Weight |
|---------|--------|
| Large titles | **Bebas Neue (Regular/400)** - *Always Uppercase* |
| Section headers | **DM Sans (Bold/700)** |
| Body text | **DM Sans (Regular/400)** |
| Captions/labels | **DM Sans (Medium/500)** |
| Buttons | **DM Sans (Bold/700)** - *Uppercase* |

**Spacing Density:**
- [ ] Compact (information-dense)
- [ ] Standard (balanced)
- [x] Generous (breathing room) — *Editorial layout requires whitespace to feel "magazine-like"*

---

## Shape & Depth

**Corner Radius Philosophy:**
- [ ] Sharp (0-4pt) — modern, editorial
- [ ] Soft (8-12pt) — friendly, approachable
- [x] Rounded (16-20pt) — playful, bubbly
- [ ] Pill/Full (50%) — bold, distinctive

**Elevation/Shadow Style:**
- [x] Flat (no shadows, use borders or color) — *Graphic, print-inspired look*
- [ ] Subtle (soft, barely visible shadows)
- [ ] Pronounced (clear depth, layered feel)

**Border Usage:**
- [x] None (rely on background contrast) — *Cream background vs White cards*
- [ ] Subtle (1pt, light color)
- [ ] Defined (visible borders as design element)

---

## Component Style Notes

### Buttons
- Fill style: [x] Solid [ ] Outline [ ] Ghost
- Shape: [ ] Rectangle [ ] Rounded [x] Pill
- Other notes: **Primary buttons are Tangerine (`#FF5A36`). Secondary buttons are Marigold (`#FFC800`) with Dark Coffee text.**

### Cards (Recipe cards, menu items)
- Background: [x] White/elevated [ ] Subtle tint [ ] Transparent
- Image treatment: [x] Full bleed [ ] Inset with padding [ ] Rounded corners
- Other notes: **Images should feel like magazine cutouts. If possible, mask the bottom edge of hero images with a slight wave.**

### Lists (Grocery items, ingredients)
- Style: [ ] Minimal lines [x] Cards [ ] Grouped sections
- Checkboxes: [ ] Circle [ ] Square [x] Custom
- Other notes: **Thick circular checkbox. When checked, it fills with the Primary Tangerine color.**

### Navigation
- Tab bar: [ ] Standard iOS [x] Custom floating [ ] Hidden labels
- Headers: [x] Large title [ ] Inline [ ] Custom
- Other notes: **Floating "Pill" tab bar at bottom. Active state uses a glowing dot or filled icon.**

---

## Iconography

**Icon Style:**
- [ ] SF Symbols (default iOS)
- [ ] Outlined/line icons
- [x] Filled/solid icons
- [ ] Custom illustrated
- Specific set: **Phosphor Icons (Fill weight) or FontAwesome (Solid)**

---

## Visual References

**Reference Apps** (1-3 apps with similar vibe):
1. **Headspace** (For the warmth and soft shapes)
2. **Bon Appétit** (For the typography hierarchy and photography focus)
3. **Superlist** (For the playful, non-standard UI elements)

**Moodboard/Images:**
*Reference: The Drew Barrymore Show Season 4 Key Art (Uploaded). Focus on "Sunshine State" colors and concentric wave patterns.*

---

## Special Considerations

**Must preserve iOS conventions?**
- [ ] Yes, feel native
- [x] No, can be distinctive — *Prioritize the Brand Vibe over platform norms.*

**Accessibility priority:**
- [x] Standard (WCAG AA)
- [ ] High contrast option needed — *Watch the White text on Orange background; ensure bold weights are used.*

**Animation feel:**
- [ ] Snappy/instant
- [ ] Smooth/fluid
- [x] Playful/bouncy — *Spring animations on button presses; elements slide in with energy.*

---

## Additional Notes
**Pattern Usage:** Use the "Wave" motif from the moodboard as a background element on empty states or loading screens to avoid "boring white space."

**Empty States:** Should be very colorful. If the user has no recipes, show a large, warm illustration or a "sunburst" graphic.

**Typography scaling:** The "Bebas Neue" headers should be significantly larger than standard iOS headers to achieve the "poster" look.