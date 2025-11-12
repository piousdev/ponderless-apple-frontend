//
//  PracticeView.swift
//  Ponderless
//
//  Practice tab with TRAIN and FRAMEWORKS sections
//

import SwiftUI

struct PracticeView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedSegment: PracticeSegment = .train

    var body: some View {
        @Bindable var appState = appState

        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control
                SegmentedPicker(selection: $selectedSegment)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)

                // Segment Subtitle
                Text(selectedSegment.subtitle)
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, Spacing.lg)

                // Content based on segment
                ScrollView {
                    switch selectedSegment {
                    case .train:
                        TrainSectionView()
                            .padding(.horizontal, Spacing.lg)
                    case .frameworks:
                        FrameworksSectionView()
                            .padding(.horizontal, Spacing.lg)
                    }
                }
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Segmented Picker

struct SegmentedPicker: View {
    @Binding var selection: PracticeSegment

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PracticeSegment.allCases, id: \.self) { segment in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selection = segment
                    }
                } label: {
                    Text(segment.title)
                        .font(Typography.headline)
                        .foregroundStyle(selection == segment ? DesignSystem.Colors.onPrimary : DesignSystem.Colors.secondaryForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(
                            selection == segment ?
                            DesignSystem.Colors.primary :
                            Color.clear
                        )
                        .cornerRadius(Corners.md)
                }
            }
        }
        .padding(Spacing.xs)
        .background(DesignSystem.Colors.secondary)
        .cornerRadius(Corners.lg)
    }
}

// MARK: - TRAIN Section

struct TrainSectionView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Skill Categories
            ForEach(SkillCategory.allCases, id: \.self) { category in
                SkillCategoryCard(category: category)
            }

            // Progress Summary
            TrainingProgressSummary()
                .padding(.top, Spacing.lg)
        }
        .padding(.vertical, Spacing.lg)
    }
}

struct SkillCategoryCard: View {
    let category: SkillCategory
    @Environment(AppState.self) private var appState

    var progress: TrainingProgress.SkillProgress? {
        appState.trainingProgress.skillProgress[category]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Colors.onPrimary)
                    .frame(width: Spacing.xxxxl, height: Spacing.xxxxl)
                    .background(category.color)
                    .cornerRadius(Corners.md)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(category.rawValue)
                        .font(Typography.headline)

                    Text(category.description)
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        .lineLimit(2)
                }

                Spacer()

                // Level Badge
                if let progress = progress {
                    VStack(alignment: .trailing, spacing: Spacing.xxs) {
                        Text("Lvl \(progress.level)")
                            .font(Typography.caption.bold())
                            .foregroundStyle(category.color)

                        Text(progress.masteryLevel.rawValue)
                            .font(Typography.caption2)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    }
                }
            }

            // Progress Bar
            if let progress = progress {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: Corners.xs)
                            .fill(DesignSystem.Colors.secondary)
                            .frame(height: Spacing.sm)

                        RoundedRectangle(cornerRadius: Corners.xs)
                            .fill(category.color)
                            .frame(
                                width: geometry.size.width * (Double(progress.experience % 100) / 100.0),
                                height: Spacing.sm
                            )
                    }
                }
                .frame(height: Spacing.sm)

                // Stats
                HStack {
                    Label("\(progress.exercisesCompleted) completed", systemImage: "checkmark.circle.fill")
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)

                    Spacer()

                    Label("\(Int(progress.accuracy * 100))% accuracy", systemImage: "target")
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                }
            }

            // Start Button
            Button {
                // Start training exercise
            } label: {
                HStack {
                    Text("Start 2-min exercise")
                        .font(Typography.subheadline.bold())

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                }
                .foregroundStyle(category.color)
                .padding(.vertical, Spacing.sm)
                .padding(.horizontal, Spacing.md)
                .background(category.color.opacity(0.1))
                .cornerRadius(Corners.sm)
            }
        }
        .padding(Spacing.lg)
        .background(DesignSystem.Colors.background)
        .cardCorners()
        .cardShadow()
    }
}

struct TrainingProgressSummary: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Your Progress")
                .font(Typography.headline)

            HStack(spacing: Spacing.lg) {
                ProgressStatCard(
                    title: "Total Exercises",
                    value: "\(appState.trainingProgress.totalExercisesCompleted)",
                    icon: "checkmark.circle.fill",
                    color: DesignSystem.Colors.success
                )

                ProgressStatCard(
                    title: "Avg Accuracy",
                    value: "\(Int(appState.trainingProgress.averageAccuracy * 100))%",
                    icon: "target",
                    color: DesignSystem.Colors.primary
                )

                ProgressStatCard(
                    title: "Streak",
                    value: "\(appState.trainingProgress.dailyStreak)d",
                    icon: "flame.fill",
                    color: DesignSystem.Colors.warning
                )
            }
        }
        .padding(Spacing.lg)
        .background(DesignSystem.Colors.secondary)
        .cornerRadius(Corners.lg)
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(Typography.headline)

            Text(title)
                .font(Typography.caption2)
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(DesignSystem.Colors.background)
        .cornerRadius(Corners.sm)
    }
}

// MARK: - FRAMEWORKS Section

struct FrameworksSectionView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Framework Types
            ForEach(FrameworkType.allCases, id: \.self) { type in
                FrameworkCard(type: type)
            }

            // Recent Applications
            RecentFrameworkApplications()
                .padding(.top, Spacing.lg)
        }
        .padding(.vertical, Spacing.lg)
    }
}

struct FrameworkCard: View {
    let type: FrameworkType

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Colors.onPrimary)
                    .frame(width: Spacing.xxxxl, height: Spacing.xxxxl)
                    .background(type.color)
                    .cornerRadius(Corners.md)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(type.rawValue)
                        .font(Typography.headline)

                    Text(type.description)
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        .lineLimit(2)
                }

                Spacer()
            }

            // Key Features
            VStack(alignment: .leading, spacing: Spacing.xs) {
                ForEach(featuresFor(type), id: \.self) { feature in
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(Typography.caption)
                            .foregroundStyle(type.color.opacity(0.7))

                        Text(feature)
                            .font(Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    }
                }
            }

            // Apply Button
            Button {
                // Start framework application
            } label: {
                HStack {
                    Text("Apply to micro-decision")
                        .font(Typography.subheadline.bold())

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                }
                .foregroundStyle(type.color)
                .padding(.vertical, Spacing.sm)
                .padding(.horizontal, Spacing.md)
                .background(type.color.opacity(0.1))
                .cornerRadius(Corners.sm)
            }
        }
        .padding(Spacing.lg)
        .background(DesignSystem.Colors.background)
        .cardCorners()
        .cardShadow()
    }

    func featuresFor(_ type: FrameworkType) -> [String] {
        switch type {
        case .evidenceToDecision:
            return ["Evaluate evidence quality", "Weight decision criteria", "Compare alternatives"]
        case .toulminArgumentation:
            return ["Build strong claims", "Support with evidence", "Address rebuttals"]
        case .superforecasting:
            return ["Fermi estimation", "Reference class forecasting", "Probability calibration"]
        case .problemDecomposition:
            return ["Issue tree analysis", "Identify assumptions", "Test hypotheses"]
        }
    }
}

struct RecentFrameworkApplications: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recent Applications")
                .font(Typography.headline)

            VStack(spacing: Spacing.sm) {
                RecentApplicationRow(
                    framework: "Evidence-to-Decision",
                    decision: "Career move evaluation",
                    date: Date().addingTimeInterval(-86400)
                )

                RecentApplicationRow(
                    framework: "Toulmin Argumentation",
                    decision: "Product feature proposal",
                    date: Date().addingTimeInterval(-172800)
                )

                RecentApplicationRow(
                    framework: "Superforecasting",
                    decision: "Market trend prediction",
                    date: Date().addingTimeInterval(-259200)
                )
            }
        }
        .padding(Spacing.lg)
        .background(DesignSystem.Colors.secondary)
        .cornerRadius(Corners.lg)
    }
}

struct RecentApplicationRow: View {
    let framework: String
    let decision: String
    let date: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(framework)
                    .font(Typography.caption.bold())
                    .foregroundStyle(DesignSystem.Colors.primary)

                Text(decision)
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.foreground)
            }

            Spacer()

            Text(date, style: .relative)
                .font(Typography.caption2)
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    PracticeView()
        .environment(AppState())
}