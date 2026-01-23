import SwiftUI

struct MenuHistoryView: View {
    @Environment(MenuState.self) private var menuState
    @Environment(SubscriptionState.self) private var subscriptionState
    @Environment(\.dismiss) private var dismiss

    private var shouldShowUpgradePrompt: Bool {
        !subscriptionState.isPro &&
        menuState.archivedMenus.count >= FreemiumLimits.freeMenuHistoryLimit
    }

    var body: some View {
        NavigationStack {
            Group {
                if menuState.isLoadingHistory {
                    LoadingView(message: "Loading history...")
                } else if menuState.archivedMenus.isEmpty {
                    emptyHistoryView
                } else {
                    historyListView
                }
            }
            .navigationTitle("Menu History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        menuState.closeHistory()
                    }
                }
            }
            .navigationDestination(item: Binding(
                get: { menuState.selectedArchivedMenu },
                set: { menuState.selectedArchivedMenu = $0 }
            )) { menu in
                ArchivedMenuDetailView(menu: menu)
            }
            .sheet(isPresented: Binding(
                get: { subscriptionState.isShowingPaywall },
                set: { subscriptionState.isShowingPaywall = $0 }
            )) {
                PaywallView()
            }
        }
    }

    private var emptyHistoryView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No Past Menus")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Your completed menus will appear here")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    private var historyListView: some View {
        List {
            ForEach(menuState.archivedMenus) { menu in
                Button {
                    menuState.selectArchivedMenu(menu)
                } label: {
                    MenuHistoryRow(menu: menu)
                }
                .buttonStyle(.plain)
            }

            // Show upgrade prompt for free tier
            if shouldShowUpgradePrompt {
                Section {
                    Button {
                        subscriptionState.showPaywall()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Upgrade to Pro")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Unlock unlimited menu history")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct MenuHistoryRow: View {
    let menu: MenuWithRecipes

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let archivedAt = menu.archivedAt {
                        Text(dateFormatter.string(from: archivedAt))
                            .font(.headline)
                    }

                    Text("\(menu.totalCount) recipes")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Completion badge
                if menu.isComplete {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Recipe thumbnails
            if !menu.items.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(menu.items.prefix(5)) { item in
                            AsyncImageView(url: item.recipe.imageUrl)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }

                        if menu.items.count > 5 {
                            Text("+\(menu.items.count - 5)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MenuHistoryView()
        .environment(MenuState())
        .environment(SubscriptionState())
}
