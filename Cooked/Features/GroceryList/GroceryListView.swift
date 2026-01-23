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
                    .onAppear {
                        // Reload when tab becomes visible
                        if let menuId = menuState.currentMenu?.id {
                            Task {
                                await groceryState.loadGroceryList(menuId: menuId)
                            }
                        }
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
            .navigationTitle("Grocery List")
        }
        .task {
            if let menuId = menuState.currentMenu?.id {
                await groceryState.loadGroceryList(menuId: menuId)
            } else {
                groceryState.viewState = .empty
            }
        }
    }
}

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
                .tint(.orange)
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
