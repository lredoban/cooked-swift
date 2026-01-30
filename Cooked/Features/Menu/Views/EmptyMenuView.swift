import SwiftUI

struct EmptyMenuView: View {
    @Environment(MenuState.self) private var menuState
    @Environment(SubscriptionState.self) private var subscriptionState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundStyle(Color.curatedTerracotta)
                .accessibilityHidden(true)

            Text("What do you want to cook?")
                .font(.curatedTitle2)
                .foregroundStyle(Color.curatedCharcoal)
                .accessibilityAddTraits(.isHeader)

            Text("Build your menu for the week")
                .font(.curatedSubheadline)
                .foregroundStyle(Color.curatedWarmGrey)

            Button {
                Task {
                    await menuState.createMenu()
                    menuState.openRecipePicker()
                }
            } label: {
                Label("Add Recipes", systemImage: "plus")
            }
            .curatedButton()
            .padding(.top, 8)
            .accessibilityLabel("Add recipes to menu")
            .accessibilityHint("Opens recipe picker to select recipes for your weekly menu")

            Spacer()

            Button("View past menus") {
                menuState.openHistory(historyLimit: subscriptionState.menuHistoryLimit())
            }
            .font(.curatedSubheadline)
            .foregroundStyle(Color.curatedWarmGrey)
            .padding(.bottom, 20)
            .accessibilityLabel("View past menus")
            .accessibilityHint("Shows your previously cooked menus")
        }
    }
}

#Preview {
    EmptyMenuView()
        .environment(MenuState())
        .environment(SubscriptionState())
        .curatedBackground()
}
