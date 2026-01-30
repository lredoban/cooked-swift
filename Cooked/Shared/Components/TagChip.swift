import SwiftUI

/// A selectable chip for filtering by tag - Electric Utility style
struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.electricCaption)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.yolk : Color.surfaceWhite)
                .foregroundColor(isSelected ? .ink : .graphite)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.graphite.opacity(0.3), lineWidth: 1)
                )
                .shadow(
                    color: isSelected ? Color.yolk.opacity(0.3) : .clear,
                    radius: 4,
                    x: 0,
                    y: 2
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    HStack(spacing: 10) {
        TagChip(tag: "dinner", isSelected: false, action: {})
        TagChip(tag: "quick", isSelected: true, action: {})
        TagChip(tag: "vegetarian", isSelected: false, action: {})
    }
    .padding()
    .warmConcreteBackground()
}
