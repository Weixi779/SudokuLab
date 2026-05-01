//
//  AppTab.swift
//  SudokuLab
//
//  Created by 孙世伟 on 2026/5/1.
//

import Foundation

enum AppTab: CaseIterable, Identifiable, Hashable {
    case home
    case game
    case records
    case settings

    var id: Self { self }

    var title: String {
        switch self {
        case .home:
            "Home"
        case .game:
            "Game"
        case .records:
            "Records"
        case .settings:
            "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            "house"
        case .game:
            "square.grid.3x3"
        case .records:
            "chart.bar"
        case .settings:
            "gearshape"
        }
    }
}
