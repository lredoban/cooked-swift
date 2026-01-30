import SwiftUI

// MARK: - Dopamine Scrapbook Design System
// A chaotic maximalist, anti-design style with dark mode only

// MARK: - Colors

extension Color {
    /// Deep Black #000000 - Main background
    static let dopamineBlack = Color(red: 0, green: 0, blue: 0)

    /// Grainy Dark Gray #121212 - Surface/Card background
    static let dopamineSurface = Color(red: 0.071, green: 0.071, blue: 0.071)

    /// Acid Green #CCFF00 - Primary CTAs, Success States, Checkboxes
    static let dopamineAcid = Color(red: 0.8, green: 1.0, blue: 0)

    /// Hyper-Pink #FF007F - Badges, Progress Bars, Selection Borders
    static let dopaminePink = Color(red: 1.0, green: 0, blue: 0.498)

    /// Cyber Yellow #FFF01F - Warning, Highlights, Secondary Icons
    static let dopamineYellow = Color(red: 1.0, green: 0.941, blue: 0.122)

    /// Secondary text color - Light gray
    static let dopamineSecondary = Color(white: 0.6)

    /// Tertiary text color - Darker gray
    static let dopamineTertiary = Color(white: 0.4)
}

// MARK: - Fonts

extension Font {
    /// Headers: Syne Extra Bold - For screen titles and recipe names
    static func dopamineHeader(_ size: CGFloat = 28) -> Font {
        .custom("Syne-ExtraBold", size: size)
    }

    /// Large title variant
    static var dopamineLargeTitle: Font {
        .custom("Syne-ExtraBold", size: 34)
    }

    /// Title variant
    static var dopamineTitle: Font {
        .custom("Syne-ExtraBold", size: 28)
    }

    /// Title 2 variant
    static var dopamineTitle2: Font {
        .custom("Syne-ExtraBold", size: 22)
    }

    /// Title 3 variant
    static var dopamineTitle3: Font {
        .custom("Syne-ExtraBold", size: 20)
    }

    /// Sub-headers: Space Grotesk - For section headers and button text
    static func dopamineSubheader(_ size: CGFloat = 16) -> Font {
        .custom("SpaceGrotesk-Medium", size: size)
    }

    /// Headline variant
    static var dopamineHeadline: Font {
        .custom("SpaceGrotesk-Bold", size: 17)
    }

    /// Subheadline variant
    static var dopamineSubheadline: Font {
        .custom("SpaceGrotesk-Medium", size: 15)
    }

    /// Body: Inter - For ingredients and instructions
    static func dopamineBody(_ size: CGFloat = 16) -> Font {
        .custom("Inter-Regular", size: size)
    }

    /// Body regular variant
    static var dopamineBodyRegular: Font {
        .custom("Inter-Regular", size: 16)
    }

    /// Body medium variant
    static var dopamineBodyMedium: Font {
        .custom("Inter-Medium", size: 16)
    }

    /// Caption variant
    static var dopamineCaption: Font {
        .custom("Inter-Regular", size: 12)
    }

    /// Caption 2 variant
    static var dopamineCaption2: Font {
        .custom("Inter-Medium", size: 11)
    }
}

// MARK: - View Modifiers

/// Dark card styling with subtle border and surface background
struct DopamineCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var hasBorder: Bool = true

    func body(content: Content) -> some View {
        content
            .background(Color.dopamineSurface)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(hasBorder ? 0.1 : 0), lineWidth: 1)
            )
    }
}

/// Full screen dark background
struct DopamineBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.dopamineBlack)
    }
}

/// Primary button style with Acid Green
struct DopamineButtonModifier: ViewModifier {
    var isSecondary: Bool = false

    func body(content: Content) -> some View {
        content
            .font(.dopamineHeadline)
            .foregroundColor(isSecondary ? .dopamineAcid : .black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSecondary ? Color.clear : Color.dopamineAcid)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.dopamineAcid, lineWidth: isSecondary ? 2 : 0)
            )
    }
}

/// Progress bar with Hyper-Pink
struct DopamineProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.dopamineSurface)
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.dopaminePink)
                    .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0), height: 8)
            }
        }
        .frame(height: 8)
    }
}

/// Glowing icon effect for active states
struct DopamineGlowModifier: ViewModifier {
    var color: Color = .dopamineAcid
    var isActive: Bool = true

    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color.opacity(0.6) : .clear, radius: 8)
            .shadow(color: isActive ? color.opacity(0.3) : .clear, radius: 16)
    }
}

/// Frosted glass effect for nav bar
struct DopamineFrostedGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial.opacity(0.8))
            .background(Color.dopamineBlack.opacity(0.7))
    }
}

// MARK: - View Extensions

extension View {
    /// Apply dark card styling
    func dopamineCard(cornerRadius: CGFloat = 16, hasBorder: Bool = true) -> some View {
        modifier(DopamineCardModifier(cornerRadius: cornerRadius, hasBorder: hasBorder))
    }

    /// Apply full screen dark background
    func dopamineBackground() -> some View {
        modifier(DopamineBackgroundModifier())
    }

    /// Apply primary button styling
    func dopamineButton(isSecondary: Bool = false) -> some View {
        modifier(DopamineButtonModifier(isSecondary: isSecondary))
    }

    /// Apply glowing effect
    func dopamineGlow(color: Color = .dopamineAcid, isActive: Bool = true) -> some View {
        modifier(DopamineGlowModifier(color: color, isActive: isActive))
    }

    /// Apply frosted glass effect
    func dopamineFrostedGlass() -> some View {
        modifier(DopamineFrostedGlassModifier())
    }
}

// MARK: - Button Styles

/// Primary button style with Acid Green background
struct DopaminePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dopamineHeadline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.dopamineAcid)
            .cornerRadius(24)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Secondary button style with Acid Green border
struct DopamineSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dopamineHeadline)
            .foregroundColor(.dopamineAcid)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.clear)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.dopamineAcid, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Ghost button style with subtle styling
struct DopamineGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dopamineSubheadline)
            .foregroundColor(.dopamineSecondary)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

// MARK: - Toggle Styles

/// Checkbox style using Acid Green
struct DopamineCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(configuration.isOn ? Color.dopamineAcid : Color.dopamineSecondary)
                .dopamineGlow(color: .dopamineAcid, isActive: configuration.isOn)
        }
        .buttonStyle(.plain)
    }
}
