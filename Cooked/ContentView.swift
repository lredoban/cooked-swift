//
//  ContentView.swift
//  Cooked
//
//  Created by Lova on 22/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .menu  // Menu is default

    var body: some View {
        TabView(selection: $selectedTab) {
            RecipesView()
                .tabItem {
                    Label(AppTab.recipes.title, systemImage: AppTab.recipes.icon)
                }
                .tag(AppTab.recipes)

            MenuView()
                .tabItem {
                    Label(AppTab.menu.title, systemImage: AppTab.menu.icon)
                }
                .tag(AppTab.menu)

            GroceryListView(selectedTab: $selectedTab)
                .tabItem {
                    Label(AppTab.list.title, systemImage: AppTab.list.icon)
                }
                .tag(AppTab.list)
        }
    }
}

#Preview {
    ContentView()
}
