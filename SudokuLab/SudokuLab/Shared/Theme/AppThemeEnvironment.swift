import SwiftUI

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme(
        mode: .system,
        colorScheme: .light,
        colors: .light
    )
}

private struct ThemeProviderKey: EnvironmentKey {
    static let defaultValue: (any ThemeProviding)? = nil
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }

    var themeProvider: (any ThemeProviding)? {
        get { self[ThemeProviderKey.self] }
        set { self[ThemeProviderKey.self] = newValue }
    }
}
