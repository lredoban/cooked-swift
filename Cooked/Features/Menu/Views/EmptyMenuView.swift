import SwiftUI

struct EmptyMenuView: View {
    @Environment(MenuState.self) private var menuState
    @Environment(SubscriptionState.self) private var subscriptionState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundStyle(Color.vintageTangerine)
                .accessibilityHidden(true)

            Text("WHAT DO YOU WANT TO COOK?")
                .font(.vintageHeadline)
                .foregroundColor(.vintageCoffee)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text("Build your menu for the week")
                .font(.vintageBody)
                .foregroundStyle(Color.vintageMutedCocoa)

            Button {
                Task {
                    await menuState.createMenu()
                    menuState.openRecipePicker()
                }
            } label: {
                Label("Add Recipes", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.vintage)
            .padding(.horizontal, 40)
            .accessibilityLabel("Add recipes to menu")
            .accessibilityHint("Opens recipe picker to select recipes for your weekly menu")

            Spacer()

            Button("View past menus") {
                menuState.openHistory(historyLimit: subscriptionState.menuHistoryLimit())
            }
            .font(.vintageCaption)
            .foregroundStyle(Color.vintageMutedCocoa)
            .padding(.bottom, 20)
            .accessibilityLabel("View past menus")
            .accessibilityHint("Shows your previously cooked menus")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vintageCream)
    }
}

#Preview {
    EmptyMenuView()
        .environment(MenuState())
        .environment(SubscriptionState())
}
