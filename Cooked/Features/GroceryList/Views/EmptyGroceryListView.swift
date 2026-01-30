import SwiftUI

struct EmptyGroceryListView: View {
    let onGoToMenu: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundStyle(Color.dopaminePink)
                .dopamineGlow(color: .dopaminePink)

            Text("No Grocery List")
                .font(.dopamineTitle2)
                .foregroundStyle(.white)

            Text("Generate a list from your menu to start shopping")
                .font(.dopamineBody())
                .foregroundStyle(Color.dopamineSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: onGoToMenu) {
                Label("Go to Menu", systemImage: "menucard")
            }
            .buttonStyle(DopaminePrimaryButtonStyle())
            .padding(.horizontal, 40)
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dopamineBlack)
    }
}

#Preview {
    EmptyGroceryListView(onGoToMenu: {})
}
