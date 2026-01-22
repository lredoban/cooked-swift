# Cooked - Recipe Menu App (iOS)

A native iOS app that helps people turn food inspiration into a real plan — and actually cook it.

Built with Swift and SwiftUI for iOS 17+.

## Features

- **Menu-First Approach**: Build a menu of recipes you'll actually cook this week
- **Recipe Import**: Import recipes from TikTok, Instagram, YouTube, and recipe blogs
- **Smart Grocery Lists**: Auto-generated, categorized shopping lists
- **Progress Tracking**: Mark recipes as cooked and track your cooking journey

## Tech Stack

- **UI**: SwiftUI with iOS 17's `@Observable`
- **Backend**: Supabase (PostgreSQL + Auth)
- **Payments**: RevenueCat
- **Architecture**: Feature-based with Services layer

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/cooked-swift.git
cd cooked-swift
```

### 2. Configure environment

Copy the example config and fill in your values:

```bash
cp Config.xcconfig.example Config.xcconfig
```

Edit `Config.xcconfig`:
```
SUPABASE_URL = your-project-id.supabase.co
SUPABASE_ANON_KEY = your-anon-key
BACKEND_URL = http://localhost:3000
REVENUECAT_API_KEY = appl_your_api_key
```

### 3. Open in Xcode

```bash
open Package.swift
```

Or open the folder in Xcode and let it resolve SPM dependencies.

### 4. Run

Select a simulator or device and press ⌘R.

## Project Structure

```
Cooked/
├── App/           # App entry point, global state
├── Features/      # Feature modules (Menu, Recipes, GroceryList)
├── Services/      # Supabase, Auth, RevenueCat wrappers
├── Models/        # Data models (Codable structs)
└── Shared/        # Reusable components
```

## Development

### Building

```bash
# Command line build
xcodebuild -scheme Cooked -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Testing

```bash
xcodebuild test -scheme Cooked -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Backend

This app shares its Supabase backend with the Expo/React Native version. The Nitro backend handles recipe extraction from videos and URLs.

See the main [cooked-app](../cooked-app) repository for backend setup.

## Related

- [cooked-app](../cooked-app) - Expo/React Native version
- [PRD.md](./PRD.md) - Product Requirements Document
- [ROADMAP.md](./ROADMAP.md) - Development Roadmap

## License

MIT
