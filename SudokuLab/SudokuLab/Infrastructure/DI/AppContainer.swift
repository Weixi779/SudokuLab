import FactoryKit

enum AppContainer {
    @MainActor
    static func rootStore() -> RootStore {
        Container.shared.rootStore()
    }

    @MainActor
    static func themeProvider() -> any ThemeProviding {
        Container.shared.themeProvider()
    }
}
