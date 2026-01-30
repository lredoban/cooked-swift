import SwiftUI

/// A selectable chip for filtering by tag - uses GlassChip from design system
struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        GlassChip(text: tag, isSelected: isSelected, action: action)
    }
}

#Preview {
    HStack(spacing: 8) {
        TagChip(tag: "dinner", isSelected: false, action: {})
        TagChip(tag: "quick", isSelected: true, action: {})
        TagChip(tag: "vegetarian", isSelected: false, action: {})
    }
    .padding()
    .spatialBackground()
}
