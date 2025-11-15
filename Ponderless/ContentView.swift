//
//  ContentView.swift
//  Ponderless
//
//  Created by Pious Alpha on 11/11/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()

    var body: some View {
        MainTabView()
            .environment(appState)
            .background(DesignSystem.Colors.background)
            .preferredColorScheme(appState.preferredColorScheme)
            .task {
                // Initialize cached data after view appears
                await appState.startup()
            }
    }
}

#Preview {
    ContentView()
}

