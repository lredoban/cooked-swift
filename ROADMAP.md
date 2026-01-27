# Development Roadmap (Swift/SwiftUI)

**Project:** Cooked - Recipe Menu App (iOS Native) **Based on:** PRD v1.0
(January 2026) **Tech Stack:** Swift 5.9 + SwiftUI + Supabase + RevenueCat

---

## Overview

This roadmap adapts the original React Native/Expo roadmap for native iOS
development with Swift and SwiftUI. The app shares the same Supabase database as
the Expo version, so database setup is already complete.

### Key Differences from Expo Version

| Aspect           | Expo/React Native      | Swift/SwiftUI           |
| ---------------- | ---------------------- | ----------------------- |
| State Management | React Context          | `@Observable` (iOS 17+) |
| Navigation       | Expo Router            | NavigationStack         |
| Styling          | NativeWind/Tailwind    | Native SwiftUI          |
| Package Manager  | npm                    | Swift Package Manager   |
| Database         | supabase-js            | supabase-swift          |
| Purchases        | react-native-purchases | purchases-ios           |

---

## Phase 0: Foundation & Setup

**Goal:** Project structure and Supabase connection (database already exists)

### Scope

- [x] Create Xcode project with SwiftUI
- [x] Add supabase-swift via SPM
- [x] Set up project folder structure (App/, Models/, Services/, Features/,
      Configuration/)
- [x] Create `@Observable` models matching Supabase schema
- [x] Configure Supabase Swift client (SupabaseService.swift)
- [x] Set up 3-tab navigation (Recipes, Menu, List)
- [x] Create placeholder views
- [x] Configure Xcode build settings to use Config.xcconfig
- [x] Copy Secrets.xcconfig.template to Secrets.xcconfig with real credentials
- [x] Test Supabase connection

### Deliverables

- App opens with 3-tab navigation
- Supabase client configured and connecting
- Models match existing database schema

### Review Checkpoint

- App builds and runs on simulator
- Can authenticate with Supabase
- Navigation structure matches PRD

---

## Phase 1: Recipe Import & Core CRUD

**Goal:** Import recipes from URLs and save them to the library

### Scope

- **Recipe Import (Primary Focus)**
  - [x] URL input sheet with paste support
  - [x] Call backend Extract API
  - [x] Processing view with ProgressView
  - [x] Preview/edit imported data before saving

- **Recipe CRUD (Minimal)**
  - [x] Save recipe to Supabase
  - [x] View recipe detail
  - [x] Delete recipe
  - (Manual entry deferred - import is primary flow)

- **Recipe Library**
  - [x] Display user's recipes in LazyVGrid
  - [x] Recipe count display
  - [x] Loading states with ProgressView

### Recipe Extract API

**Endpoint:** `POST /api/recipes/extract`

**Request:**

```json
{
  "url": "https://example.com/recipe-page",
  "sourceType": "url" // optional: "url" | "video"
}
```

**Response (Success):**

```json
{
  "success": true,
  "recipe": {
    "title": "Recipe title",
    "source_type": "url",
    "source_url": "https://example.com/recipe-page",
    "source_name": "Author or site name",
    "ingredients": [
      { "text": "chicken breast", "quantity": "2 lbs" },
      { "text": "olive oil", "quantity": "2 tbsp" }
    ],
    "steps": ["Step 1 instructions", "Step 2 instructions"],
    "tags": ["dinner", "chicken", "quick"],
    "image_url": "https://example.com/image.jpg"
  }
}
```

**Error Response:**

```json
{
  "statusCode": 400,
  "message": "URL is required"
}
```

### Swift Implementation

```swift
// Services/RecipeImportService.swift
struct ExtractRequest: Encodable {
    let url: String
    let sourceType: String?
}

struct ExtractResponse: Decodable {
    let success: Bool
    let recipe: ExtractedRecipe
}

struct ExtractedRecipe: Decodable {
    let title: String
    let sourceType: String
    let sourceUrl: String
    let sourceName: String?
    let ingredients: [ExtractedIngredient]
    let steps: [String]
    let tags: [String]
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case title
        case sourceType = "source_type"
        case sourceUrl = "source_url"
        case sourceName = "source_name"
        case ingredients, steps, tags
        case imageUrl = "image_url"
    }
}

struct ExtractedIngredient: Decodable {
    let text: String
    let quantity: String?
}

func extractRecipe(from url: String) async throws -> ExtractedRecipe {
    let endpoint = URL(string: "\(AppConfig.backendURL)/api/recipes/extract")!
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(ExtractRequest(url: url, sourceType: nil))

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw RecipeImportError.extractionFailed
    }

    let result = try JSONDecoder().decode(ExtractResponse.self, from: data)
    return result.recipe
}
```

### SwiftUI Patterns

```swift
// Recipe grid
LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
    ForEach(recipes) { recipe in
        RecipeCard(recipe: recipe)
    }
}

// Import sheet
struct ImportRecipeSheet: View {
    @State private var url = ""
    @State private var isLoading = false

    var body: some View {
        VStack {
            TextField("Paste recipe URL", text: $url)
            Button("Import") { /* call extractRecipe */ }
        }
    }
}
```

### Deliverables

- [x] Import from TikTok, Instagram, YouTube, URLs
- [x] Preview and edit before saving
- [x] Recipe saved to Supabase
- [x] Recipe library displays all recipes
- [x] Recipe detail view working

---

## Phase 2: Menu System (Core Product)

**Goal:** Implement the menu state machine

### Scope

- **MenuState Observable**
  - Track current menu state (empty/planning/to_cook)
  - Handle state transitions

- **Menu Views**
  - EmptyMenuView - "What do you want to cook?"
  - PlanningMenuView - Recipe grid with add/remove
  - ToCookMenuView - Checklist with progress

- **Add to Menu Flow**
  - Multi-select recipe picker
  - Visual selection indicators
  - Confirmation sheet

### SwiftUI Patterns

```swift
@Observable
class MenuState {
    var currentMenu: MenuWithRecipes?
    var viewState: ViewState = .loading

    func addRecipe(_ recipe: Recipe) async { }
    func markCooked(_ item: RecipeInMenu) async { }
}
```

### Deliverables

- Full menu state machine working
- Add/remove recipes from menu
- Mark recipes as cooked
- State persists in Supabase

---

## Phase 3: Grocery List Generation

**Goal:** Complete the core user flow

### Scope

- **Ingredient Consolidation**
  - Merge ingredients from menu recipes
  - Group by category

- **List Generation Sheet**
  - Staple check UI
  - "Create List" action

- **Active List View**
  - Grouped by category
  - Check/uncheck items
  - Share as text

### SwiftUI Patterns

```swift
// Grouped list
ForEach(groceryList.sortedCategories, id: \.self) { category in
    Section(header: CategoryHeader(category)) {
        ForEach(groceryList.itemsByCategory[category] ?? []) { item in
            GroceryItemRow(item: item)
        }
    }
}
```

### Deliverables

- Grocery list generation from menu
- Staple check flow
- Shareable list format

---

## Phase 4: Search & Filtering

**Goal:** Make library browsable and searchable

### Scope

- **Search**
  - `.searchable()` modifier
  - Real-time filtering

- **Tag Filtering**
  - Horizontal scroll of tag chips
  - Filter by selected tag

- **Sort Options**
  - Menu picker (Recent, A-Z, Most Cooked)

### SwiftUI Patterns

```swift
.searchable(text: $searchText, prompt: "Search recipes...")

ScrollView(.horizontal) {
    HStack {
        ForEach(tags, id: \.self) { tag in
            TagChip(tag: tag, isSelected: selectedTag == tag)
        }
    }
}
```

### Deliverables

- Search by title
- Filter by tags
- Sort options working

---

## Phase 5: Menu History & Reuse

**Goal:** View and reuse past menus

### Scope

- **History View**
  - List of archived menus
  - Date, recipe count, completion status

- **Reuse Flow**
  - "Cook This Again" button
  - Copy recipes to new menu

- **Free Tier Limit**
  - Show last 3 for free users

### Deliverables

- Menu history accessible
- Reuse functionality working
- Free tier limits enforced

---

## Phase 6: Monetization (RevenueCat) ✅

**Goal:** Implement freemium subscription

### Scope

- **RevenueCat Setup**
  - [x] Add RevenueCat SDK via SPM
  - [x] Configure in Xcode
  - [x] Set up products in RevenueCat dashboard (via MCP)
  - [x] Create "pro" entitlement
  - [x] Create monthly subscription product ($4.99)
  - [x] Create default offering and package

- **Anonymous Auth**
  - [x] Implement Supabase anonymous sign-in
  - [x] Pass user ID to RevenueCat for tracking
  - [x] Restore existing sessions

- **Entitlement Checks**
  - [x] Recipe limit (15 for free)
  - [x] Import limit (5/month for free) - configured
  - [x] History limit (3 for free)
  - [x] Centralized FreemiumLimits.swift config

- **Paywall UI**
  - [x] Native SwiftUI PaywallView
  - [x] Pro benefits display
  - [x] Purchase and restore buttons
  - [x] Limit reached prompts in ImportRecipeSheet
  - [x] Upgrade prompt in MenuHistoryView

### Deliverables

- [x] RevenueCat SDK integrated
- [x] Anonymous auth working
- [x] Limits enforced with upgrade prompts
- [x] Paywall UX clear
- [ ] Test purchases in TestFlight (requires App Store Connect)

---

## Phase 7: UX Polish

**Goal:** Improve user flows and fix friction points

### Scope

- **Flow Review**
  - Audit core flows (import → menu → grocery list)
  - Identify and fix friction points
  - Improve error states and feedback

- **Onboarding**
  - First-launch experience
  - Guide users through core value proposition
  - Explain menu-first concept

- **Empty States**
  - Meaningful empty state messaging
  - Clear calls-to-action

### Deliverables

- Smooth core user flows
- Onboarding implemented
- Clear error handling throughout

---

## Phase 8: Analytics (PostHog) [WON'T DO NOT USEFUL TO CONTEST]

**Goal:** Understand how users use the app

### Scope

- **SDK Integration**
  - Add PostHog SDK via SPM
  - Configure in app startup

- **Event Tracking**
  - Recipe import (success/failure, source type)
  - Menu creation and completion
  - Grocery list generation
  - Feature usage patterns

- **Analysis Setup**
  - Funnel analysis (import → menu → cook)
  - User session tracking
  - Retention metrics

### Deliverables

- PostHog integrated
- Key events tracked
- Dashboard configured

---

## Phase 9: UI Polish

**Goal:** Visual refinement and animations

### Scope

- **Loading States**
  - Loading skeletons for lists
  - Placeholder shimmer effects

- **Animations**
  - Smooth transitions with `.animation()`
  - Meaningful micro-interactions
  - State change animations

- **Visual Consistency**
  - Typography audit
  - Spacing consistency
  - Color usage review

### Deliverables

- Polished loading states
- Smooth animations
- Consistent visual design

---

## Phase 10: Security & Performance

**Goal:** Production hardening

### Scope

- **Security**
  - Supabase RLS policy audit
  - Verify all tables have appropriate policies
  - Test edge cases

- **Performance**
  - App launch < 2 seconds
  - Smooth scrolling with many recipes
  - Image caching optimization

- **SIMPLE Offline Support**
  - Cache recipes locally
  - Sync when online
  - Handle offline gracefully

### Deliverables

- RLS policies verified
- Performance targets met
- Offline support working

---

## Phase 11: App Store Preparation (Deferred)

**Goal:** Prepare for App Store submission

### Scope

- **App Assets**
  - App icon (all sizes)
  - Screenshots for all device sizes
  - App preview video (optional)

- **Store Listing**
  - App name and subtitle
  - Description and keywords
  - Privacy policy URL
  - Support URL

- **Submission**
  - TestFlight internal testing
  - TestFlight external beta
  - App Store submission

### Deliverables

- All assets ready
- Store listing complete
- App submitted

---

## Cloud Phase (Ongoing) ✅

**Goal:** Tasks that can be run by cloud agents asynchronously

These tasks don't require local simulator testing and can be worked on
independently:

### Scope

- **Documentation**
  - [x] Code documentation updates (docstrings for Models and Services)
  - [x] README improvements (comprehensive setup guide, architecture docs)

- **Testing**
  - [x] Unit test coverage improvements (Model tests, Service error tests)
  - [x] Test documentation

- **Accessibility**
  - [x] VoiceOver label audit (RecipeCard, MenuRecipeCard, GroceryItemRow, etc.)
  - [ ] Dynamic type support verification (requires device testing)

- **Code Quality**
  - [x] MARK comments added to organize files
  - [x] Code documentation cleanup

- **Website Content** (Markdown files for landing page)
  - [x] Hero section copy
  - [x] App features and benefits
  - [x] Pricing section content
  - [x] SEO metadata
  - [x] Privacy policy draft
  - [x] Terms of service draft

### Deliverables

- `web-content/landing-page.md` - Full landing page copy
- `web-content/privacy-policy.md` - Privacy policy draft
- `web-content/terms-of-service.md` - Terms of service draft
- `CookedTests/CookedTests.swift` - Unit tests for models
- `CookedTests/ServiceTests.swift` - Service and error tests

### Notes

These tasks can be picked up anytime and don't block other phases.

---

## Backend & Web (Ongoing)

**Goal:** Nuxt.js website + Python extraction API

### Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                 Cloudflare Pages (FREE)                      │
│                    Nuxt Website                              │
│       Landing • Privacy • Terms • Shareable Grocery Lists    │
│       Server routes: /api/recipes/import, /api/extract (dev) │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                        Supabase                              │
│                (shared with iOS app)                         │
└──────────────────────────────────────────────────────────────┘
```

### Scope

- **Project Setup** ✅
  - [x] Initialize Nuxt 3 project with Nuxt UI
  - [x] Configure pnpm workspace
  - [x] Set up CI workflow (GitHub Actions)
  - [x] Add code quality tools (oxlint, oxfmt)
  - [x] Add Claude Code skills for Nuxt, Vue, Nuxt UI, Motion, Nuxt SEO, VueUse

- **Recipe Extraction**
  - [x] yt-dlp extraction endpoints in Nuxt (`/api/extract`, `/api/recipes/import`, `/api/recipes/[id]/stream`)
  - [x] `/api/extract` and `/admin/extract` gated with `import.meta.dev` (dev-only)
  - [ ] Production extraction solution (TBD)

- **Website (Cloudflare Pages)**
  - [x] Landing page (hero, features, pricing)
  - ~~Blog for SEO content (Maybe Later)~~
  - [x] Legal pages (privacy policy, terms of service)
  - [ ] App Store / download links
  - [ ] Deploy to Cloudflare Pages

- **Shareable Grocery Lists**
  - Public URLs for grocery lists (no auth required)
  - Real-time sync (family can check items together)
  - QR code generation for easy sharing

### Tech Stack

| Component | Technology | Hosting |
|-----------|------------|---------|
| Website | Nuxt 3 + Nuxt UI | Cloudflare Pages (free) |
| Extraction | yt-dlp in Nuxt server routes | Dev-only for now |
| Database | PostgreSQL | Supabase |
| Code Quality | oxlint + oxfmt | - |

### Folder Structure

```
Cooked/
├── Cooked/              # iOS app
├── Cooked.xcodeproj
├── web/                 # Nuxt website → Cloudflare Pages
│   ├── nuxt.config.ts
│   ├── app/pages/
│   ├── server/api/      # Server routes (extraction dev-only)
│   └── ...
├── CLAUDE.md
├── ROADMAP.md
└── ...
```

---

## Backlog / Future

Items to implement later when ready:

- [ ] **Supabase RLS Policies** - Audit and enforce row-level security on all tables (recipes, menus, menu_recipes, grocery_lists, user_settings). RLS is enabled but policies need review.
- [ ] **Scalable Job Store** - Current in-memory job store (jobs.ts) won't work with horizontal scaling. SSE listeners are in-memory callbacks that can't be shared across instances. Options: Supabase Realtime (subscribe to recipe row changes, eliminates in-memory store entirely), or Redis pub/sub + Nitro `useStorage()`. Supabase Realtime is preferred since the extraction already writes to DB.
- [ ] **RevenueCat Paywall UI** - Use RevenueCat's native paywall (waiting for credentials)
- [ ] **Annual Plan** - Add yearly subscription option to RevenueCat
- [ ] **Code Quality Tooling** - Set up SwiftLint and SwiftFormat

---

## Appendix: Swift/SwiftUI Patterns

### Observable State

```swift
@Observable
class RecipeState {
    var recipes: [Recipe] = []
    var isLoading = false

    func load() async {
        isLoading = true
        recipes = try? await supabase.fetchRecipes()
        isLoading = false
    }
}
```

### Async/Await with Supabase

```swift
func fetchRecipes() async throws -> [Recipe] {
    try await client
        .from("recipes")
        .select()
        .eq("user_id", value: userId)
        .execute()
        .value
}
```

### Navigation

```swift
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

### Environment

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

struct SomeView: View {
    @Environment(AppState.self) private var appState
}
```

---

## Timeline Notes

No specific timelines included. Each phase should be completed thoroughly before
moving to the next. The shared Supabase backend means Phase 0 is significantly
faster than the Expo version.
