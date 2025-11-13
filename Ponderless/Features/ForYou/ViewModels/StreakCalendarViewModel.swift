//
//  StreakCalendarViewModel.swift
//  Ponderless
//
//  ViewModel for StreakSheetView with calendar logic
//

import Foundation
import Observation

@MainActor
@Observable
final class StreakCalendarViewModel {
    // MARK: - Properties

    private let progressProvider: TrainingProgressProvider
    private let calendar = Calendar.current

    var selectedWeekOffset: Int = 0 // 0 = current week, -1 = last week

    var dailyStreak: Int {
        progressProvider.dailyStreak
    }

    var canGoToNextWeek: Bool {
        selectedWeekOffset < 0
    }

    // MARK: - Initialization

    init(progressProvider: TrainingProgressProvider) {
        self.progressProvider = progressProvider
    }

    // MARK: - Week Navigation

    func navigateToPreviousWeek() {
        selectedWeekOffset -= 1
    }

    func navigateToNextWeek() {
        guard canGoToNextWeek else { return }
        selectedWeekOffset += 1
    }

    // MARK: - Date Calculations (with safe fallbacks)

    var weekDateRange: String {
        let today = Date()

        guard let weekStartDate = startOfWeek(for: today),
              let adjustedWeekStart = calendar.date(byAdding: .weekOfYear, value: selectedWeekOffset, to: weekStartDate),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: adjustedWeekStart) else {
            return "Date unavailable"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"

        let startString = formatter.string(from: adjustedWeekStart)
        let endDay = calendar.component(.day, from: weekEnd)

        return "\(startString) - \(endDay)"
    }

    func startOfWeek(for date: Date) -> Date? {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components)
    }

    func dateForDayInWeek(_ dayIndex: Int) -> Date? {
        let today = Date()

        guard let weekStart = startOfWeek(for: today),
              let adjustedWeekStart = calendar.date(byAdding: .weekOfYear, value: selectedWeekOffset, to: weekStart),
              let dayDate = calendar.date(byAdding: .day, value: dayIndex, to: adjustedWeekStart) else {
            return nil
        }

        return dayDate
    }

    func dayOfWeekLabel(for index: Int) -> String {
        ForYouConstants.Calendar.daysOfWeek[index]
    }

    func isFutureDate(_ date: Date) -> Bool {
        date > Date()
    }

    // MARK: - Activity Tracking

    func hasActivityForDate(_ date: Date) -> Bool {
        // Placeholder logic - in a real app, this would check actual training history
        if isFutureDate(date) {
            return false
        }

        // For demo: show activity on Mon, Wed, Fri (2, 4, 6)
        let dayOfWeek = calendar.component(.weekday, from: date)
        return [2, 4, 6].contains(dayOfWeek)
    }

    // MARK: - Motivational Text

    var motivationalMessage: String {
        switch dailyStreak {
        case 0:
            return "Start your streak today with just one exercise"
        case 1:
            return "Great start! Keep it going tomorrow"
        case 2...6:
            return ForYouConstants.TextContent.streakSubtitle
        case 7...13:
            return "One week down! Your consistency is building strong judgment habits"
        case 14...29:
            return "Two weeks strong! You're developing lasting critical thinking skills"
        case 30...:
            return "30+ days! Your dedication to overcoming overthinking is remarkable"
        default:
            return ForYouConstants.TextContent.streakSubtitle
        }
    }
}

// MARK: - Preview Helpers

extension StreakCalendarViewModel {
    static let preview = StreakCalendarViewModel(
        progressProvider: MockTrainingProgressProvider.preview
    )

    static let previewHighStreak = StreakCalendarViewModel(
        progressProvider: MockTrainingProgressProvider.previewWithHighStreak
    )

    static let previewNewUser = StreakCalendarViewModel(
        progressProvider: MockTrainingProgressProvider.previewNewUser
    )
}
