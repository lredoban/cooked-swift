import SwiftUI

// MARK: - Spatial Glass Design System
// "The Culinary Operating System" - Immersive dark theme with frosted glass effects

// MARK: - Color Extensions

extension Color {
    // MARK: Glass Colors

    /// Near-black background (#0A0A0A)
    static let glassBackground = Color(hex: "0A0A0A")

    /// Secondary dark background (#151515)
    static let glassBackgroundSecondary = Color(hex: "151515")

    /// Glass surface with 8% white
    static let glassSurface = Color.white.opacity(0.08)

    /// Glass border with 15% white
    static let glassBorder = Color.white.opacity(0.15)

    /// Primary text - pure white
    static let glassTextPrimary = Color.white

    /// Secondary text - 65% white
    static let glassTextSecondary = Color.white.opacity(0.65)

    /// Tertiary text - 40% white
    static let glassTextTertiary = Color.white.opacity(0.40)

    // MARK: Accent Colors

    /// Holographic orange start (#FF9966)
    static let accentOrangeStart = Color(hex: "FF9966")

    /// Holographic orange end (#FF5E62)
    static let accentOrangeEnd = Color(hex: "FF5E62")

    /// Neon green for progress/success
    static let neonGreen = Color(hex: "00FF88")

    /// Neon green dimmed
    static let neonGreenDimmed = Color(hex: "00FF88").opacity(0.3)

    // MARK: Initializer from Hex

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
            (a, r, g, b) = (255, 0, 0, 0)
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

// MARK: - Gradient Extensions

extension LinearGradient {
    /// Holographic orange gradient for primary accents
    static let holographicOrange = LinearGradient(
        colors: [Color.accentOrangeStart, Color.accentOrangeEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Dark background gradient
    static let darkBackground = LinearGradient(
        colors: [Color.glassBackground, Color.glassBackgroundSecondary],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Frosted overlay gradient for cards (bottom to top)
    static let frostedOverlay = LinearGradient(
        colors: [Color.black.opacity(0.8), Color.black.opacity(0.3), Color.clear],
        startPoint: .bottom,
        endPoint: .top
    )

    /// Neon green gradient for progress
    static let neonProgress = LinearGradient(
        colors: [Color(hex: "00FF88"), Color(hex: "00CC66")],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Font Extensions

extension Font {
    // MARK: Display / Headers - Plus Jakarta Sans style (using system bold wide)

    static func glassDisplay(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }

    static func glassTitle(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }

    static func glassHeadline(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }

    // MARK: Body - Space Grotesk style (using system rounded)

    static func glassBody(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    static func glassBodyMedium(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    // MARK: Monospace / Technical - Space Mono style

    static func glassMono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }

    static func glassMonoMedium(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }

    // MARK: Captions

    static func glassCaption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
}

// MARK: - View Modifiers

/// Adds a glass background with blur effect
struct GlassBackgroundModifier: ViewModifier {
    var cornerRadius: CGFloat = 24
    var showBorder: Bool = true

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.glassSurface)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(showBorder ? Color.glassBorder : Color.clear, lineWidth: 1)
            )
    }
}

/// Adds an ambient glow shadow effect
struct GlowShadowModifier: ViewModifier {
    var color: Color = .black
    var radius: CGFloat = 40
    var y: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius, x: 0, y: y)
    }
}

/// Makes a card appear as floating glass panel
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.glassSurface)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.5), radius: 40, x: 0, y: 10)
    }
}

/// Luminous glass button style with inner bevel
struct GlassButtonModifier: ViewModifier {
    var isSmall: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, isSmall ? 16 : 24)
            .padding(.vertical, isSmall ? 10 : 16)
            .background(
                ZStack {
                    // Outer gradient
                    RoundedRectangle(cornerRadius: isSmall ? 12 : 16, style: .continuous)
                        .fill(LinearGradient.holographicOrange)

                    // Inner highlight for bevel effect
                    RoundedRectangle(cornerRadius: isSmall ? 12 : 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .padding(1)
                }
            )
            .foregroundColor(.white)
            .shadow(color: Color.accentOrangeEnd.opacity(0.4), radius: 16, x: 0, y: 8)
    }
}

/// Secondary glass button style (outline)
struct GlassButtonSecondaryModifier: ViewModifier {
    var isSmall: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, isSmall ? 16 : 24)
            .padding(.vertical, isSmall ? 10 : 16)
            .background(
                RoundedRectangle(cornerRadius: isSmall ? 12 : 16, style: .continuous)
                    .fill(Color.glassSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: isSmall ? 12 : 16, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
            .foregroundColor(.glassTextPrimary)
    }
}

/// Glowing border effect
struct GlowBorderModifier: ViewModifier {
    var color: Color = .accentOrangeStart
    var cornerRadius: CGFloat = 24
    var lineWidth: CGFloat = 2
    var glowRadius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(color, lineWidth: lineWidth)
                    .blur(radius: glowRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(color, lineWidth: lineWidth)
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Applies glass background effect
    func glassBackground(cornerRadius: CGFloat = 24, showBorder: Bool = true) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius, showBorder: showBorder))
    }

    /// Applies glass card effect with shadow
    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }

    /// Applies primary glass button styling
    func glassButton(small: Bool = false) -> some View {
        modifier(GlassButtonModifier(isSmall: small))
    }

    /// Applies secondary glass button styling
    func glassButtonSecondary(small: Bool = false) -> some View {
        modifier(GlassButtonSecondaryModifier(isSmall: small))
    }

    /// Applies glowing border effect
    func glowBorder(color: Color = .accentOrangeStart, cornerRadius: CGFloat = 24, lineWidth: CGFloat = 2, glowRadius: CGFloat = 8) -> some View {
        modifier(GlowBorderModifier(color: color, cornerRadius: cornerRadius, lineWidth: lineWidth, glowRadius: glowRadius))
    }

    /// Applies ambient glow shadow
    func glowShadow(color: Color = .black, radius: CGFloat = 40, y: CGFloat = 10) -> some View {
        modifier(GlowShadowModifier(color: color, radius: radius, y: y))
    }

    /// Applies dark spatial background
    func spatialBackground() -> some View {
        self
            .background(LinearGradient.darkBackground.ignoresSafeArea())
    }
}

// MARK: - Reusable Components

/// Glass-styled progress bar with neon glow
struct GlassProgressBar: View {
    let value: Double
    var tint: Color = .neonGreen
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.glassSurface)

                // Fill with glow
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * CGFloat(value)))
                    .shadow(color: tint.opacity(0.6), radius: 8, x: 0, y: 0)
            }
        }
        .frame(height: height)
    }
}

/// Glass-styled checkbox with opacity dimming
struct GlassCheckbox: View {
    let isChecked: Bool
    let action: () -> Void
    var size: CGFloat = 28

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isChecked ? Color.neonGreen : Color.glassSurface)
                    .frame(width: size, height: size)

                if !isChecked {
                    Circle()
                        .stroke(Color.glassBorder, lineWidth: 2)
                        .frame(width: size, height: size)
                }

                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.5, weight: .bold))
                        .foregroundColor(.glassBackground)
                }
            }
            .shadow(color: isChecked ? Color.neonGreen.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }
}

/// Glass-styled category header
struct GlassCategoryHeader: View {
    let icon: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.glassBody())
                .foregroundColor(.glassTextSecondary)

            Text(title)
                .font(.glassHeadline())
                .foregroundColor(.glassTextPrimary)

            if let subtitle = subtitle {
                Spacer()
                Text(subtitle)
                    .font(.glassMono(12))
                    .foregroundColor(.glassTextTertiary)
            }
        }
    }
}

/// Glass-styled tab bar item
struct GlassTabItem: View {
    let icon: String
    let label: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: isSelected ? icon + ".fill" : icon)
                .font(.system(size: 22))
                .foregroundStyle(
                    isSelected ? AnyShapeStyle(LinearGradient.holographicOrange) : AnyShapeStyle(Color.glassTextSecondary)
                )

            Text(label)
                .font(.glassCaption(10))
                .foregroundColor(isSelected ? .glassTextPrimary : .glassTextSecondary)
        }
    }
}

/// Glass chip/tag component
struct GlassChip: View {
    let text: String
    var isSelected: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    chipContent
                }
                .buttonStyle(.plain)
            } else {
                chipContent
            }
        }
    }

    private var chipContent: some View {
        Text(text)
            .font(.glassCaption(13))
            .foregroundColor(isSelected ? .white : .glassTextSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? AnyShapeStyle(LinearGradient.holographicOrange) : AnyShapeStyle(Color.glassSurface))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.glassBorder, lineWidth: 1)
            )
    }
}

/// Glowing spinner for loading states
struct GlassLoadingSpinner: View {
    @State private var isAnimating = false
    var size: CGFloat = 40
    var lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.glassSurface, lineWidth: lineWidth)

            // Animated gradient arc
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(
                    LinearGradient.holographicOrange,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .shadow(color: Color.accentOrangeStart.opacity(0.5), radius: 8, x: 0, y: 0)
        }
        .frame(width: size, height: size)
        .onAppear {
            isAnimating = true
        }
    }
}

/// Frosted card overlay for recipe images
struct FrostedImageCard<Content: View>: View {
    let imageUrl: String?
    let height: CGFloat
    let content: () -> Content

    init(imageUrl: String?, height: CGFloat = 180, @ViewBuilder content: @escaping () -> Content) {
        self.imageUrl = imageUrl
        self.height = height
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Image
            AsyncImageView(url: imageUrl)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .clipped()

            // Frosted gradient overlay
            LinearGradient.frostedOverlay
                .frame(height: height * 0.6)
                .frame(maxWidth: .infinity, alignment: .bottom)

            // Content at bottom
            content()
                .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Preview

#Preview("Glass Components") {
    ScrollView {
        VStack(spacing: 32) {
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                Text("Progress Bar")
                    .font(.glassHeadline())
                    .foregroundColor(.glassTextPrimary)
                GlassProgressBar(value: 0.65)
            }

            // Checkbox
            HStack(spacing: 24) {
                GlassCheckbox(isChecked: false, action: {})
                GlassCheckbox(isChecked: true, action: {})
            }

            // Category Header
            GlassCategoryHeader(icon: "carrot.fill", title: "Produce", subtitle: "3 items")

            // Chips
            HStack(spacing: 8) {
                GlassChip(text: "dinner", isSelected: false)
                GlassChip(text: "quick", isSelected: true)
                GlassChip(text: "vegetarian", isSelected: false)
            }

            // Buttons
            VStack(spacing: 16) {
                Text("Add Recipe")
                    .font(.glassHeadline())
                    .glassButton()

                Text("Cancel")
                    .font(.glassBody())
                    .glassButtonSecondary()
            }

            // Loading Spinner
            GlassLoadingSpinner()
        }
        .padding(24)
    }
    .spatialBackground()
}
