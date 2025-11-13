//
//  ExerciseSheetViewModel.swift
//  Ponderless
//
//  ViewModel for ExerciseSheet with step navigation and answer state
//

import Foundation
import Observation

@MainActor
@Observable
final class ExerciseSheetViewModel {
    // MARK: - Properties

    let todo: DailyTodo
    var currentStep: Int = 1
    var onComplete: () -> Void

    // Answer state
    var confidenceLevel: Double = ForYouConstants.Confidence.defaultValue

    var selectedChoice: Int?
    var textAnswer: String = ""

    // Validation state
    var validationError: String?

    var totalSteps: Int {
        todo.exerciseType.stepCount
    }

    var isFirstStep: Bool {
        currentStep == 1
    }

    var isLastStep: Bool {
        currentStep >= totalSteps
    }

    var canProceed: Bool {
        // Clear previous validation error
        validationError = nil

        // Validation logic based on exercise type
        switch todo.exerciseType {
        case .calibration:
            // Validate confidence slider value
            return InputValidator.validateConfidence(confidenceLevel)

        case .biasRecognition:
            guard selectedChoice != nil else {
                validationError = "Please select an answer"
                return false
            }
            return true

        case .decisionFramework:
            // Validate text input
            let result = InputValidator.validateExerciseInput(textAnswer)

            if !result.isValid {
                validationError = result.errors.first
                return false
            }

            // Update with sanitized value
            if result.sanitizedValue != textAnswer {
                textAnswer = result.sanitizedValue
            }

            return true
        }
    }

    // MARK: - Initialization

    init(todo: DailyTodo, initialStep: Int = 1, onComplete: @escaping () -> Void) {
        self.todo = todo
        self.currentStep = initialStep
        self.onComplete = onComplete
    }

    // MARK: - Navigation

    func nextStep() {
        guard currentStep < totalSteps else { return }
        guard canProceed else { return }

        // Save current answer
        saveCurrentAnswer()

        // Reset answer state for next step
        resetAnswerState()

        currentStep += 1
    }

    func previousStep() {
        guard currentStep > 1 else { return }
        currentStep -= 1

        // Load previous answer if available
        loadPreviousAnswer()
    }

    func complete() {
        guard isLastStep else { return }
        guard canProceed else { return }

        // Save final answer
        saveCurrentAnswer()

        // Call completion handler
        onComplete()
    }

    // MARK: - Answer Management

    private func saveCurrentAnswer() {
        // In a real app, this would save to repository or AppState
        // For now, just log
        print("Saving answer for step \(currentStep)")
    }

    private func resetAnswerState() {
        confidenceLevel = ForYouConstants.Confidence.defaultValue
        selectedChoice = nil
        textAnswer = ""
    }

    private func loadPreviousAnswer() {
        // In a real app, this would load from saved state
        // For now, just reset
        resetAnswerState()
    }

    // MARK: - Exercise Content

    func getCalibrationQuestion() -> String {
        ForYouConstants.CalibrationQuestions.question(for: currentStep)
    }

    func getBiasScenario() -> ForYouConstants.BiasScenario? {
        ForYouConstants.BiasScenarios.scenario(for: currentStep)
    }

    func getDecisionFrameworkPrompt() -> ForYouConstants.FrameworkPrompt? {
        ForYouConstants.DecisionFramework.prompt(for: currentStep)
    }

    // MARK: - Input Validation

    func validateTextInput(_ text: String) -> String {
        // Limit length
        let trimmed = String(text.prefix(ForYouConstants.Validation.maxTextLength))

        // Filter invalid characters
        let filtered = trimmed.unicodeScalars.filter { scalar in
            ForYouConstants.Validation.allowedCharacterSet.contains(scalar)
        }

        return String(String.UnicodeScalarView(filtered))
    }

    func updateTextAnswer(_ text: String) {
        textAnswer = validateTextInput(text)
    }
}

// MARK: - Preview Helpers

extension ExerciseSheetViewModel {
    static let previewCalibration = ExerciseSheetViewModel(
        todo: DailyTodo(
            title: "Morning Calibration",
            description: "Test your confidence on 5 predictions",
            icon: .waveSignal,
            isCompleted: false,
            points: 10,
            exerciseType: .calibration
        ),
        onComplete: {}
    )

    static let previewBiasRecognition = ExerciseSheetViewModel(
        todo: DailyTodo(
            title: "Bias Recognition Exercise",
            description: "2-minute skill builder",
            icon: .machineLearning,
            isCompleted: false,
            points: 15,
            exerciseType: .biasRecognition
        ),
        onComplete: {}
    )

    static let previewDecisionFramework = ExerciseSheetViewModel(
        todo: DailyTodo(
            title: "Decision Framework",
            description: "Apply EtD to a micro-decision",
            icon: .constructionHouse,
            isCompleted: false,
            points: 20,
            exerciseType: .decisionFramework
        ),
        onComplete: {}
    )
}
