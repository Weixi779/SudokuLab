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
            ContentUnavailableView("Settings", systemImage: "gearshape")
                .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsScreen()
}
