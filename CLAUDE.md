# CLAUDE.md

## Quick Reference

- **Project:** Cooked - Recipe Menu App (iOS Native)
- **Platform:** iOS 17+
- **Language:** Swift 6.0
- **UI Framework:** SwiftUI with `@Observable`
- **Backend:** Supabase (PostgreSQL + Auth)
- **Payments:** RevenueCat
- **Recipe Import:** Nitro backend API

## Project Philosophy

**Core concept:** Menu-first - users build a menu of recipes they commit to cooking, then generate a grocery list. The menu (not recipes) is the product.

**Key principle:** "Does this help the user cook this week?" — every feature must pass this filter.

## XcodeBuildMCP Integration

This project uses XcodeBuildMCP for all Xcode operations:

```
# Set session defaults first
mcp__xcodebuildmcp__session-set-defaults (scheme: "Cooked", simulatorName: "iPhone 16")

# Build & Run
mcp__xcodebuildmcp__build_sim
mcp__xcodebuildmcp__build_run_sim

# Test
mcp__xcodebuildmcp__test_sim

# Clean
mcp__xcodebuildmcp__clean
```

## Project Structure

```
Cooked/
├── App/                    # App entry point, AppTab enum
├── Features/               # Feature modules
│   ├── Recipes/            # Recipe library, import, detail
│   │   └── Import/         # ImportRecipeSheet, RecipePreviewSheet
│   ├── Menu/               # Menu planning and cooking
│   └── GroceryList/        # Shopping list generation
├── Models/                 # Codable structs matching Supabase
├── Services/               # Supabase, RecipeService wrappers
├── Shared/
│   └── Components/         # Reusable UI (LoadingView, AsyncImageView)
└── Configuration/          # Config.xcconfig, Secrets.xcconfig
```

## Data Models

```
User { id, email, subscription_status }
Recipe { id, user_id, title, source_type, source_url, ingredients[], steps[], tags[], times_cooked }
Menu { id, user_id, status (planning|to_cook|archived), recipes[] }
GroceryList { id, menu_id, items[], staples_confirmed[] }
```

## Menu State Machine

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

## Coding Standards

### Swift Style

- Use Swift 6 strict concurrency
- Prefer `@Observable` over `ObservableObject`
- Use `async/await` for all async operations
- Use `guard` for early exits
- Prefer value types (structs) over reference types (classes)
- No force unwrapping (`!`) without justification

### SwiftUI Patterns

```swift
// State Management
@Observable
class RecipeState {
    var recipes: [Recipe] = []
    var isLoading = false
}

// Environment Injection
@main
struct CookedApp: App {
    @State private var recipeState = RecipeState()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(recipeState)
        }
    }
}

// View consuming state
struct RecipesView: View {
    @Environment(RecipeState.self) private var recipeState

    var body: some View {
        @Bindable var state = recipeState  // For bindings
        // ...
    }
}

// Navigation
NavigationStack {
    List(recipes) { recipe in
        NavigationLink(value: recipe) {
            RecipeRow(recipe: recipe)
        }
    }
    .navigationDestination(for: Recipe.self) { recipe in
        RecipeDetailView(recipe: recipe)
    }
}
```

### Supabase Queries

```swift
func fetchRecipes() async throws -> [Recipe] {
    try await client
        .from("recipes")
        .select()
        .eq("user_id", value: userId)
        .order("created_at", ascending: false)
        .execute()
        .value
}
```

### Error Handling

```swift
enum RecipeServiceError: LocalizedError {
    case extractionFailed(String)
    case networkError
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .extractionFailed(let msg): return "Failed to extract: \(msg)"
        case .networkError: return "Network connection failed"
        case .unauthorized: return "Please sign in"
        }
    }
}
```

## Environment Configuration

Create `Secrets.xcconfig` from template with:
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

## Development Status

See `ROADMAP.md` for detailed phase breakdown.

- **Phase 0:** Foundation & Setup ✅
- **Phase 1:** Recipe Import & Core CRUD ✅
- **Phase 2:** Menu System (Core Product) ✅
- **Phase 3:** Grocery List Generation ✅
- **Phase 4:** Search & Filtering ✅
- **Phase 5:** Menu History & Reuse ✅
- **Phase 6:** Monetization (RevenueCat) ✅
- **Phase 7:** UX Polish ⬅️ Current
- **Phase 8:** Analytics (PostHog)
- **Phase 9:** UI Polish
- **Phase 10:** Security & Performance
- **Phase 11:** App Store Preparation (Deferred)
- **Cloud Phase:** Ongoing async tasks
- **Backend & Web:** Ongoing - Next.js API + website

## DO NOT

- Use deprecated APIs (UIKit when SwiftUI suffices)
- Create massive monolithic views (extract at ~100 lines)
- Ignore Swift 6 concurrency warnings
- Skip the menu-first philosophy
- Add features that don't help users "cook this week"
