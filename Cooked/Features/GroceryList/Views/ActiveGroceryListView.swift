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
            VStack(alignment: .leading, spacing: 0) {
                // Progress Header - Bold Swiss style
                SwissProgressBar(value: Double(groceryState.checkedCount), total: Double(groceryState.totalCount))
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Shopping progress: \(groceryState.checkedCount) of \(groceryState.totalCount) items checked, \(Int(groceryState.progress * 100)) percent complete")

                // Progress label
                Text("\(groceryState.checkedCount) OF \(groceryState.totalCount) ITEMS")
                    .font(.swissCaption(11))
                    .fontWeight(.medium)
                    .tracking(1)
                    .foregroundStyle(BoldSwiss.black.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                SwissDivider()

                // Items by Category
                VStack(spacing: 0) {
                    ForEach(groupedItems, id: \.category) { group in
                        CategorySection(
                            category: group.category,
                            items: group.items
                        )
                    }
                }
                .padding(.top, 16)
            }
            .padding(.bottom, 40)
        }
        .background(BoldSwiss.white)
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
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(BoldSwiss.black)
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

                // Icon
                ZStack {
                    if isLoading {
                        // Loading state with spinning animation
                        Rectangle()
                            .stroke(BoldSwiss.black.opacity(0.3), lineWidth: 2)
                            .frame(width: 80, height: 80)

                        Rectangle()
                            .trim(from: 0, to: 0.3)
                            .stroke(BoldSwiss.black, style: StrokeStyle(lineWidth: 2, lineCap: .square))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .modifier(SpinningModifier())

                        Image(systemName: "link")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(BoldSwiss.black)
                    } else {
                        // Ready state
                        Image(systemName: "link")
                            .font(.system(size: 64, weight: .ultraLight))
                            .foregroundStyle(BoldSwiss.black)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(duration: 0.4), value: isLoading)
                .frame(height: 80)

                // Title
                Text(isLoading ? "CREATING LINK..." : "SHARE GROCERY LIST")
                    .font(.swissHeader(20))
                    .tracking(1)
                    .foregroundStyle(BoldSwiss.black)
                    .animation(.easeInOut, value: isLoading)

                // Description
                Text("Anyone with this link can view and check off items in real-time.")
                    .font(.swissBody(14))
                    .foregroundStyle(BoldSwiss.black.opacity(0.6))
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
                                    .font(.swissMono(12))
                                    .foregroundStyle(BoldSwiss.black)
                                    .lineLimit(1)
                                    .truncationMode(.middle)

                                Spacer()

                                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(copied ? BoldSwiss.black : BoldSwiss.black.opacity(0.5))
                                    .contentTransition(.symbolEffect(.replace))
                            }
                            .padding(16)
                            .swissBorder()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                        // Feedback text
                        if copied {
                            Text("COPIED TO CLIPBOARD")
                                .font(.swissCaption(11))
                                .fontWeight(.medium)
                                .tracking(1)
                                .foregroundStyle(BoldSwiss.black)
                                .transition(.opacity)
                        }

                        // Share button
                        ShareLink(item: url) {
                            HStack(spacing: 12) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14, weight: .bold))
                                Text("SHARE")
                            }
                            .swissPrimaryButton()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)

                        // Revoke link button
                        Button(role: .destructive) {
                            Task {
                                await groceryState.revokeShareLink()
                                dismiss()
                            }
                        } label: {
                            Text("REVOKE LINK")
                                .font(.swissCaption(12))
                                .fontWeight(.medium)
                                .tracking(1)
                                .foregroundStyle(BoldSwiss.accent)
                        }
                        .padding(.top, 8)
                    }
                    .animation(.spring(duration: 0.4), value: shareURL != nil)
                } else if !isLoading {
                    // Fallback if link generation failed
                    Text("Failed to create link. Please try again.")
                        .font(.swissBody(14))
                        .foregroundStyle(BoldSwiss.black.opacity(0.5))
                }

                Spacer()
            }
            .background(BoldSwiss.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("DONE") {
                        dismiss()
                    }
                    .font(.swissCaption(12))
                    .fontWeight(.bold)
                    .tracking(1)
                    .foregroundStyle(BoldSwiss.black)
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
        VStack(alignment: .leading, spacing: 0) {
            // Category Header - WHITE TEXT ON BLACK BAR (inverted)
            HStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .font(.system(size: 12, weight: .bold))
                    .accessibilityHidden(true)
                Text(category.displayName.uppercased())
                    .font(.swissCaption(12))
                    .fontWeight(.bold)
                    .tracking(1)
            }
            .swissSectionHeader()
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(category.displayName) section, \(checkedCount) of \(items.count) items checked")
            .accessibilityAddTraits(.isHeader)

            // Items
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    GroceryItemRow(item: item)

                    if index < items.count - 1 {
                        SwissDivider()
                    }
                }
            }
        }
        .swissBorder()
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
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
                // Square checkbox
                SwissCheckbox(isChecked: item.isChecked) {
                    // Action handled by parent button
                }
                .allowsHitTesting(false)

                // Item info
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.text.uppercased())
                        .font(.swissBody(14))
                        .fontWeight(.medium)
                        .foregroundStyle(item.isChecked ? BoldSwiss.black.opacity(BoldSwiss.dimmedOpacity) : BoldSwiss.black)

                    if let qty = item.quantity {
                        Text(qty.uppercased())
                            .font(.swissCaption(12))
                            .foregroundStyle(item.isChecked ? BoldSwiss.black.opacity(0.2) : BoldSwiss.black.opacity(0.5))
                    }
                }

                Spacer()
            }
            .padding(16)
            .background(BoldSwiss.white)
            .opacity(item.isChecked ? 0.6 : 1.0)
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
        .navigationTitle("GROCERY LIST")
    }
    .environment(GroceryListState())
}
