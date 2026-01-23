import SwiftUI

/// A horizontal scrolling bar of tag chips for filtering recipes
struct TagFilterBar: View {
    let tags: [String]
    let selectedTag: String?
    let onTagTap: (String) -> Void

    var body: some View {
        if !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagChip(
                            tag: tag,
                            isSelected: selectedTag == tag,
                            action: { onTagTap(tag) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    VStack {
        TagFilterBar(
            tags: ["dinner", "quick", "vegetarian", "pasta", "chicken", "breakfast"],
            selectedTag: "quick",
            onTagTap: { _ in }
        )

        TagFilterBar(
            tags: ["dinner", "quick", "vegetarian"],
            selectedTag: nil,
            onTagTap: { _ in }
        )
    }
}
