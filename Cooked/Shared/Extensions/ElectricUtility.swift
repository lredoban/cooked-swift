import SwiftUI

// MARK: - Electric Utility Design System
// "The Nintendo Approach" - High-function utility with joyful, tactile aesthetics

// MARK: - Color Palette

extension Color {
    // Primary Brand Colors
    static let hyperOrange = Color(hex: "FF4D00")     // Primary CTAs, active states
    static let yolk = Color(hex: "FFD600")            // Secondary accent, selected tags
    static let cobalt = Color(hex: "4A5AF7")          // Section backgrounds

    // Base Colors
    static let warmConcrete = Color(hex: "F2F2F0")    // Main background
    static let surfaceWhite = Color.white             // Cards pop off grey background

    // Text Colors
    static let ink = Color(hex: "1A1C20")             // Primary text
    static let graphite = Color(hex: "6B6E75")        // Secondary text

    // Semantic Colors
    static let softYellow = Color(hex: "FFF9C4")      // Ingredients background
    static let softBlue = Color(hex: "E8EAF6")        // Steps background
    static let softGreen = Color(hex: "E8F5E9")       // Success/checked states

    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Design Constants

enum ElectricUI {
    // Corner Radii
    static let cornerRadius: CGFloat = 24
    static let smallCornerRadius: CGFloat = 16
    static let pillCornerRadius: CGFloat = 100

    // Spacing
    static let gridSpacing: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    static let cardPadding: CGFloat = 16

    // Sizes
    static let buttonHeight: CGFloat = 56
    static let checkboxSize: CGFloat = 28
    static let progressBarHeight: CGFloat = 12
    static let stepNumberSize: CGFloat = 32

    // Shadows
    static let cardShadowRadius: CGFloat = 10
    static let cardShadowY: CGFloat = 8
    static let cardShadowOpacity: CGFloat = 0.06

    static let floatingShadowRadius: CGFloat = 20
    static let floatingShadowY: CGFloat = 12
    static let floatingShadowOpacity: CGFloat = 0.10
}

// MARK: - View Modifiers

/// Applies the warm concrete background
struct WarmConcreteBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.warmConcrete.ignoresSafeArea())
    }
}

/// Applies Electric Utility card styling
struct ElectricCard: ViewModifier {
    var padding: CGFloat = ElectricUI.cardPadding

    func body(content: Content) -> some View {
        content
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

/// Primary CTA button styling
struct ElectricPrimaryButton: ViewModifier {
    var isFullWidth: Bool = true

    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.bold)
            .textCase(.uppercase)
            .tracking(0.5)
            .foregroundColor(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: ElectricUI.buttonHeight)
            .background(Color.hyperOrange)
            .clipShape(RoundedRectangle(cornerRadius: ElectricUI.cornerRadius))
            .shadow(
                color: Color.hyperOrange.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
    }
}

/// Secondary stroke button styling
struct ElectricSecondaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.ink)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: ElectricUI.pillCornerRadius)
                    .stroke(Color.ink, lineWidth: 2)
            )
    }
}

/// Floating card with stronger shadow
struct FloatingCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: ElectricUI.cornerRadius))
            .shadow(
                color: .black.opacity(ElectricUI.floatingShadowOpacity),
                radius: ElectricUI.floatingShadowRadius,
                x: 0,
                y: ElectricUI.floatingShadowY
            )
    }
}

// MARK: - View Extensions

extension View {
    func warmConcreteBackground() -> some View {
        modifier(WarmConcreteBackground())
    }

    func electricCard(padding: CGFloat = ElectricUI.cardPadding) -> some View {
        modifier(ElectricCard(padding: padding))
    }

    func electricPrimaryButton(fullWidth: Bool = true) -> some View {
        modifier(ElectricPrimaryButton(isFullWidth: fullWidth))
    }

    func electricSecondaryButton() -> some View {
        modifier(ElectricSecondaryButton())
    }

    func floatingCard() -> some View {
        modifier(FloatingCard())
    }
}

// MARK: - Custom Components

/// Electric Utility styled progress bar - "Health Bar" style
struct ElectricProgressBar: View {
    let progress: Double
    var showPercentage: Bool = true

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: ElectricUI.progressBarHeight / 2)
                        .fill(Color.warmConcrete)
                        .frame(height: ElectricUI.progressBarHeight)

                    // Fill with gradient
                    RoundedRectangle(cornerRadius: ElectricUI.progressBarHeight / 2)
                        .fill(
                            LinearGradient(
                                colors: [.hyperOrange, .yolk],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(geometry.size.width * progress, ElectricUI.progressBarHeight),
                            height: ElectricUI.progressBarHeight
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: ElectricUI.progressBarHeight)

            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.graphite)
            }
        }
    }
}

/// Electric Utility styled checkbox
struct ElectricCheckbox: View {
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isChecked ? Color.hyperOrange : Color.clear)
                    .frame(width: ElectricUI.checkboxSize, height: ElectricUI.checkboxSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isChecked ? Color.hyperOrange : Color.graphite, lineWidth: 2)
                    )

                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isChecked)
    }
}

/// Electric step number circle
struct ElectricStepNumber: View {
    let number: Int

    var body: some View {
        Text("\(number)")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: ElectricUI.stepNumberSize, height: ElectricUI.stepNumberSize)
            .background(Color.hyperOrange)
            .clipShape(Circle())
    }
}

/// Floating status sticker badge
struct StickerBadge: View {
    let text: String
    let icon: String
    var color: Color = .hyperOrange

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color)
                .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)
        )
    }
}

/// Floating title pill for cards
struct FloatingTitlePill: View {
    let text: String
    var maxWidth: CGFloat = .infinity

    var body: some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.ink)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ElectricUI.smallCornerRadius)
                    .fill(Color.surfaceWhite.opacity(0.95))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
    }
}

// MARK: - Font Styles

extension Font {
    /// Large playful display font for headlines
    static let electricDisplay = Font.system(size: 32, weight: .bold, design: .rounded)

    /// Medium headline for sections
    static let electricHeadline = Font.system(size: 24, weight: .bold, design: .rounded)

    /// Subheadline for cards
    static let electricSubheadline = Font.system(size: 17, weight: .semibold, design: .default)

    /// Body text
    static let electricBody = Font.system(size: 16, weight: .regular, design: .default)

    /// Caption text
    static let electricCaption = Font.system(size: 13, weight: .medium, design: .default)
}

// MARK: - Preview

#Preview("Electric Utility Components") {
    ScrollView {
        VStack(spacing: 24) {
            // Colors
            HStack(spacing: 8) {
                Circle().fill(Color.hyperOrange).frame(width: 40, height: 40)
                Circle().fill(Color.yolk).frame(width: 40, height: 40)
                Circle().fill(Color.cobalt).frame(width: 40, height: 40)
                Circle().fill(Color.warmConcrete).frame(width: 40, height: 40)
                Circle().fill(Color.ink).frame(width: 40, height: 40)
            }

            // Primary Button
            Button("Add Recipes") {}
                .electricPrimaryButton()

            // Secondary Button
            Button("View History") {}
                .electricSecondaryButton()

            // Progress Bar
            ElectricProgressBar(progress: 0.65)

            // Checkboxes
            HStack(spacing: 16) {
                ElectricCheckbox(isChecked: false, action: {})
                ElectricCheckbox(isChecked: true, action: {})
            }

            // Step Numbers
            HStack(spacing: 12) {
                ElectricStepNumber(number: 1)
                ElectricStepNumber(number: 2)
                ElectricStepNumber(number: 3)
            }

            // Sticker Badges
            HStack {
                StickerBadge(text: "Ready", icon: "checkmark.circle.fill")
                StickerBadge(text: "Importing", icon: "arrow.down.circle.fill", color: .cobalt)
            }

            // Card
            VStack {
                Text("Sample Card")
                    .font(.electricHeadline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .electricCard()
        }
        .padding()
    }
    .warmConcreteBackground()
}
