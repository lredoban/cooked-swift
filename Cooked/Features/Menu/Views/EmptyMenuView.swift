import SwiftUI

struct EmptyMenuView: View {
    @Environment(MenuState.self) private var menuState
    @Environment(SubscriptionState.self) private var subscriptionState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Glowing icon
            ZStack {
                Circle()
                    .fill(LinearGradient.holographicOrange.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .blur(radius: 30)

                Image(systemName: "fork.knife")
                    .font(.system(size: 60))
                    .foregroundStyle(LinearGradient.holographicOrange)
            }
            .accessibilityHidden(true)

            Text("What do you want to cook?")
                .font(.glassTitle())
                .foregroundColor(.glassTextPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Build your menu for the week")
                .font(.glassBody())
                .foregroundColor(.glassTextSecondary)

            Button {
                Task {
                    await menuState.createMenu()
                    menuState.openRecipePicker()
                }
            } label: {
                Label("Add Recipes", systemImage: "plus")
                    .font(.glassHeadline())
                    .frame(maxWidth: 280)
                    .glassButton()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add recipes to menu")
            .accessibilityHint("Opens recipe picker to select recipes for your weekly menu")

            Spacer()

            Button("View past menus") {
                menuState.openHistory(historyLimit: subscriptionState.menuHistoryLimit())
            }
            .font(.glassCaption(14))
            .foregroundColor(.glassTextTertiary)
            .padding(.bottom, 20)
            .accessibilityLabel("View past menus")
            .accessibilityHint("Shows your previously cooked menus")
        }
    }
}

#Preview {
    EmptyMenuView()
        .spatialBackground()
        .environment(MenuState())
        .environment(SubscriptionState())
}
