//
//  SettingsScreen.swift
//  SudokuLab
//
//  Created by 孙世伟 on 2026/5/1.
//

import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label {
                    Text(AppTab.settings.emptyStateTitle)
                } icon: {
                    Image(systemName: AppTab.settings.systemImage)
                }
            } description: {
                Text(AppTab.settings.emptyStateDescription)
            }
            .navigationTitle(Text(AppTab.settings.title))
        }
    }
}

#Preview {
    SettingsScreen()
}
