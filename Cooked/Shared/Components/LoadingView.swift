import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            // Custom spinning loader with Electric Utility colors
            ZStack {
                // Background track
                Circle()
                    .stroke(Color.warmConcrete, lineWidth: 4)
                    .frame(width: 48, height: 48)

                // Animated arc
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        LinearGradient(
                            colors: [.hyperOrange, .yolk],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }

            Text(message)
                .font(.electricCaption)
                .foregroundColor(.graphite)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingView(message: "Loading recipes...")
        .warmConcreteBackground()
}
