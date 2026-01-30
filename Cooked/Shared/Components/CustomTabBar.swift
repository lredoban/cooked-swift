//
//  CustomTabBar.swift
//  Cooked
//
//  Electric Utility - Nintendo-inspired floating tab bar with bouncy interactions
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
        HStack(spacing: 8) {
            ForEach(AppTab.allCases) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: ElectricUI.cornerRadius)
                .fill(Color.surfaceWhite)
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 20,
                    x: 0,
                    y: 8
                )
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
            VStack(spacing: 4) {
                // Large icon with orange pill background when selected
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.hyperOrange)
                            .frame(width: 56, height: 40)
                            .shadow(color: Color.hyperOrange.opacity(0.4), radius: 6, x: 0, y: 3)
                    }

                    Image(systemName: isSelected ? "\(tab.icon).fill" : tab.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .graphite)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .frame(height: 44)

                // Label
                Text(tab.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isSelected ? .hyperOrange : .graphite)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Bouncy Button Style

private struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

#Preview("Custom Tab Bar") {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.menu))
    }
    .warmConcreteBackground()
}

#Preview("Tab Bar States") {
    VStack(spacing: 40) {
        CustomTabBar(selectedTab: .constant(.recipes))
        CustomTabBar(selectedTab: .constant(.menu))
        CustomTabBar(selectedTab: .constant(.list))
    }
    .padding()
    .warmConcreteBackground()
}
