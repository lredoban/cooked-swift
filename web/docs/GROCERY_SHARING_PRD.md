# Grocery List Sharing - Web PRD

## Overview

Web page for viewing and interacting with a shared grocery list in real-time. Partners/family can help check off items from any browser while the primary user shops with the iOS app.

## User Flow

1. iOS user taps "Share with Link" on their grocery list
2. iOS app generates share link: `https://cooked.app/list/{shareToken}`
3. User shares link with partner (text, AirDrop, etc.)
4. Partner opens link in browser (no login required)
5. Both see real-time updates as items are checked off

## Technical Context

### Database Schema

```sql
-- grocery_lists table (already exists)
-- New column: share_token text unique
-- RLS policies allow anon SELECT/UPDATE when share_token is not null
```

### Items Structure (JSONB)

```typescript
interface GroceryItem {
  id: string        // UUID
  text: string      // "Chicken breast"
  quantity?: string // "2 lbs"
  category: 'produce' | 'meat' | 'dairy' | 'pantry' | 'other'
  is_checked: boolean
}

interface GroceryList {
  id: string
  menu_id: string
  items: GroceryItem[]
  staples_confirmed: string[]
  share_token: string | null
  created_at: string
  updated_at: string
}
```

## Page: `/list/[token]`

### Route

- File: `app/list/[token].vue` (Nuxt 4 file-based routing)
- Example URL: `https://cooked.app/list/abc123xyz789`

### Data Fetching

```typescript
// Fetch by share_token (not id)
const { data: groceryList } = await useAsyncData('grocery-list', () =>
  supabase
    .from('grocery_lists')
    .select('*')
    .eq('share_token', token)
    .single()
)
```

### Realtime Subscription

```typescript
const channel = supabase
  .channel(`grocery-list-${token}`)
  .on(
    'postgres_changes',
    {
      event: 'UPDATE',
      schema: 'public',
      table: 'grocery_lists',
      filter: `share_token=eq.${token}`
    },
    (payload) => {
      groceryList.value = payload.new
    }
  )
  .subscribe()

// Cleanup on unmount
onUnmounted(() => {
  channel.unsubscribe()
})
```

### Updating Items (Check/Uncheck)

```typescript
async function toggleItem(itemId: string) {
  // Optimistic update
  const itemIndex = groceryList.value.items.findIndex(i => i.id === itemId)
  groceryList.value.items[itemIndex].is_checked = !groceryList.value.items[itemIndex].is_checked

  // Persist to Supabase
  const { error } = await supabase
    .from('grocery_lists')
    .update({ items: groceryList.value.items })
    .eq('share_token', token)

  if (error) {
    // Revert on error
    groceryList.value.items[itemIndex].is_checked = !groceryList.value.items[itemIndex].is_checked
    // Show toast
  }
}
```

## UI Components

### Layout

```
┌─────────────────────────────────┐
│        🛒 Grocery List          │  ← Header
│         12/20 items             │  ← Progress
│ ████████████░░░░░░░ 60%         │  ← Progress bar
├─────────────────────────────────┤
│ 🥬 Produce                      │  ← Category header
│ ┌─────────────────────────────┐ │
│ │ ○ Spinach          1 bag    │ │  ← Unchecked item
│ │ ○ Tomatoes         4        │ │
│ │ ✓ Lettuce          1 head   │ │  ← Checked (strikethrough)
│ └─────────────────────────────┘ │
│ 🥩 Meat & Seafood               │
│ ┌─────────────────────────────┐ │
│ │ ○ Chicken breast   2 lbs    │ │
│ │ ✓ Salmon fillet    1 lb     │ │
│ └─────────────────────────────┘ │
│ ...                             │
└─────────────────────────────────┘
```

### Component Breakdown

1. **Header** - "Grocery List" title, progress count
2. **ProgressBar** - Visual progress indicator
3. **CategorySection** - Category icon, name, items
4. **GroceryItemRow** - Checkbox, text, quantity, tap to toggle

### Category Icons (use Nuxt UI icons)

| Category | Icon |
|----------|------|
| produce  | `i-heroicons-leaf` |
| meat     | `i-heroicons-fire` |
| dairy    | `i-heroicons-beaker` |
| pantry   | `i-heroicons-archive-box` |
| other    | `i-heroicons-shopping-bag` |

### States

1. **Loading** - Skeleton/spinner while fetching
2. **Not Found** - Invalid/expired token → friendly error page
3. **Active** - Main list view with items
4. **Empty** - List exists but has no items (edge case)

## Styling

- Use `@nuxt/ui` components (UButton, UCheckbox, UCard, UProgress)
- Mobile-first responsive design
- Touch-friendly targets (min 44px tap area)
- Checked items: strikethrough text, muted color, stay in category but at bottom

## Error Handling

| Error | User Message |
|-------|--------------|
| Invalid token | "This grocery list doesn't exist or the link has expired." |
| Network error | "Unable to connect. Check your internet and try again." |
| Update failed | Toast: "Couldn't save change. Tap to retry." |

## Performance

- Initial load should be < 2s
- Optimistic updates for instant feedback
- Realtime subscription for live sync
- No polling fallback needed (Realtime is reliable)

## Security

- No authentication required (share token = access)
- Share tokens are 12-char alphanumeric (URL-safe)
- RLS policies restrict access to rows with valid share_token
- Only items field can be updated (not the whole row structure)

## Out of Scope (v1)

- Adding new items from web
- Reordering items
- Deleting the list from web
- Multiple lists view
- User accounts on web
- Push notifications

## Dependencies

```json
{
  "@supabase/supabase-js": "^2.x",
  "@nuxt/ui": "^3.x"
}
```

## Environment Variables

```env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
```

## Testing Checklist

- [ ] Page loads with valid token
- [ ] 404 page for invalid token
- [ ] Items display grouped by category
- [ ] Tapping checkbox toggles item
- [ ] Checked items show strikethrough
- [ ] Progress bar updates on toggle
- [ ] Realtime: changes from iOS appear instantly
- [ ] Realtime: changes from web appear on iOS instantly
- [ ] Mobile responsive layout
- [ ] Works on Safari, Chrome, Firefox
