# Cooked - Recipe Menu App (iOS)

A native iOS app that helps people turn food inspiration into a real plan — and actually cook it.

Built with Swift 6.0 and SwiftUI for iOS 17+.

## Philosophy

**Menu-first, not recipe-first.** Users build a menu of recipes they commit to cooking this week, then generate a grocery list. The menu (not individual recipes) is the product. Every feature must pass this filter: "Does this help the user cook this week?"

## Features

- **Menu-First Approach**: Build a menu of recipes you'll actually cook this week
- **Recipe Import**: Import recipes from TikTok, Instagram, YouTube, and recipe blogs
- **Smart Grocery Lists**: Auto-generated, categorized shopping lists with staple detection
- **Progress Tracking**: Mark recipes as cooked and track your cooking journey
- **Menu History**: Reuse past menus to cook favorites again
- **Freemium Model**: Free tier with 15 recipes, Pro unlocks unlimited

## Tech Stack

| Component | Technology |
|-----------|------------|
| UI Framework | SwiftUI with iOS 17's `@Observable` |
| Language | Swift 6.0 (strict concurrency) |
| Backend | Supabase (PostgreSQL + Auth) |
| Payments | RevenueCat |
| Architecture | Feature-based with Services layer |

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 6.0+

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/cooked-swift.git
cd cooked-swift
```

### 2. Configure secrets

Create `Secrets.xcconfig` from the template:

```bash
cp Configuration/Secrets.xcconfig.template Configuration/Secrets.xcconfig
```

Edit `Secrets.xcconfig` with your credentials:
```
SUPABASE_URL = your-project-id.supabase.co
SUPABASE_ANON_KEY = your-anon-key
BACKEND_URL = http://localhost:3000
REVENUECAT_API_KEY = appl_your_api_key
```

### 3. Open in Xcode

```bash
open Cooked.xcodeproj
```

Xcode will automatically resolve Swift Package Manager dependencies.

### 4. Run

Select a simulator (iPhone 15 recommended) and press `⌘R`.

## Project Structure

```
Cooked/
├── App/                    # App entry point, AppTab enum
├── Features/               # Feature modules
│   ├── Recipes/            # Recipe library, import, detail
│   │   └── Import/         # ImportRecipeSheet, RecipePreviewSheet
│   ├── Menu/               # Menu planning and cooking
│   ├── GroceryList/        # Shopping list generation
│   └── Subscription/       # Paywall and subscription state
├── Models/                 # Codable structs matching Supabase schema
├── Services/               # Supabase, RecipeService wrappers
├── Shared/
│   └── Components/         # Reusable UI (LoadingView, AsyncImageView)
└── Configuration/          # Config.xcconfig, Secrets.xcconfig
```

## Architecture

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

### Navigation

```
┌─────────┐     ┌─────────────┐     ┌─────────┐
│ RECIPES │     │    MENU     │     │  LIST   │
│   📖    │     │     🍳      │     │    ✓    │
└─────────┘     └─────────────┘     └─────────┘
 secondary          PRIMARY          secondary
```

Menu is the center tab and always opens first, reflecting the menu-first philosophy.

## Development

### Building

```bash
# Command line build
xcodebuild -scheme Cooked -destination 'platform=iOS Simulator,name=iPhone 16'

# Or use XcodeBuildMCP (if configured)
mcp__xcodebuildmcp__build_sim
```

### Testing

```bash
# Run all tests
xcodebuild test -scheme Cooked -destination 'platform=iOS Simulator,name=iPhone 16'

# Or use XcodeBuildMCP
mcp__xcodebuildmcp__test_sim
```

### Code Style

- Use Swift 6 strict concurrency
- Prefer `@Observable` over `ObservableObject`
- Use `async/await` for all async operations
- Use `guard` for early exits
- Prefer value types (structs) over reference types
- No force unwrapping without justification

## Freemium Limits

| Feature | Free | Pro ($4.99/mo) |
|---------|------|----------------|
| Recipes | 15 | Unlimited |
| Video imports/month | 5 | Unlimited |
| Menu history | 3 | Unlimited |

## Backend

This app uses Supabase for authentication and data storage. The recipe extraction API (for importing from URLs and videos) runs on a separate Nitro backend.

### Database Schema

The database is shared with the Expo/React Native version. Key tables:
- `users` - User profiles with subscription status
- `recipes` - User's saved recipes
- `menus` - Menu planning state
- `menu_recipes` - Junction table linking menus to recipes
- `grocery_lists` - Generated shopping lists

## Documentation

- [PRD.md](./PRD.md) - Product Requirements Document
- [ROADMAP.md](./ROADMAP.md) - Development Roadmap
- [CLAUDE.md](./CLAUDE.md) - AI Assistant Guidelines

## Contributing

1. Read [CLAUDE.md](./CLAUDE.md) for coding standards
2. Create a feature branch from `main`
3. Follow the existing code patterns
4. Ensure all tests pass
5. Submit a pull request

## License

MIT
