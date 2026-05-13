import SwiftUI

@main
struct SudokuLabApp: App {
    @Environment(\.colorScheme) private var colorScheme
    @State private var themeProvider = AppContainer.themeProvider()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(
                    \.appTheme,
                    themeProvider.theme(
                        for: AppThemeContext(systemColorScheme: colorScheme)
                    )
                )
                .environment(\.themeProvider, themeProvider)
                .preferredColorScheme(themeProvider.preferredColorScheme)
        }
    }
}
