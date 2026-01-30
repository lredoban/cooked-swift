//
//  CustomTabBar.swift
//  Cooked
//
//  Bold Swiss - Sharp geometric tab bar with inverted active state
//
//  STYLE PHILOSOPHY:
//  "The Grid Is Sacred" — Bold Swiss embraces the rigor and clarity of International
//  Typographic Style. Purely black and white, with sharp 0px corners and strict geometry,
//  this style strips away decoration to reveal pure function. Inspired by Josef Müller-Brockmann
//  and Massimo Vignelli, it treats the interface as a well-designed poster—every pixel
//  intentional, every element precisely placed. For users who believe good design is invisible.
//

import SwiftUI

// MARK: - Environment Key for Tab Bar Height

private struct CustomTabBarHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 60
}

extension EnvironmentValues {
    var customTabBarHeight: CGFloat {
        get { self[CustomTabBarHeightKey.self] }
        set { self[CustomTabBarHeightKey.self] = newValue }
    }
}

// MARK: - View Extension for Tab Bar Padding

extension View {
    /// Adds bottom padding for the custom tab bar
    func tabBarPadding() -> some View {
        self.safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 60)
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(BoldSwiss.black)
                .frame(height: 1)

            // Tab buttons with separators
            HStack(spacing: 0) {
                ForEach(Array(AppTab.allCases.enumerated()), id: \.element) { index, tab in
                    // Separator before tab (except first)
                    if index > 0 {
                        Rectangle()
                            .fill(BoldSwiss.black)
                            .frame(width: 1)
                    }

                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                    }
                }
            }
            .frame(height: 56)
        }
        .background(BoldSwiss.white)
    }
}

private struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(isSelected ? BoldSwiss.white : BoldSwiss.black)

                Text(tab.title.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundColor(isSelected ? BoldSwiss.white : BoldSwiss.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isSelected ? BoldSwiss.black : BoldSwiss.white)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Custom Tab Bar") {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.menu))
    }
    .background(BoldSwiss.white)
}

#Preview("Tab Bar States") {
    VStack(spacing: 40) {
        CustomTabBar(selectedTab: .constant(.recipes))
        CustomTabBar(selectedTab: .constant(.menu))
        CustomTabBar(selectedTab: .constant(.list))
    }
    .padding()
    .background(BoldSwiss.white)
}
