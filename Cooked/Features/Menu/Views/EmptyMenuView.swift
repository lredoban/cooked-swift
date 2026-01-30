import SwiftUI

struct EmptyMenuView: View {
    @Environment(MenuState.self) private var menuState
    @Environment(SubscriptionState.self) private var subscriptionState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundStyle(Color.dopaminePink)
                .dopamineGlow(color: .dopaminePink)
                .accessibilityHidden(true)

            Text("What do you want to cook?")
                .font(.dopamineTitle2)
                .foregroundStyle(.white)
                .accessibilityAddTraits(.isHeader)

            Text("Build your menu for the week")
                .font(.dopamineBody())
                .foregroundStyle(Color.dopamineSecondary)

            Button {
                Task {
                    await menuState.createMenu()
                    menuState.openRecipePicker()
                }
            } label: {
                Label("Add Recipes", systemImage: "plus")
            }
            .buttonStyle(DopaminePrimaryButtonStyle())
            .padding(.horizontal, 40)
            .accessibilityLabel("Add recipes to menu")
            .accessibilityHint("Opens recipe picker to select recipes for your weekly menu")

            Spacer()

            Button("View past menus") {
                menuState.openHistory(historyLimit: subscriptionState.menuHistoryLimit())
            }
            .font(.dopamineCaption)
            .foregroundStyle(Color.dopamineSecondary)
            .padding(.bottom, 20)
            .accessibilityLabel("View past menus")
            .accessibilityHint("Shows your previously cooked menus")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dopamineBlack)
    }
}

#Preview {
    EmptyMenuView()
        .environment(MenuState())
        .environment(SubscriptionState())
}
