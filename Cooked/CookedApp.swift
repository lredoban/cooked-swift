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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(supabaseService)
                .environment(recipeState)
                .task {
                    await initializeApp()
                }
        }
    }

    private func initializeApp() async {
        let connected = await supabaseService.testConnection()
        if connected {
            await recipeState.loadRecipes()
        } else {
            print("[Cooked] Supabase connection failed")
        }
    }
}
