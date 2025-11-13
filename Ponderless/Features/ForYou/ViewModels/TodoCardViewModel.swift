//
//  TodoCardViewModel.swift
//  Ponderless
//
//  ViewModel for TodoCard with state management
//

import Foundation
import Observation

@MainActor
@Observable
final class TodoCardViewModel {
    // MARK: - Properties

    private(set) var todo: DailyTodo
    private let repository: TodoRepository

    var isCompleted: Bool
    var showExerciseSheet: Bool = false
    var isInProgress: Bool = false
    var currentStep: Int = 1

    // MARK: - Initialization

    init(todo: DailyTodo, repository: TodoRepository? = nil) {
        self.todo = todo
        self.repository = repository ?? DefaultTodoRepository()
        self.isCompleted = todo.isCompleted
    }

    // MARK: - Actions

    func handleTap() {
        guard !isCompleted else { return }
        showExerciseSheet = true
    }

    func markInProgress() {
        guard !isCompleted else { return }
        isInProgress = true
    }

    func updateProgress(step: Int) {
        currentStep = step
        Task {
            try? await repository.updateTodoProgress(id: todo.id, currentStep: step)
        }
    }

    func complete() async {
        do {
            try await repository.completeTodo(id: todo.id)
            isCompleted = true
            isInProgress = false
            showExerciseSheet = false
        } catch {
            // Handle error - in a real app, this would show an error message
            print("Error completing todo: \(error)")
        }
    }

    func dismissSheet() {
        showExerciseSheet = false
        // If user closes sheet without completing, mark as in progress
        if !isCompleted {
            markInProgress()
        }
    }
}

// MARK: - Preview Helpers

extension TodoCardViewModel {
    static let preview = TodoCardViewModel(
        todo: DailyTodo.preview,
        repository: MockTodoRepository.preview
    )

    static let previewCompleted = TodoCardViewModel(
        todo: DailyTodo.previewCompleted,
        repository: MockTodoRepository.preview
    )

    static let previewInProgress: TodoCardViewModel = {
        let vm = TodoCardViewModel(
            todo: DailyTodo.preview,
            repository: MockTodoRepository.preview
        )
        vm.isInProgress = true
        vm.currentStep = 3
        return vm
    }()
}
