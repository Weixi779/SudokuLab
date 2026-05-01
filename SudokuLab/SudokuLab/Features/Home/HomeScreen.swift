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
            ContentUnavailableView("Home", systemImage: "house")
                .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeScreen()
}
