//
//  DailyTodosSectionViewModel.swift
//  Ponderless
//
//  ViewModel for DailyTodosSection with sheet management
//

import Foundation
import Observation

@Observable
final class DailyTodosSectionViewModel {
    // MARK: - Properties

    let progressProvider: TrainingProgressProvider
    let todoRepository: TodoRepository
    let errorHandler: ErrorHandler

    var todos: [DailyTodo] = []
    var showStreakSheet = false
    var showStarsSheet = false
    var isLoading = false

    var dailyStreak: Int {
        progressProvider.dailyStreak
    }

    var totalStars: Int {
        progressProvider.totalStars
    }

    // Error handling
    var hasError: Bool {
        errorHandler.hasError
    }

    var errorMessage: String {
        errorHandler.errorMessage
    }

    var canRetry: Bool {
        errorHandler.canRetry
    }

    // MARK: - Initialization

    init(
        progressProvider: TrainingProgressProvider,
        todoRepository: TodoRepository = DefaultTodoRepository(),
        errorHandler: ErrorHandler? = nil
    ) {
        self.progressProvider = progressProvider
        self.todoRepository = todoRepository
        self.errorHandler = errorHandler ?? ErrorHandler()
    }

    // MARK: - Actions

    @MainActor
    func loadTodos() async {
        isLoading = true
        errorHandler.clearError()

        await errorHandler.execute(
            {
                self.todos = await self.todoRepository.getTodaysTodos()
            },
            context: "Loading today's todos"
        )

        isLoading = false
    }

    @MainActor
    func retryLoadTodos() async {
        await errorHandler.retry {
            self.todos = await self.todoRepository.getTodaysTodos()
        }
    }

    func showStreak() {
        showStreakSheet = true
    }

    func showStars() {
        showStarsSheet = true
    }
}

// MARK: - Preview Helpers

extension DailyTodosSectionViewModel {
    static let preview = DailyTodosSectionViewModel(
        progressProvider: MockTrainingProgressProvider.preview,
        todoRepository: MockTodoRepository.preview
    )

    static let previewWithHighStreak = DailyTodosSectionViewModel(
        progressProvider: MockTrainingProgressProvider.previewWithHighStreak,
        todoRepository: MockTodoRepository.preview
    )

    static let previewNewUser = DailyTodosSectionViewModel(
        progressProvider: MockTrainingProgressProvider.previewNewUser,
        todoRepository: MockTodoRepository.preview
    )
}
