//
//  Container+App.swift
//  SudokuLab
//
//  Created by 孙世伟 on 2026/5/1.
//

import FactoryKit

enum AppContainer {
    @MainActor
    static func rootStore() -> RootStore {
        Container.shared.rootStore()
    }
}

extension Container {
    @MainActor
    var rootStore: Factory<RootStore> {
        self { RootStore() }
    }
}
