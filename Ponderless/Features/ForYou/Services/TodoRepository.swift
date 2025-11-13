//
//  TodoRepository.swift
//  Ponderless
//
//  Protocol for accessing daily todo data
//

import Foundation

/// Protocol for providing daily todo data
/// Enables dependency injection and testability
protocol TodoRepository {
    func getTodaysTodos() async -> [DailyTodo]
    func completeTodo(id: UUID) async throws
    func updateTodoProgress(id: UUID, currentStep: Int) async throws
}

// MARK: - Default Implementation

final class DefaultTodoRepository: TodoRepository {
    func getTodaysTodos() async -> [DailyTodo] {
        // In a real app, this would fetch from AppState or API
        // For now, return sample data
        return [
            DailyTodo(
                title: "Morning Calibration",
                description: "Test your confidence on 5 predictions",
                icon: .waveSignal,
                isCompleted: false,
                points: 10,
                exerciseType: .calibration
            ),
            DailyTodo(
                title: "Bias Recognition Exercise",
                description: "2-minute skill builder",
                icon: .machineLearning,
                isCompleted: false,
                points: 15,
                exerciseType: .biasRecognition
            ),
            DailyTodo(
                title: "Decision Framework",
                description: "Apply EtD to a micro-decision",
                icon: .constructionHouse,
                isCompleted: false,
                points: 20,
                exerciseType: .decisionFramework
            )
        ]
    }

    func completeTodo(id: UUID) async throws {
        // In a real app, this would update AppState and sync to backend
        try await Task.sleep(nanoseconds: 100_000_000) // Simulate network delay
    }

    func updateTodoProgress(id: UUID, currentStep: Int) async throws {
        // In a real app, this would update AppState
        try await Task.sleep(nanoseconds: 50_000_000) // Simulate update
    }
}

// MARK: - Mock Implementation

final class MockTodoRepository: TodoRepository {
    var todos: [DailyTodo]
    var shouldThrowError = false

    init(todos: [DailyTodo] = DailyTodo.previewList) {
        self.todos = todos
    }

    func getTodaysTodos() async -> [DailyTodo] {
        return todos
    }

    func completeTodo(id: UUID) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockTodoRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos[index] = DailyTodo(
                id: todos[index].id,
                title: todos[index].title,
                description: todos[index].description,
                icon: todos[index].icon,
                isCompleted: true,
                points: todos[index].points,
                exerciseType: todos[index].exerciseType
            )
        }
    }

    func updateTodoProgress(id: UUID, currentStep: Int) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockTodoRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
    }

    // Convenience for previews
    static let preview = MockTodoRepository()

    static let previewWithCompletedTodos = MockTodoRepository(
        todos: [
            DailyTodo(
                title: "Morning Calibration",
                description: "Test your confidence on 5 predictions",
                icon: .waveSignal,
                isCompleted: true,
                points: 10,
                exerciseType: .calibration
            ),
            DailyTodo(
                title: "Bias Recognition Exercise",
                description: "2-minute skill builder",
                icon: .machineLearning,
                isCompleted: true,
                points: 15,
                exerciseType: .biasRecognition
            ),
            DailyTodo(
                title: "Decision Framework",
                description: "Apply EtD to a micro-decision",
                icon: .constructionHouse,
                isCompleted: false,
                points: 20,
                exerciseType: .decisionFramework
            )
        ]
    )
}
