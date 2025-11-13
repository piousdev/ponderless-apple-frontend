//
//  ForYouView.swift
//  Ponderless
//
//  For You tab - Daily tracker and calibration analytics
//  Refactored for better maintainability and performance
//

import SwiftUI

struct ForYouView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.xxxxl) {
                    // Daily Todos Section
                    DailyTodosSection(
                        progressProvider: appState,
                        todoRepository: DefaultTodoRepository()
                    )
                    .padding(.horizontal)

                    // Track Your Judgment Section
                    TrackYourJudgmentSection(
                        calculator: DefaultCalibrationCalculator(appState: appState)
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Overview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("Default") {
    ForYouView()
        .environment(AppState())
}

#Preview("With Data") {
    let appState = AppState()
    appState.trainingProgress.dailyStreak = 7
    appState.trainingProgress.totalStars = 150

    return ForYouView()
        .environment(appState)
}

#Preview("High Streak") {
    let appState = AppState()
    appState.trainingProgress.dailyStreak = 30
    appState.trainingProgress.totalStars = 500

    return ForYouView()
        .environment(appState)
}

#Preview("New User") {
    let appState = AppState()
    appState.trainingProgress.dailyStreak = 1
    appState.trainingProgress.totalStars = 10

    return ForYouView()
        .environment(appState)
}

#Preview("Dark Mode") {
    let appState = AppState()
    appState.trainingProgress.dailyStreak = 7
    appState.trainingProgress.totalStars = 150

    return ForYouView()
        .environment(appState)
        .preferredColorScheme(.dark)
}

#Preview("Large Text") {
    ForYouView()
        .environment(AppState())
        .environment(\.sizeCategory, .accessibilityLarge)
}
