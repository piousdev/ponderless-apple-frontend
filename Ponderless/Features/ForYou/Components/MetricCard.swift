//
//  MetricCard.swift
//  Ponderless
//
//  Card displaying a single metric with trend indicator
//

import SwiftUI

struct MetricCard: View {
    enum Trend {
        case improving
        case declining
        case stable
        case neutral

        var color: Color {
            switch self {
            case .improving: return DesignSystem.Colors.chart2
            case .declining: return DesignSystem.Colors.destructive
            case .stable: return DesignSystem.Colors.primary
            case .neutral: return DesignSystem.Colors.mutedForeground
            }
        }

        var icon: String {
            switch self {
            case .improving: return "arrow.up.right"
            case .declining: return "arrow.down.right"
            case .stable: return "arrow.right"
            case .neutral: return "minus"
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .improving: return ForYouConstants.Metrics.improvingTrend
            case .declining: return ForYouConstants.Metrics.decliningTrend
            case .stable: return ForYouConstants.Metrics.stableTrend
            case .neutral: return ForYouConstants.Metrics.neutralTrend
            }
        }
    }

    let title: String
    let value: String
    let trend: Trend
    let helpText: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(title)
                    .font(Typography.caption1)
                    .foregroundStyle(DesignSystem.Colors.mutedForeground)

                Spacer()

                Image(systemName: trend.icon)
                    .font(Typography.caption1)
                    .foregroundStyle(trend.color)
            }

            Text(value)
                .font(Typography.title2.bold())
                .foregroundStyle(DesignSystem.Colors.foreground)

            Text(helpText)
                .font(Typography.caption2)
                .foregroundStyle(DesignSystem.Colors.mutedForeground)
        }
        .cardStyle()
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value). \(helpText). \(trend.accessibilityLabel)")
        .accessibilityHint(ForYouConstants.AccessibilityLabels.metricCard)
    }
}

#Preview("All Trends") {
    VStack(spacing: Spacing.md) {
        HStack(spacing: Spacing.md) {
            MetricCard(
                title: "Brier Score",
                value: "0.18",
                trend: .improving,
                helpText: "Lower is better"
            )

            MetricCard(
                title: "Calibration",
                value: "85%",
                trend: .stable,
                helpText: "Prediction accuracy"
            )
        }

        HStack(spacing: Spacing.md) {
            MetricCard(
                title: "Confidence",
                value: "72%",
                trend: .declining,
                helpText: "Average confidence"
            )

            MetricCard(
                title: "Predictions",
                value: "47",
                trend: .neutral,
                helpText: "This week"
            )
        }
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.md) {
        HStack(spacing: Spacing.md) {
            MetricCard(
                title: "Brier Score",
                value: "0.18",
                trend: .improving,
                helpText: "Lower is better"
            )

            MetricCard(
                title: "Calibration",
                value: "85%",
                trend: .stable,
                helpText: "Prediction accuracy"
            )
        }

        HStack(spacing: Spacing.md) {
            MetricCard(
                title: "Confidence",
                value: "72%",
                trend: .improving,
                helpText: "Average confidence"
            )

            MetricCard(
                title: "Predictions",
                value: "47",
                trend: .neutral,
                helpText: "This week"
            )
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
