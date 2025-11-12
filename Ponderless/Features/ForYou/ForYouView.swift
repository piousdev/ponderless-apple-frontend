//
//  ForYouView.swift
//  Ponderless
//
//  For You tab - Daily tracker and calibration analytics
//

import SwiftUI
import Charts

struct ForYouView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxxxl) {
                    
                    // Daily Todos Section
                    DailyTodosSection()
                        .padding(.horizontal)

                    // Track Your Judgment Section
                    TrackYourJudgmentSection()
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Overview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Daily Todos Section

struct DailyTodosSection: View {
    @Environment(AppState.self) private var appState
    @State private var showStreakSheet = false
    @State private var showStarsSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            // Header with badges
            HStack(alignment: .center, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Your Daily Plan")
                        .font(Typography.title2.bold())
                        .foregroundStyle(DesignSystem.Colors.foreground)
                    
                    Text("Complete daily exercises to build your judgment skills")
                        .font(Typography.caption1)
                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                }
                
                Spacer()
                
                HStack(spacing: Spacing.sm) {
                    // Streak Badge
                    Button {
                        showStreakSheet = true
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "flame.fill")
                                .font(Typography.body)
                                .foregroundStyle(DesignSystem.Colors.chart3)
                            
                            Text("\(appState.trainingProgress.dailyStreak)")
                                .font(Typography.body.bold())
                                .foregroundStyle(DesignSystem.Colors.foreground)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .frame(minHeight: Spacing.Layout.minTouchTarget)
                        .background(DesignSystem.Colors.secondary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                    }
                    
                    // Stars Badge
                    Button {
                        showStarsSheet = true
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "star.fill")
                                .font(Typography.body)
                                .foregroundStyle(DesignSystem.Colors.chart5)
                            
                            Text("\(appState.trainingProgress.totalStars)")
                                .font(Typography.body.bold())
                                .foregroundStyle(DesignSystem.Colors.foreground)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .frame(minHeight: Spacing.Layout.minTouchTarget)
                        .background(DesignSystem.Colors.secondary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                    }
                }
            }

            VStack(spacing: Spacing.md) {
                ForEach(todaysTodos) { todo in
                    TodoCard(todo: todo)
                }
            }
        }
        .sheet(isPresented: $showStreakSheet) {
            StreakSheetView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showStarsSheet) {
            StarsSheetView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    var todaysTodos: [DailyTodo] {
        // In a real app, these would come from AppState
        [
            DailyTodo(
                title: "Morning Calibration",
                description: "Test your confidence on 5 predictions",
                icon: .waveSignal,
                isCompleted: false,
                points: 10,
                exerciseType: .calibration
            ),
            DailyTodo(
                title: "Bias Recognition Exercise",
                description: "2-minute skill builder",
                icon: .machineLearning,
                isCompleted: false,
                points: 15,
                exerciseType: .biasRecognition
            ),
            DailyTodo(
                title: "Decision Framework",
                description: "Apply EtD to a micro-decision",
                icon: .constructionHouse,
                isCompleted: false,
                points: 20,
                exerciseType: .decisionFramework
            )
        ]
    }
}

struct DailyTodo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: TodoIcon
    let isCompleted: Bool
    let points: Int
    let exerciseType: ExerciseType
    
    enum ExerciseType {
        case calibration
        case biasRecognition
        case decisionFramework
        
        var stepCount: Int {
            switch self {
            case .calibration: return 5
            case .biasRecognition: return 3
            case .decisionFramework: return 4
            }
        }
    }
}

enum TodoIcon {
    case waveSignal
    case machineLearning
    case constructionHouse
    // Add more custom icons here as needed
    // case anotherCustomIcon
    // case yetAnotherIcon
}

struct TodoCard: View {
    let todo: DailyTodo
    @State private var isCompleted: Bool = false
    @State private var showExerciseSheet: Bool = false
    @State private var isInProgress: Bool = false
    @State private var lastStep: Int = 1

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Icon
            ZStack {
                Circle()
                    .fill(isCompleted ? DesignSystem.Colors.chart2 : DesignSystem.Colors.primary.opacity(0.1))
                    .frame(width: Spacing.Layout.minTouchTarget, height: Spacing.Layout.minTouchTarget)

                Group {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(Typography.headline)
                            .foregroundStyle(DesignSystem.Colors.primaryForeground)
                    } else {
                        iconView(for: todo.icon)
                    }
                }
            }

            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(todo.title)
                    .font(Typography.headline)
                    .foregroundStyle(isCompleted ? DesignSystem.Colors.mutedForeground : DesignSystem.Colors.foreground)

                Text(todo.description)
                    .font(Typography.caption1)
                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
                
                if isInProgress && !isCompleted {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "clock.fill")
                            .font(Typography.caption2)
                        Text("In Progress")
                            .font(Typography.caption2.bold())
                        Text("·")
                            .font(Typography.caption2)
                        Text("\(lastStep) of \(todo.exerciseType.stepCount)")
                            .font(Typography.caption2)
                    }
                    .foregroundStyle(DesignSystem.Colors.primary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(DesignSystem.Colors.primary.opacity(0.1))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                    )
                }
            }

            Spacer()

            // Points
            Text("+\(todo.points)")
                .font(Typography.footnote.bold())
                .foregroundStyle(isCompleted ? DesignSystem.Colors.chart2 : DesignSystem.Colors.mutedForeground)
        }
        .cardPadding()
        .background(DesignSystem.Colors.secondary)
        .cardCorners()
        .overlay(
            RoundedRectangle(cornerRadius: Corners.Component.card)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
        .cardShadow()
        .onTapGesture {
            if !isCompleted {
                showExerciseSheet = true
            }
        }
        .sheet(isPresented: $showExerciseSheet) {
            ExerciseSheet(
                todo: todo,
                isInProgress: $isInProgress,
                currentStep: $lastStep,
                onComplete: {
                    withAnimation(.spring(response: 0.3)) {
                        isCompleted = true
                        isInProgress = false
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .onDisappear {
                // If user closes sheet without completing, mark as in progress
                if !isCompleted {
                    isInProgress = true
                }
            }
        }
    }
    
    @ViewBuilder
    private func iconView(for icon: TodoIcon) -> some View {
        switch icon {
        case .constructionHouse:
            ConstructionHouse()
                .fill(DesignSystem.Colors.primary)
                .frame(width: Spacing.lg, height: Spacing.lg)
        case .waveSignal:
            WaveSignal()
                .fill(DesignSystem.Colors.primary)
                .frame(width: Spacing.lg, height: Spacing.lg)
        case .machineLearning:
            MachineLearning()
                .fill(DesignSystem.Colors.primary)
                .frame(width: Spacing.lg, height: Spacing.lg)
        }
    }
}

// MARK: - Track Your Judgment Section

struct TrackYourJudgmentSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Track Your Judgment")
                    .font(Typography.title2.bold())
                    .foregroundStyle(DesignSystem.Colors.foreground)
                
                Text("Monitor your prediction accuracy and calibration")
                    .font(Typography.caption1)
                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
            }

            // Calibration Chart
            CalibrationChart()
                .frame(height: Spacing.custom(50))
                .cardPadding()
                .background(DesignSystem.Colors.secondary)
                .cardCorners()
                .overlay(
                    RoundedRectangle(cornerRadius: Corners.Component.card)
                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                )
                .cardShadow()

            // Metrics Grid
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
    }
}

struct CalibrationChart: View {
    @Environment(AppState.self) private var appState

    // Sample data
    let data = [
        CalibrationDataPoint(confidence: 0, accuracy: 0),
        CalibrationDataPoint(confidence: 10, accuracy: 12),
        CalibrationDataPoint(confidence: 20, accuracy: 18),
        CalibrationDataPoint(confidence: 30, accuracy: 35),
        CalibrationDataPoint(confidence: 40, accuracy: 42),
        CalibrationDataPoint(confidence: 50, accuracy: 48),
        CalibrationDataPoint(confidence: 60, accuracy: 58),
        CalibrationDataPoint(confidence: 70, accuracy: 72),
        CalibrationDataPoint(confidence: 80, accuracy: 78),
        CalibrationDataPoint(confidence: 90, accuracy: 85),
        CalibrationDataPoint(confidence: 100, accuracy: 95)
    ]

    var body: some View {
        Chart {
            // Perfect calibration line
            RuleMark(y: .value("Perfect", 0))
                .foregroundStyle(DesignSystem.Colors.mutedForeground.opacity(0.3))

            ForEach(0...100, id: \.self) { value in
                if value % 10 == 0 {
                    LineMark(
                        x: .value("Confidence", value),
                        y: .value("Accuracy", value)
                    )
                    .foregroundStyle(DesignSystem.Colors.mutedForeground.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
            }

            // Actual calibration curve
            ForEach(data) { point in
                LineMark(
                    x: .value("Confidence", point.confidence),
                    y: .value("Accuracy", point.accuracy)
                )
                .foregroundStyle(DesignSystem.Colors.primary)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }

            ForEach(data) { point in
                PointMark(
                    x: .value("Confidence", point.confidence),
                    y: .value("Accuracy", point.accuracy)
                )
                .foregroundStyle(DesignSystem.Colors.primary)
                .symbolSize(Spacing.custom(15))
            }
        }
        .chartXAxisLabel("Predicted Confidence %")
        .chartYAxisLabel("Actual Accuracy %")
        .chartXScale(domain: 0...100)
        .chartYScale(domain: 0...100)
    }
}

struct CalibrationDataPoint: Identifiable {
    let id = UUID()
    let confidence: Int
    let accuracy: Int
}

struct MetricCard: View {
    let title: String
    let value: String
    let trend: Trend
    let helpText: String

    enum Trend {
        case improving, declining, stable, neutral

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
    }

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
        .cardPadding()
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.secondary)
        .cardCorners()
        .overlay(
            RoundedRectangle(cornerRadius: Corners.Component.card)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
        .cardShadow()
    }
}

// MARK: - Daily Streak Card

struct DailyStreakCard: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Streak Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [DesignSystem.Colors.chart3, DesignSystem.Colors.chart5],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: Spacing.custom(15), height: Spacing.custom(15))

                VStack(spacing: 0) {
                    Image(systemName: "flame.fill")
                        .font(Typography.title2)
                        .foregroundStyle(DesignSystem.Colors.primaryForeground)

                    Text("\(appState.trainingProgress.dailyStreak)")
                        .font(Typography.caption1.bold())
                        .foregroundStyle(DesignSystem.Colors.primaryForeground)
                }
            }

            // Streak Info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Daily Streak")
                    .font(Typography.headline)
                    .foregroundStyle(DesignSystem.Colors.foreground)

                Text("Keep your streak alive with daily practice!")
                    .font(Typography.caption1)
                    .foregroundStyle(DesignSystem.Colors.mutedForeground)

                // Streak Calendar (simplified)
                HStack(spacing: Spacing.xs) {
                    ForEach(0..<7) { day in
                        Circle()
                            .fill(day < 5 ? DesignSystem.Colors.chart3 : DesignSystem.Colors.mutedForeground.opacity(0.3))
                            .frame(width: Spacing.sm, height: Spacing.sm)
                    }
                }
                .padding(.top, Spacing.xs)
            }

            Spacer()
        }
        .cardPadding()
        .background(DesignSystem.Colors.secondary)
        .cardCorners()
        .cardShadow()
    }
}

// MARK: - Quick Actions Section

struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionHeader(title: "Quick Actions")

            HStack(spacing: Spacing.md) {
                QuickActionButton(
                    title: "Practice",
                    icon: "brain.head.profile",
                    color: DesignSystem.Colors.primary
                ) {
                    // Navigate to practice
                }

                QuickActionButton(
                    title: "Coach Chat",
                    icon: "message.fill",
                    color: DesignSystem.Colors.chart4
                ) {
                    // Navigate to coach
                }

                QuickActionButton(
                    title: "Analytics",
                    icon: "chart.bar.fill",
                    color: DesignSystem.Colors.chart3
                ) {
                    // Navigate to analytics
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(Typography.title2)
                    .foregroundStyle(DesignSystem.Colors.primaryForeground)
                    .frame(width: Spacing.xxxxl + Spacing.md, height: Spacing.xxxxl + Spacing.md)
                    .background(color)
                    .cornerRadius(Corners.md)

                Text(title)
                    .font(Typography.caption1)
                    .foregroundStyle(DesignSystem.Colors.foreground)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Helpers

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text(title)
                .font(Typography.title3.bold())
                .foregroundStyle(DesignSystem.Colors.foreground)

            Spacer()
        }
    }
}

// MARK: - Sheet Views

// MARK: - Exercise Sheet

struct ExerciseSheet: View {
    let todo: DailyTodo
    @Binding var isInProgress: Bool
    @Binding var currentStep: Int
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    // Answer state
    @State private var confidenceLevel: Double = 50
    @State private var selectedChoice: Int? = nil
    @State private var textAnswer: String = ""
    
    var totalSteps: Int {
        todo.exerciseType.stepCount
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                VStack(spacing: Spacing.md) {
                    // Step counter
                    Text("Step \(currentStep) of \(totalSteps)")
                        .font(Typography.caption1)
                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: Corners.full)
                                .fill(DesignSystem.Colors.muted)
                                .frame(height: 8)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: Corners.full)
                                .fill(DesignSystem.Colors.primary)
                                .frame(width: geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps), height: 8)
                                .animation(.spring(response: 0.3), value: currentStep)
                        }
                    }
                    .frame(height: 8)
                }
                .padding()
                
                Divider()
                
                // Exercise Content
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        exerciseContent(for: currentStep)
                    }
                    .padding()
                }
                
                Divider()
                
                // Navigation Buttons
                HStack(spacing: Spacing.md) {
                    if currentStep > 1 {
                        Button {
                            withAnimation {
                                currentStep -= 1
                            }
                        } label: {
                            Text("Previous")
                                .font(Typography.body)
                                .foregroundStyle(DesignSystem.Colors.foreground)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(DesignSystem.Colors.secondary)
                                .cornerRadius(Corners.xxxxl)
                        }
                    }
                    
                    if currentStep < totalSteps {
                        Button {
                            withAnimation {
                                currentStep += 1
                            }
                        } label: {
                            Text("Next")
                                .font(Typography.body.bold())
                                .foregroundStyle(DesignSystem.Colors.primaryForeground)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(DesignSystem.Colors.primary)
                                .cornerRadius(Corners.xxxxl)
                        }
                    } else {
                        Button {
                            onComplete()
                            dismiss()
                        } label: {
                            HStack {
                                Text("Complete")
                                Image(systemName: "checkmark.circle.fill")
                            }
                            .font(Typography.body.bold())
                            .foregroundStyle(DesignSystem.Colors.primaryForeground)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignSystem.Colors.chart2)
                            .cornerRadius(Corners.xxxxl)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(todo.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func exerciseContent(for step: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Placeholder content based on exercise type
            switch todo.exerciseType {
            case .calibration:
                calibrationStep(step)
            case .biasRecognition:
                biasRecognitionStep(step)
            case .decisionFramework:
                decisionFrameworkStep(step)
            }
        }
    }
    
    @ViewBuilder
    private func calibrationStep(_ step: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Prediction \(step) of 5")
                .font(Typography.title3.bold())
                .foregroundStyle(DesignSystem.Colors.foreground)
            
            Text("How confident are you that this will happen?")
                .font(Typography.body)
                .foregroundStyle(DesignSystem.Colors.mutedForeground)
            
            // Question
            Text(calibrationQuestion(for: step))
                .font(Typography.headline)
                .foregroundStyle(DesignSystem.Colors.foreground)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignSystem.Colors.secondary)
                .cornerRadius(Corners.md)
            
            // Confidence Slider
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("Your confidence:")
                        .font(Typography.body)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                    
                    Spacer()
                    
                    Text("\(Int(confidenceLevel))%")
                        .font(Typography.title3.bold())
                        .foregroundStyle(DesignSystem.Colors.primary)
                }
                
                Slider(value: $confidenceLevel, in: 0...100, step: 5)
                    .tint(DesignSystem.Colors.primary)
                
                HStack {
                    Text("Not confident")
                        .font(Typography.caption2)
                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                    
                    Spacer()
                    
                    Text("Very confident")
                        .font(Typography.caption2)
                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                }
            }
            .padding()
            .background(DesignSystem.Colors.secondary.opacity(0.5))
            .cornerRadius(Corners.md)
        }
    }
    
    private func calibrationQuestion(for step: Int) -> String {
        switch step {
        case 1: return "Will it rain tomorrow in your city?"
        case 2: return "Will the stock market close higher tomorrow?"
        case 3: return "Will you complete all your planned tasks today?"
        case 4: return "Will your favorite sports team win their next game?"
        case 5: return "Will you learn something new in the next 24 hours?"
        default: return "Generic prediction question"
        }
    }
    
    @ViewBuilder
    private func biasRecognitionStep(_ step: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Scenario \(step)")
                .font(Typography.title3.bold())
                .foregroundStyle(DesignSystem.Colors.foreground)
            
            Text("Read the scenario and identify the cognitive bias:")
                .font(Typography.body)
                .foregroundStyle(DesignSystem.Colors.mutedForeground)
            
            // Scenario
            Text(biasScenario(for: step))
                .font(Typography.body)
                .foregroundStyle(DesignSystem.Colors.foreground)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignSystem.Colors.secondary)
                .cornerRadius(Corners.md)
            
            // Multiple Choice Options
            VStack(spacing: Spacing.sm) {
                Text("Which bias is this?")
                    .font(Typography.headline)
                    .foregroundStyle(DesignSystem.Colors.foreground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(0..<4) { index in
                    Button {
                        selectedChoice = index
                    } label: {
                        HStack {
                            Image(systemName: selectedChoice == index ? "checkmark.circle.fill" : "circle")
                                .font(Typography.title3)
                                .foregroundStyle(selectedChoice == index ? DesignSystem.Colors.primary : DesignSystem.Colors.mutedForeground)
                            
                            Text(biasOption(index, for: step))
                                .font(Typography.body)
                                .foregroundStyle(DesignSystem.Colors.foreground)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding()
                        .background(selectedChoice == index ? DesignSystem.Colors.primary.opacity(0.1) : DesignSystem.Colors.secondary)
                        .cornerRadius(Corners.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: Corners.md)
                                .stroke(selectedChoice == index ? DesignSystem.Colors.primary : DesignSystem.Colors.border, lineWidth: selectedChoice == index ? 2 : 1)
                        )
                    }
                }
            }
        }
    }
    
    private func biasScenario(for step: Int) -> String {
        switch step {
        case 1: return "Sarah invested in a stock that lost 20% of its value. Instead of reconsidering, she doubled down on her investment, convinced it would bounce back because she had researched it thoroughly."
        case 2: return "Mike always remembers the times his hunches were correct but forgets all the times he was wrong. He now believes he has a 'sixth sense' for predicting outcomes."
        case 3: return "Emma sees a news article confirming her political views and immediately shares it. She ignores three other well-researched articles that present contradicting evidence."
        default: return "A generic scenario about cognitive bias"
        }
    }
    
    private func biasOption(_ index: Int, for step: Int) -> String {
        switch step {
        case 1:
            switch index {
            case 0: return "Sunk Cost Fallacy"
            case 1: return "Confirmation Bias"
            case 2: return "Anchoring Bias"
            case 3: return "Availability Heuristic"
            default: return ""
            }
        case 2:
            switch index {
            case 0: return "Hindsight Bias"
            case 1: return "Selection Bias"
            case 2: return "Survivorship Bias"
            case 3: return "Dunning-Kruger Effect"
            default: return ""
            }
        case 3:
            switch index {
            case 0: return "Confirmation Bias"
            case 1: return "Bandwagon Effect"
            case 2: return "Recency Bias"
            case 3: return "Framing Effect"
            default: return ""
            }
        default:
            return "Option \(index + 1)"
        }
    }
    
    @ViewBuilder
    private func decisionFrameworkStep(_ step: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text(decisionFrameworkTitle(for: step))
                .font(Typography.title3.bold())
                .foregroundStyle(DesignSystem.Colors.foreground)
            
            Text(decisionFrameworkPrompt(for: step))
                .font(Typography.body)
                .foregroundStyle(DesignSystem.Colors.mutedForeground)
            
            // Text Input Area
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Your answer:")
                    .font(Typography.caption1)
                    .foregroundStyle(DesignSystem.Colors.foreground)
                
                TextEditor(text: $textAnswer)
                    .font(Typography.body)
                    .foregroundStyle(DesignSystem.Colors.foreground)
                    .frame(minHeight: 120)
                    .padding(Spacing.sm)
                    .background(DesignSystem.Colors.secondary)
                    .cornerRadius(Corners.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: Corners.md)
                            .stroke(DesignSystem.Colors.border, lineWidth: 1)
                    )
                
                if textAnswer.isEmpty {
                    Text("Type your thoughts here...")
                        .font(Typography.caption1)
                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                        .padding(.top, Spacing.xs)
                }
            }
            
            // Example/Tip Box
            HStack(alignment: .top, spacing: Spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .font(Typography.body)
                    .foregroundStyle(DesignSystem.Colors.chart5)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Tip:")
                        .font(Typography.caption1.bold())
                        .foregroundStyle(DesignSystem.Colors.foreground)
                    
                    Text(decisionFrameworkTip(for: step))
                        .font(Typography.caption1)
                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                }
            }
            .padding()
            .background(DesignSystem.Colors.chart5.opacity(0.1))
            .cornerRadius(Corners.md)
        }
    }
    
    private func decisionFrameworkTitle(for step: Int) -> String {
        switch step {
        case 1: return "Define the Decision"
        case 2: return "Identify Key Factors"
        case 3: return "Consider Alternatives"
        case 4: return "Evaluate & Commit"
        default: return "Framework Step \(step)"
        }
    }
    
    private func decisionFrameworkPrompt(for step: Int) -> String {
        switch step {
        case 1: return "What specific decision are you trying to make? Be as clear and concrete as possible."
        case 2: return "What are the 3 most important factors that should influence this decision?"
        case 3: return "What are at least 2 alternative approaches or solutions you could take?"
        case 4: return "Based on your analysis, what's your decision and why?"
        default: return "Answer the framework question"
        }
    }
    
    private func decisionFrameworkTip(for step: Int) -> String {
        switch step {
        case 1: return "Good decisions start with clear problem definition. Avoid vague statements."
        case 2: return "Focus on factors you can actually influence or measure."
        case 3: return "Even bad alternatives help clarify what you really want."
        case 4: return "Commit with confidence, but plan to review and adjust if needed."
        default: return "Think carefully about your answer"
        }
    }
}

struct StreakSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var selectedWeekOffset: Int = 0 // 0 = current week, -1 = last week, +1 = next week
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    // Fire Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.chart3, DesignSystem.Colors.chart5],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )
                            .shadow(style: .sm)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(DesignSystem.Colors.primaryForeground)
                    }
                    
                    // Streak Count - same line
                    HStack(spacing: Spacing.xs) {
                        Text("\(appState.trainingProgress.dailyStreak)")
                            .font(Typography.title2.bold())
                            .foregroundStyle(DesignSystem.Colors.foreground)
                        
                        Text(appState.trainingProgress.dailyStreak == 1 ? "Day Streak" : "Days Streak")
                            .font(Typography.title2)
                            .foregroundStyle(DesignSystem.Colors.foreground)
                    }
                    
                    // Motivational Message
                    Text("You're doing great, practice today to keep the momentum going")
                        .font(Typography.body)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                    
                    // Week Calendar
                    VStack(spacing: Spacing.lg) {
                        // Week Navigation Header
                        HStack {
                            // Left Chevron
                            Button {
                                withAnimation {
                                    selectedWeekOffset -= 1
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(DesignSystem.Colors.secondary)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                                        )
                                        .shadow(style: .xs)
                                    
                                    Image(systemName: "chevron.left")
                                        .font(Typography.body.bold())
                                        .foregroundStyle(DesignSystem.Colors.foreground)
                                }
                            }
                            
                            Spacer()
                            
                            Text(weekDateRange)
                                .font(Typography.headline)
                                .foregroundStyle(DesignSystem.Colors.foreground)
                            
                            Spacer()
                            
                            // Right Chevron
                            Button {
                                withAnimation {
                                    selectedWeekOffset += 1
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(selectedWeekOffset >= 0 ? DesignSystem.Colors.muted : DesignSystem.Colors.secondary)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                                        )
                                        .shadow(style: selectedWeekOffset >= 0 ? .none : .xs)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(Typography.body.bold())
                                        .foregroundStyle(selectedWeekOffset >= 0 ? DesignSystem.Colors.mutedForeground : DesignSystem.Colors.foreground)
                                }
                            }
                            .disabled(selectedWeekOffset >= 0) // Can't go to future weeks
                            .opacity(selectedWeekOffset >= 0 ? 0.5 : 1.0)
                        }
                        .padding(.horizontal)
                        
                        // Week Calendar Grid
                        HStack(spacing: Spacing.sm) {
                            ForEach(0..<7) { dayIndex in
                                let date = dateForDayInWeek(dayIndex)
                                let hasActivity = checkActivityForDate(date)
                                
                                VStack(spacing: Spacing.sm) {
                                    // Day of week label
                                    Text(dayOfWeekLabel(for: dayIndex))
                                        .font(Typography.caption2)
                                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                                    
                                    // Day circle with indicator
                                    ZStack {
                                        Circle()
                                            .fill(hasActivity ? DesignSystem.Colors.chart2.opacity(0.1) : DesignSystem.Colors.secondary)
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Circle()
                                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                                            )
                                            .shadow(style: hasActivity ? .xs : .none)
                                        
                                        if hasActivity {
                                            Image(systemName: "checkmark")
                                                .font(Typography.headline)
                                                .foregroundStyle(DesignSystem.Colors.chart2)
                                        } else if isFutureDate(date) {
                                            // Future dates - empty
                                        } else {
                                            Image(systemName: "xmark")
                                                .font(Typography.headline)
                                                .foregroundStyle(DesignSystem.Colors.mutedForeground)
                                        }
                                    }
                                    
                                    // Day number
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .font(Typography.caption2)
                                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, Spacing.xl)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Streak")
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
    
    // Helper computed properties and functions
    private var weekDateRange: String {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(byAdding: .weekOfYear, value: selectedWeekOffset, to: startOfWeek(for: today))!
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        
        let startString = formatter.string(from: weekStart)
        let endDay = Calendar.current.component(.day, from: weekEnd)
        
        return "\(startString) - \(endDay)"
    }
    
    private func startOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components)!
    }
    
    private func dateForDayInWeek(_ dayIndex: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(byAdding: .weekOfYear, value: selectedWeekOffset, to: startOfWeek(for: today))!
        return calendar.date(byAdding: .day, value: dayIndex, to: weekStart)!
    }
    
    private func dayOfWeekLabel(for index: Int) -> String {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days[index]
    }
    
    private func checkActivityForDate(_ date: Date) -> Bool {
        // Placeholder logic - replace with actual activity tracking
        // For demo: randomly show some days as active in past weeks
        if isFutureDate(date) {
            return false
        }
        
        let dayOfWeek = Calendar.current.component(.weekday, from: date)
        // Demo: show activity on Mon, Wed, Fri (2, 4, 6)
        return [2, 4, 6].contains(dayOfWeek)
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        return date > Date()
    }
}

struct StarsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    // Level system constants
    let starsPerLevel = 100
    
    var currentLevel: Int {
        appState.trainingProgress.totalStars / starsPerLevel
    }
    
    var nextLevel: Int {
        currentLevel + 1
    }
    
    var starsInCurrentLevel: Int {
        appState.trainingProgress.totalStars % starsPerLevel
    }
    
    var starsToNextLevel: Int {
        starsPerLevel - starsInCurrentLevel
    }
    
    var progressPercentage: Double {
        Double(starsInCurrentLevel) / Double(starsPerLevel)
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
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(DesignSystem.Colors.primaryForeground)
                    }
                    
                    // Stars Count
                    HStack(spacing: Spacing.xs) {
                        Text("\(appState.trainingProgress.totalStars)")
                            .font(Typography.title2.bold())
                            .foregroundStyle(DesignSystem.Colors.foreground)
                        
                        Text("Stars")
                            .font(Typography.title2)
                            .foregroundStyle(DesignSystem.Colors.foreground)
                    }
                    
                    // Earned Stars Message
                    Text("You have earned \(appState.trainingProgress.totalStars) stars!")
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
                                    .animation(.spring(response: 0.5), value: progressPercentage)
                            }
                            .frame(height: 12)
                            
                            // Milestone circle at the end
                            HStack {
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .fill(progressPercentage >= 1.0 ? DesignSystem.Colors.chart2 : DesignSystem.Colors.muted)
                                        .frame(width: 32, height: 32)
                                    
                                    if progressPercentage >= 1.0 {
                                        Image(systemName: "checkmark")
                                            .font(Typography.body.bold())
                                            .foregroundStyle(DesignSystem.Colors.primaryForeground)
                                    } else {
                                        Circle()
                                            .stroke(DesignSystem.Colors.border, lineWidth: 2)
                                            .fill(DesignSystem.Colors.background)
                                            .frame(width: 28, height: 28)
                                    }
                                }
                                .offset(x: 16) // Align to the end
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        
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
            .navigationTitle("Stars")
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
    ForYouView()
        .environment(AppState())
}
