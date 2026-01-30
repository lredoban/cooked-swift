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
                            Text("I ALREADY HAVE THESE STAPLES:")
                                .font(.vintageLabel)
                                .foregroundColor(.vintageCoffee)

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
                            Text("ITEMS TO ADD:")
                                .font(.vintageLabel)
                                .foregroundColor(.vintageCoffee)
                            Spacer()
                            Text("\(filteredItemCount) items")
                                .font(.vintageCaption)
                                .foregroundStyle(Color.vintageMutedCocoa)
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
            .background(Color.vintageCream)
            .navigationTitle("Generate List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.vintageMutedCocoa)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await groceryState.generateList(menuId: menuId)
                        }
                    } label: {
                        if groceryState.isGenerating {
                            ProgressView()
                                .tint(Color.vintageTangerine)
                        } else {
                            Text("Create List")
                                .font(.vintageButton)
                                .foregroundColor(.vintageTangerine)
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
                        .font(.vintageCaption)
                }
                Text(text.capitalized)
                    .font(.vintageLabel)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.vintageLeafy : Color.vintageMutedCocoa.opacity(0.15))
            .foregroundStyle(isSelected ? .white : Color.vintageCoffee)
            .cornerRadius(20)
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
                        .font(.vintageCaption)
                        .foregroundStyle(Color.vintageMutedCocoa)
                    Text(category.displayName.uppercased())
                        .font(.vintageCaption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.vintageMutedCocoa)
                }

                ForEach(filteredItems) { item in
                    HStack {
                        Circle()
                            .fill(Color.vintageMutedCocoa.opacity(0.3))
                            .frame(width: 6, height: 6)
                        if let qty = item.quantity {
                            Text(qty)
                                .font(.vintageBody)
                                .fontWeight(.medium)
                                .foregroundColor(.vintageCoffee)
                        }
                        Text(item.text)
                            .font(.vintageBody)
                            .foregroundColor(.vintageCoffee)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.vintageWhite)
            .cornerRadius(16)
        }
    }
}

#Preview {
    GenerateListSheet(menuId: UUID())
        .environment(GroceryListState())
}
