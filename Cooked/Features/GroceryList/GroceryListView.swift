import SwiftUI

struct GroceryListView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                Image(systemName: "checklist")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                Text("No list yet")
                    .font(.title2)

                Text("Generate a grocery list from your menu")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Go to Menu") {
                    // TODO: Switch to menu tab
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)

                Spacer()
            }
            .navigationTitle("Grocery List")
        }
    }
}

#Preview {
    GroceryListView()
}
