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
                                .font(.curatedHeadline)
                                .foregroundStyle(Color.curatedCharcoal)

                            FlowLayout(spacing: 8) {
                                ForEach(GroceryListState.commonStaples, id: \.self) { staple in
                                    CuratedStapleChip(
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
                                .font(.curatedHeadline)
                                .foregroundStyle(Color.curatedCharcoal)
                            Spacer()
                            Text("\(filteredItemCount) items")
                                .font(.curatedSubheadline)
                                .foregroundStyle(Color.curatedWarmGrey)
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
            .curatedBackground()
            .navigationTitle("Generate List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.curatedWarmGrey)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await groceryState.generateList(menuId: menuId)
                        }
                    } label: {
                        if groceryState.isGenerating {
                            CuratedSpinner(size: 20)
                        } else {
                            Text("Create List")
                                .font(.curatedSans(size: 17, weight: .semibold))
                                .foregroundStyle(Color.curatedTerracotta)
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
                        .font(.curatedCaption)
                        .foregroundStyle(Color.curatedWarmGrey)
                    Text(category.displayName)
                        .font(.curatedSans(size: 14, weight: .medium))
                        .foregroundStyle(Color.curatedWarmGrey)
                }

                ForEach(filteredItems) { item in
                    HStack {
                        Circle()
                            .fill(Color.curatedBeige)
                            .frame(width: 6, height: 6)
                        if let qty = item.quantity {
                            Text(qty)
                                .font(.curatedSans(size: 15, weight: .medium))
                                .foregroundStyle(Color.curatedCharcoal)
                        }
                        Text(item.text)
                            .font(.curatedSubheadline)
                            .foregroundStyle(Color.curatedCharcoal)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.curatedWhite)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }
}

#Preview {
    GenerateListSheet(menuId: UUID())
        .environment(GroceryListState())
}
