//
//  TrainingProgressProvider.swift
//  Ponderless
//
//  Protocol for accessing training progress data
//

import Foundation

/// Protocol for providing training progress data
/// Enables dependency injection and testability
protocol TrainingProgressProvider {
    var dailyStreak: Int { get }
    var totalStars: Int { get }
    var totalExercisesCompleted: Int { get }
    var averageAccuracy: Double { get }
    var lastTrainingDate: Date? { get }
}

// MARK: - AppState Conformance

extension AppState: TrainingProgressProvider {
    var dailyStreak: Int {
        trainingProgress.dailyStreak
    }

    var totalStars: Int {
        trainingProgress.totalStars
    }

    var totalExercisesCompleted: Int {
        trainingProgress.totalExercisesCompleted
    }

    var averageAccuracy: Double {
        trainingProgress.averageAccuracy
    }

    var lastTrainingDate: Date? {
        trainingProgress.lastTrainingDate
    }
}

// MARK: - Mock Implementation

final class MockTrainingProgressProvider: TrainingProgressProvider {
    var dailyStreak: Int
    var totalStars: Int
    var totalExercisesCompleted: Int
    var averageAccuracy: Double
    var lastTrainingDate: Date?

    init(
        dailyStreak: Int = 7,
        totalStars: Int = 150,
        totalExercisesCompleted: Int = 42,
        averageAccuracy: Double = 0.85,
        lastTrainingDate: Date? = Date()
    ) {
        self.dailyStreak = dailyStreak
        self.totalStars = totalStars
        self.totalExercisesCompleted = totalExercisesCompleted
        self.averageAccuracy = averageAccuracy
        self.lastTrainingDate = lastTrainingDate
    }

    // Convenience for previews
    static let preview = MockTrainingProgressProvider()

    static let previewWithHighStreak = MockTrainingProgressProvider(
        dailyStreak: 30,
        totalStars: 500
    )

    static let previewNewUser = MockTrainingProgressProvider(
        dailyStreak: 1,
        totalStars: 10,
        totalExercisesCompleted: 2,
        averageAccuracy: 0.5
    )
}
