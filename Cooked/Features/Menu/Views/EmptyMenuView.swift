import SwiftUI

struct EmptyMenuView: View {
    @Environment(MenuState.self) private var menuState
    @Environment(SubscriptionState.self) private var subscriptionState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Playful icon with circular background
            ZStack {
                Circle()
                    .fill(Color.hyperOrange.opacity(0.1))
                    .frame(width: 140, height: 140)

                Image(systemName: "fork.knife")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.hyperOrange)
            }
            .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text("What do you want to cook?")
                    .font(.electricDisplay)
                    .foregroundColor(.ink)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("Build your menu for the week")
                    .font(.electricBody)
                    .foregroundColor(.graphite)
            }

            Spacer()

            // Floating CTA button
            VStack(spacing: 16) {
                Button {
                    Task {
                        await menuState.createMenu()
                        menuState.openRecipePicker()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Add Recipes")
                    }
                    .electricPrimaryButton()
                }
                .floatingCard()
                .padding(.horizontal, 32)
                .accessibilityLabel("Add recipes to menu")
                .accessibilityHint("Opens recipe picker to select recipes for your weekly menu")

                Button("View past menus") {
                    menuState.openHistory(historyLimit: subscriptionState.menuHistoryLimit())
                }
                .font(.electricCaption)
                .fontWeight(.semibold)
                .foregroundColor(.graphite)
                .accessibilityLabel("View past menus")
                .accessibilityHint("Shows your previously cooked menus")
            }
            .padding(.bottom, 32)
        }
        .warmConcreteBackground()
    }
}

#Preview {
    EmptyMenuView()
        .environment(MenuState())
        .environment(SubscriptionState())
}
