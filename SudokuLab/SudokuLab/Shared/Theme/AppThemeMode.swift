import SwiftUI

enum AppThemeMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: Self { self }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }

    func resolvedColorScheme(systemColorScheme: ColorScheme) -> ColorScheme {
        preferredColorScheme ?? systemColorScheme
    }
}
