//
//  CustomTabBar.swift
//  Cooked
//
//  Vintage Aesthetic - Floating pill tab bar with tangerine accents
//
//  STYLE PHILOSOPHY:
//  "Sunshine Editorial" — Vintage Aesthetic captures the warm nostalgia of 1970s cookbook
//  photography and lifestyle magazines. Creamy backgrounds, tangerine accents, and rounded
//  organic shapes evoke Sunday morning brunch vibes. Inspired by Bon Appétit, Mejuri, and
//  indie recipe blogs, this style feels handcrafted and inviting—like a well-loved recipe
//  card passed down through generations. Cooking should feel cozy, not clinical.
//

import SwiftUI

// MARK: - Environment Key for Tab Bar Height

private struct CustomTabBarHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 90
}

extension EnvironmentValues {
    var customTabBarHeight: CGFloat {
        get { self[CustomTabBarHeightKey.self] }
        set { self[CustomTabBarHeightKey.self] = newValue }
    }
}

// MARK: - View Extension for Tab Bar Padding

extension View {
    /// Adds bottom padding for the custom floating tab bar
    func tabBarPadding() -> some View {
        self.safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 90)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.vintageWhite)
        )
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }
}

private struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.iconFilled : tab.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? .vintageTangerine : .vintageMutedCocoa)
                    .frame(height: 24)

                // Active indicator dot
                Circle()
                    .fill(isSelected ? Color.vintageTangerine : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AppTab Extension for filled icons

extension AppTab {
    var iconFilled: String {
        switch self {
        case .recipes: return "book.fill"
        case .menu: return "fork.knife"
        case .list: return "checklist"
        }
    }
}

#Preview("Custom Tab Bar") {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.menu))
    }
    .background(Color.vintageCream)
}

#Preview("Tab Bar States") {
    VStack(spacing: 40) {
        CustomTabBar(selectedTab: .constant(.recipes))
        CustomTabBar(selectedTab: .constant(.menu))
        CustomTabBar(selectedTab: .constant(.list))
    }
    .padding()
    .background(Color.vintageCream)
}
