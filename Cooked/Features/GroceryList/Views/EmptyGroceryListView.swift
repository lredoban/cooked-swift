import SwiftUI

struct EmptyGroceryListView: View {
    let onGoToMenu: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundStyle(Color.curatedWarmGrey)

            Text("No Grocery List")
                .font(.curatedTitle2)
                .foregroundStyle(Color.curatedCharcoal)

            Text("Generate a list from your menu to start shopping")
                .font(.curatedSubheadline)
                .foregroundStyle(Color.curatedWarmGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: onGoToMenu) {
                Label("Go to Menu", systemImage: "menucard")
            }
            .curatedButton()
            .padding(.top, 8)

            Spacer()
        }
    }
}

#Preview {
    EmptyGroceryListView(onGoToMenu: {})
        .curatedBackground()
}
