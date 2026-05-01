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
            ContentUnavailableView {
                Label {
                    Text(AppTab.game.emptyStateTitle)
                } icon: {
                    Image(systemName: AppTab.game.systemImage)
                }
            } description: {
                Text(AppTab.game.emptyStateDescription)
            }
            .navigationTitle(Text(AppTab.game.title))
        }
    }
}

#Preview {
    GameScreen()
}
