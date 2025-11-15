//
//  TrainingModels.swift
//  Ponderless
//
//  Models for TRAIN exercises and skill-building activities
//

import Foundation
import SwiftUI

// MARK: - Skill Categories

enum SkillCategory: String, CaseIterable, Codable, Sendable {
    case evidenceLiteracy = "Evidence Literacy"
    case biasRecognition = "Bias Recognition"
    case probabilityFundamentals = "Probability Fundamentals"
    case metacognition = "Metacognition"

    var description: String {
        switch self {
        case .evidenceLiteracy:
            return "Source credibility, data quality, correlation vs causation, statistical reasoning"
        case .biasRecognition:
            return "Confirmation bias, anchoring bias, base rate neglect, availability bias"
        case .probabilityFundamentals:
            return "Uncertainty percentages, base rate integration, Bayesian updating"
        case .metacognition:
            return "Confidence calibration, self-assessment accuracy"
        }
    }

    var icon: String {
        switch self {
        case .evidenceLiteracy: return "doc.text.magnifyingglass"
        case .biasRecognition: return "brain.head.profile"
        case .probabilityFundamentals: return "percent"
        case .metacognition: return "sparkle.magnifyingglass"
        }
    }

    var color: Color {
        switch self {
        case .evidenceLiteracy: return DesignSystem.Colors.primary
        case .biasRecognition: return DesignSystem.Colors.chart4
        case .probabilityFundamentals: return DesignSystem.Colors.success
        case .metacognition: return DesignSystem.Colors.warning
        }
    }
}

// MARK: - Training Exercise

struct TrainingExercise: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let skillCategory: SkillCategory
    let duration: TimeInterval // Target: 2 minutes
    let difficulty: Difficulty
    let scenario: String
    let exercises: [SkillBuilderTask]
    let learningPoints: [String]
    let immediatelFeedback: Bool

    init(
        id: UUID = UUID(),
        title: String,
        skillCategory: SkillCategory,
        duration: TimeInterval = 120, // 2 minutes default
        difficulty: Difficulty = .beginner,
        scenario: String,
        exercises: [SkillBuilderTask],
        learningPoints: [String],
        immediatelFeedback: Bool = true
    ) {
        self.id = id
        self.title = title
        self.skillCategory = skillCategory
        self.duration = duration
        self.difficulty = difficulty
        self.scenario = scenario
        self.exercises = exercises
        self.learningPoints = learningPoints
        self.immediatelFeedback = immediatelFeedback
    }
}

// MARK: - Skill Builder Task

struct SkillBuilderTask: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let type: TaskType
    let prompt: String
    let content: TaskContent
    let correctAnswer: AnswerType
    let feedback: TaskFeedback
    let points: Int

    enum TaskType: String, Codable, Sendable {
        case sourceEvaluation = "Source Evaluation"
        case biasIdentification = "Bias Identification"
        case probabilityEstimation = "Probability Estimation"
        case confidenceCalibration = "Confidence Calibration"
        case dataInterpretation = "Data Interpretation"
        case assumptionChecking = "Assumption Checking"
    }

    enum TaskContent: Codable, Hashable, Sendable {
        case text(String)
        case claim(statement: String, source: String)
        case dataSet(title: String, values: [DataPoint])
        case scenario(context: String, options: [String])
        case probabilityQuestion(event: String, context: String)

        struct DataPoint: Codable, Hashable, Sendable {
            let label: String
            let value: Double
        }
    }

    enum AnswerType: Codable, Hashable, Sendable {
        case multipleChoice(correct: String, options: [String])
        case probability(value: Double, acceptableRange: ClosedRange<Double>)
        case confidence(level: Int, accuracy: Bool)
        case ranking(correctOrder: [String])
        case binaryChoice(correct: Bool)
    }

    struct TaskFeedback: Codable, Hashable, Sendable {
        let correct: String
        let incorrect: String
        let explanation: String
        let concept: String
    }

    init(
        id: UUID = UUID(),
        type: TaskType,
        prompt: String,
        content: TaskContent,
        correctAnswer: AnswerType,
        feedback: TaskFeedback,
        points: Int = 10
    ) {
        self.id = id
        self.type = type
        self.prompt = prompt
        self.content = content
        self.correctAnswer = correctAnswer
        self.feedback = feedback
        self.points = points
    }
}

// MARK: - Calibration Tracking

struct CalibrationRecord: Codable, Hashable, Sendable {
    let id: UUID
    let date: Date
    let predictions: [PredictionRecord]
    let brierScore: Double
    let calibrationCurve: [CalibrationPoint]
    let overconfidenceRatio: Double
    let underconfidenceRatio: Double

    struct PredictionRecord: Codable, Hashable, Sendable {
        let questionId: UUID
        let predictedProbability: Double
        let actualOutcome: Bool
        let confidence: Int // 0-100
        let wasCorrect: Bool
    }

    struct CalibrationPoint: Codable, Hashable, Sendable {
        let confidenceBucket: Int // 0, 10, 20, ..., 100
        let accuracy: Double
        let count: Int
    }
}

// MARK: - Training Progress

struct TrainingProgress: Codable, Hashable, Sendable {
    let userId: UUID
    var skillProgress: [SkillCategory: SkillProgress]
    var dailyStreak: Int
    var totalStars: Int
    var totalExercisesCompleted: Int
    var averageAccuracy: Double
    var lastTrainingDate: Date?
    var completedExerciseIds: Set<UUID>

    struct SkillProgress: Codable, Hashable, Sendable {
        var level: Int
        var experience: Int
        var exercisesCompleted: Int
        var accuracy: Double
        var lastPracticed: Date?
        var masteryLevel: MasteryLevel

        enum MasteryLevel: String, Codable, Sendable {
            case novice = "Novice"
            case developing = "Developing"
            case proficient = "Proficient"
            case advanced = "Advanced"
            case expert = "Expert"
        }
    }
}


// MARK: - Mock Data

extension TrainingExercise {
    static func mockExercises(for category: SkillCategory) -> [TrainingExercise] {
        switch category {
        case .evidenceLiteracy:
            return [
                TrainingExercise(
                    title: "Source Credibility Assessment",
                    skillCategory: SkillCategory.evidenceLiteracy,
                    duration: 120,
                    difficulty: Difficulty.beginner,
                    scenario: "Evaluate the reliability of different information sources",
                    exercises: [],
                    learningPoints: ["Assess source expertise", "Check for conflicts of interest", "Verify publication standards"]
                ),
                TrainingExercise(
                    title: "Correlation vs Causation",
                    skillCategory: SkillCategory.evidenceLiteracy,
                    duration: 120,
                    difficulty: Difficulty.intermediate,
                    scenario: "Distinguish between correlated and causal relationships",
                    exercises: [],
                    learningPoints: ["Identify confounding variables", "Understand temporal relationships", "Evaluate experimental design"]
                ),
                TrainingExercise(
                    title: "Statistical Reasoning",
                    skillCategory: SkillCategory.evidenceLiteracy,
                    duration: 150,
                    difficulty: Difficulty.advanced,
                    scenario: "Analyze statistical claims and methodologies",
                    exercises: [],
                    learningPoints: ["Understand sample sizes", "Evaluate confidence intervals", "Assess statistical significance"]
                )
            ]
            
        case .biasRecognition:
            return [
                TrainingExercise(
                    title: "Confirmation Bias Detection",
                    skillCategory: SkillCategory.biasRecognition,
                    duration: 120,
                    difficulty: Difficulty.beginner,
                    scenario: "Recognize when you're favoring information that confirms your beliefs",
                    exercises: [],
                    learningPoints: ["Identify selective attention", "Challenge assumptions", "Seek disconfirming evidence"]
                ),
                TrainingExercise(
                    title: "Anchoring Bias Awareness",
                    skillCategory: SkillCategory.biasRecognition,
                    duration: 120,
                    difficulty: Difficulty.intermediate,
                    scenario: "Notice how initial information affects your judgments",
                    exercises: [],
                    learningPoints: ["Recognize first impressions", "Adjust from anchors", "Use multiple reference points"]
                ),
                TrainingExercise(
                    title: "Availability Heuristic",
                    skillCategory: SkillCategory.biasRecognition,
                    duration: 120,
                    difficulty: Difficulty.intermediate,
                    scenario: "Understand how recent or memorable events skew perception",
                    exercises: [],
                    learningPoints: ["Consider base rates", "Look beyond vivid examples", "Gather systematic data"]
                ),
                TrainingExercise(
                    title: "Base Rate Neglect",
                    skillCategory: SkillCategory.biasRecognition,
                    duration: 150,
                    difficulty: Difficulty.advanced,
                    scenario: "Learn to incorporate statistical base rates in decisions",
                    exercises: [],
                    learningPoints: ["Identify prior probabilities", "Update beliefs systematically", "Avoid representativeness errors"]
                )
            ]
            
        case .probabilityFundamentals:
            return [
                TrainingExercise(
                    title: "Expressing Uncertainty",
                    skillCategory: SkillCategory.probabilityFundamentals,
                    duration: 120,
                    difficulty: Difficulty.beginner,
                    scenario: "Learn to express beliefs as probabilities",
                    exercises: [],
                    learningPoints: ["Convert feelings to percentages", "Understand probability scales", "Calibrate confidence"]
                ),
                TrainingExercise(
                    title: "Base Rate Integration",
                    skillCategory: SkillCategory.probabilityFundamentals,
                    duration: 120,
                    difficulty: Difficulty.intermediate,
                    scenario: "Combine specific evidence with general base rates",
                    exercises: [],
                    learningPoints: ["Apply Bayes' theorem", "Weight prior information", "Update beliefs rationally"]
                ),
                TrainingExercise(
                    title: "Bayesian Updating",
                    skillCategory: SkillCategory.probabilityFundamentals,
                    duration: 150,
                    difficulty: Difficulty.advanced,
                    scenario: "Master systematic belief revision with new evidence",
                    exercises: [],
                    learningPoints: ["Calculate likelihood ratios", "Track belief changes", "Avoid over-updating"]
                )
            ]
            
        case .metacognition:
            return [
                TrainingExercise(
                    title: "Confidence Calibration",
                    skillCategory: SkillCategory.metacognition,
                    duration: 120,
                    difficulty: Difficulty.beginner,
                    scenario: "Align your confidence levels with actual accuracy",
                    exercises: [],
                    learningPoints: ["Assess your certainty", "Track prediction outcomes", "Adjust confidence appropriately"]
                ),
                TrainingExercise(
                    title: "Recognizing Knowledge Gaps",
                    skillCategory: SkillCategory.metacognition,
                    duration: 120,
                    difficulty: Difficulty.intermediate,
                    scenario: "Identify what you don't know that matters",
                    exercises: [],
                    learningPoints: ["Question assumptions", "Seek missing information", "Acknowledge uncertainty"]
                ),
                TrainingExercise(
                    title: "Decision Quality Review",
                    skillCategory: SkillCategory.metacognition,
                    duration: 150,
                    difficulty: Difficulty.advanced,
                    scenario: "Evaluate your decision-making process systematically",
                    exercises: [],
                    learningPoints: ["Review thought patterns", "Learn from outcomes", "Improve future decisions"]
                )
            ]
        }
    }
}
