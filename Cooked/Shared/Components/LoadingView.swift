import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.vintageTangerine)
            Text(message)
                .font(.vintageBody)
                .foregroundStyle(Color.vintageMutedCocoa)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vintageCream)
    }
}

#Preview {
    LoadingView(message: "Loading recipes...")
}
