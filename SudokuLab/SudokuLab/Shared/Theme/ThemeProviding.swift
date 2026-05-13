import SwiftUI

@MainActor
protocol ThemeProviding: AnyObject {
    var mode: AppThemeMode { get set }
    var preferredColorScheme: ColorScheme? { get }

    func theme(for context: AppThemeContext) -> AppTheme
}
