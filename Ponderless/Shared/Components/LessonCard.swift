//
//  LessonCard.swift
//  Ponderless
//
//  Reusable lesson card component
//

import SwiftUI

struct LessonCard: View {
    let lesson: Lesson
    @Environment(AppState.self) private var appState

    private var progress: LessonProgress? {
        appState.userProgress.lessonProgress[lesson.id]
    }

    private var isCompleted: Bool {
        progress?.completionStatus == .completed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                // Category Badge
                HStack(spacing: Spacing.xs) {
                    Image(systemName: lesson.category.icon)
                        .font(Typography.caption)
                    Text(lesson.category.rawValue)
                        .font(Typography.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(lesson.category.color.opacity(0.2))
                .foregroundStyle(lesson.category.color)
                .clipShape(Capsule())

                Spacer()

                // Premium/Lock Badge
                if lesson.isPremium && !appState.isPremiumUser {
                    Image(systemName: "crown.fill")
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.warning)
                } else if lesson.isLocked {
                    Image(systemName: "lock.fill")
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                }
            }

            // Title & Subtitle
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(lesson.title)
                    .font(Typography.headline)
                    .foregroundStyle(DesignSystem.Colors.foreground)
                    .lineLimit(2)

                Text(lesson.subtitle)
                    .font(Typography.subheadline)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    .lineLimit(2)
            }

            // Tags
            if !lesson.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.xs + Spacing.xxs) {
                        ForEach(lesson.tags, id: \.self) { tag in
                            Text(tag)
                                .font(Typography.caption2)
                                .padding(.horizontal, Spacing.xs + Spacing.xxs)
                                .padding(.vertical, Spacing.xxs)
                                .background(DesignSystem.Colors.muted)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // Footer
            HStack {
                // Duration
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "clock")
                        .font(Typography.caption)
                    Text(formatDuration(lesson.estimatedDuration))
                        .font(Typography.caption)
                }
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)

                Spacer()

                // Difficulty
                DifficultyBadge(difficulty: lesson.difficulty)

                Spacer()

                // Progress Indicator
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DesignSystem.Colors.success)
                        .font(Typography.body)
                } else if progress?.completionStatus == .inProgress {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
        }
        .padding(Spacing.lg)
        .background(DesignSystem.Colors.secondary)
        .cornerRadius(Corners.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Corners.lg)
                .stroke(isCompleted ? DesignSystem.Colors.success.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .cardShadow()
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(index < difficultyLevel ? difficulty.color : DesignSystem.Colors.muted)
                    .frame(width: Spacing.xs + Spacing.xxs, height: Spacing.xs + Spacing.xxs)
            }
        }
    }

    private var difficultyLevel: Int {
        switch difficulty {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        }
    }
}