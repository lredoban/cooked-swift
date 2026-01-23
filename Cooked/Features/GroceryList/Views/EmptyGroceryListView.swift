import SwiftUI

struct EmptyGroceryListView: View {
    let onGoToMenu: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Grocery List")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Generate a list from your menu to start shopping")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: onGoToMenu) {
                Label("Go to Menu", systemImage: "menucard")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.top, 8)

            Spacer()
        }
    }
}

#Preview {
    EmptyGroceryListView(onGoToMenu: {})
}
