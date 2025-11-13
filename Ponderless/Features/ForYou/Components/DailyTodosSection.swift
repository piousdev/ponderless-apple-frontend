//
//  DailyTodosSection.swift
//  Ponderless
//
//  Refactored daily todos section with ViewModel and dependency injection
//

import SwiftUI

struct DailyTodosSection: View {
    @State private var viewModel: DailyTodosSectionViewModel

    init(progressProvider: TrainingProgressProvider, todoRepository: TodoRepository = DefaultTodoRepository()) {
        self._viewModel = State(initialValue: DailyTodosSectionViewModel(
            progressProvider: progressProvider,
            todoRepository: todoRepository
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            // Header with badges
            HStack(alignment: .center, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(ForYouConstants.TextContent.dailyPlanTitle)
                        .font(Typography.title2.bold())
                        .foregroundStyle(DesignSystem.Colors.foreground)

                    Text(ForYouConstants.TextContent.dailyPlanSubtitle)
                        .font(Typography.caption1)
                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                }

                Spacer()

                HStack(spacing: Spacing.sm) {
                    StatsBadge(
                        icon: "flame.fill",
                        value: "\(viewModel.dailyStreak)",
                        label: ForYouConstants.AccessibilityLabels.streakBadge,
                        iconColor: DesignSystem.Colors.chart3,
                        action: { viewModel.showStreak() }
                    )

                    StatsBadge(
                        icon: "star.fill",
                        value: "\(viewModel.totalStars)",
                        label: ForYouConstants.AccessibilityLabels.starsBadge,
                        iconColor: DesignSystem.Colors.chart5,
                        action: { viewModel.showStars() }
                    )
                }
            }

            // Todo cards
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.hasError {
                ErrorStateView(
                    errorHandler: viewModel.errorHandler,
                    onRetry: {
                        Task {
                            await viewModel.retryLoadTodos()
                        }
                    }
                )
            } else {
                VStack(spacing: Spacing.md) {
                    ForEach(viewModel.todos) { todo in
                        TodoCard(todo: todo, repository: viewModel.todoRepository)
                    }
                }
            }
        }
        .task {
            await viewModel.loadTodos()
        }
        .sheet(isPresented: $viewModel.showStreakSheet) {
            StreakSheetView(viewModel: StreakCalendarViewModel(progressProvider: viewModel.progressProvider))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showStarsSheet) {
            StarsSheetView(progressProvider: viewModel.progressProvider)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ScrollView {
        DailyTodosSection(
            progressProvider: MockTrainingProgressProvider.preview,
            todoRepository: MockTodoRepository.preview
        )
        .padding()
    }
}

#Preview("High Streak") {
    ScrollView {
        DailyTodosSection(
            progressProvider: MockTrainingProgressProvider.previewWithHighStreak,
            todoRepository: MockTodoRepository.preview
        )
        .padding()
    }
}

#Preview("New User") {
    ScrollView {
        DailyTodosSection(
            progressProvider: MockTrainingProgressProvider.previewNewUser,
            todoRepository: MockTodoRepository.preview
        )
        .padding()
    }
}

#Preview("Dark Mode") {
    ScrollView {
        DailyTodosSection(
            progressProvider: MockTrainingProgressProvider.preview,
            todoRepository: MockTodoRepository.preview
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}
