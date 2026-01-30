//
//  CustomTabBar.swift
//  Cooked
//
//  The Dopamine Scrapbook - Neon glowing tab bar with frosted glass
//

import SwiftUI

// MARK: - Environment Key for Tab Bar Height

private struct CustomTabBarHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 100
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
            Color.clear.frame(height: 100)
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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            ZStack {
                // Dark frosted glass background
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial.opacity(0.5))

                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.dopamineBlack.opacity(0.6))

                // Subtle border glow
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

private struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Icon with thick stroke and glow
                ZStack {
                    // Glow layers for active state
                    if isSelected {
                        Image(systemName: tab.icon)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.dopamineAcid)
                            .blur(radius: 8)
                            .opacity(0.6)

                        Image(systemName: tab.icon)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.dopamineAcid)
                            .blur(radius: 4)
                            .opacity(0.4)
                    }

                    // Main icon
                    Image(systemName: tab.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .dopamineAcid : .white.opacity(0.5))
                }
                .frame(height: 28)

                // Label with glow
                ZStack {
                    if isSelected {
                        Text(tab.title)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.dopamineAcid)
                            .blur(radius: 4)
                            .opacity(0.5)
                    }

                    Text(tab.title)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(isSelected ? .dopamineAcid : .white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Custom Tab Bar") {
    ZStack {
        Color.dopamineBlack.ignoresSafeArea()

        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(.menu))
        }
    }
}

#Preview("Tab Bar States") {
    ZStack {
        Color.dopamineBlack.ignoresSafeArea()

        VStack(spacing: 40) {
            CustomTabBar(selectedTab: .constant(.recipes))
            CustomTabBar(selectedTab: .constant(.menu))
            CustomTabBar(selectedTab: .constant(.list))
        }
        .padding()
    }
}
