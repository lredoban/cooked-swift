//
//  CustomTabBar.swift
//  Cooked
//
//  Spatial Glass - Frosted glass tab bar with holographic accents
//
//  STYLE PHILOSOPHY:
//  "The Culinary Operating System" — Spatial Glass transforms cooking into a cinematic,
//  immersive experience. Inspired by visionOS and high-end car interfaces, this style
//  uses deep blacks, frosted glass panels, and holographic orange gradients to create
//  a premium, futuristic feel. Every element floats in space with ambient glows and
//  soft reflections, making meal planning feel like piloting a spacecraft.
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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            ZStack {
                // Frosted glass effect
                Capsule()
                    .fill(.ultraThinMaterial)

                Capsule()
                    .fill(Color.glassSurface)

                // Subtle border
                Capsule()
                    .stroke(Color.glassBorder, lineWidth: 1)
            }
        )
        .shadow(color: Color.black.opacity(0.4), radius: 30, x: 0, y: 10)
        .padding(.horizontal, 32)
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
                // Icon with glow effect
                ZStack {
                    // Glow layers for active state
                    if isSelected {
                        Image(systemName: tab.icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(LinearGradient.holographicOrange)
                            .blur(radius: 10)
                            .opacity(0.5)

                        Image(systemName: tab.icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(LinearGradient.holographicOrange)
                            .blur(radius: 5)
                            .opacity(0.3)
                    }

                    // Main icon
                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(
                            isSelected
                                ? AnyShapeStyle(LinearGradient.holographicOrange)
                                : AnyShapeStyle(Color.glassTextSecondary)
                        )
                }
                .frame(height: 26)

                // Gradient reflection indicator
                if isSelected {
                    Capsule()
                        .fill(LinearGradient.holographicOrange)
                        .frame(width: 20, height: 3)
                        .shadow(color: Color.accentOrangeStart.opacity(0.5), radius: 4, x: 0, y: 0)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 20, height: 3)
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
        LinearGradient.darkBackground.ignoresSafeArea()

        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(.menu))
        }
    }
}

#Preview("Tab Bar States") {
    ZStack {
        LinearGradient.darkBackground.ignoresSafeArea()

        VStack(spacing: 40) {
            CustomTabBar(selectedTab: .constant(.recipes))
            CustomTabBar(selectedTab: .constant(.menu))
            CustomTabBar(selectedTab: .constant(.list))
        }
        .padding()
    }
}
