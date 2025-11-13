//
//  TodoIconView.swift
//  Ponderless
//
//  Icon view for todo items with completion state
//

import SwiftUI

struct TodoIconView: View {
    let icon: TodoIcon
    let isCompleted: Bool

    @ScaledMetric private var iconSize: CGFloat = Spacing.lg
    @ScaledMetric private var circleSize: CGFloat = Spacing.Layout.minTouchTarget

    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? DesignSystem.Colors.chart2 : DesignSystem.Colors.primary.opacity(0.1))
                .frame(width: circleSize, height: circleSize)

            Group {
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.primaryForeground)
                } else {
                    iconView(for: icon)
                }
            }
        }
        .accessibilityLabel(isCompleted ? "Completed" : icon.displayName)
    }

    @ViewBuilder
    private func iconView(for icon: TodoIcon) -> some View {
        switch icon {
        case .constructionHouse:
            ConstructionHouse()
                .fill(DesignSystem.Colors.primary)
                .frame(width: iconSize, height: iconSize)
        case .waveSignal:
            WaveSignal()
                .fill(DesignSystem.Colors.primary)
                .frame(width: iconSize, height: iconSize)
        case .machineLearning:
            MachineLearning()
                .fill(DesignSystem.Colors.primary)
                .frame(width: iconSize, height: iconSize)
        }
    }
}

#Preview("All Icons - Not Completed") {
    HStack(spacing: Spacing.lg) {
        TodoIconView(icon: .waveSignal, isCompleted: false)
        TodoIconView(icon: .machineLearning, isCompleted: false)
        TodoIconView(icon: .constructionHouse, isCompleted: false)
    }
    .padding()
}

#Preview("All Icons - Completed") {
    HStack(spacing: Spacing.lg) {
        TodoIconView(icon: .waveSignal, isCompleted: true)
        TodoIconView(icon: .machineLearning, isCompleted: true)
        TodoIconView(icon: .constructionHouse, isCompleted: true)
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.lg) {
        HStack(spacing: Spacing.lg) {
            TodoIconView(icon: .waveSignal, isCompleted: false)
            TodoIconView(icon: .machineLearning, isCompleted: false)
            TodoIconView(icon: .constructionHouse, isCompleted: false)
        }

        HStack(spacing: Spacing.lg) {
            TodoIconView(icon: .waveSignal, isCompleted: true)
            TodoIconView(icon: .machineLearning, isCompleted: true)
            TodoIconView(icon: .constructionHouse, isCompleted: true)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
