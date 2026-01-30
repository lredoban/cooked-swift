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
            .background(Color.vintageCream)
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
                .foregroundStyle(Color.vintageTangerine)

            Text("SOMETHING WENT WRONG")
                .font(.vintageHeadline)
                .foregroundColor(.vintageCoffee)

            Text(message)
                .font(.vintageBody)
                .foregroundStyle(Color.vintageMutedCocoa)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Try Again") {
                Task {
                    await menuState.loadCurrentMenu()
                }
            }
            .buttonStyle(.vintagePill)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vintageCream)
    }
}

#Preview {
    MenuView()
        .environment(MenuState())
        .environment(RecipeState())
        .environment(SubscriptionState())
}
