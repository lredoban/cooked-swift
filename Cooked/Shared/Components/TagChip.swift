import SwiftUI

/// A selectable chip for filtering by tag with Curated Kitchen styling
struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.curatedSans(size: 14, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.curatedSage : Color.clear)
                .foregroundStyle(isSelected ? .white : Color.curatedSage)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.curatedSage, lineWidth: 1.5)
                )
                .cornerRadius(24)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.curatedOatmeal.ignoresSafeArea()

        HStack {
            TagChip(tag: "dinner", isSelected: false, action: {})
            TagChip(tag: "quick", isSelected: true, action: {})
            TagChip(tag: "vegetarian", isSelected: false, action: {})
        }
        .padding()
    }
}
