//
//  APIService.swift
//  Ponderless
//
//  High-level API service layer
//

import Foundation

/// Main API service for all network operations
actor APIService {
    static let shared = APIService()
    private let networkClient = NetworkClient.shared

    private init() {}

    // MARK: - Lessons

    func fetchLessons() async throws -> [Lesson] {
        try await networkClient.fetch(endpoint: .lessons, type: [Lesson].self)
    }

    func fetchLesson(id: UUID) async throws -> Lesson {
        try await networkClient.fetch(endpoint: .lesson(id: id), type: Lesson.self)
    }

    func fetchLessonsByCategory(_ category: LessonCategory) async throws -> [Lesson] {
        let endpoint = Endpoint(path: "lessons?category=\(category.rawValue)")
        return try await networkClient.fetch(endpoint: endpoint, type: [Lesson].self)
    }

    // MARK: - Exercises

    func fetchExercises() async throws -> [Exercise] {
        try await networkClient.fetch(endpoint: .exercises, type: [Exercise].self)
    }

    func fetchExercise(id: UUID) async throws -> Exercise {
        try await networkClient.fetch(endpoint: .exercise(id: id), type: Exercise.self)
    }

    func submitExerciseResponse(_ response: ExerciseResponse) async throws -> ExerciseResult {
        try await networkClient.post(
            endpoint: .exercises,
            body: response,
            responseType: ExerciseResult.self
        )
    }

    // MARK: - Reflections

    func fetchDailyReflection() async throws -> Reflection {
        let endpoint = Endpoint(path: "reflections/daily")
        return try await networkClient.fetch(endpoint: endpoint, type: Reflection.self)
    }

    func fetchReflections(category: ReflectionCategory? = nil) async throws -> [Reflection] {
        var path = "reflections"
        if let category = category {
            path += "?category=\(category.rawValue)"
        }
        let endpoint = Endpoint(path: path)
        return try await networkClient.fetch(endpoint: endpoint, type: [Reflection].self)
    }

    func saveJournalEntry(_ entry: JournalEntry) async throws -> JournalEntry {
        try await networkClient.post(
            endpoint: Endpoint(path: "journal"),
            body: entry,
            responseType: JournalEntry.self
        )
    }

    // MARK: - Coaches

    func fetchCoaches() async throws -> [Coach] {
        try await networkClient.fetch(endpoint: .coaches, type: [Coach].self)
    }

    func startChatSession(with coachId: UUID) async throws -> ChatSession {
        let endpoint = Endpoint(path: "coaches/\(coachId)/sessions")
        return try await networkClient.post(
            endpoint: endpoint,
            body: ["userId": UUID().uuidString],
            responseType: ChatSession.self
        )
    }

    func sendChatMessage(
        _ message: String,
        sessionId: UUID,
        coachId: UUID
    ) async throws -> ChatMessage {
        let endpoint = Endpoint(path: "coaches/\(coachId)/sessions/\(sessionId)/messages")
        let body = ["content": message]
        return try await networkClient.post(
            endpoint: endpoint,
            body: body,
            responseType: ChatMessage.self
        )
    }

    // MARK: - Progress

    func fetchUserProgress() async throws -> UserProgress {
        try await networkClient.fetch(endpoint: .progress, type: UserProgress.self)
    }

    func updateProgress(_ progress: UserProgress) async throws -> UserProgress {
        try await networkClient.update(
            endpoint: .progress,
            body: progress,
            responseType: UserProgress.self
        )
    }

    func syncProgress(_ progress: UserProgress) async throws {
        let endpoint = Endpoint(path: "progress/sync")
        _ = try await networkClient.post(
            endpoint: endpoint,
            body: progress,
            responseType: EmptyResponse.self
        )
    }

    // MARK: - Authentication

    func authenticate(with token: String) async {
        await networkClient.setAuthToken(token)
    }

    func logout() async {
        await networkClient.setAuthToken(nil)
    }
}

// MARK: - Response Models

struct ExerciseResult: Codable {
    let score: Double
    let passed: Bool
    let feedback: String
    let correctAnswers: [String]
    let nextRecommendation: UUID?
}