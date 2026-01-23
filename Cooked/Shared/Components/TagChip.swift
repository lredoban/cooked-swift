import SwiftUI

/// A selectable chip for filtering by tag
struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color.orange.opacity(0.15))
                .foregroundStyle(isSelected ? .white : .orange)
                .cornerRadius(16)
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
}
