import SwiftUI

struct EmptyMenuView: View {
    @Environment(MenuState.self) private var menuState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("What do you want to cook?")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Build your menu for the week")
                .foregroundStyle(.secondary)

            Button {
                Task {
                    await menuState.createMenu()
                    menuState.openRecipePicker()
                }
            } label: {
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
                menuState.openHistory()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    EmptyMenuView()
        .environment(MenuState())
}
