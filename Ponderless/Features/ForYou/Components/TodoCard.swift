//
//  TodoCard.swift
//  Ponderless
//
//  Refactored todo card with ViewModel and extracted sub-components
//

import SwiftUI

struct TodoCard: View {
    @State private var viewModel: TodoCardViewModel

    init(todo: DailyTodo, repository: TodoRepository = DefaultTodoRepository()) {
        self._viewModel = State(initialValue: TodoCardViewModel(todo: todo, repository: repository))
    }

    var body: some View {
        HStack(spacing: Spacing.lg) {
            TodoIconView(icon: viewModel.todo.icon, isCompleted: viewModel.isCompleted)

            TodoContentView(
                title: viewModel.todo.title,
                description: viewModel.todo.description,
                isCompleted: viewModel.isCompleted,
                isInProgress: viewModel.isInProgress,
                currentStep: viewModel.currentStep,
                totalSteps: viewModel.todo.exerciseType.stepCount
            )

            Spacer()

            TodoPointsView(points: viewModel.todo.points, isCompleted: viewModel.isCompleted)
        }
        .cardStyle()
        .onTapGesture {
            viewModel.handleTap()
        }
        .sheet(isPresented: $viewModel.showExerciseSheet) {
            ExerciseSheet(
                viewModel: ExerciseSheetViewModel(
                    todo: viewModel.todo,
                    initialStep: viewModel.currentStep,
                    onComplete: {
                        Task {
                            await viewModel.complete()
                        }
                    }
                ),
                onUpdateProgress: { step in
                    viewModel.updateProgress(step: step)
                },
                onDismiss: {
                    viewModel.dismissSheet()
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ForYouConstants.AccessibilityLabels.todoCard)
        .accessibilityHint(viewModel.isCompleted ? ForYouConstants.AccessibilityLabels.completedHint : ForYouConstants.AccessibilityLabels.todoCardHint)
    }
}

#Preview("Not Started") {
    TodoCard(todo: DailyTodo.preview, repository: MockTodoRepository.preview)
        .padding()
}

#Preview("In Progress") {
    TodoCard(
        todo: DailyTodo(
            title: "Bias Recognition Exercise",
            description: "2-minute skill builder",
            icon: .machineLearning,
            isCompleted: false,
            points: 15,
            exerciseType: .biasRecognition
        ),
        repository: MockTodoRepository.preview
    )
    .padding()
}

#Preview("Completed") {
    TodoCard(todo: DailyTodo.previewCompleted, repository: MockTodoRepository.preview)
        .padding()
}

#Preview("All States") {
    ScrollView {
        VStack(spacing: Spacing.md) {
            ForEach(DailyTodo.previewList) { todo in
                TodoCard(todo: todo, repository: MockTodoRepository.preview)
            }
        }
        .padding()
    }
}

#Preview("Dark Mode") {
    ScrollView {
        VStack(spacing: Spacing.md) {
            ForEach(DailyTodo.previewList) { todo in
                TodoCard(todo: todo, repository: MockTodoRepository.preview)
            }
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
