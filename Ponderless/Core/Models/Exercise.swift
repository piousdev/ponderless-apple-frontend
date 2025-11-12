//
//  Exercise.swift
//  Ponderless
//
//  Interactive exercises and decision-making scenarios
//

import Foundation

/// Represents an interactive exercise or quiz
struct Exercise: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let instructions: String
    let type: ExerciseType
    let questions: [Question]
    let timeLimit: TimeInterval?
    let passingScore: Double
    let feedback: FeedbackStrategy
    let relatedLessonId: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        instructions: String,
        type: ExerciseType,
        questions: [Question],
        timeLimit: TimeInterval? = nil,
        passingScore: Double = 0.7,
        feedback: FeedbackStrategy = .immediate,
        relatedLessonId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.instructions = instructions
        self.type = type
        self.questions = questions
        self.timeLimit = timeLimit
        self.passingScore = passingScore
        self.feedback = feedback
        self.relatedLessonId = relatedLessonId
    }
}

/// Types of exercises available
enum ExerciseType: String, Codable, Sendable {
    case quiz = "Quiz"
    case scenario = "Scenario"
    case reflection = "Reflection"
    case practical = "Practical"
    case assessment = "Assessment"
}

/// Feedback delivery strategies
enum FeedbackStrategy: String, Codable, Sendable {
    case immediate = "Immediate"
    case afterSubmission = "After Submission"
    case delayed = "Delayed"
}

/// Represents a question within an exercise
struct Question: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let text: String
    let type: QuestionType
    let options: [Option]?
    let correctAnswers: [String]
    let explanation: String?
    let points: Int
    let hint: String?
    let metadata: QuestionMetadata?

    init(
        id: UUID = UUID(),
        text: String,
        type: QuestionType,
        options: [Option]? = nil,
        correctAnswers: [String],
        explanation: String? = nil,
        points: Int = 1,
        hint: String? = nil,
        metadata: QuestionMetadata? = nil
    ) {
        self.id = id
        self.text = text
        self.type = type
        self.options = options
        self.correctAnswers = correctAnswers
        self.explanation = explanation
        self.points = points
        self.hint = hint
        self.metadata = metadata
    }
}

/// Types of questions available
enum QuestionType: String, Codable, Sendable {
    case multipleChoice = "Multiple Choice"
    case multipleSelect = "Multiple Select"
    case trueFalse = "True/False"
    case shortAnswer = "Short Answer"
    case scenario = "Scenario"
    case ranking = "Ranking"
    case matching = "Matching"
}

/// Answer option for questions
struct Option: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let text: String
    let isCorrect: Bool
    let feedback: String?

    init(
        id: UUID = UUID(),
        text: String,
        isCorrect: Bool,
        feedback: String? = nil
    ) {
        self.id = id
        self.text = text
        self.isCorrect = isCorrect
        self.feedback = feedback
    }
}

/// Additional metadata for questions
struct QuestionMetadata: Codable, Hashable, Sendable {
    let difficulty: Difficulty
    let cognitiveLevel: CognitiveLevel
    let tags: [String]

    enum CognitiveLevel: String, Codable, Sendable {
        case remember = "Remember"
        case understand = "Understand"
        case apply = "Apply"
        case analyze = "Analyze"
        case evaluate = "Evaluate"
        case create = "Create"
    }
}

/// Decision-making scenario exercise
struct Scenario: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let context: String
    let situation: String
    let decisions: [Decision]
    let outcomes: [UUID: Outcome]
    let learningObjectives: [String]

    struct Decision: Identifiable, Codable, Hashable, Sendable {
        let id: UUID
        let text: String
        let rationale: String
        let consequences: [String]
        let leadToDecisionId: UUID?
        let outcomeId: UUID?
    }

    struct Outcome: Codable, Hashable, Sendable {
        let description: String
        let analysis: String
        let score: Double
        let lessonsLearned: [String]
    }
}

/// User's response to an exercise
struct ExerciseResponse: Codable, Hashable, Sendable {
    let exerciseId: UUID
    let userId: UUID
    let startedAt: Date
    let completedAt: Date?
    let answers: [QuestionAnswer]
    let score: Double?
    let timeSpent: TimeInterval

    struct QuestionAnswer: Codable, Hashable, Sendable {
        let questionId: UUID
        let answer: [String]
        let isCorrect: Bool
        let pointsEarned: Int
        let timestamp: Date
    }
}