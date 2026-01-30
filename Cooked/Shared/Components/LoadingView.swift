import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            CuratedSpinner(size: 40)
            Text(message)
                .font(.curatedSubheadline)
                .foregroundStyle(Color.curatedWarmGrey)
        }
    }
}

#Preview {
    LoadingView(message: "Loading recipes...")
        .curatedBackground()
}
