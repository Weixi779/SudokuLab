import SwiftUI
import Testing

@testable import SudokuLab

@MainActor
struct ThemeProviderTests {
    @Test func systemModeResolvesFromContextColorScheme() {
        let provider = DefaultThemeProvider(mode: .system)

        #expect(provider.preferredColorScheme == nil)
        #expect(
            provider.theme(for: AppThemeContext(systemColorScheme: .light)).colorScheme == .light)
        #expect(provider.theme(for: AppThemeContext(systemColorScheme: .dark)).colorScheme == .dark)
    }

    @Test func explicitModesOverrideContextColorScheme() {
        let lightProvider = DefaultThemeProvider(mode: .light)
        let darkProvider = DefaultThemeProvider(mode: .dark)

        #expect(lightProvider.preferredColorScheme == .light)
        #expect(
            lightProvider.theme(for: AppThemeContext(systemColorScheme: .dark)).colorScheme
                == .light)

        #expect(darkProvider.preferredColorScheme == .dark)
        #expect(
            darkProvider.theme(for: AppThemeContext(systemColorScheme: .light)).colorScheme == .dark
        )
    }
}
