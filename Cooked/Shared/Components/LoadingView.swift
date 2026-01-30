import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.dopamineAcid)
            Text(message)
                .font(.dopamineCaption)
                .foregroundStyle(Color.dopamineSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dopamineBlack)
    }
}

#Preview {
    LoadingView(message: "Loading recipes...")
}
