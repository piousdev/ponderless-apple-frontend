//
//  ExerciseSheet.swift
//  Ponderless
//
//  Refactored exercise sheet with ViewModel and protocol-oriented design
//

import SwiftUI

struct ExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExerciseSheetViewModel

    let onUpdateProgress: (Int) -> Void
    let onDismiss: () -> Void

    init(
        viewModel: ExerciseSheetViewModel,
        onUpdateProgress: @escaping (Int) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onUpdateProgress = onUpdateProgress
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                ExerciseProgressBar(
                    currentStep: viewModel.currentStep,
                    totalSteps: viewModel.totalSteps
                )
                .padding()

                Divider()

                // Exercise Content
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        exerciseContent
                    }
                    .padding()
                }

                Divider()

                // Navigation Buttons
                ExerciseNavigationButtons(
                    currentStep: viewModel.currentStep,
                    totalSteps: viewModel.totalSteps,
                    onPrevious: {
                        withAnimation {
                            viewModel.previousStep()
                        }
                    },
                    onNext: {
                        withAnimation {
                            viewModel.nextStep()
                            onUpdateProgress(viewModel.currentStep)
                        }
                    },
                    onComplete: {
                        viewModel.complete()
                        dismiss()
                    }
                )
                .padding()
            }
            .navigationTitle(viewModel.todo.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(ForYouConstants.TextContent.cancelButton) {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var exerciseContent: some View {
        switch viewModel.todo.exerciseType {
        case .calibration:
            CalibrationExerciseView(viewModel: viewModel)
        case .biasRecognition:
            BiasRecognitionExerciseView(viewModel: viewModel)
        case .decisionFramework:
            DecisionFrameworkExerciseView(viewModel: viewModel)
        }
    }
}

// MARK: - Calibration Exercise View

private struct CalibrationExerciseView: View {
    @Bindable var viewModel: ExerciseSheetViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Prediction \(viewModel.currentStep) of \(viewModel.totalSteps)")
                .font(Typography.title3.bold())
                .foregroundStyle(DesignSystem.Colors.foreground)

            Text(ForYouConstants.CalibrationQuestions.instructionText)
                .font(Typography.body)
                .foregroundStyle(DesignSystem.Colors.mutedForeground)

            // Question
            Text(viewModel.getCalibrationQuestion())
                .font(Typography.headline)
                .foregroundStyle(DesignSystem.Colors.foreground)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignSystem.Colors.secondary)
                .cornerRadius(Corners.md)

            // Confidence Slider
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("Your confidence:")
                        .font(Typography.body)
                        .foregroundStyle(DesignSystem.Colors.foreground)

                    Spacer()

                    Text("\(Int(viewModel.confidenceLevel))%")
                        .font(Typography.title3.bold())
                        .foregroundStyle(DesignSystem.Colors.primary)
                }

                Slider(
                    value: $viewModel.confidenceLevel,
                    in: ForYouConstants.Confidence.minValue...ForYouConstants.Confidence.maxValue,
                    step: ForYouConstants.Confidence.stepValue
                )
                .tint(DesignSystem.Colors.primary)

                HStack {
                    Text("Not confident")
                        .font(Typography.caption2)
                        .foregroundStyle(DesignSystem.Colors.mutedForeground)

                    Spacer()

                    Text("Very confident")
                        .font(Typography.caption2)
                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                }
            }
            .padding()
            .background(DesignSystem.Colors.secondary.opacity(0.5))
            .cornerRadius(Corners.md)
        }
    }
}

// MARK: - Bias Recognition Exercise View

private struct BiasRecognitionExerciseView: View {
    @Bindable var viewModel: ExerciseSheetViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Scenario \(viewModel.currentStep)")
                .font(Typography.title3.bold())
                .foregroundStyle(DesignSystem.Colors.foreground)

            Text(ForYouConstants.BiasScenarios.instructionText)
                .font(Typography.body)
                .foregroundStyle(DesignSystem.Colors.mutedForeground)

            if let scenario = viewModel.getBiasScenario() {
                // Scenario
                Text(scenario.text)
                    .font(Typography.body)
                    .foregroundStyle(DesignSystem.Colors.foreground)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DesignSystem.Colors.secondary)
                    .cornerRadius(Corners.md)

                // Multiple Choice Options
                VStack(spacing: Spacing.sm) {
                    Text("Which bias is this?")
                        .font(Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(0..<scenario.options.count, id: \.self) { index in
                        Button {
                            viewModel.selectedChoice = index
                        } label: {
                            HStack {
                                Image(systemName: viewModel.selectedChoice == index ? "checkmark.circle.fill" : "circle")
                                    .font(Typography.title3)
                                    .foregroundStyle(viewModel.selectedChoice == index ? DesignSystem.Colors.primary : DesignSystem.Colors.mutedForeground)

                                Text(scenario.options[index])
                                    .font(Typography.body)
                                    .foregroundStyle(DesignSystem.Colors.foreground)
                                    .multilineTextAlignment(.leading)

                                Spacer()
                            }
                            .padding()
                            .background(viewModel.selectedChoice == index ? DesignSystem.Colors.primary.opacity(0.1) : DesignSystem.Colors.secondary)
                            .cornerRadius(Corners.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: Corners.md)
                                    .stroke(viewModel.selectedChoice == index ? DesignSystem.Colors.primary : DesignSystem.Colors.border, lineWidth: viewModel.selectedChoice == index ? 2 : 1)
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Decision Framework Exercise View

private struct DecisionFrameworkExerciseView: View {
    @Bindable var viewModel: ExerciseSheetViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            if let prompt = viewModel.getDecisionFrameworkPrompt() {
                Text(prompt.title)
                    .font(Typography.title3.bold())
                    .foregroundStyle(DesignSystem.Colors.foreground)

                Text(prompt.question)
                    .font(Typography.body)
                    .foregroundStyle(DesignSystem.Colors.mutedForeground)

                // Text Input Area
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text("Your answer:")
                            .font(Typography.caption1)
                            .foregroundStyle(DesignSystem.Colors.foreground)

                        Spacer()

                        // Character count
                        Text("\(viewModel.textAnswer.count)/\(ForYouConstants.Validation.maxTextLength)")
                            .font(Typography.caption2)
                            .foregroundStyle(
                                viewModel.textAnswer.count > ForYouConstants.Validation.maxTextLength * 9 / 10
                                    ? DesignSystem.Colors.destructive
                                    : DesignSystem.Colors.mutedForeground
                            )
                    }

                    TextEditor(text: $viewModel.textAnswer)
                        .font(Typography.body)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                        .frame(minHeight: 120)
                        .padding(Spacing.sm)
                        .background(DesignSystem.Colors.secondary)
                        .cornerRadius(Corners.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: Corners.md)
                                .stroke(
                                    viewModel.validationError != nil
                                        ? DesignSystem.Colors.destructive
                                        : DesignSystem.Colors.border,
                                    lineWidth: viewModel.validationError != nil ? 2 : 1
                                )
                        )

                    if viewModel.textAnswer.isEmpty {
                        Text(prompt.placeholder)
                            .font(Typography.caption1)
                            .foregroundStyle(DesignSystem.Colors.mutedForeground)
                            .padding(.top, Spacing.xs)
                    }

                    // Validation error
                    if let error = viewModel.validationError {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(Typography.caption2)
                                .foregroundStyle(DesignSystem.Colors.destructive)

                            Text(error)
                                .font(Typography.caption1)
                                .foregroundStyle(DesignSystem.Colors.destructive)
                        }
                        .padding(.top, Spacing.xs)
                    }
                }

                // Hint Box
                HStack(alignment: .top, spacing: Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .font(Typography.body)
                        .foregroundStyle(DesignSystem.Colors.chart5)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Tip:")
                            .font(Typography.caption1.bold())
                            .foregroundStyle(DesignSystem.Colors.foreground)

                        Text(prompt.hint)
                            .font(Typography.caption1)
                            .foregroundStyle(DesignSystem.Colors.mutedForeground)
                    }
                }
                .padding()
                .background(DesignSystem.Colors.chart5.opacity(0.1))
                .cornerRadius(Corners.md)
            }
        }
    }
}

#Preview("Calibration") {
    ExerciseSheet(
        viewModel: .previewCalibration,
        onUpdateProgress: { _ in },
        onDismiss: {}
    )
}

#Preview("Bias Recognition") {
    ExerciseSheet(
        viewModel: .previewBiasRecognition,
        onUpdateProgress: { _ in },
        onDismiss: {}
    )
}

#Preview("Decision Framework") {
    ExerciseSheet(
        viewModel: .previewDecisionFramework,
        onUpdateProgress: { _ in },
        onDismiss: {}
    )
}
