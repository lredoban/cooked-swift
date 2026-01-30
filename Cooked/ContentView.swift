//
//  ContentView.swift
//  Cooked
//
//  Created by Lova on 22/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .menu  // Menu is default

    // Tab bar height for content padding
    private let tabBarHeight: CGFloat = 90

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .recipes:
                    RecipesView()
                case .menu:
                    MenuView()
                case .list:
                    GroceryListView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom floating tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .environment(\.customTabBarHeight, tabBarHeight)
    }
}

#Preview {
    ContentView()
        .environment(SupabaseService.shared)
        .environment(RecipeState())
        .environment(MenuState())
        .environment(GroceryListState())
        .environment(SubscriptionState())
}
