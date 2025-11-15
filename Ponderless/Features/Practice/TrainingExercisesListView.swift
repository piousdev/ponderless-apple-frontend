//
//  TrainingExercisesListView.swift
//  Ponderless
//
//  Shows list of training exercises for a specific skill category
//

import SwiftUI

struct TrainingExercisesListView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let skillCategory: SkillCategory
    @State private var exercises: [TrainingExercise] = []
    @State private var selectedExercise: TrainingExercise?
    var progress: TrainingProgress.SkillProgress? {
        appState.trainingProgress.skillProgress[skillCategory]
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Header with progress
                if let progress = progress {
                    ProgressHeaderView(
                        skillCategory: skillCategory,
                        progress: progress
                    )
                    .padding(.horizontal, Spacing.xl)
                }
                
                // Exercises List
                VStack(spacing: Spacing.md) {
                    ForEach(exercises) { exercise in
                        TrainingExerciseCard(
                            exercise: exercise,
                            onTap: {
                                selectedExercise = exercise
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.xl)
            }
            .padding(.vertical, Spacing.xl)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle(skillCategory.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadExercises()
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseSheetWrapper(
                exercise: exercise,
                skillCategory: skillCategory,
                onComplete: { completedExercise in
                    Task {
                        await completeExercise(completedExercise)
                    }
                },
                onDismiss: {
                    selectedExercise = nil
                }
            )
        }
    }
    
    private func loadExercises() {
        exercises = TrainingExercise.mockExercises(for: skillCategory)
    }
    
    // Removed - now handled by ExerciseSheetWrapper
    
    private func completeExercise(_ exercise: TrainingExercise) async {
        // Update training progress
        let accuracy = 0.85 // This would come from the actual exercise results
        appState.completeTrainingExercise(exercise, accuracy: accuracy)
        selectedExercise = nil
    }
}

// MARK: - Progress Header


// MARK: - Exercise Sheet Wrapper

struct ExerciseSheetWrapper: View {
    @Environment(AppState.self) private var appState
    let exercise: TrainingExercise
    let skillCategory: SkillCategory
    let onComplete: (TrainingExercise) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        if let todo = convertExerciseToTodo(exercise, skillCategory: skillCategory) {
            ExerciseSheet(
                viewModel: ExerciseSheetViewModel(
                    todo: todo,
                    initialStep: 1,
                    onComplete: {
                        // Call completion handler with the specific exercise
                        onComplete(exercise)
                    }
                ),
                onUpdateProgress: { step in
                    // Update progress if needed
                },
                onDismiss: {
                    onDismiss()
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func convertExerciseToTodo(_ exercise: TrainingExercise, skillCategory: SkillCategory) -> DailyTodo? {
        let exerciseType: DailyTodo.ExerciseType = {
            switch skillCategory {
            case .biasRecognition:
                return .biasRecognition
            case .probabilityFundamentals, .metacognition:
                return .calibration
            case .evidenceLiteracy:
                return .decisionFramework
            }
        }()
        
        return DailyTodo(
            title: exercise.title,
            description: exercise.scenario,
            icon: .machineLearning,
            isCompleted: false,
            points: 15,
            exerciseType: exerciseType
        )
    }
}

struct ProgressHeaderView: View {
    let skillCategory: SkillCategory
    let progress: TrainingProgress.SkillProgress
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            HStack {
                // Icon with gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [skillCategory.color, skillCategory.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: skillCategory.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // Level Badge
                VStack(spacing: Spacing.xxs) {
                    Text("\(progress.level)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(skillCategory.color)
                    
                    Text("LEVEL")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        .tracking(0.5)
                }
                .frame(minWidth: 60)
                .padding(.vertical, Spacing.md)
                .padding(.horizontal, Spacing.sm)
                .background {
                    RoundedRectangle(cornerRadius: Corners.md, style: .continuous)
                        .fill(skillCategory.color.opacity(0.12))
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text(progress.masteryLevel.rawValue.uppercased())
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(skillCategory.color)
                        .tracking(0.3)
                    
                    Spacer()
                    
                    Text("\(progress.experience % 100)/100 XP")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(skillCategory.color.opacity(0.12))
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [skillCategory.color, skillCategory.color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * (Double(progress.experience % 100) / 100.0),
                                height: 10
                            )
                    }
                }
                .frame(height: 10)
            }
            
            // Stats
            HStack(spacing: Spacing.xl) {
                StatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(progress.exercisesCompleted)",
                    label: "completed",
                    color: skillCategory.color
                )
                
                StatItem(
                    icon: "checkmark.circle",
                    value: "\(Int(progress.accuracy * 100))%",
                    label: "accuracy",
                    color: skillCategory.color
                )
            }
        }
        .padding(Spacing.xl)
        .background(DesignSystem.Colors.background)
        .cardCorners()
        .cardBorder()
        .cardShadow()
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color.opacity(0.8))
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.foreground)
                
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Training Exercise Card

struct TrainingExerciseCard: View {
    @Environment(AppState.self) private var appState
    let exercise: TrainingExercise
    let onTap: () -> Void
    @State private var isPressed = false
    
    var isCompleted: Bool {
        appState.trainingProgress.completedExerciseIds.contains(exercise.id)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.lg) {
                // Icon - Show checkmark if completed
                ZStack {
                    Circle()
                        .fill(
                            isCompleted 
                            ? DesignSystem.Colors.success.opacity(0.12)
                            : exercise.skillCategory.color.opacity(0.12)
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "brain.head.profile")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(
                            isCompleted 
                            ? DesignSystem.Colors.success
                            : exercise.skillCategory.color
                        )
                }
                
                // Content
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(exercise.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            isCompleted 
                            ? DesignSystem.Colors.success
                            : DesignSystem.Colors.foreground
                        )
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: Spacing.sm) {
                        Label {
                            Text("\(Int(exercise.duration / 60)) min")
                                .font(.system(size: 13, weight: .medium))
                        } icon: {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(
                            isCompleted 
                            ? DesignSystem.Colors.success.opacity(0.8)
                            : DesignSystem.Colors.secondaryForeground
                        )
                        
                        Text("•")
                            .foregroundStyle(
                                isCompleted 
                                ? DesignSystem.Colors.success.opacity(0.8)
                                : DesignSystem.Colors.secondaryForeground
                            )
                        
                        Text(isCompleted ? "Completed" : exercise.difficulty.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(
                                isCompleted 
                                ? DesignSystem.Colors.success
                                : DesignSystem.Colors.secondaryForeground
                            )
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: isCompleted ? "checkmark" : "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        isCompleted 
                        ? DesignSystem.Colors.success
                        : DesignSystem.Colors.secondaryForeground
                    )
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.background)
            .cardCorners()
            .cardBorder()
            .cardShadow()
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    NavigationStack {
        TrainingExercisesListView(skillCategory: .evidenceLiteracy)
            .environment(AppState())
    }
}
