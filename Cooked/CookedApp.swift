//
//  CookedApp.swift
//  Cooked
//
//  Created by Lova on 22/01/2026.
//

import SwiftUI

@main
struct CookedApp: App {
    @State private var supabaseService = SupabaseService.shared
    @State private var recipeState = RecipeState()
    @State private var menuState = MenuState()
    @State private var groceryListState = GroceryListState()
    @State private var subscriptionState = SubscriptionState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(supabaseService)
                .environment(recipeState)
                .environment(menuState)
                .environment(groceryListState)
                .environment(subscriptionState)
                .task {
                    await initializeApp()
                }
        }
    }

    private func initializeApp() async {
        // 1. Initialize Supabase (anonymous auth)
        let connected = await supabaseService.initialize()

        guard connected, let userId = supabaseService.authUser?.id else {
            print("[Cooked] Failed to initialize Supabase")
            return
        }

        // 2. Configure RevenueCat with Supabase user ID
        await subscriptionState.configure(userId: userId.uuidString)

        // 3. Load app data
        await recipeState.loadRecipes()
        await menuState.loadCurrentMenu()
    }
}
