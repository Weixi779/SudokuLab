import SwiftUI

struct AppThemeColors {
    let backgroundPrimary: Color
    let backgroundSecondary: Color
    let surfacePrimary: Color
    let surfaceElevated: Color
    let textPrimary: Color
    let textSecondary: Color
    let accentPrimary: Color
    let accentSecondary: Color
    let borderPrimary: Color
    let borderSecondary: Color
    let feedbackDestructive: Color

    static func palette(for colorScheme: ColorScheme) -> Self {
        switch colorScheme {
        case .dark:
            dark
        default:
            light
        }
    }

    static let light = AppThemeColors(
        backgroundPrimary: hex(0xF8FAFC),
        backgroundSecondary: hex(0xF1F5F9),
        surfacePrimary: hex(0xFFFFFF),
        surfaceElevated: hex(0xFFFFFF),
        textPrimary: hex(0x0F172A),
        textSecondary: hex(0x475569),
        accentPrimary: hex(0x2563EB),
        accentSecondary: hex(0xDBEAFE),
        borderPrimary: hex(0xCBD5E1),
        borderSecondary: hex(0xE2E8F0),
        feedbackDestructive: hex(0xDC2626)
    )

    static let dark = AppThemeColors(
        backgroundPrimary: hex(0x0C121C),
        backgroundSecondary: hex(0x121A26),
        surfacePrimary: hex(0x182230),
        surfaceElevated: hex(0x1F2A3A),
        textPrimary: hex(0xF1F5F9),
        textSecondary: hex(0x94A3B8),
        accentPrimary: hex(0x60A5FA),
        accentSecondary: hex(0x1E3A5F),
        borderPrimary: hex(0x475569),
        borderSecondary: hex(0x334155),
        feedbackDestructive: hex(0xF87171)
    )

    private static func hex(
        _ value: UInt32,
        opacity: Double = 1
    ) -> Color {
        let red = Double((value & 0xFF0000) >> 16) / 255
        let green = Double((value & 0x00FF00) >> 8) / 255
        let blue = Double(value & 0x0000FF) / 255

        return Color(
            .sRGB,
            red: red,
            green: green,
            blue: blue,
            opacity: opacity
        )
    }
}
