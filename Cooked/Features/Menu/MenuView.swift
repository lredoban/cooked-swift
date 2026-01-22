import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "fork.knife")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)

                Text("What do you want to cook?")
                    .font(.title2)
                    .fontWeight(.semibold)

                Button(action: {
                    // TODO: Navigate to add recipes
                }) {
                    Label("Add Recipes", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)

                Spacer()

                Button("View past menus") {
                    // TODO: Navigate to menu history
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
            }
            .navigationTitle("Menu")
        }
    }
}

#Preview {
    MenuView()
}
