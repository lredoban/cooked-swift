import SwiftUI

struct GroceryListView: View {
    @Environment(GroceryListState.self) private var groceryState
    @Environment(MenuState.self) private var menuState
    @Binding var selectedTab: AppTab

    var body: some View {
        NavigationStack {
            Group {
                switch groceryState.viewState {
                case .loading:
                    LoadingView(message: "Loading grocery list...")

                case .empty:
                    EmptyGroceryListView {
                        selectedTab = .menu
                    }

                case .active(let list):
                    ActiveGroceryListView(list: list)

                case .error(let message):
                    ErrorStateView(message: message) {
                        if let menuId = menuState.currentMenu?.id {
                            Task {
                                await groceryState.loadGroceryList(menuId: menuId)
                            }
                        }
                    }
                }
            }
            .spatialBackground()
            .navigationTitle("Grocery List")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.glassBackground.opacity(0.9), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .task {
            if let menuId = menuState.currentMenu?.id {
                await groceryState.loadGroceryList(menuId: menuId)

                // Subscribe to realtime changes if we have an active list
                if let list = groceryState.activeList {
                    await groceryState.subscribeToChanges(listId: list.id)
                }
            } else {
                groceryState.viewState = .empty
            }
        }
        .onDisappear {
            Task {
                await groceryState.unsubscribeFromChanges()
            }
        }
    }
}

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Glowing warning icon
            ZStack {
                Circle()
                    .fill(LinearGradient.holographicOrange.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundStyle(LinearGradient.holographicOrange)
            }

            Text("Something went wrong")
                .font(.glassTitle())
                .foregroundColor(.glassTextPrimary)

            Text(message)
                .font(.glassBody())
                .foregroundColor(.glassTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("Try Again", action: onRetry)
                .font(.glassHeadline())
                .glassButton()
                .buttonStyle(.plain)
                .padding(.top, 8)

            Spacer()
        }
    }
}

#Preview {
    GroceryListView(selectedTab: .constant(.list))
        .environment(GroceryListState())
        .environment(MenuState())
}
