import SwiftUI

struct EmptyGroceryListView: View {
    let onGoToMenu: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Glowing icon
            ZStack {
                Circle()
                    .fill(Color.neonGreen.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .blur(radius: 30)

                Image(systemName: "checklist")
                    .font(.system(size: 60))
                    .foregroundColor(.neonGreen)
            }

            Text("No Grocery List")
                .font(.glassTitle())
                .foregroundColor(.glassTextPrimary)

            Text("Generate a list from your menu to start shopping")
                .font(.glassBody())
                .foregroundColor(.glassTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: onGoToMenu) {
                Label("Go to Menu", systemImage: "menucard")
                    .font(.glassHeadline())
                    .glassButton()
            }
            .buttonStyle(.plain)
            .padding(.top, 8)

            Spacer()
        }
    }
}

#Preview {
    EmptyGroceryListView(onGoToMenu: {})
        .spatialBackground()
}
