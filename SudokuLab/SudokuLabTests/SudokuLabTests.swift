//
//  SudokuLabTests.swift
//  SudokuLabTests
//
//  Created by 孙世伟 on 2026/5/1.
//

import FactoryTesting
import Testing

@testable import SudokuLab

@MainActor
@Suite(.container)
struct SudokuLabTests {

    @Test func rootStoreStartsOnHomeTab() {
        let store = AppContainer.rootStore()

        #expect(store.selectedTab == .home)
    }

}
