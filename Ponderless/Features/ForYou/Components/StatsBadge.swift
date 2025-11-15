//
//  StatsBadge.swift
//  Ponderless
//
//  Reusable stats badge for streak and stars display
//

import SwiftUI

struct StatsBadge: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(Typography.body)
                    .foregroundStyle(iconColor)

                Text(value)
                    .font(Typography.body.bold())
                    .foregroundStyle(DesignSystem.Colors.foreground)
                    .lineLimit(1)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .fixedSize(horizontal: true, vertical: false)
            .frame(minHeight: Spacing.Layout.minTouchTarget)
            .background(DesignSystem.Colors.secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
        }
        .accessibilityLabel(label)
        .accessibilityValue(value)
        .accessibilityHint(ForYouConstants.AccessibilityLabels.badgeHint)
    }
}

#Preview("Streak Badge") {
    StatsBadge(
        icon: "flame.fill",
        value: "7",
        label: "Daily streak",
        iconColor: DesignSystem.Colors.chart3,
        action: {}
    )
    .padding()
}

#Preview("Stars Badge") {
    StatsBadge(
        icon: "star.fill",
        value: "150",
        label: "Total stars",
        iconColor: DesignSystem.Colors.chart5,
        action: {}
    )
    .padding()
}

#Preview("Large Numbers") {
    VStack(spacing: Spacing.md) {
        HStack(spacing: Spacing.sm) {
            StatsBadge(
                icon: "flame.fill",
                value: "999",
                label: "Daily streak",
                iconColor: DesignSystem.Colors.chart3,
                action: {}
            )
            
            StatsBadge(
                icon: "star.fill",
                value: "9999",
                label: "Total stars",
                iconColor: DesignSystem.Colors.chart5,
                action: {}
            )
        }
        
        HStack(spacing: Spacing.sm) {
            StatsBadge(
                icon: "flame.fill",
                value: "12",
                label: "Daily streak",
                iconColor: DesignSystem.Colors.chart3,
                action: {}
            )
            
            StatsBadge(
                icon: "star.fill",
                value: "156",
                label: "Total stars",
                iconColor: DesignSystem.Colors.chart5,
                action: {}
            )
        }
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.md) {
        StatsBadge(
            icon: "flame.fill",
            value: "7",
            label: "Daily streak",
            iconColor: DesignSystem.Colors.chart3,
            action: {}
        )

        StatsBadge(
            icon: "star.fill",
            value: "150",
            label: "Total stars",
            iconColor: DesignSystem.Colors.chart5,
            action: {}
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
