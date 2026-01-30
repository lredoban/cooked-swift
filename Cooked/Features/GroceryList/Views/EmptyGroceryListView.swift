import SwiftUI

struct EmptyGroceryListView: View {
    let onGoToMenu: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundStyle(Color.vintageMutedCocoa)

            Text("NO GROCERY LIST")
                .font(.vintageHeadline)
                .foregroundColor(.vintageCoffee)

            Text("Generate a list from your menu to start shopping")
                .font(.vintageBody)
                .foregroundStyle(Color.vintageMutedCocoa)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: onGoToMenu) {
                Label("Go to Menu", systemImage: "menucard")
            }
            .buttonStyle(.vintagePill)
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vintageCream)
        .tabBarPadding()
    }
}

#Preview {
    EmptyGroceryListView(onGoToMenu: {})
}
