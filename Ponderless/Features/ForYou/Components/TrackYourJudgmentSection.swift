//
//  TrackYourJudgmentSection.swift
//  Ponderless
//
//  Refactored judgment tracking section with extracted MetricCard components
//

import SwiftUI

struct TrackYourJudgmentSection: View {
    let calculator: CalibrationCalculator

    private var brierScore: String {
        String(format: "%.2f", calculator.getBrierScore())
    }

    private var calibrationPercentage: String {
        "\(calculator.getCalibrationPercentage())%"
    }

    private var averageConfidence: String {
        "\(calculator.getAverageConfidence())%"
    }

    private var totalPredictions: String {
        "\(calculator.getTotalPredictions())"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(ForYouConstants.TextContent.trackJudgmentTitle)
                    .font(Typography.title2.bold())
                    .foregroundStyle(DesignSystem.Colors.foreground)

                Text(ForYouConstants.TextContent.trackJudgmentSubtitle)
                    .font(Typography.caption1)
                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
            }

            // Calibration Chart with non-clipping card style
            CalibrationChart(calculator: calculator)
                .frame(height: ForYouConstants.Sizing.calibrationChartHeight)
                .cardPadding()
                .background(
                    RoundedRectangle(cornerRadius: Corners.Component.card, style: .continuous)
                        .fill(DesignSystem.Colors.secondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Corners.Component.card, style: .continuous)
                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

            // Metrics Grid
            VStack(spacing: Spacing.md) {
                HStack(spacing: Spacing.md) {
                    MetricCard(
                        title: ForYouConstants.Metrics.brierScoreTitle,
                        value: brierScore,
                        trend: .improving,
                        helpText: ForYouConstants.Metrics.brierScoreHelp
                    )

                    MetricCard(
                        title: ForYouConstants.Metrics.calibrationTitle,
                        value: calibrationPercentage,
                        trend: .stable,
                        helpText: ForYouConstants.Metrics.calibrationHelp
                    )
                }

                HStack(spacing: Spacing.md) {
                    MetricCard(
                        title: ForYouConstants.Metrics.confidenceTitle,
                        value: averageConfidence,
                        trend: .improving,
                        helpText: ForYouConstants.Metrics.confidenceHelp
                    )

                    MetricCard(
                        title: ForYouConstants.Metrics.predictionsTitle,
                        value: totalPredictions,
                        trend: .neutral,
                        helpText: ForYouConstants.Metrics.predictionsHelp
                    )
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        TrackYourJudgmentSection(calculator: MockCalibrationCalculator.preview)
            .padding()
    }
}

#Preview("Perfect Calibration") {
    ScrollView {
        TrackYourJudgmentSection(calculator: MockCalibrationCalculator.previewPerfectCalibration)
            .padding()
    }
}

#Preview("Poor Calibration") {
    ScrollView {
        TrackYourJudgmentSection(calculator: MockCalibrationCalculator.previewPoorCalibration)
            .padding()
    }
}

#Preview("Dark Mode") {
    ScrollView {
        TrackYourJudgmentSection(calculator: MockCalibrationCalculator.preview)
            .padding()
    }
    .preferredColorScheme(.dark)
}
