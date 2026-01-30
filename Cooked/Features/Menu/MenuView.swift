import SwiftUI

struct MenuView: View {
    @Environment(MenuState.self) private var menuState
    @Environment(RecipeState.self) private var recipeState

    var body: some View {
        @Bindable var state = menuState

        NavigationStack {
            Group {
                switch menuState.viewState {
                case .loading:
                    LoadingView(message: "Loading menu...")

                case .empty:
                    EmptyMenuView()

                case .planning(let menu):
                    PlanningMenuView(menu: menu)

                case .toCook(let menu):
                    ToCookMenuView(menu: menu)

                case .error(let message):
                    errorView(message: message)
                }
            }
            .curatedBackground()
            .navigationTitle("Menu")
            .sheet(isPresented: $state.isShowingRecipePicker) {
                RecipePickerSheet()
            }
            .sheet(isPresented: $state.isShowingHistory) {
                MenuHistoryView()
            }
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(Color.curatedTerracotta)

            Text("Something went wrong")
                .font(.curatedTitle2)
                .foregroundStyle(Color.curatedCharcoal)

            Text(message)
                .font(.curatedSubheadline)
                .foregroundStyle(Color.curatedWarmGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Try Again") {
                Task {
                    await menuState.loadCurrentMenu()
                }
            }
            .curatedButton()

            Spacer()
        }
    }
}

#Preview {
    MenuView()
        .environment(MenuState())
        .environment(RecipeState())
        .environment(SubscriptionState())
}
