import SwiftUI

/// A shimmer/skeleton loading view that pulses to indicate content is loading.
///
/// Use this instead of a spinner when you want to show *where* content will appear.
struct ShimmerView: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemGray5))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color(.systemGray4), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 200 : -200)
            )
            .clipped()
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

/// A block of shimmer lines mimicking text content.
struct ShimmerBlock: View {
    let lineCount: Int
    var lineHeight: CGFloat = 14
    var spacing: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<lineCount, id: \.self) { index in
                ShimmerView()
                    .frame(
                        maxWidth: index == lineCount - 1 ? 180 : .infinity,
                        maxHeight: lineHeight
                    )
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ShimmerView()
            .frame(height: 20)

        ShimmerBlock(lineCount: 4)
    }
    .padding()
}
