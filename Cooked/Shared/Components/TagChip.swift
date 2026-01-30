import SwiftUI

/// A selectable chip for filtering by tag - Bold Swiss style
struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag.uppercased())
                .font(.swissCaption(11))
                .fontWeight(.medium)
                .tracking(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? BoldSwiss.black : BoldSwiss.white)
                .foregroundStyle(isSelected ? BoldSwiss.white : BoldSwiss.black)
                .overlay(
                    Rectangle()
                        .stroke(BoldSwiss.black, lineWidth: 1)
                )
                .clipShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 8) {
        TagChip(tag: "dinner", isSelected: false, action: {})
        TagChip(tag: "quick", isSelected: true, action: {})
        TagChip(tag: "vegetarian", isSelected: false, action: {})
    }
    .padding()
    .background(BoldSwiss.white)
}
