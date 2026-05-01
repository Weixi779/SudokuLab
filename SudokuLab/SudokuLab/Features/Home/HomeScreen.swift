//
//  HomeScreen.swift
//  SudokuLab
//
//  Created by 孙世伟 on 2026/5/1.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label {
                    Text(AppTab.home.emptyStateTitle)
                } icon: {
                    Image(systemName: AppTab.home.systemImage)
                }
            } description: {
                Text(AppTab.home.emptyStateDescription)
            }
            .navigationTitle(Text(AppTab.home.title))
        }
    }
}

#Preview {
    HomeScreen()
}
