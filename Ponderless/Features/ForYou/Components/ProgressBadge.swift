//
//  ProgressBadge.swift
//  Ponderless
//
//  In-progress indicator badge for todos
//

import SwiftUI

struct ProgressBadge: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "clock.fill")
            Text(ForYouConstants.TextContent.inProgressLabel)
                .bold()
            Text("·")
            Text(String(format: ForYouConstants.TextContent.stepFormat, currentStep, totalSteps))
        }
        .font(Typography.caption2)
        .foregroundStyle(DesignSystem.Colors.primary)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(DesignSystem.Colors.primary.opacity(0.1))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .accessibilityLabel("\(ForYouConstants.TextContent.inProgressLabel): step \(currentStep) of \(totalSteps)")
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        ProgressBadge(currentStep: 1, totalSteps: 5)
        ProgressBadge(currentStep: 3, totalSteps: 4)
        ProgressBadge(currentStep: 2, totalSteps: 3)
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.md) {
        ProgressBadge(currentStep: 1, totalSteps: 5)
        ProgressBadge(currentStep: 3, totalSteps: 4)
    }
    .padding()
    .preferredColorScheme(.dark)
}
