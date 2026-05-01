//
//  RecordsScreen.swift
//  SudokuLab
//
//  Created by 孙世伟 on 2026/5/1.
//

import SwiftUI

struct RecordsScreen: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label {
                    Text(AppTab.records.emptyStateTitle)
                } icon: {
                    Image(systemName: AppTab.records.systemImage)
                }
            } description: {
                Text(AppTab.records.emptyStateDescription)
            }
            .navigationTitle(Text(AppTab.records.title))
        }
    }
}

#Preview {
    RecordsScreen()
}
