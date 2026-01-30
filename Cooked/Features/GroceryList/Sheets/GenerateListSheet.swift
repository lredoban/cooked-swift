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
                                .font(.dopamineHeadline)
                                .foregroundStyle(.white)

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
                                .font(.dopamineHeadline)
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(filteredItemCount) items")
                                .font(.dopamineCaption)
                                .foregroundStyle(Color.dopamineSecondary)
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
            .background(Color.dopamineBlack)
            .navigationTitle("Generate List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.dopamineSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await groceryState.generateList(menuId: menuId)
                        }
                    } label: {
                        if groceryState.isGenerating {
                            ProgressView()
                                .tint(Color.dopamineAcid)
                        } else {
                            Text("Create List")
                                .font(.dopamineSubheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.dopamineAcid)
                        }
                    }
                    .disabled(groceryState.isGenerating || filteredItemCount == 0)
                }
            }
        }
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
                        .font(.dopamineCaption)
                }
                Text(text.capitalized)
                    .font(.dopamineSubheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.dopamineAcid : Color.dopamineSurface)
            .foregroundStyle(isSelected ? .black : .white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
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
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: category.iconName)
                        .font(.dopamineCaption)
                        .foregroundStyle(Color.dopamineYellow)
                    Text(category.displayName)
                        .font(.dopamineSubheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.dopamineSecondary)
                }

                ForEach(filteredItems) { item in
                    HStack {
                        Circle()
                            .fill(Color.dopamineAcid.opacity(0.5))
                            .frame(width: 6, height: 6)
                        if let qty = item.quantity {
                            Text(qty)
                                .font(.dopamineBodyMedium)
                                .foregroundStyle(Color.dopamineYellow)
                        }
                        Text(item.text)
                            .font(.dopamineBodyRegular)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
            }
            .padding()
            .dopamineCard()
        }
    }
}

#Preview {
    GenerateListSheet(menuId: UUID())
        .environment(GroceryListState())
}
