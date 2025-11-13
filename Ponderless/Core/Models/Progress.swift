//
//  Progress.swift
//  Ponderless
//
//  Track user progress and achievements
//

import Foundation

/// Tracks overall user progress and statistics
struct UserProgress: Codable, Hashable, Sendable {
    let userId: UUID
    var totalLessonsCompleted: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var totalTimeSpent: TimeInterval
    var lessonProgress: [UUID: LessonProgress]
    var achievements: Set<Achievement>
    var dailyGoal: Int
    var weeklyStats: WeeklyStats

    init(
        userId: UUID = UUID(),
        totalLessonsCompleted: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastActivityDate: Date? = nil,
        totalTimeSpent: TimeInterval = 0,
        lessonProgress: [UUID: LessonProgress] = [:],
        achievements: Set<Achievement> = [],
        dailyGoal: Int = 1,
        weeklyStats: WeeklyStats = WeeklyStats()
    ) {
        self.userId = userId
        self.totalLessonsCompleted = totalLessonsCompleted
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActivityDate = lastActivityDate
        self.totalTimeSpent = totalTimeSpent
        self.lessonProgress = lessonProgress
        self.achievements = achievements
        self.dailyGoal = dailyGoal
        self.weeklyStats = weeklyStats
    }

    mutating func updateStreak() {
        guard let lastActivity = lastActivityDate else {
            currentStreak = 1
            longestStreak = max(longestStreak, currentStreak)
            lastActivityDate = Date()
            return
        }

        let calendar = Calendar.current
        let daysSinceLastActivity = calendar.dateComponents([.day], from: lastActivity, to: Date()).day ?? 0

        switch daysSinceLastActivity {
        case 0:
            // Same day, no change
            break
        case 1:
            // Consecutive day
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        default:
            // Streak broken
            currentStreak = 1
        }

        lastActivityDate = Date()
    }
}

/// Individual lesson progress tracking
struct LessonProgress: Codable, Hashable, Sendable {
    let lessonId: UUID
    var completionStatus: CompletionStatus
    var startedAt: Date?
    var completedAt: Date?
    var timeSpent: TimeInterval
    var exercisesCompleted: Int
    var score: Double?
    var notes: String

    enum CompletionStatus: String, Codable, Sendable {
        case notStarted = "Not Started"
        case inProgress = "In Progress"
        case completed = "Completed"
    }

    init(
        lessonId: UUID,
        completionStatus: CompletionStatus = .notStarted,
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        timeSpent: TimeInterval = 0,
        exercisesCompleted: Int = 0,
        score: Double? = nil,
        notes: String = ""
    ) {
        self.lessonId = lessonId
        self.completionStatus = completionStatus
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.timeSpent = timeSpent
        self.exercisesCompleted = exercisesCompleted
        self.score = score
        self.notes = notes
    }
}

/// Weekly statistics for progress tracking
struct WeeklyStats: Codable, Hashable, Sendable {
    var lessonsPerDay: [Date: Int]
    var averageTimePerLesson: TimeInterval
    var mostActiveCategory: LessonCategory?
    var weekStartDate: Date

    init() {
        self.lessonsPerDay = [:]
        self.averageTimePerLesson = 0
        self.mostActiveCategory = nil
        self.weekStartDate = Calendar.current.startOfWeek(for: Date()) ?? Date()
    }
}

/// User achievements and milestones
struct Achievement: Codable, Hashable, Sendable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let unlockedAt: Date
    let type: AchievementType

    enum AchievementType: String, Codable, Sendable {
        case streak = "Streak"
        case completion = "Completion"
        case mastery = "Mastery"
        case exploration = "Exploration"
        case speed = "Speed"
    }
}


// MARK: - Calendar Extension

extension Calendar {
    func startOfWeek(for date: Date) -> Date? {
        guard let weekday = dateComponents([.weekday], from: date).weekday else { return nil }
        let daysToSubtract = (weekday - firstWeekday + 7) % 7
        return self.date(byAdding: .day, value: -daysToSubtract, to: startOfDay(for: date))
    }
}