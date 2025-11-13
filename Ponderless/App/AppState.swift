//
//  AppState.swift
//  Ponderless
//
//  Global app state management using @Observable
//

import SwiftUI
import Observation

/// Main app state using Swift 5.9+ @Observable macro
@Observable
final class AppState {
    // Navigation
    var selectedTab: AppTab = .forYou
    var navigationPath: [NavigationDestination] = []
    var practiceSegment: PracticeSegment = .train

    // User state
    var isAuthenticated: Bool = false
    var currentUser: User?
    var userProgress: UserProgress = UserProgress()

    // Data state - Original
    var lessons: [Lesson] = []
    var exercises: [Exercise] = []
    var reflections: [Reflection] = []
    var journalEntries: [JournalEntry] = []

    // Data state - New
    var coaches: [Coach] = CoachFactory.createDefaultCoaches()
    var trainingExercises: [TrainingExercise] = []
    var frameworkTemplates: [FrameworkTemplate] = []
    var calibrationRecords: [CalibrationRecord] = []
    var trainingProgress: TrainingProgress = TrainingProgress(
        userId: UUID(),
        skillProgress: [:],
        dailyStreak: 0,
        totalStars: 0,
        totalExercisesCompleted: 0,
        averageAccuracy: 0.0,
        lastTrainingDate: nil
    )
    var activeChatSessions: [CoachType: ChatSession] = [:]

    // UI state
    var isLoading: Bool = false
    var error: AppError?
    var showOnboarding: Bool = false
    var preferredColorScheme: ColorScheme? = nil

    // Premium state
    var isPremiumUser: Bool = false
    var availableFeatures: Set<Feature> = [.basicLessons, .dailyReflection]

    init() {
        // Only synchronous initialization here
        // No async operations to prevent crashes
        loadThemePreference()
    }

    // MARK: - Theme Management

    func toggleTheme() {
        switch preferredColorScheme {
        case .none:
            preferredColorScheme = .dark
        case .dark:
            preferredColorScheme = .light
        case .light:
            preferredColorScheme = nil
        @unknown default:
            preferredColorScheme = nil
        }
        saveThemePreference()
    }

    private func loadThemePreference() {
        if let savedTheme = UserDefaults.standard.string(forKey: "preferredColorScheme") {
            switch savedTheme {
            case "dark":
                preferredColorScheme = .dark
            case "light":
                preferredColorScheme = .light
            default:
                preferredColorScheme = nil
            }
        }
    }

    func saveThemePreference() {
        let themeString: String?
        switch preferredColorScheme {
        case .dark:
            themeString = "dark"
        case .light:
            themeString = "light"
        default:
            themeString = nil
        }

        if let themeString = themeString {
            UserDefaults.standard.set(themeString, forKey: "preferredColorScheme")
        } else {
            UserDefaults.standard.removeObject(forKey: "preferredColorScheme")
        }
    }

    // MARK: - Startup

    /// Call this method after initialization to load cached data
    @MainActor
    func startup() async {
        await loadCachedData()
    }

    // MARK: - Navigation

    func navigate(to destination: NavigationDestination) {
        navigationPath.append(destination)
    }

    func popNavigation() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func popToRoot() {
        navigationPath.removeAll()
    }

    // MARK: - Data Loading

    @MainActor
    func loadCachedData() async {
        do {
            // Load cached progress
            if let progress = try await CacheManager.shared.loadProgress() {
                self.userProgress = progress
            }

            // Load cached lessons
            if let lessons = try await CacheManager.shared.loadLessons() {
                self.lessons = lessons
            }

            // Load cached journal entries
            if let entries = try await CacheManager.shared.loadJournalEntries() {
                self.journalEntries = entries
            }
        } catch {
            // Log error but don't crash - app should work even without cached data
            print("Warning: Failed to load cached data: \(error.localizedDescription)")
            // Initialize with empty data is fine - already done in property declarations
        }
    }

    @MainActor
    func refreshData() async {
        isLoading = true
        error = nil

        do {
            // Fetch fresh data from API
            async let lessonsTask = APIService.shared.fetchLessons()
            async let exercisesTask = APIService.shared.fetchExercises()
            async let reflectionsTask = APIService.shared.fetchReflections()
            async let coachesTask = APIService.shared.fetchCoaches()
            async let progressTask = APIService.shared.fetchUserProgress()

            let (lessons, exercises, reflections, coaches, progress) = try await (
                lessonsTask,
                exercisesTask,
                reflectionsTask,
                coachesTask,
                progressTask
            )

            self.lessons = lessons
            self.exercises = exercises
            self.reflections = reflections
            self.coaches = coaches
            self.userProgress = progress

            // Cache the data
            Task {
                try await CacheManager.shared.saveLessons(lessons)
                try await CacheManager.shared.saveProgress(progress)
            }
        } catch {
            self.error = AppError.networkError(error)
        }

        isLoading = false
    }

    // MARK: - Progress Management

    @MainActor
    func completeLesson(_ lesson: Lesson) async {
        userProgress.totalLessonsCompleted += 1
        userProgress.updateStreak()

        let lessonProgress = LessonProgress(
            lessonId: lesson.id,
            completionStatus: .completed,
            completedAt: Date(),
            timeSpent: lesson.estimatedDuration
        )
        userProgress.lessonProgress[lesson.id] = lessonProgress

        // Save locally
        Task {
            try await CacheManager.shared.saveProgress(userProgress)
        }

        // Sync with server
        Task {
            try await APIService.shared.syncProgress(userProgress)
        }
    }

    // MARK: - Journal Management

    @MainActor
    func saveJournalEntry(_ entry: JournalEntry) async {
        journalEntries.append(entry)

        // Save locally
        Task {
            try await CacheManager.shared.saveJournalEntries(journalEntries)
        }

        // Save to server
        Task {
            _ = try await APIService.shared.saveJournalEntry(entry)
        }
    }

    // MARK: - Coach Chat Management

    @MainActor
    func startChatSession(with coachType: CoachType) async {
        let session = ChatSession(
            coachType: coachType,
            userId: currentUser?.id ?? UUID()
        )
        activeChatSessions[coachType] = session
    }

    @MainActor
    func endChatSession(for coachType: CoachType) {
        activeChatSessions[coachType]?.endSession()
    }

    @MainActor
    func sendMessage(_ message: String, to coachType: CoachType) async {
        guard var session = activeChatSessions[coachType] else {
            await startChatSession(with: coachType)
            return
        }

        let chatMessage = ChatMessage(
            sender: .user,
            content: message
        )
        session.messages.append(chatMessage)
        activeChatSessions[coachType] = session

        // Simulate coach response (in real app, this would call API)
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            await receiveCoachResponse(for: coachType)
        }
    }

    @MainActor
    private func receiveCoachResponse(for coachType: CoachType) async {
        guard var session = activeChatSessions[coachType] else { return }

        let response = ChatMessage(
            sender: .coach(coachType),
            content: generateCoachResponse(for: coachType)
        )
        session.messages.append(response)
        activeChatSessions[coachType] = session
    }

    private func generateCoachResponse(for coachType: CoachType) -> String {
        switch coachType {
        case .challenger:
            return "Interesting perspective. But have you considered what evidence actually supports that assumption?"
        case .navigator:
            return "Let's break this down systematically. What are the key components we need to consider?"
        case .explorer:
            return "That's one way to look at it. What if we approached this from a completely different angle?"
        }
    }

    // MARK: - Training Progress

    @MainActor
    func completeTrainingExercise(_ exercise: TrainingExercise, accuracy: Double) {
        trainingProgress.totalExercisesCompleted += 1
        trainingProgress.lastTrainingDate = Date()

        // Update skill-specific progress
        if trainingProgress.skillProgress[exercise.skillCategory] == nil {
            trainingProgress.skillProgress[exercise.skillCategory] = TrainingProgress.SkillProgress(
                level: 1,
                experience: 0,
                exercisesCompleted: 0,
                accuracy: 0.0,
                lastPracticed: nil,
                masteryLevel: .novice
            )
        }

        if var skillProgress = trainingProgress.skillProgress[exercise.skillCategory] {
            skillProgress.exercisesCompleted += 1
            skillProgress.accuracy = ((skillProgress.accuracy * Double(skillProgress.exercisesCompleted - 1)) + accuracy) / Double(skillProgress.exercisesCompleted)
            skillProgress.lastPracticed = Date()
            skillProgress.experience += Int(accuracy * 100)

            // Level up logic
            if skillProgress.experience >= skillProgress.level * 100 {
                skillProgress.level += 1
                if skillProgress.level >= 10 {
                    skillProgress.masteryLevel = .expert
                } else if skillProgress.level >= 8 {
                    skillProgress.masteryLevel = .advanced
                } else if skillProgress.level >= 5 {
                    skillProgress.masteryLevel = .proficient
                } else if skillProgress.level >= 3 {
                    skillProgress.masteryLevel = .developing
                }
            }

            trainingProgress.skillProgress[exercise.skillCategory] = skillProgress
        }

        // Update average accuracy
        let totalAccuracy = trainingProgress.skillProgress.values.reduce(0) { $0 + $1.accuracy }
        trainingProgress.averageAccuracy = totalAccuracy / Double(trainingProgress.skillProgress.count)

        // Update streak
        updateTrainingStreak()
    }

    private func updateTrainingStreak() {
        let calendar = Calendar.current
        if let lastDate = trainingProgress.lastTrainingDate {
            let daysSince = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if daysSince == 0 {
                // Same day, streak continues
            } else if daysSince == 1 {
                trainingProgress.dailyStreak += 1
            } else {
                trainingProgress.dailyStreak = 1
            }
        } else {
            trainingProgress.dailyStreak = 1
        }
    }

    // MARK: - Calibration Tracking

    @MainActor
    func recordPrediction(questionId: UUID, predicted: Double, confidence: Int, actual: Bool) {
        let prediction = CalibrationRecord.PredictionRecord(
            questionId: questionId,
            predictedProbability: predicted,
            actualOutcome: actual,
            confidence: confidence,
            wasCorrect: (predicted >= 0.5) == actual
        )

        // Add to today's calibration record or create new one
        let today = Date()
        if let index = calibrationRecords.firstIndex(where: {
            Calendar.current.isDateInToday($0.date)
        }) {
            let record = calibrationRecords[index]
            var predictions = record.predictions
            predictions.append(prediction)

            // Recalculate Brier score
            let brierScore = calculateBrierScore(predictions: predictions)

            // Update calibration curve
            let calibrationCurve = calculateCalibrationCurve(predictions: predictions)

            // Update confidence ratios
            let (overconfidence, underconfidence) = calculateConfidenceRatios(predictions: predictions)

            calibrationRecords[index] = CalibrationRecord(
                id: record.id,
                date: record.date,
                predictions: predictions,
                brierScore: brierScore,
                calibrationCurve: calibrationCurve,
                overconfidenceRatio: overconfidence,
                underconfidenceRatio: underconfidence
            )
        } else {
            let newRecord = CalibrationRecord(
                id: UUID(),
                date: today,
                predictions: [prediction],
                brierScore: pow(predicted - (actual ? 1.0 : 0.0), 2),
                calibrationCurve: [],
                overconfidenceRatio: 0,
                underconfidenceRatio: 0
            )
            calibrationRecords.append(newRecord)
        }
    }

    private func calculateBrierScore(predictions: [CalibrationRecord.PredictionRecord]) -> Double {
        guard !predictions.isEmpty else { return 0 }
        let sum = predictions.reduce(0.0) { result, pred in
            result + pow(pred.predictedProbability - (pred.actualOutcome ? 1.0 : 0.0), 2)
        }
        return sum / Double(predictions.count)
    }

    private func calculateCalibrationCurve(predictions: [CalibrationRecord.PredictionRecord]) -> [CalibrationRecord.CalibrationPoint] {
        var buckets: [Int: (correct: Int, total: Int)] = [:]

        for pred in predictions {
            let bucket = Int(pred.confidence / 10) * 10
            if buckets[bucket] == nil {
                buckets[bucket] = (0, 0)
            }
            buckets[bucket]?.total += 1
            if pred.wasCorrect {
                buckets[bucket]?.correct += 1
            }
        }

        return buckets.map { bucket, counts in
            CalibrationRecord.CalibrationPoint(
                confidenceBucket: bucket,
                accuracy: counts.total > 0 ? Double(counts.correct) / Double(counts.total) : 0,
                count: counts.total
            )
        }.sorted { $0.confidenceBucket < $1.confidenceBucket }
    }

    private func calculateConfidenceRatios(predictions: [CalibrationRecord.PredictionRecord]) -> (overconfidence: Double, underconfidence: Double) {
        guard !predictions.isEmpty else { return (0, 0) }

        var overconfident = 0
        var underconfident = 0

        for pred in predictions {
            let confidenceAccuracy = Double(pred.confidence) / 100.0
            let actualAccuracy = pred.wasCorrect ? 1.0 : 0.0

            if confidenceAccuracy > actualAccuracy + 0.1 {
                overconfident += 1
            } else if confidenceAccuracy < actualAccuracy - 0.1 {
                underconfident += 1
            }
        }

        return (
            Double(overconfident) / Double(predictions.count),
            Double(underconfident) / Double(predictions.count)
        )
    }
}

// MARK: - Supporting Types

enum AppTab: String, CaseIterable {
    case forYou = "For You"
    case practice = "Practice"
    case coach = "Coach"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .forYou: return "house.fill"
        case .practice: return "brain.head.profile"
        case .coach: return "message.fill"
        case .profile: return "person.circle.fill"
        }
    }
}

enum PracticeSegment: String, CaseIterable {
    case train = "Train"
    case frameworks = "Frameworks"

    var title: String {
        switch self {
        case .train: return "TRAIN"
        case .frameworks: return "FRAMEWORKS"
        }
    }

    var subtitle: String {
        switch self {
        case .train: return "Build Your Core Skills"
        case .frameworks: return "Structured Decision Methods"
        }
    }
}

enum NavigationDestination: Hashable {
    case lesson(Lesson)
    case exercise(Exercise)
    case reflection(Reflection)
    case coach(Coach)
    case journalEntry(JournalEntry)
    case settings
    case profile
}

enum Feature: String {
    case basicLessons = "Basic Lessons"
    case premiumLessons = "Premium Lessons"
    case dailyReflection = "Daily Reflection"
    case unlimitedReflections = "Unlimited Reflections"
    case basicCoaches = "Basic Coaches"
    case allCoaches = "All Coaches"
    case advancedAnalytics = "Advanced Analytics"
}

enum AppError: LocalizedError {
    case networkError(Error)
    case cacheError(Error)
    case authenticationRequired
    case premiumRequired
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .cacheError(let error):
            return "Cache error: \(error.localizedDescription)"
        case .authenticationRequired:
            return "Please sign in to continue"
        case .premiumRequired:
            return "Premium subscription required"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}

struct User: Codable {
    let id: UUID
    let name: String
    let email: String
    let joinedAt: Date
}