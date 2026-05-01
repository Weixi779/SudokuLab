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
            ContentUnavailableView("Records", systemImage: "chart.bar")
                .navigationTitle("Records")
        }
    }
}

#Preview {
    RecordsScreen()
}
