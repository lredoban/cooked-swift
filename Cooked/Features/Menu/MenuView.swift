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
            .navigationTitle("Menu")
            .sheet(isPresented: $state.isShowingRecipePicker) {
                RecipePickerSheet()
            }
        }
    }

    private func errorView(message: String) -> some View {
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
                .padding(.horizontal)

            Button("Try Again") {
                Task {
                    await menuState.loadCurrentMenu()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            Spacer()
        }
    }
}

#Preview {
    MenuView()
        .environment(MenuState())
        .environment(RecipeState())
}
