import SwiftUI

// MARK: - Bold Swiss Design System

/// Bold Swiss color palette - Swiss International Style
enum BoldSwiss {
    /// Primary black - text, borders, primary CTAs
    static let black = Color(hex: "000000")
    /// Pure white - stark, clinical background
    static let white = Color(hex: "FFFFFF")
    /// Swiss red - errors and active notification dots ONLY
    static let accent = Color(hex: "FF3300")
    /// Dimmed content opacity
    static let dimmedOpacity: Double = 0.3
}

// MARK: - Color Extension for Hex Support

extension Color {
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

// MARK: - Bold Swiss Typography

extension Font {
    /// Large display header - MASSIVE, for hero sections
    /// Use: Empty states, main headlines
    static func swissDisplay(_ size: CGFloat = 48) -> Font {
        .system(size: size, weight: .black, design: .default)
    }

    /// Section header - Bold, uppercase style
    /// Use: Section titles, card titles
    static func swissHeader(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .black, design: .default)
    }

    /// Body text - Clean, readable
    /// Use: Descriptions, ingredient lists
    static func swissBody(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    /// Caption text - Small, secondary info
    /// Use: Source labels, metadata
    static func swissCaption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    /// Monospaced - For counts and technical text
    static func swissMono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }

    /// Large step numbers for recipe instructions
    static func swissStepNumber(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .black, design: .default)
    }
}

// MARK: - Bold Swiss View Modifiers

extension View {
    /// Apply uppercase with tight letter spacing for headers
    func swissUppercase() -> some View {
        self.textCase(.uppercase)
            .tracking(1.5)
    }

    /// Standard 1px black border
    func swissBorder(color: Color = BoldSwiss.black, width: CGFloat = 1) -> some View {
        self.overlay(
            Rectangle()
                .stroke(color, lineWidth: width)
        )
    }

    /// Sharp corners (removes any corner radius)
    func swissClip() -> some View {
        self.clipShape(Rectangle())
    }

    /// Inverted style - white text on black background
    func swissInverted() -> some View {
        self.padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(BoldSwiss.black)
            .foregroundStyle(BoldSwiss.white)
    }

    /// Primary CTA button style
    func swissPrimaryButton() -> some View {
        self.font(.swissBody(16))
            .fontWeight(.bold)
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(BoldSwiss.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(BoldSwiss.black)
            .clipShape(Rectangle())
    }

    /// Secondary button style
    func swissSecondaryButton() -> some View {
        self.font(.swissBody(16))
            .fontWeight(.medium)
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(BoldSwiss.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(BoldSwiss.white)
            .swissBorder()
    }

    /// Section header bar - inverted style
    func swissSectionHeader() -> some View {
        self.font(.swissCaption(12))
            .fontWeight(.bold)
            .textCase(.uppercase)
            .tracking(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(BoldSwiss.black)
            .foregroundStyle(BoldSwiss.white)
    }
}

// MARK: - Bold Swiss Progress Bar

struct SwissProgressBar: View {
    let value: Double
    let total: Double

    private var progress: Double {
        guard total > 0 else { return 0 }
        return min(value / total, 1.0)
    }

    private var percentage: Int {
        Int(progress * 100)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Large percentage number
            Text("\(percentage)%")
                .font(.swissDisplay(36))
                .fontWeight(.black)
                .foregroundStyle(BoldSwiss.black)
                .monospacedDigit()

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.clear)
                        .swissBorder()

                    // Fill
                    Rectangle()
                        .fill(BoldSwiss.black)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 24)
        }
    }
}

// MARK: - Bold Swiss Checkbox

struct SwissCheckbox: View {
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(isChecked ? BoldSwiss.black : BoldSwiss.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Rectangle()
                            .stroke(BoldSwiss.black, lineWidth: 2)
                    )

                if isChecked {
                    // Solid X mark
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(BoldSwiss.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bold Swiss Status Badge

struct SwissStatusBadge: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.swissCaption(10))
            .fontWeight(.bold)
            .tracking(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(BoldSwiss.black)
            .foregroundStyle(BoldSwiss.white)
            .clipShape(Rectangle())
    }
}

// MARK: - Bold Swiss Divider

struct SwissDivider: View {
    var thickness: CGFloat = 1

    var body: some View {
        Rectangle()
            .fill(BoldSwiss.black)
            .frame(height: thickness)
    }
}

// MARK: - Preview

#Preview("Bold Swiss Components") {
    ScrollView {
        VStack(spacing: 32) {
            // Typography
            VStack(alignment: .leading, spacing: 8) {
                Text("TYPOGRAPHY")
                    .swissSectionHeader()

                Text("DISPLAY HEADER")
                    .font(.swissDisplay(36))
                    .swissUppercase()

                Text("SECTION HEADER")
                    .font(.swissHeader())
                    .swissUppercase()

                Text("Body text for descriptions")
                    .font(.swissBody())

                Text("Caption text")
                    .font(.swissCaption())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            SwissDivider(thickness: 2)

            // Buttons
            VStack(spacing: 16) {
                Text("BUTTONS")
                    .swissSectionHeader()

                Button {} label: {
                    Text("PRIMARY ACTION")
                        .swissPrimaryButton()
                }
                .buttonStyle(.plain)
                .padding(.horizontal)

                Button {} label: {
                    Text("SECONDARY ACTION")
                        .swissSecondaryButton()
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }

            SwissDivider(thickness: 2)

            // Progress Bar
            VStack(alignment: .leading, spacing: 16) {
                Text("PROGRESS")
                    .swissSectionHeader()

                SwissProgressBar(value: 3, total: 5)
                    .padding(.horizontal)
            }

            SwissDivider(thickness: 2)

            // Checkboxes
            VStack(alignment: .leading, spacing: 16) {
                Text("CHECKBOXES")
                    .swissSectionHeader()

                HStack(spacing: 24) {
                    SwissCheckbox(isChecked: false) {}
                    SwissCheckbox(isChecked: true) {}
                }
                .padding(.horizontal)
            }

            SwissDivider(thickness: 2)

            // Badge
            VStack(alignment: .leading, spacing: 16) {
                Text("STATUS BADGE")
                    .swissSectionHeader()

                SwissStatusBadge(text: "Importing")
                    .padding(.horizontal)
            }
        }
    }
    .background(BoldSwiss.white)
}
