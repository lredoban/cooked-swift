import SwiftUI

/// A selectable chip for filtering by tag
struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.vintageLabel)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.vintageMarigold : Color.vintageMarigold.opacity(0.2))
                .foregroundStyle(isSelected ? Color.vintageCoffee : Color.vintageMutedCocoa)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        TagChip(tag: "dinner", isSelected: false, action: {})
        TagChip(tag: "quick", isSelected: true, action: {})
        TagChip(tag: "vegetarian", isSelected: false, action: {})
    }
    .padding()
    .background(Color.vintageCream)
}
