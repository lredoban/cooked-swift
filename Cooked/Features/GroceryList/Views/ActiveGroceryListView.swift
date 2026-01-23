import SwiftUI

struct ActiveGroceryListView: View {
    let list: GroceryList
    @Environment(GroceryListState.self) private var groceryState
    @State private var showDeleteConfirmation = false
    @State private var showShareSheet = false

    private var groupedItems: [(category: Ingredient.IngredientCategory, items: [GroceryItem])] {
        let grouped = Dictionary(grouping: list.items) { $0.category }
        return grouped.keys.sorted { $0.sortOrder < $1.sortOrder }.map { key in
            (category: key, items: grouped[key] ?? [])
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Progress Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(groceryState.checkedCount) of \(groceryState.totalCount) items")
                            .font(.headline)

                        Spacer()

                        Text("\(Int(groceryState.progress * 100))%")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ProgressView(value: groceryState.progress)
                        .tint(.green)
                }
                .padding(.horizontal)

                // Items by Category
                VStack(spacing: 16) {
                    ForEach(groupedItems, id: \.category) { group in
                        CategorySection(
                            category: group.category,
                            items: group.items
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                SwiftUI.Menu {
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share List", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete List", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Delete this grocery list?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await groceryState.deleteList()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [groceryState.shareListAsText()])
        }
    }
}

struct CategorySection: View {
    let category: Ingredient.IngredientCategory
    let items: [GroceryItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category Header
            HStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .foregroundStyle(.secondary)
                Text(category.displayName)
                    .font(.headline)
            }

            // Items
            VStack(spacing: 0) {
                ForEach(items) { item in
                    GroceryItemRow(item: item)

                    if item.id != items.last?.id {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct GroceryItemRow: View {
    let item: GroceryItem
    @Environment(GroceryListState.self) private var groceryState

    var body: some View {
        Button {
            Task {
                await groceryState.toggleItemChecked(item)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isChecked ? .green : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.text)
                        .font(.body)
                        .strikethrough(item.isChecked)
                        .foregroundStyle(item.isChecked ? .secondary : .primary)

                    if let qty = item.quantity {
                        Text(qty)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ActiveGroceryListView(
            list: GroceryList(
                id: UUID(),
                menuId: UUID(),
                items: [
                    GroceryItem(text: "Chicken breast", quantity: "2 lbs", category: .meat, isChecked: false),
                    GroceryItem(text: "Salmon fillet", quantity: "1 lb", category: .meat, isChecked: true),
                    GroceryItem(text: "Spinach", quantity: "1 bag", category: .produce, isChecked: false),
                    GroceryItem(text: "Tomatoes", quantity: "4", category: .produce, isChecked: false),
                    GroceryItem(text: "Milk", quantity: "1 gallon", category: .dairy, isChecked: true),
                    GroceryItem(text: "Pasta", quantity: "1 box", category: .pantry, isChecked: false)
                ],
                staplesConfirmed: ["salt", "pepper"],
                createdAt: Date()
            )
        )
        .navigationTitle("Grocery List")
    }
    .environment(GroceryListState())
}
