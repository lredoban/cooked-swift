import SwiftUI

struct EmptyGroceryListView: View {
    let onGoToMenu: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Poster-style layout
            VStack(alignment: .leading, spacing: 32) {
                // Large checklist icon
                Image(systemName: "checklist")
                    .font(.system(size: 80, weight: .ultraLight))
                    .foregroundStyle(BoldSwiss.black)
                    .accessibilityHidden(true)

                // Headline
                VStack(alignment: .leading, spacing: 8) {
                    Text("NO GROCERY")
                        .font(.swissDisplay(36))
                        .foregroundStyle(BoldSwiss.black)

                    Text("LIST YET")
                        .font(.swissDisplay(36))
                        .foregroundStyle(BoldSwiss.black)
                }

                // Subtext
                Text("Generate a list from your menu to start shopping")
                    .font(.swissMono(14))
                    .foregroundStyle(BoldSwiss.black.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Spacer()

            // CTA button
            Button(action: onGoToMenu) {
                HStack(spacing: 12) {
                    Image(systemName: "menucard")
                        .font(.system(size: 14, weight: .bold))
                    Text("GO TO MENU")
                }
                .swissPrimaryButton()
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(BoldSwiss.white)
    }
}

#Preview {
    EmptyGroceryListView(onGoToMenu: {})
}
