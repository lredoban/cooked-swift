import SwiftUI

struct LoadingView: View {
    var message: String = "LOADING..."
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            // Animated square spinner - Bold Swiss style
            ZStack {
                Rectangle()
                    .stroke(BoldSwiss.black.opacity(0.2), lineWidth: 2)
                    .frame(width: 48, height: 48)

                Rectangle()
                    .trim(from: 0, to: 0.25)
                    .stroke(BoldSwiss.black, style: StrokeStyle(lineWidth: 2, lineCap: .square))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(rotation))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
            }
            .onAppear {
                rotation = 360
            }

            Text(message.uppercased())
                .font(.swissCaption(12))
                .fontWeight(.medium)
                .tracking(2)
                .foregroundStyle(BoldSwiss.black.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BoldSwiss.white)
    }
}

#Preview {
    LoadingView(message: "Loading recipes...")
}
