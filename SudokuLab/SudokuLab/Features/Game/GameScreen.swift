//
//  GameScreen.swift
//  SudokuLab
//
//  Created by 孙世伟 on 2026/5/1.
//

import SwiftUI

struct GameScreen: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Game", systemImage: "square.grid.3x3")
                .navigationTitle("Game")
        }
    }
}

#Preview {
    GameScreen()
}
