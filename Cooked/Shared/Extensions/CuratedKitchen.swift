import SwiftUI

// MARK: - The Curated Kitchen Design System
// A warm, editorial "Kinfolk magazine" aesthetic
// Philosophy: "A digital sanctuary" - Kinfolk magazine for utility

// MARK: - Color Extensions

extension Color {
    /// Initialize Color from hex string (without #)
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

// MARK: - Curated Kitchen Colors

extension Color {
    /// Primary CTA color - Warm terracotta
    static let curatedTerracotta = Color(hex: "E07A5F")

    /// Secondary/Success color - Sage green
    static let curatedSage = Color(hex: "8DA399")

    /// Background canvas - Warm oatmeal
    static let curatedOatmeal = Color(hex: "F9F8F4")

    /// Card background - Pure white
    static let curatedWhite = Color(hex: "FFFFFF")

    /// Track color for progress bars - Light beige
    static let curatedBeige = Color(hex: "EBE9E4")

    /// Primary text - Charcoal
    static let curatedCharcoal = Color(hex: "2D2D2D")

    /// Secondary text - Warm grey
    static let curatedWarmGrey = Color(hex: "666666")
}

// MARK: - Curated Kitchen Fonts

extension Font {
    /// Serif font for headers and display text - Playfair Display style
    /// Using system serif as fallback since custom fonts need to be bundled
    static func curatedSerif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// Sans-serif font for body and UI text - Lato style
    /// Using system default with rounded design for warmth
    static func curatedSans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    // Preset sizes
    static let curatedLargeTitle = curatedSerif(size: 34, weight: .bold)
    static let curatedTitle = curatedSerif(size: 28, weight: .bold)
    static let curatedTitle2 = curatedSerif(size: 22, weight: .semibold)
    static let curatedTitle3 = curatedSerif(size: 20, weight: .semibold)
    static let curatedHeadline = curatedSerif(size: 17, weight: .semibold)
    static let curatedSubheadline = curatedSans(size: 15, weight: .regular)
    static let curatedBody = curatedSans(size: 17, weight: .regular)
    static let curatedCallout = curatedSans(size: 16, weight: .regular)
    static let curatedCaption = curatedSans(size: 12, weight: .regular)
    static let curatedCaption2 = curatedSans(size: 11, weight: .regular)
}

// MARK: - View Modifiers

/// Card style with warm shadow and white background
struct CuratedCardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.curatedWhite)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

/// Primary button style - Pill shape with terracotta background
struct CuratedButtonModifier: ViewModifier {
    var isDisabled: Bool = false

    func body(content: Content) -> some View {
        content
            .font(.curatedSans(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(isDisabled ? Color.curatedTerracotta.opacity(0.5) : Color.curatedTerracotta)
            .cornerRadius(24)
    }
}

/// Secondary button style - Ghost/outline with terracotta border
struct CuratedSecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.curatedSans(size: 17, weight: .medium))
            .foregroundColor(.curatedTerracotta)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.curatedTerracotta, lineWidth: 1.5)
            )
    }
}

/// Oatmeal background modifier
struct CuratedBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.curatedOatmeal.ignoresSafeArea())
    }
}

// MARK: - View Extensions

extension View {
    /// Apply curated card style with white background and warm shadow
    func curatedCard(padding: CGFloat = 16) -> some View {
        modifier(CuratedCardModifier(padding: padding))
    }

    /// Apply curated primary button style
    func curatedButton(isDisabled: Bool = false) -> some View {
        modifier(CuratedButtonModifier(isDisabled: isDisabled))
    }

    /// Apply curated secondary button style
    func curatedSecondaryButton() -> some View {
        modifier(CuratedSecondaryButtonModifier())
    }

    /// Apply oatmeal background
    func curatedBackground() -> some View {
        modifier(CuratedBackgroundModifier())
    }
}

// MARK: - Custom Components

/// Progress bar with sage green fill and beige track
struct CuratedProgressBar: View {
    let value: Double
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.curatedBeige)
                    .frame(height: height)

                // Fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.curatedSage)
                    .frame(width: max(0, geometry.size.width * value), height: height)
                    .animation(.easeInOut(duration: 0.3), value: value)
            }
        }
        .frame(height: height)
    }
}

/// Checkbox with sage green checked state
struct CuratedCheckbox: View {
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isChecked ? Color.curatedSage : Color.curatedWarmGrey)
        }
        .buttonStyle(.plain)
    }
}

/// Chip component for tags with sage green outline
struct CuratedChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.curatedSans(size: 14, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.curatedSage : Color.clear)
                .foregroundStyle(isSelected ? .white : Color.curatedSage)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.curatedSage, lineWidth: 1.5)
                )
                .cornerRadius(24)
        }
        .buttonStyle(.plain)
    }
}

/// Badge component with sage green outline
struct CuratedBadge: View {
    let text: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(text)
                .font(.curatedSans(size: 12, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.clear)
        .foregroundStyle(Color.curatedSage)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.curatedSage, lineWidth: 1)
        )
        .cornerRadius(24)
    }
}

/// Terracotta spinner for loading states
struct CuratedSpinner: View {
    @State private var isAnimating = false
    var size: CGFloat = 40

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                Color.curatedTerracotta,
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                .linear(duration: 1)
                .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

/// Staple chip for grocery list with curated styling
struct CuratedStapleChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                }
                Text(text.capitalized)
                    .font(.curatedSans(size: 14, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.curatedSage : Color.clear)
            .foregroundStyle(isSelected ? .white : Color.curatedCharcoal)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? Color.curatedSage : Color.curatedBeige, lineWidth: 1.5)
            )
            .cornerRadius(24)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Curated Kitchen Components") {
    ScrollView {
        VStack(spacing: 24) {
            // Colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Colors")
                    .font(.curatedTitle2)

                HStack(spacing: 12) {
                    colorSwatch("Terracotta", color: .curatedTerracotta)
                    colorSwatch("Sage", color: .curatedSage)
                    colorSwatch("Oatmeal", color: .curatedOatmeal)
                    colorSwatch("Charcoal", color: .curatedCharcoal)
                }
            }

            Divider()

            // Typography
            VStack(alignment: .leading, spacing: 8) {
                Text("Typography")
                    .font(.curatedTitle2)

                Text("Serif Title")
                    .font(.curatedTitle)
                Text("Body Sans")
                    .font(.curatedBody)
                Text("Caption")
                    .font(.curatedCaption)
                    .foregroundStyle(Color.curatedWarmGrey)
            }

            Divider()

            // Buttons
            VStack(alignment: .leading, spacing: 12) {
                Text("Buttons")
                    .font(.curatedTitle2)

                Button {} label: {
                    Text("Primary Button")
                }
                .curatedButton()

                Button {} label: {
                    Text("Secondary Button")
                }
                .curatedSecondaryButton()
            }

            Divider()

            // Components
            VStack(alignment: .leading, spacing: 12) {
                Text("Components")
                    .font(.curatedTitle2)

                CuratedProgressBar(value: 0.65)
                    .frame(width: 200)

                HStack {
                    CuratedCheckbox(isChecked: false, action: {})
                    CuratedCheckbox(isChecked: true, action: {})
                }

                HStack {
                    CuratedChip(text: "dinner", isSelected: false, action: {})
                    CuratedChip(text: "quick", isSelected: true, action: {})
                }

                CuratedBadge(text: "Ready", icon: "checkmark.circle.fill")

                CuratedSpinner()
            }

            Divider()

            // Card
            VStack(alignment: .leading) {
                Text("Card Component")
                    .font(.curatedTitle2)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Recipe Title")
                        .font(.curatedHeadline)
                    Text("From TikTok")
                        .font(.curatedCaption)
                        .foregroundStyle(Color.curatedWarmGrey)
                        .textCase(.uppercase)
                }
                .curatedCard()
            }
        }
        .padding()
    }
    .curatedBackground()
}

@ViewBuilder
private func colorSwatch(_ name: String, color: Color) -> some View {
    VStack {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(width: 60, height: 60)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.curatedCharcoal.opacity(0.1), lineWidth: 1)
            )
        Text(name)
            .font(.curatedCaption)
    }
}
