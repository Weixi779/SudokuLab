import Observation
import SwiftUI

@Observable
final class DefaultThemeProvider: ThemeProviding {
    var mode: AppThemeMode

    init(mode: AppThemeMode = .system) {
        self.mode = mode
    }

    var preferredColorScheme: ColorScheme? {
        mode.preferredColorScheme
    }

    func theme(for context: AppThemeContext) -> AppTheme {
        let resolvedColorScheme = mode.resolvedColorScheme(
            systemColorScheme: context.systemColorScheme
        )

        return AppTheme(
            mode: mode,
            colorScheme: resolvedColorScheme,
            colors: .palette(for: resolvedColorScheme)
        )
    }
}
