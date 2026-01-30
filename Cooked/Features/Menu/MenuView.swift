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
            .spatialBackground()
            .navigationTitle("Menu")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.glassBackground.opacity(0.9), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $state.isShowingRecipePicker) {
                RecipePickerSheet()
            }
            .sheet(isPresented: $state.isShowingHistory) {
                MenuHistoryView()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func errorView(message: String) -> some View {
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
                .padding(.horizontal)

            Button("Try Again") {
                Task {
                    await menuState.loadCurrentMenu()
                }
            }
            .font(.glassHeadline())
            .glassButton()
            .buttonStyle(.plain)

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
