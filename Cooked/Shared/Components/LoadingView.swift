import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 20) {
            GlassLoadingSpinner(size: 48, lineWidth: 4)

            Text(message)
                .font(.glassBody())
                .foregroundColor(.glassTextSecondary)
        }
    }
}

#Preview {
    LoadingView(message: "Loading recipes...")
        .spatialBackground()
}
