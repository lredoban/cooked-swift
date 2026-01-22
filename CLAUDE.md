# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cooked is a native iOS recipe menu app built with Swift/SwiftUI. The core concept is **menu-first**: users build a menu of recipes they commit to cooking, then generate a grocery list. The menu (not recipes) is the product.

**Key principle:** "Does this help the user cook this week?" — every feature must pass this filter.

## Build & Development Commands

```bash
# Build for simulator
xcodebuild -scheme Cooked -destination 'platform=iOS Simulator,name=iPhone 15'

# Run all tests
xcodebuild test -scheme Cooked -destination 'platform=iOS Simulator,name=iPhone 15'

# Open in Xcode
open Cooked.xcodeproj
```

Or use Xcode directly: select scheme and press ⌘R to run, ⌘U to test.

## Architecture

### Tech Stack
- **Language:** Swift 5.9+, iOS 17+
- **UI:** SwiftUI with `@Observable` for state management
- **Navigation:** NavigationStack with 3-tab structure
- **Backend:** Supabase (PostgreSQL + Auth) — shared with React Native version
- **Payments:** RevenueCat for subscriptions
- **Recipe Import:** Nitro backend API for video/URL extraction

### Planned Directory Structure
```
Cooked/
├── App/           # App entry point, global state
├── Features/      # Feature modules (Menu, Recipes, GroceryList)
├── Services/      # Supabase, Auth, RevenueCat wrappers
├── Models/        # Codable structs matching Supabase schema
└── Shared/        # Reusable UI components
```

### Data Models
```
User { id, email, subscription_status }
Recipe { id, user_id, title, source_type, source_url, ingredients[], steps[], tags[], times_cooked }
Menu { id, user_id, status (planning|to_cook|archived), recipes[] }
GroceryList { id, menu_id, items[], staples_confirmed[] }
```

### Menu State Machine
```
EMPTY ──[add recipe]──▶ PLANNING ──[generate list]──▶ TO COOK ──[all cooked]──▶ ARCHIVED
```
Only ONE menu can be in "To Cook" state at a time.

## Navigation Structure

```
┌─────────┐     ┌─────────────┐     ┌─────────┐
│ RECIPES │     │    MENU     │     │  LIST   │
│   📖    │     │     🍳      │     │    ✓    │
└─────────┘     └─────────────┘     └─────────┘
 secondary          PRIMARY          secondary
```

MENU is center tab, always opens first. This reflects the menu-first philosophy.

## SwiftUI Patterns Used

### State Management
```swift
@Observable
class MenuState {
    var currentMenu: MenuWithRecipes?
    var viewState: ViewState = .loading
}
```

### Environment Injection
```swift
@main
struct CookedApp: App {
    @State private var appState = AppState()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
```

### Supabase Queries
```swift
func fetchRecipes() async throws -> [Recipe] {
    try await client.from("recipes").select().eq("user_id", value: userId).execute().value
}
```

## Environment Configuration

Create `Config.xcconfig` with:
```
SUPABASE_URL = your-project-id.supabase.co
SUPABASE_ANON_KEY = your-anon-key
BACKEND_URL = http://localhost:3000
REVENUECAT_API_KEY = appl_your_api_key
```

## Freemium Limits

| Feature | Free | Pro ($4.99/mo) |
|---------|------|----------------|
| Recipes | 15 | Unlimited |
| Video imports/month | 5 | Unlimited |
| Menu history | 3 | Unlimited |

## Development Phases

Current: **Phase 0** (Foundation) — basic project structure complete

Upcoming phases:
1. Manual recipe entry + CRUD
2. Menu system (core product)
3. Grocery list generation
4. Recipe import from URLs/videos
5. Search & filtering
6. Menu history
7. RevenueCat monetization
8. Polish & App Store

See `ROADMAP.md` for detailed implementation guidance per phase.
