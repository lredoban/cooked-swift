import SwiftUI

struct EmptyMenuView: View {
    @Environment(MenuState.self) private var menuState
    @Environment(SubscriptionState.self) private var subscriptionState

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Poster-style layout
            VStack(alignment: .leading, spacing: 32) {
                // Large graphic icon - fork/knife with thick black lines
                Image(systemName: "fork.knife")
                    .font(.system(size: 100, weight: .ultraLight))
                    .foregroundStyle(BoldSwiss.black)
                    .accessibilityHidden(true)

                // Headline - MASSIVE font, flush left
                VStack(alignment: .leading, spacing: 8) {
                    Text("WHAT DO YOU")
                        .font(.swissDisplay(42))
                        .foregroundStyle(BoldSwiss.black)

                    Text("WANT TO COOK?")
                        .font(.swissDisplay(42))
                        .foregroundStyle(BoldSwiss.black)
                }
                .accessibilityAddTraits(.isHeader)

                // Subtext - small, monospaced
                Text("Build your menu for the week")
                    .font(.swissMono(14))
                    .foregroundStyle(BoldSwiss.black.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Spacer()

            // Bottom section
            VStack(spacing: 16) {
                // CTA button - full-width, black background, white text
                Button {
                    Task {
                        await menuState.createMenu()
                        menuState.openRecipePicker()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                        Text("ADD RECIPES")
                    }
                    .swissPrimaryButton()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .accessibilityLabel("Add recipes to menu")
                .accessibilityHint("Opens recipe picker to select recipes for your weekly menu")

                // History link
                Button("VIEW PAST MENUS") {
                    menuState.openHistory(historyLimit: subscriptionState.menuHistoryLimit())
                }
                .font(.swissCaption(12))
                .fontWeight(.medium)
                .tracking(1)
                .foregroundStyle(BoldSwiss.black.opacity(0.5))
                .padding(.bottom, 24)
                .accessibilityLabel("View past menus")
                .accessibilityHint("Shows your previously cooked menus")
            }
        }
        .background(BoldSwiss.white)
    }
}

#Preview {
    EmptyMenuView()
        .environment(MenuState())
        .environment(SubscriptionState())
}
