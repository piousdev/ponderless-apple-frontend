//
//  StarsSheetView.swift
//  Ponderless
//
//  Refactored stars sheet with cleaner structure
//

import SwiftUI

struct StarsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let progressProvider: TrainingProgressProvider

    @ScaledMetric private var iconSize: CGFloat = 30
    @ScaledMetric private var circleDiameter: CGFloat = ForYouConstants.Sizing.badgeCircleDiameter

    private var currentLevel: Int {
        progressProvider.totalStars / ForYouConstants.Gamification.starsPerLevel
    }

    private var nextLevel: Int {
        currentLevel + 1
    }

    private var starsInCurrentLevel: Int {
        progressProvider.totalStars % ForYouConstants.Gamification.starsPerLevel
    }

    private var starsToNextLevel: Int {
        ForYouConstants.Gamification.starsPerLevel - starsInCurrentLevel
    }

    private var progressPercentage: Double {
        Double(starsInCurrentLevel) / Double(ForYouConstants.Gamification.starsPerLevel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    // Star Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.chart5, DesignSystem.Colors.chart3],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: circleDiameter, height: circleDiameter)

                        Image(systemName: "star.fill")
                            .font(.system(size: iconSize))
                            .foregroundStyle(DesignSystem.Colors.primaryForeground)
                    }
                    .accessibilityLabel("Star icon")

                    // Stars Count
                    HStack(spacing: Spacing.xs) {
                        Text("\(progressProvider.totalStars)")
                            .font(Typography.title2.bold())
                            .foregroundStyle(DesignSystem.Colors.foreground)

                        Text("Stars")
                            .font(Typography.title2)
                            .foregroundStyle(DesignSystem.Colors.foreground)
                    }
                    .accessibilityLabel("\(progressProvider.totalStars) stars")

                    // Earned Stars Message
                    Text(String(format: ForYouConstants.TextContent.starsSubtitleFormat, progressProvider.totalStars))
                        .font(Typography.body)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)

                    // Next Level Message
                    Text("You're \(starsToNextLevel) away to Level \(nextLevel)")
                        .font(Typography.body.bold())
                        .foregroundStyle(DesignSystem.Colors.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)

                    // Progress Bar Section
                    VStack(spacing: Spacing.md) {
                        // Progress Bar with Milestone
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: Corners.full)
                                .fill(DesignSystem.Colors.muted)
                                .frame(height: 12)

                            // Progress fill
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: Corners.full)
                                    .fill(
                                        LinearGradient(
                                            colors: [DesignSystem.Colors.chart5, DesignSystem.Colors.chart3],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(20, progressPercentage * geometry.size.width), height: 12)
                                    .animation(.spring(response: ForYouConstants.Animation.springResponse), value: progressPercentage)
                            }
                            .frame(height: 12)

                            // Milestone circle at the end
                            HStack {
                                Spacer()

                                ZStack {
                                    Circle()
                                        .fill(progressPercentage >= 1.0 ? DesignSystem.Colors.chart2 : DesignSystem.Colors.muted)
                                        .frame(
                                            width: ForYouConstants.Sizing.progressMilestoneCircleSize,
                                            height: ForYouConstants.Sizing.progressMilestoneCircleSize
                                        )

                                    if progressPercentage >= 1.0 {
                                        Image(systemName: "checkmark")
                                            .font(Typography.body.bold())
                                            .foregroundStyle(DesignSystem.Colors.primaryForeground)
                                    } else {
                                        Circle()
                                            .stroke(DesignSystem.Colors.border, lineWidth: 2)
                                            .fill(DesignSystem.Colors.background)
                                            .frame(
                                                width: ForYouConstants.Sizing.progressMilestoneInnerCircleSize,
                                                height: ForYouConstants.Sizing.progressMilestoneInnerCircleSize
                                            )
                                    }
                                }
                                .offset(x: 16) // Align to the end
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .accessibilityLabel("Level progress")
                        .accessibilityValue("\(Int(progressPercentage * 100)) percent to next level")

                        // Level Labels
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Current Level")
                                    .font(Typography.caption1)
                                    .foregroundStyle(DesignSystem.Colors.mutedForeground)

                                Text("Level \(currentLevel)")
                                    .font(Typography.headline.bold())
                                    .foregroundStyle(DesignSystem.Colors.foreground)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: Spacing.xs) {
                                Text("Next Level")
                                    .font(Typography.caption1)
                                    .foregroundStyle(DesignSystem.Colors.mutedForeground)

                                Text("Level \(nextLevel)")
                                    .font(Typography.headline.bold())
                                    .foregroundStyle(DesignSystem.Colors.primary)
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                    }

                    // Additional Info Card
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(Typography.body)
                                .foregroundStyle(DesignSystem.Colors.primary)

                            Text("How to earn stars")
                                .font(Typography.headline)
                                .foregroundStyle(DesignSystem.Colors.foreground)
                        }

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Text("•")
                                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
                                Text("Complete daily exercises")
                                    .font(Typography.body)
                                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
                            }

                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Text("•")
                                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
                                Text("Maintain your daily streak")
                                    .font(Typography.body)
                                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
                            }

                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Text("•")
                                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
                                Text("Improve your calibration accuracy")
                                    .font(Typography.body)
                                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(DesignSystem.Colors.secondary)
                    .cornerRadius(Corners.Component.card)
                    .padding(.horizontal)
                }
                .padding(.vertical, Spacing.xl)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle(ForYouConstants.TextContent.starsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    StarsSheetView(progressProvider: MockTrainingProgressProvider.preview)
}

#Preview("High Stars") {
    StarsSheetView(progressProvider: MockTrainingProgressProvider.previewWithHighStreak)
}

#Preview("New User") {
    StarsSheetView(progressProvider: MockTrainingProgressProvider.previewNewUser)
}

#Preview("Dark Mode") {
    StarsSheetView(progressProvider: MockTrainingProgressProvider.preview)
        .preferredColorScheme(.dark)
}
