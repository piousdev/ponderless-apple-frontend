//
//  TodoContentView.swift
//  Ponderless
//
//  Content view for todo items with title, description, and progress
//

import SwiftUI

struct TodoContentView: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let isInProgress: Bool
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(Typography.headline)
                .foregroundStyle(isCompleted ? DesignSystem.Colors.mutedForeground : DesignSystem.Colors.foreground)

            Text(description)
                .font(Typography.caption1)
                .foregroundStyle(DesignSystem.Colors.mutedForeground)

            if isInProgress && !isCompleted {
                ProgressBadge(currentStep: currentStep, totalSteps: totalSteps)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
        .accessibilityValue(isCompleted ? "Completed" : isInProgress ? "In progress, step \(currentStep) of \(totalSteps)" : "Not started")
    }
}

#Preview("Not Started") {
    TodoContentView(
        title: "Morning Calibration",
        description: "Test your confidence on 5 predictions",
        isCompleted: false,
        isInProgress: false,
        currentStep: 1,
        totalSteps: 5
    )
    .padding()
}

#Preview("In Progress") {
    TodoContentView(
        title: "Morning Calibration",
        description: "Test your confidence on 5 predictions",
        isCompleted: false,
        isInProgress: true,
        currentStep: 3,
        totalSteps: 5
    )
    .padding()
}

#Preview("Completed") {
    TodoContentView(
        title: "Morning Calibration",
        description: "Test your confidence on 5 predictions",
        isCompleted: true,
        isInProgress: false,
        currentStep: 5,
        totalSteps: 5
    )
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.lg) {
        TodoContentView(
            title: "Morning Calibration",
            description: "Test your confidence on 5 predictions",
            isCompleted: false,
            isInProgress: false,
            currentStep: 1,
            totalSteps: 5
        )

        TodoContentView(
            title: "Bias Recognition Exercise",
            description: "2-minute skill builder",
            isCompleted: false,
            isInProgress: true,
            currentStep: 2,
            totalSteps: 3
        )

        TodoContentView(
            title: "Decision Framework",
            description: "Apply EtD to a micro-decision",
            isCompleted: true,
            isInProgress: false,
            currentStep: 4,
            totalSteps: 4
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
