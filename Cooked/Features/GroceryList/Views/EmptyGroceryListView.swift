import SwiftUI

struct EmptyGroceryListView: View {
    let onGoToMenu: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Playful icon with circular background
            ZStack {
                Circle()
                    .fill(Color.cobalt.opacity(0.1))
                    .frame(width: 140, height: 140)

                Image(systemName: "checklist")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.cobalt)
            }

            VStack(spacing: 12) {
                Text("No Grocery List")
                    .font(.electricDisplay)
                    .foregroundColor(.ink)

                Text("Generate a list from your menu to start shopping")
                    .font(.electricBody)
                    .foregroundColor(.graphite)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // Floating CTA button
            Button(action: onGoToMenu) {
                HStack(spacing: 8) {
                    Image(systemName: "menucard")
                    Text("Go to Menu")
                }
                .electricPrimaryButton()
            }
            .floatingCard()
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .warmConcreteBackground()
    }
}

#Preview {
    EmptyGroceryListView(onGoToMenu: {})
}
