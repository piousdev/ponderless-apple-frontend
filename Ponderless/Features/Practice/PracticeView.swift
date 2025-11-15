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
                // Modern Segmented Control
                ModernSegmentedPicker(selection: $selectedSegment)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.sm)

                // Segment Subtitle with subtle animation
                Text(selectedSegment.subtitle)
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    .padding(.top, Spacing.xs)
                    .padding(.bottom, Spacing.md)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .id(selectedSegment)

                // Content based on segment
                ScrollView {
                    switch selectedSegment {
                    case .train:
                        TrainSectionView()
                            .padding(.horizontal, Spacing.xl)
                            .padding(.top, Spacing.md)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case .frameworks:
                        FrameworksSectionView()
                            .padding(.horizontal, Spacing.xl)
                            .padding(.top, Spacing.md)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .background(DesignSystem.Colors.background)
        }
    }
}

// MARK: - Segmented Picker

struct ModernSegmentedPicker: View {
    @Binding var selection: PracticeSegment
    @Namespace private var animation

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(PracticeSegment.allCases, id: \.self) { segment in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selection = segment
                    }
                } label: {
                    VStack(spacing: Spacing.xs) {
                        Text(segment.title)
                            .font(Typography.headline)
                            .foregroundStyle(
                                selection == segment ? 
                                DesignSystem.Colors.foreground : 
                                DesignSystem.Colors.secondaryForeground
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background {
                                if selection == segment {
                                    RoundedRectangle(cornerRadius: Corners.md, style: .continuous)
                                        .fill(DesignSystem.Colors.background)
                                        .shadow(style: .sm)
                                        .matchedGeometryEffect(id: "segment", in: animation)
                                }
                            }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.xxs)
        .background {
            RoundedRectangle(cornerRadius: Corners.lg, style: .continuous)
                .fill(DesignSystem.Colors.secondary)
        }
    }
}

// MARK: - TRAIN Section

struct TrainSectionView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Progress Summary at the top
            TrainingProgressSummary()
            
            // Skill Categories below
            ForEach(SkillCategory.allCases, id: \.self) { category in
                SkillCategoryCard(category: category)
            }
        }
        .padding(.bottom, Spacing.xxl)
    }
}

struct SkillCategoryCard: View {
    let category: SkillCategory
    @Environment(AppState.self) private var appState

    var progress: TrainingProgress.SkillProgress? {
        appState.trainingProgress.skillProgress[category]
    }

    var body: some View {
        NavigationLink(destination: TrainingExercisesListView(skillCategory: category)) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Header with modern icon design
                HStack(spacing: Spacing.md) {
                    // Modern Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [category.color, category.color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(category.rawValue)
                            .font(Typography.headline)
                            .foregroundStyle(DesignSystem.Colors.foreground)
                        
                        Text(category.description)
                            .font(Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer(minLength: Spacing.md)
                    
                    // Modern Level Badge
                    if let progress = progress {
                        VStack(spacing: Spacing.xxs) {
                            Text("\(progress.level)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(category.color)
                            
                            Text("LEVEL")
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                                .tracking(0.5)
                        }
                        .frame(minWidth: 52)
                        .padding(.vertical, Spacing.sm)
                        .padding(.horizontal, Spacing.xs)
                        .background {
                            RoundedRectangle(cornerRadius: Corners.sm, style: .continuous)
                                .fill(category.color.opacity(0.12))
                        }
                    }
                }
                
                // Modern Progress Bar
                if let progress = progress {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text(progress.masteryLevel.rawValue.uppercased())
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(category.color)
                                .tracking(0.3)
                            
                            Spacer()
                            
                            Text("\(progress.experience % 100)/100 XP")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                Capsule()
                                    .fill(category.color.opacity(0.12))
                                    .frame(height: 8)
                                
                                // Progress with gradient
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [category.color, category.color.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * (Double(progress.experience % 100) / 100.0),
                                        height: 8
                                    )
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress.experience)
                            }
                        }
                        .frame(height: 8)
                    }
                    
                    // Compact Stats Row
                    HStack(spacing: Spacing.lg) {
                        StatLabel(
                            icon: "checkmark.circle.fill",
                            value: "\(progress.exercisesCompleted)",
                            label: "completed",
                            color: category.color
                        )
                        
                        StatLabel(
                            icon: "checkmark.circle",
                            value: "\(Int(progress.accuracy * 100))%",
                            label: "accuracy",
                            color: category.color
                        )
                    }
                    .padding(.top, Spacing.xs)
                }
                
                // Modern Action Button
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Start 2-min exercise")
                        .font(.system(size: 15, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(category.color)
                .padding(.vertical, Spacing.md)
                .padding(.horizontal, Spacing.lg)
                .background {
                    RoundedRectangle(cornerRadius: Corners.Component.card, style: .continuous)
                        .fill(category.color.opacity(0.12))
                }
            }
            .padding(Spacing.xl)
            .background(DesignSystem.Colors.background)
            .cardCorners()
            .cardBorder()
            .cardShadow()
        }
        .buttonStyle(.plain)
    }
}

// Helper view for stat labels
private struct StatLabel: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color.opacity(0.8))
            
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(DesignSystem.Colors.foreground)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
        }
    }
}

struct TrainingProgressSummary: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Your Progress")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DesignSystem.Colors.foreground)

            HStack(spacing: Spacing.md) {
                ModernProgressStatCard(
                    title: "Total",
                    value: "\(appState.trainingProgress.totalExercisesCompleted)",
                    icon: "chart.bar.fill",
                    gradient: [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.7)]
                )

                ModernProgressStatCard(
                    title: "Accuracy",
                    value: "\(Int(appState.trainingProgress.averageAccuracy * 100))%",
                    icon: "checkmark.circle",
                    gradient: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.7)]
                )

                ModernProgressStatCard(
                    title: "Streak",
                    value: "\(appState.trainingProgress.dailyStreak)",
                    icon: "flame.fill",
                    gradient: [DesignSystem.Colors.warning, DesignSystem.Colors.warning.opacity(0.7)],
                    suffix: "d"
                )
            }
        }
        .padding(Spacing.xl)
        .background(DesignSystem.Colors.secondary)
        .cornerRadiusDesign(Corners.Component.card)
        .cardBorder()
    }
}

struct ModernProgressStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    var suffix: String = ""

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: Spacing.xxs) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(DesignSystem.Colors.foreground)
                    
                    if !suffix.isEmpty {
                        Text(suffix)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    }
                }

                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .background(DesignSystem.Colors.background)
            .cornerRadiusDesign(Corners.Component.card)
            .borderedCorners(radius: Corners.Component.card, borderColor: DesignSystem.Colors.border.opacity(0.5), borderWidth: 0.5)
    }
}

// MARK: - FRAMEWORKS Section

struct FrameworksSectionView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Recent Applications at the top
            RecentFrameworkApplications()
            
            // Framework Types below
            ForEach(FrameworkType.allCases, id: \.self) { type in
                FrameworkCard(type: type)
            }
        }
        .padding(.bottom, Spacing.xxl)
    }
}

struct FrameworkCard: View {
    let type: FrameworkType
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Modern Header
            HStack(spacing: Spacing.md) {
                // Modern Icon with gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [type.color, type.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(type.rawValue)
                        .font(Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.foreground)

                    Text(type.description)
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            // Modern Key Features
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(featuresFor(type), id: \.self) { feature in
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(type.color.opacity(0.8))

                        Text(feature)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    }
                }
            }
            .padding(.vertical, Spacing.xs)

            // Modern Apply Button
            Button {
                // Start framework application
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Apply to micro-decision")
                        .font(.system(size: 15, weight: .semibold))

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(type.color)
                .padding(.vertical, Spacing.md)
                .padding(.horizontal, Spacing.lg)
                .background {
                    RoundedRectangle(cornerRadius: Corners.Component.card, style: .continuous)
                        .fill(type.color.opacity(0.12))
                }
            }
            .buttonStyle(.plain)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
        }
        .padding(Spacing.xl)
        .background(DesignSystem.Colors.background)
        .cardCorners()
        .cardBorder()
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
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Recent Applications")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DesignSystem.Colors.foreground)

            VStack(spacing: Spacing.md) {
                ModernApplicationRow(
                    framework: "Evidence-to-Decision",
                    decision: "Career move evaluation",
                    date: Date().addingTimeInterval(-86400),
                    icon: "scale.3d",
                    color: .blue
                )

                ModernApplicationRow(
                    framework: "Toulmin Argumentation",
                    decision: "Product feature proposal",
                    date: Date().addingTimeInterval(-172800),
                    icon: "quote.bubble",
                    color: .purple
                )

                ModernApplicationRow(
                    framework: "Superforecasting",
                    decision: "Market trend prediction",
                    date: Date().addingTimeInterval(-259200),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
            }
        }
        .padding(Spacing.xl)
        .background(DesignSystem.Colors.secondary)
        .cornerRadiusDesign(Corners.Component.card)
        .cardBorder()
    }
}

struct ModernApplicationRow: View {
    let framework: String
    let decision: String
    let date: Date
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Modern icon badge
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(framework)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DesignSystem.Colors.foreground)

                Text(decision)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    .lineLimit(1)
            }

            Spacer(minLength: Spacing.sm)

            Text(date, style: .relative)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
        }
        .padding(Spacing.md)
        .background(DesignSystem.Colors.background)
            .cornerRadiusDesign(Corners.Component.card)
            .borderedCorners(radius: Corners.Component.card, borderColor: DesignSystem.Colors.border.opacity(0.3), borderWidth: 0.5)
    }
}

#Preview {
    PracticeView()
        .environment(AppState())
}