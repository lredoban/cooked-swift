import SwiftUI

struct ActiveGroceryListView: View {
    let list: GroceryList
    @Environment(GroceryListState.self) private var groceryState
    @State private var showDeleteConfirmation = false
    @State private var showShareLinkSheet = false

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
                            .font(.vintageSubheadline)
                            .foregroundColor(.vintageCoffee)

                        Spacer()

                        Text("\(Int(groceryState.progress * 100))%")
                            .font(.vintageCaption)
                            .foregroundStyle(Color.vintageMutedCocoa)
                    }

                    ProgressView(value: groceryState.progress)
                        .tint(Color.vintageLeafy)
                }
                .padding(.horizontal)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Shopping progress: \(groceryState.checkedCount) of \(groceryState.totalCount) items checked, \(Int(groceryState.progress * 100)) percent complete")

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
        .background(Color.vintageCream)
        .tabBarPadding()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                SwiftUI.Menu {
                    Button {
                        showShareLinkSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete List", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.vintageTangerine)
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
        .sheet(isPresented: $showShareLinkSheet) {
            ShareLinkSheet(list: list)
        }
    }
}

// MARK: - Share Link Sheet

struct ShareLinkSheet: View {
    let list: GroceryList
    @Environment(GroceryListState.self) private var groceryState
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false
    @State private var linkReady = false

    private var shareURL: URL? {
        guard let token = list.shareToken ?? groceryState.activeList?.shareToken else {
            return nil
        }
        return AppConfig.backendURL.appendingPathComponent("list/\(token)")
    }

    private var isLoading: Bool {
        groceryState.isGeneratingShareLink || (shareURL == nil && !linkReady)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Animated icon that transforms from loading to link
                ZStack {
                    if isLoading {
                        // Loading state with spinning animation
                        Circle()
                            .stroke(Color.vintageLeafy.opacity(0.3), lineWidth: 4)
                            .frame(width: 80, height: 80)

                        Circle()
                            .trim(from: 0, to: 0.3)
                            .stroke(Color.vintageLeafy, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .modifier(SpinningModifier())

                        Image(systemName: "link")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.vintageLeafy)
                    } else {
                        // Ready state
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.vintageLeafy)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(duration: 0.4), value: isLoading)
                .frame(height: 80)

                // Title
                Text(isLoading ? "CREATING LINK..." : "SHARE GROCERY LIST")
                    .font(.vintageHeadline)
                    .foregroundColor(.vintageCoffee)
                    .animation(.easeInOut, value: isLoading)

                // Description
                Text("Anyone with this link can view and check off items in real-time.")
                    .font(.vintageBody)
                    .foregroundStyle(Color.vintageMutedCocoa)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                // Link input area
                if let url = shareURL {
                    VStack(spacing: 16) {
                        // Copyable link field
                        Button {
                            UIPasteboard.general.string = url.absoluteString
                            copied = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copied = false
                            }
                        } label: {
                            HStack {
                                Text(url.absoluteString)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundStyle(Color.vintageCoffee)
                                    .lineLimit(1)
                                    .truncationMode(.middle)

                                Spacer()

                                Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                                    .foregroundStyle(copied ? Color.vintageLeafy : Color.vintageMutedCocoa)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                            .padding()
                            .background(Color.vintageWhite)
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                        // Feedback text
                        if copied {
                            Text("Copied to clipboard!")
                                .font(.vintageCaption)
                                .foregroundStyle(Color.vintageLeafy)
                                .transition(.opacity)
                        }

                        // Share button
                        ShareLink(item: url) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.vintage(backgroundColor: .vintageLeafy))
                        .padding(.horizontal)

                        // Revoke link button
                        Button(role: .destructive) {
                            Task {
                                await groceryState.revokeShareLink()
                                dismiss()
                            }
                        } label: {
                            Text("Revoke Link")
                                .font(.vintageCaption)
                                .foregroundColor(.vintageBurnt)
                        }
                        .padding(.top, 8)
                    }
                    .animation(.spring(duration: 0.4), value: shareURL != nil)
                } else if !isLoading {
                    // Fallback if link generation failed
                    Text("Failed to create link. Please try again.")
                        .font(.vintageBody)
                        .foregroundStyle(Color.vintageMutedCocoa)
                }

                Spacer()
            }
            .background(Color.vintageCream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.vintageButton)
                    .foregroundColor(.vintageTangerine)
                }
            }
        }
        .presentationDetents([.medium])
        .task {
            // Auto-generate link if not already present
            if shareURL == nil {
                await groceryState.generateShareLink()
                withAnimation {
                    linkReady = true
                }
            } else {
                linkReady = true
            }
        }
    }
}

// MARK: - Spinning Animation Modifier

struct SpinningModifier: ViewModifier {
    @State private var isSpinning = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isSpinning)
            .onAppear {
                isSpinning = true
            }
    }
}

struct CategorySection: View {
    let category: Ingredient.IngredientCategory
    let items: [GroceryItem]

    private var checkedCount: Int {
        items.filter(\.isChecked).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category Header
            HStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .foregroundStyle(Color.vintageMutedCocoa)
                    .accessibilityHidden(true)
                Text(category.displayName.uppercased())
                    .font(.vintageLabel)
                    .foregroundColor(.vintageCoffee)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(category.displayName) section, \(checkedCount) of \(items.count) items checked")
            .accessibilityAddTraits(.isHeader)

            // Items
            VStack(spacing: 0) {
                ForEach(items) { item in
                    GroceryItemRow(item: item)

                    if item.id != items.last?.id {
                        Rectangle()
                            .fill(Color.vintageMutedCocoa.opacity(0.1))
                            .frame(height: 1)
                            .padding(.leading, 44)
                    }
                }
            }
            .background(Color.vintageWhite)
            .cornerRadius(16)
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
                    .foregroundStyle(item.isChecked ? Color.vintageLeafy : Color.vintageMutedCocoa)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.text)
                        .font(.vintageBody)
                        .strikethrough(item.isChecked)
                        .foregroundStyle(item.isChecked ? Color.vintageMutedCocoa : Color.vintageCoffee)

                    if let qty = item.quantity {
                        Text(qty)
                            .font(.vintageCaption)
                            .foregroundStyle(Color.vintageMutedCocoa)
                    }
                }

                Spacer()
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(item.isChecked ? "Double tap to uncheck" : "Double tap to check off")
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityLabel: String {
        var label = item.text
        if let qty = item.quantity {
            label += ", \(qty)"
        }
        if item.isChecked {
            label += ", checked"
        }
        return label
    }
}

#Preview {
    NavigationStack {
        ActiveGroceryListView(
            list: GroceryList(
                id: UUID(),
                menuId: UUID(),
                items: [
                    GroceryItem(text: "Chicken breast", quantity: "2 lbs", category: .meat, isChecked: false),
                    GroceryItem(text: "Salmon fillet", quantity: "1 lb", category: .seafood, isChecked: true),
                    GroceryItem(text: "Spinach", quantity: "1 bag", category: .produce, isChecked: false),
                    GroceryItem(text: "Tomatoes", quantity: "4", category: .produce, isChecked: false),
                    GroceryItem(text: "Milk", quantity: "1 gallon", category: .dairy, isChecked: true),
                    GroceryItem(text: "Pasta", quantity: "1 box", category: .pantry, isChecked: false),
                    GroceryItem(text: "Ice cream", quantity: "1 pint", category: .frozen, isChecked: false),
                    GroceryItem(text: "Bread", quantity: "1 loaf", category: .bakery, isChecked: false),
                    GroceryItem(text: "Paper towels", quantity: "1 roll", category: .other, isChecked: false)
                ],
                staplesConfirmed: ["salt", "pepper"],
                createdAt: Date(),
                shareToken: nil
            )
        )
        .navigationTitle("Grocery List")
    }
    .environment(GroceryListState())
}
