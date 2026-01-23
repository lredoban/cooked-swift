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
                                .font(.headline)

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
                                .font(.headline)
                            Spacer()
                            Text("\(filteredItemCount) items")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
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
            .navigationTitle("Generate List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await groceryState.generateList(menuId: menuId)
                        }
                    } label: {
                        if groceryState.isGenerating {
                            ProgressView()
                        } else {
                            Text("Create List")
                                .fontWeight(.semibold)
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
                        .font(.caption)
                }
                Text(text.capitalized)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.green : Color.gray.opacity(0.15))
            .foregroundStyle(isSelected ? .white : .primary)
            .cornerRadius(16)
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
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(category.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }

                ForEach(filteredItems) { item in
                    HStack {
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 6, height: 6)
                        if let qty = item.quantity {
                            Text(qty)
                                .fontWeight(.medium)
                        }
                        Text(item.text)
                        Spacer()
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

#Preview {
    GenerateListSheet(menuId: UUID())
        .environment(GroceryListState())
}
