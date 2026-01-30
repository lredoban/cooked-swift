//
//  CustomTabBar.swift
//  Cooked
//
//  The Curated Kitchen - Warm, editorial floating tab bar
//
//  STYLE PHILOSOPHY:
//  "A Digital Sanctuary" — The Curated Kitchen channels the quiet elegance of Kinfolk
//  magazine and Aesop stores. Warm oatmeal backgrounds, terracotta accents, and delicate
//  serif typography create a sense of calm intentionality. This style is for users who
//  approach cooking as a mindful ritual, not a chore. Every element breathes, with generous
//  whitespace and soft shadows that make the app feel like a beautifully designed cookbook.
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

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.curatedWhite)
                .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

private struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Fine-line stroke icon
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(isSelected ? .curatedTerracotta : .curatedWarmGrey)
                    .frame(height: 24)

                // Small dot indicator
                Circle()
                    .fill(isSelected ? Color.curatedTerracotta : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Custom Tab Bar") {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.menu))
    }
    .background(Color.curatedOatmeal)
}

#Preview("Tab Bar States") {
    VStack(spacing: 40) {
        CustomTabBar(selectedTab: .constant(.recipes))
        CustomTabBar(selectedTab: .constant(.menu))
        CustomTabBar(selectedTab: .constant(.list))
    }
    .padding()
    .background(Color.curatedOatmeal)
}
