import SwiftUI

// MARK: - Vintage Color Palette

extension Color {
    /// Warm cream background - #FFF9F0
    static let vintageCream = Color(red: 255/255, green: 249/255, blue: 240/255)

    /// Tangerine pop - Primary action color #FF5A36
    static let vintageTangerine = Color(red: 255/255, green: 90/255, blue: 54/255)

    /// Marigold yellow - Secondary accent #FFC800
    static let vintageMarigold = Color(red: 255/255, green: 200/255, blue: 0/255)

    /// Dark coffee - Primary text #2D2520
    static let vintageCoffee = Color(red: 45/255, green: 37/255, blue: 32/255)

    /// Muted cocoa - Secondary text #8D6E63
    static let vintageMutedCocoa = Color(red: 141/255, green: 110/255, blue: 99/255)

    /// Leafy green - Success color #66BB6A
    static let vintageLeafy = Color(red: 102/255, green: 187/255, blue: 106/255)

    /// Burnt orange - Destructive color #D84315
    static let vintageBurnt = Color(red: 216/255, green: 67/255, blue: 21/255)

    /// Pure white for cards #FFFFFF
    static let vintageWhite = Color.white
}

// MARK: - Custom Font Registration

struct VintageFonts {
    static let bebasNeue = "BebasNeue-Regular"
    static let dmSansRegular = "DMSans-Regular"
    static let dmSansMedium = "DMSans-Medium"
    static let dmSansBold = "DMSans-Bold"
    static let playfairDisplay = "PlayfairDisplay-Regular"

    /// Register custom fonts - call from App init if needed
    static func registerFonts() {
        // Fonts are registered automatically when added to the project with Info.plist entries
    }
}

// MARK: - Font Extensions

extension Font {
    /// Bebas Neue - Large titles, always UPPERCASE
    /// Size: 34pt
    static let vintageTitle: Font = .custom(VintageFonts.bebasNeue, size: 34)

    /// Bebas Neue - Headlines, always UPPERCASE
    /// Size: 28pt
    static let vintageHeadline: Font = .custom(VintageFonts.bebasNeue, size: 28)

    /// DM Sans Medium - Subheadlines
    /// Size: 17pt
    static let vintageSubheadline: Font = .custom(VintageFonts.dmSansMedium, size: 17)

    /// DM Sans Regular - Body text
    /// Size: 16pt
    static let vintageBody: Font = .custom(VintageFonts.dmSansRegular, size: 16)

    /// DM Sans Regular - Captions
    /// Size: 13pt
    static let vintageCaption: Font = .custom(VintageFonts.dmSansRegular, size: 13)

    /// DM Sans Bold - Button text
    /// Size: 17pt
    static let vintageButton: Font = .custom(VintageFonts.dmSansBold, size: 17)

    /// Playfair Display - Accent text (quotes, special callouts)
    /// Size: 20pt
    static let vintageAccent: Font = .custom(VintageFonts.playfairDisplay, size: 20)

    /// DM Sans Medium - Small labels
    /// Size: 14pt
    static let vintageLabel: Font = .custom(VintageFonts.dmSansMedium, size: 14)
}

// MARK: - View Modifiers

/// Applies vintage card styling with white background, rounded corners, no shadow
struct VintageCardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.vintageWhite)
            .cornerRadius(16)
    }
}

/// Applies vintage cream background to a view
struct VintageBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.vintageCream)
    }
}

/// Applies vintage pill button styling
struct VintagePillButtonModifier: ViewModifier {
    var backgroundColor: Color = .vintageTangerine
    var foregroundColor: Color = .white

    func body(content: Content) -> some View {
        content
            .font(.vintageButton)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(50)
    }
}

/// Applies vintage standard button styling (rounded rectangle)
struct VintageButtonModifier: ViewModifier {
    var backgroundColor: Color = .vintageTangerine
    var foregroundColor: Color = .white

    func body(content: Content) -> some View {
        content
            .font(.vintageButton)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
    }
}

/// Applies vintage section header styling
struct VintageSectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.vintageHeadline)
            .foregroundColor(.vintageCoffee)
            .textCase(.uppercase)
    }
}

/// Applies vintage tag/chip styling
struct VintageTagModifier: ViewModifier {
    var isSelected: Bool = false

    func body(content: Content) -> some View {
        content
            .font(.vintageLabel)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.vintageMarigold : Color.vintageMarigold.opacity(0.2))
            .foregroundColor(isSelected ? .vintageCoffee : .vintageMutedCocoa)
            .cornerRadius(20)
    }
}

// MARK: - View Extension Helpers

extension View {
    /// Applies vintage card styling with white background, rounded corners, no shadow
    func vintageCard(padding: CGFloat = 16) -> some View {
        modifier(VintageCardModifier(padding: padding))
    }

    /// Applies vintage cream background
    func vintageBackground() -> some View {
        modifier(VintageBackgroundModifier())
    }

    /// Applies vintage pill button styling (fully rounded ends)
    func vintagePillButton(
        backgroundColor: Color = .vintageTangerine,
        foregroundColor: Color = .white
    ) -> some View {
        modifier(VintagePillButtonModifier(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        ))
    }

    /// Applies vintage standard button styling (rounded rectangle)
    func vintageButton(
        backgroundColor: Color = .vintageTangerine,
        foregroundColor: Color = .white
    ) -> some View {
        modifier(VintageButtonModifier(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        ))
    }

    /// Applies vintage section header styling
    func vintageSectionHeader() -> some View {
        modifier(VintageSectionHeaderModifier())
    }

    /// Applies vintage tag/chip styling
    func vintageTag(isSelected: Bool = false) -> some View {
        modifier(VintageTagModifier(isSelected: isSelected))
    }
}

// MARK: - Button Styles

/// A vintage-styled button with pill shape
struct VintagePillButtonStyle: ButtonStyle {
    var backgroundColor: Color = .vintageTangerine
    var foregroundColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.vintageButton)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(configuration.isPressed ? backgroundColor.opacity(0.8) : backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(50)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// A vintage-styled button with rounded rectangle shape
struct VintageButtonStyle: ButtonStyle {
    var backgroundColor: Color = .vintageTangerine
    var foregroundColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.vintageButton)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? backgroundColor.opacity(0.8) : backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// A vintage-styled secondary/outline button
struct VintageSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.vintageButton)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color.vintageWhite)
            .foregroundColor(.vintageTangerine)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.vintageTangerine, lineWidth: 2)
            )
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == VintagePillButtonStyle {
    static var vintagePill: VintagePillButtonStyle { VintagePillButtonStyle() }

    static func vintagePill(
        backgroundColor: Color = .vintageTangerine,
        foregroundColor: Color = .white
    ) -> VintagePillButtonStyle {
        VintagePillButtonStyle(backgroundColor: backgroundColor, foregroundColor: foregroundColor)
    }
}

extension ButtonStyle where Self == VintageButtonStyle {
    static var vintage: VintageButtonStyle { VintageButtonStyle() }

    static func vintage(
        backgroundColor: Color = .vintageTangerine,
        foregroundColor: Color = .white
    ) -> VintageButtonStyle {
        VintageButtonStyle(backgroundColor: backgroundColor, foregroundColor: foregroundColor)
    }
}

extension ButtonStyle where Self == VintageSecondaryButtonStyle {
    static var vintageSecondary: VintageSecondaryButtonStyle { VintageSecondaryButtonStyle() }
}

// MARK: - Preview

#Preview("Vintage Colors") {
    ScrollView {
        VStack(spacing: 20) {
            // Colors
            Group {
                colorSwatch("Cream (Background)", color: .vintageCream)
                colorSwatch("Tangerine (Primary)", color: .vintageTangerine)
                colorSwatch("Marigold (Secondary)", color: .vintageMarigold)
                colorSwatch("Coffee (Text)", color: .vintageCoffee)
                colorSwatch("Muted Cocoa (Secondary Text)", color: .vintageMutedCocoa)
                colorSwatch("Leafy (Success)", color: .vintageLeafy)
                colorSwatch("Burnt (Destructive)", color: .vintageBurnt)
            }
        }
        .padding()
    }
    .background(Color.vintageCream)
}

#Preview("Vintage Typography") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("VINTAGE TITLE")
                .font(.vintageTitle)
                .foregroundColor(.vintageCoffee)

            Text("VINTAGE HEADLINE")
                .font(.vintageHeadline)
                .foregroundColor(.vintageCoffee)

            Text("Vintage Subheadline")
                .font(.vintageSubheadline)
                .foregroundColor(.vintageCoffee)

            Text("Vintage body text for regular content. This is how paragraphs would look in the app.")
                .font(.vintageBody)
                .foregroundColor(.vintageCoffee)

            Text("Vintage caption for small details")
                .font(.vintageCaption)
                .foregroundColor(.vintageMutedCocoa)

            Text("Button Text")
                .font(.vintageButton)
                .foregroundColor(.vintageTangerine)

            Text("Accent Style Quote")
                .font(.vintageAccent)
                .foregroundColor(.vintageCoffee)
        }
        .padding()
    }
    .background(Color.vintageCream)
}

#Preview("Vintage Components") {
    ScrollView {
        VStack(spacing: 24) {
            // Card
            VStack(alignment: .leading, spacing: 8) {
                Text("RECIPE CARD")
                    .font(.vintageHeadline)
                    .foregroundColor(.vintageCoffee)
                Text("This is how cards look with the vintage aesthetic.")
                    .font(.vintageBody)
                    .foregroundColor(.vintageMutedCocoa)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .vintageCard()

            // Buttons
            Button("Primary Button") {}
                .buttonStyle(.vintage)

            Button("Pill Button") {}
                .buttonStyle(.vintagePill)

            Button("Secondary Button") {}
                .buttonStyle(.vintageSecondary)

            // Tags
            HStack {
                Text("dinner")
                    .vintageTag(isSelected: false)
                Text("quick")
                    .vintageTag(isSelected: true)
                Text("healthy")
                    .vintageTag(isSelected: false)
            }
        }
        .padding()
    }
    .background(Color.vintageCream)
}

// Helper for color preview
private func colorSwatch(_ name: String, color: Color) -> some View {
    HStack {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(width: 60, height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.vintageCoffee.opacity(0.2), lineWidth: 1)
            )
        Text(name)
            .font(.vintageBody)
            .foregroundColor(.vintageCoffee)
        Spacer()
    }
}
