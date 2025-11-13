//
//  ExerciseNavigationButtons.swift
//  Ponderless
//
//  Navigation buttons for exercise sheets
//

import SwiftUI

struct ExerciseNavigationButtons: View {
    let currentStep: Int
    let totalSteps: Int
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onComplete: () -> Void

    var isFirstStep: Bool {
        currentStep == 1
    }

    var isLastStep: Bool {
        currentStep >= totalSteps
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            if !isFirstStep {
                NavigationButton(
                    title: ForYouConstants.TextContent.previousButton,
                    style: .secondary,
                    action: onPrevious
                )
            }

            if isLastStep {
                NavigationButton(
                    title: ForYouConstants.TextContent.completeButton,
                    icon: "checkmark.circle.fill",
                    style: .success,
                    action: onComplete
                )
            } else {
                NavigationButton(
                    title: ForYouConstants.TextContent.nextButton,
                    style: .primary,
                    action: onNext
                )
            }
        }
    }
}

#Preview("First Step") {
    ExerciseNavigationButtons(
        currentStep: 1,
        totalSteps: 5,
        onPrevious: {},
        onNext: {},
        onComplete: {}
    )
    .padding()
}

#Preview("Middle Step") {
    ExerciseNavigationButtons(
        currentStep: 3,
        totalSteps: 5,
        onPrevious: {},
        onNext: {},
        onComplete: {}
    )
    .padding()
}

#Preview("Last Step") {
    ExerciseNavigationButtons(
        currentStep: 5,
        totalSteps: 5,
        onPrevious: {},
        onNext: {},
        onComplete: {}
    )
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.lg) {
        ExerciseNavigationButtons(
            currentStep: 1,
            totalSteps: 5,
            onPrevious: {},
            onNext: {},
            onComplete: {}
        )

        ExerciseNavigationButtons(
            currentStep: 3,
            totalSteps: 5,
            onPrevious: {},
            onNext: {},
            onComplete: {}
        )

        ExerciseNavigationButtons(
            currentStep: 5,
            totalSteps: 5,
            onPrevious: {},
            onNext: {},
            onComplete: {}
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
