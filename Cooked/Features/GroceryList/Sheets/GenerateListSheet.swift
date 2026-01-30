import SwiftUI

struct GenerateListSheet: View {
    let menuId: UUID
    @Environment(GroceryListState.self) private var groceryState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var state = groceryState

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Staples Section
                    if !GroceryListState.commonStaples.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("I already have these staples:")
                                .font(.glassHeadline())
                                .foregroundColor(.glassTextPrimary)

                            FlowLayout(spacing: 8) {
                                ForEach(GroceryListState.commonStaples, id: \.self) { staple in
                                    StapleChip(
                                        text: staple,
                                        isSelected: groceryState.selectedStaples.contains(staple),
                                        action: {
                                            if groceryState.selectedStaples.contains(staple) {
                                                groceryState.selectedStaples.remove(staple)
                                            } else {
                                                groceryState.selectedStaples.insert(staple)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Items Preview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Items to add:")
                                .font(.glassHeadline())
                                .foregroundColor(.glassTextPrimary)
                            Spacer()
                            Text("\(filteredItemCount) items")
                                .font(.glassMono(13))
                                .foregroundColor(.glassTextSecondary)
                        }

                        // Group items by category
                        ForEach(groupedItems, id: \.category) { group in
                            CategoryPreviewSection(
                                category: group.category,
                                items: group.items,
                                excludedStaples: groceryState.selectedStaples
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .spatialBackground()
            .navigationTitle("Generate List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.glassTextSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await groceryState.generateList(menuId: menuId)
                        }
                    } label: {
                        if groceryState.isGenerating {
                            GlassLoadingSpinner(size: 20, lineWidth: 2)
                        } else {
                            Text("Create List")
                                .font(.glassBodyMedium())
                                .foregroundColor(.accentOrangeStart)
                        }
                    }
                    .disabled(groceryState.isGenerating || filteredItemCount == 0)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var filteredItemCount: Int {
        groceryState.pendingItems.filter { item in
            !groceryState.selectedStaples.contains { staple in
                item.text.lowercased().contains(staple.lowercased())
            }
        }.count
    }

    private var groupedItems: [(category: Ingredient.IngredientCategory, items: [GroceryItem])] {
        let grouped = Dictionary(grouping: groceryState.pendingItems) { $0.category }
        return grouped.keys.sorted { $0.sortOrder < $1.sortOrder }.map { key in
            (category: key, items: grouped[key] ?? [])
        }
    }
}

struct StapleChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.glassCaption(10))
                }
                Text(text.capitalized)
                    .font(.glassCaption(13))
            }
            .foregroundColor(isSelected ? .glassBackground : .glassTextPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.neonGreen : Color.glassSurface)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.glassBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CategoryPreviewSection: View {
    let category: Ingredient.IngredientCategory
    let items: [GroceryItem]
    let excludedStaples: Set<String>

    private var filteredItems: [GroceryItem] {
        items.filter { item in
            !excludedStaples.contains { staple in
                item.text.lowercased().contains(staple.lowercased())
            }
        }
    }

    var body: some View {
        if !filteredItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: category.iconName)
                        .font(.glassCaption())
                        .foregroundColor(.glassTextSecondary)
                    Text(category.displayName)
                        .font(.glassBodyMedium(14))
                        .foregroundColor(.glassTextSecondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(filteredItems) { item in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(LinearGradient.holographicOrange)
                                .frame(width: 6, height: 6)
                            if let qty = item.quantity {
                                Text(qty)
                                    .font(.glassBodyMedium(14))
                                    .foregroundColor(.glassTextPrimary)
                            }
                            Text(item.text)
                                .font(.glassBody(14))
                                .foregroundColor(.glassTextSecondary)
                            Spacer()
                        }
                    }
                }
                .padding(16)
                .glassBackground(cornerRadius: 12)
            }
        }
    }
}

#Preview {
    GenerateListSheet(menuId: UUID())
        .environment(GroceryListState())
}
