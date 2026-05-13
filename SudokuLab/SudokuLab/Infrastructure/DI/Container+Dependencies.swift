import FactoryKit

extension Container {
    
    @MainActor
    var rootStore: Factory<RootStore> {
        self { RootStore() }
    }
    
    @MainActor
    var themeProvider: Factory<any ThemeProviding> {
        self { DefaultThemeProvider() }
            .singleton
    }
}
