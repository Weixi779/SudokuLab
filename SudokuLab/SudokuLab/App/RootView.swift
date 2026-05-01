//
//  RootView.swift
//  SudokuLab
//
//  Created by 孙世伟 on 2026/5/1.
//

import SwiftUI

struct RootView: View {
    @State private var store: RootStore

    init() {
        _store = State(initialValue: AppContainer.rootStore())
    }

    init(store: RootStore) {
        _store = State(initialValue: store)
    }

    var body: some View {
        @Bindable var store = store

        TabView(selection: $store.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                Tab(value: tab) {
                    screen(for: tab)
                } label: {
                    Label {
                        Text(tab.title)
                    } icon: {
                        Image(systemName: tab.systemImage)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func screen(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeScreen()
        case .game:
            GameScreen()
        case .records:
            RecordsScreen()
        case .settings:
            SettingsScreen()
        }
    }
}

#Preview {
    RootView(store: RootStore())
}
