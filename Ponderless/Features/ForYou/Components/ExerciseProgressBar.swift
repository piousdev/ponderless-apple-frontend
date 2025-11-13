//
//  ExerciseProgressBar.swift
//  Ponderless
//
//  Progress bar for exercise sheets
//

import SwiftUI

struct ExerciseProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    @ScaledMetric private var barHeight: CGFloat = ForYouConstants.Sizing.progressBarHeight

    var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Step counter
            Text(String(format: ForYouConstants.TextContent.stepFormat, currentStep, totalSteps))
                .font(Typography.caption1)
                .foregroundStyle(DesignSystem.Colors.mutedForeground)
                .accessibilityLabel("Step \(currentStep) of \(totalSteps)")

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: Corners.full)
                        .fill(DesignSystem.Colors.muted)
                        .frame(height: barHeight)

                    // Progress
                    RoundedRectangle(cornerRadius: Corners.full)
                        .fill(DesignSystem.Colors.primary)
                        .frame(width: geometry.size.width * progress, height: barHeight)
                        .animation(.spring(response: ForYouConstants.Animation.springResponse), value: currentStep)
                }
            }
            .frame(height: barHeight)
            .accessibilityValue("\(Int(progress * 100)) percent complete")
        }
    }
}

#Preview {
    VStack(spacing: Spacing.xl) {
        ExerciseProgressBar(currentStep: 1, totalSteps: 5)
        ExerciseProgressBar(currentStep: 3, totalSteps: 5)
        ExerciseProgressBar(currentStep: 5, totalSteps: 5)
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.xl) {
        ExerciseProgressBar(currentStep: 1, totalSteps: 5)
        ExerciseProgressBar(currentStep: 3, totalSteps: 5)
        ExerciseProgressBar(currentStep: 5, totalSteps: 5)
    }
    .padding()
    .preferredColorScheme(.dark)
}
