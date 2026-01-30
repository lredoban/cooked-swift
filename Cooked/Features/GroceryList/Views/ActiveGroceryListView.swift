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
            VStack(alignment: .leading, spacing: ElectricUI.sectionSpacing) {
                // Progress Header with Health Bar
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("\(groceryState.checkedCount) of \(groceryState.totalCount) items")
                            .font(.electricSubheadline)
                            .foregroundColor(.ink)

                        Spacer()
                    }

                    ElectricProgressBar(progress: groceryState.progress, showPercentage: true)
                }
                .padding()
                .background(Color.surfaceWhite)
                .clipShape(RoundedRectangle(cornerRadius: ElectricUI.cornerRadius))
                .shadow(
                    color: .black.opacity(ElectricUI.cardShadowOpacity),
                    radius: ElectricUI.cardShadowRadius,
                    x: 0,
                    y: ElectricUI.cardShadowY
                )
                .padding(.horizontal)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Shopping progress: \(groceryState.checkedCount) of \(groceryState.totalCount) items checked, \(Int(groceryState.progress * 100)) percent complete")

                // Items by Category
                VStack(spacing: ElectricUI.gridSpacing) {
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
        .warmConcreteBackground()
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
                        .foregroundColor(.hyperOrange)
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
                            .stroke(Color.hyperOrange.opacity(0.3), lineWidth: 4)
                            .frame(width: 80, height: 80)

                        Circle()
                            .trim(from: 0, to: 0.3)
                            .stroke(Color.hyperOrange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .modifier(SpinningModifier())

                        Image(systemName: "link")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.hyperOrange)
                    } else {
                        // Ready state
                        ZStack {
                            Circle()
                                .fill(Color.hyperOrange.opacity(0.1))
                                .frame(width: 100, height: 100)

                            Image(systemName: "link.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(Color.hyperOrange)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(duration: 0.4), value: isLoading)
                .frame(height: 100)

                // Title
                Text(isLoading ? "Creating link..." : "Share Grocery List")
                    .font(.electricHeadline)
                    .foregroundColor(.ink)
                    .animation(.easeInOut, value: isLoading)

                // Description
                Text("Anyone with this link can view and check off items in real-time.")
                    .font(.electricBody)
                    .foregroundColor(.graphite)
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
                                    .foregroundColor(.ink)
                                    .lineLimit(1)
                                    .truncationMode(.middle)

                                Spacer()

                                Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                                    .foregroundColor(copied ? .hyperOrange : .graphite)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                            .padding()
                            .background(Color.warmConcrete)
                            .clipShape(RoundedRectangle(cornerRadius: ElectricUI.smallCornerRadius))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                        // Feedback text
                        if copied {
                            Text("Copied to clipboard!")
                                .font(.electricCaption)
                                .foregroundColor(.hyperOrange)
                                .transition(.opacity)
                        }

                        // Share button
                        ShareLink(item: url) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .electricPrimaryButton()
                        }
                        .padding(.horizontal)

                        // Revoke link button
                        Button(role: .destructive) {
                            Task {
                                await groceryState.revokeShareLink()
                                dismiss()
                            }
                        } label: {
                            Text("Revoke Link")
                                .font(.electricCaption)
                                .fontWeight(.semibold)
                                .foregroundColor(.graphite)
                        }
                        .padding(.top, 8)
                    }
                    .animation(.spring(duration: 0.4), value: shareURL != nil)
                } else if !isLoading {
                    // Fallback if link generation failed
                    Text("Failed to create link. Please try again.")
                        .font(.electricBody)
                        .foregroundColor(.graphite)
                }

                Spacer()
            }
            .warmConcreteBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.electricCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.hyperOrange)
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
        VStack(alignment: .leading, spacing: 12) {
            // Category Header with emoji
            HStack(spacing: 10) {
                Text(category.emoji)
                    .font(.title2)

                Text(category.displayName)
                    .font(.electricSubheadline)
                    .foregroundColor(.ink)

                Spacer()

                Text("\(checkedCount)/\(items.count)")
                    .font(.electricCaption)
                    .foregroundColor(.graphite)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(category.displayName) section, \(checkedCount) of \(items.count) items checked")
            .accessibilityAddTraits(.isHeader)

            // Items
            VStack(spacing: 0) {
                ForEach(items) { item in
                    GroceryItemRow(item: item)

                    if item.id != items.last?.id {
                        Divider()
                            .padding(.leading, ElectricUI.checkboxSize + 16)
                    }
                }
            }
            .padding()
            .background(Color.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: ElectricUI.cornerRadius))
            .shadow(
                color: .black.opacity(ElectricUI.cardShadowOpacity),
                radius: ElectricUI.cardShadowRadius,
                x: 0,
                y: ElectricUI.cardShadowY
            )
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
            HStack(spacing: 16) {
                ElectricCheckbox(isChecked: item.isChecked, action: {})
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.text)
                        .font(.electricBody)
                        .strikethrough(item.isChecked)
                        .foregroundColor(item.isChecked ? .graphite : .ink)

                    if let qty = item.quantity {
                        Text(qty)
                            .font(.electricCaption)
                            .fontWeight(.semibold)
                            .foregroundColor(.graphite)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(item.isChecked ? 0.6 : 1.0)
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

// MARK: - Category Emoji Extension

extension Ingredient.IngredientCategory {
    var emoji: String {
        switch self {
        case .produce:
            return "\u{1F955}" // carrot
        case .meat:
            return "\u{1F969}" // meat
        case .dairy:
            return "\u{1F9C0}" // cheese
        case .pantry:
            return "\u{1FAD9}" // jar
        case .frozen:
            return "\u{2744}\u{FE0F}" // snowflake
        case .bakery:
            return "\u{1F35E}" // bread
        case .seafood:
            return "\u{1F990}" // shrimp
        case .other:
            return "\u{1F6D2}" // shopping cart
        }
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
                    GroceryItem(text: "Salmon fillet", quantity: "1 lb", category: .meat, isChecked: true),
                    GroceryItem(text: "Spinach", quantity: "1 bag", category: .produce, isChecked: false),
                    GroceryItem(text: "Tomatoes", quantity: "4", category: .produce, isChecked: false),
                    GroceryItem(text: "Milk", quantity: "1 gallon", category: .dairy, isChecked: true),
                    GroceryItem(text: "Pasta", quantity: "1 box", category: .pantry, isChecked: false)
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
