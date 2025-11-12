//
//  FrameworkModels.swift
//  Ponderless
//
//  Models for structured decision-making frameworks
//

import Foundation
import SwiftUI

// MARK: - Framework Types

enum FrameworkType: String, CaseIterable, Codable, Sendable {
    case evidenceToDecision = "Evidence-to-Decision"
    case toulminArgumentation = "Toulmin Argumentation"
    case superforecasting = "Superforecasting Method"
    case problemDecomposition = "Problem Decomposition"

    var description: String {
        switch self {
        case .evidenceToDecision:
            return "Systematic approach to evaluate evidence quality and make informed decisions"
        case .toulminArgumentation:
            return "Build strong arguments with claims, evidence, and warrants"
        case .superforecasting:
            return "Use Fermi decomposition and reference class forecasting"
        case .problemDecomposition:
            return "Break complex problems into manageable components"
        }
    }

    var icon: String {
        switch self {
        case .evidenceToDecision: return "chart.bar.doc.horizontal"
        case .toulminArgumentation: return "text.quote"
        case .superforecasting: return "chart.line.uptrend.xyaxis"
        case .problemDecomposition: return "square.split.2x2"
        }
    }

    var color: Color {
        switch self {
        case .evidenceToDecision: return DesignSystem.Colors.chart2
        case .toulminArgumentation: return DesignSystem.Colors.chart3
        case .superforecasting: return DesignSystem.Colors.chart4
        case .problemDecomposition: return DesignSystem.Colors.warning
        }
    }
}

// MARK: - Framework Template

struct FrameworkTemplate: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let type: FrameworkType
    let title: String
    let description: String
    let steps: [FrameworkStep]
    let estimatedDuration: TimeInterval
    let difficultyLevel: Difficulty
    let tags: [String]

    init(
        id: UUID = UUID(),
        type: FrameworkType,
        title: String,
        description: String,
        steps: [FrameworkStep],
        estimatedDuration: TimeInterval = 600,
        difficultyLevel: Difficulty = .intermediate,
        tags: [String] = []
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.steps = steps
        self.estimatedDuration = estimatedDuration
        self.difficultyLevel = difficultyLevel
        self.tags = tags
    }
}

// MARK: - Framework Step

struct FrameworkStep: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let order: Int
    let title: String
    let description: String
    let inputs: [StepInput]
    let guidance: String
    let examples: [String]
    let validation: ValidationCriteria?

    struct StepInput: Identifiable, Codable, Hashable, Sendable {
        let id: UUID
        let type: InputType
        let label: String
        let placeholder: String
        let required: Bool
        let helpText: String?

        enum InputType: String, Codable, Sendable {
            case text = "Text"
            case multilineText = "Multiline Text"
            case rating = "Rating"
            case multipleChoice = "Multiple Choice"
            case checklist = "Checklist"
            case probability = "Probability"
        }
    }

    struct ValidationCriteria: Codable, Hashable, Sendable {
        let minLength: Int?
        let maxLength: Int?
        let requiredElements: [String]
    }
}

// MARK: - Evidence-to-Decision Framework

struct EvidenceToDecision: Codable, Hashable, Sendable {
    let id: UUID
    let question: String
    let context: String
    let evidence: [EvidenceItem]
    let criteria: [DecisionCriterion]
    let alternatives: [Alternative]
    let recommendation: Recommendation?
    let confidence: Double
    let createdAt: Date

    struct EvidenceItem: Identifiable, Codable, Hashable, Sendable {
        let id: UUID
        let source: String
        let content: String
        let quality: QualityRating
        let relevance: RelevanceRating
        let credibility: CredibilityScore

        enum QualityRating: String, Codable, Sendable {
            case veryLow = "Very Low"
            case low = "Low"
            case moderate = "Moderate"
            case high = "High"
        }

        enum RelevanceRating: String, Codable, Sendable {
            case notRelevant = "Not Relevant"
            case slightlyRelevant = "Slightly Relevant"
            case moderatelyRelevant = "Moderately Relevant"
            case highlyRelevant = "Highly Relevant"
        }

        struct CredibilityScore: Codable, Hashable, Sendable {
            let expertise: Int // 0-10
            let objectivity: Int // 0-10
            let recency: Int // 0-10
            let corroboration: Int // 0-10
        }
    }

    struct DecisionCriterion: Identifiable, Codable, Hashable, Sendable {
        let id: UUID
        let name: String
        let weight: Double // 0.0-1.0
        let description: String
    }

    struct Alternative: Identifiable, Codable, Hashable, Sendable {
        let id: UUID
        let name: String
        let description: String
        let pros: [String]
        let cons: [String]
        let score: Double?
    }

    struct Recommendation: Codable, Hashable, Sendable {
        let chosenAlternative: UUID
        let rationale: String
        let strengthOfRecommendation: Strength
        let keyConsiderations: [String]

        enum Strength: String, Codable, Sendable {
            case weak = "Weak"
            case conditional = "Conditional"
            case moderate = "Moderate"
            case strong = "Strong"
        }
    }
}

// MARK: - Toulmin Argumentation

struct ToulminArgument: Codable, Hashable, Sendable {
    let id: UUID
    let claim: String
    let data: [String] // Evidence/grounds
    let warrant: String // How data supports claim
    let backing: [String] // Support for warrant
    let qualifier: String? // Degree of certainty
    let rebuttal: [String] // Counterarguments
    let createdAt: Date
}

// MARK: - Superforecasting Components

struct SuperforecastingAnalysis: Codable, Hashable, Sendable {
    let id: UUID
    let question: String
    let timeHorizon: Date
    let baseRate: BaseRateAnalysis
    let fermiEstimate: FermiEstimate
    let referenceClasses: [ReferenceClass]
    let adjustments: [Adjustment]
    let finalPrediction: Prediction
    let createdAt: Date

    struct BaseRateAnalysis: Codable, Hashable, Sendable {
        let historicalFrequency: Double
        let sampleSize: Int
        let source: String
        let confidence: Double
    }

    struct FermiEstimate: Codable, Hashable, Sendable {
        let components: [Component]
        let calculation: String
        let result: Double

        struct Component: Identifiable, Codable, Hashable, Sendable {
            let id: UUID
            let name: String
            let estimate: Double
            let rangeMin: Double
            let rangeMax: Double
            let reasoning: String
        }
    }

    struct ReferenceClass: Identifiable, Codable, Hashable, Sendable {
        let id: UUID
        let name: String
        let similarity: Double // 0.0-1.0
        let outcome: Double
        let sampleSize: Int
        let relevance: String
    }

    struct Adjustment: Identifiable, Codable, Hashable, Sendable {
        let id: UUID
        let factor: String
        let direction: Direction
        let magnitude: Double
        let reasoning: String

        enum Direction: String, Codable, Sendable {
            case increase = "Increase"
            case decrease = "Decrease"
        }
    }

    struct Prediction: Codable, Hashable, Sendable {
        let probability: Double
        let confidence: Int // 0-100
        let reasoning: String
        let keyUncertainties: [String]
    }
}

// MARK: - Problem Decomposition

struct ProblemDecomposition: Codable, Hashable, Sendable {
    let id: UUID
    let problemStatement: String
    let issueTree: IssueTree
    let assumptions: [Assumption]
    let hypotheses: [Hypothesis]
    let createdAt: Date

    struct IssueTree: Codable, Hashable, Sendable {
        let rootIssue: Issue

        struct Issue: Identifiable, Codable, Hashable, Sendable {
            let id: UUID
            let question: String
            let type: IssueType
            let subIssues: [Issue]
            let priority: Priority
            let notes: String?

            enum IssueType: String, Codable, Sendable {
                case diagnostic = "Diagnostic"
                case solution = "Solution"
                case implementation = "Implementation"
            }

            enum Priority: String, Codable, Sendable {
                case low = "Low"
                case medium = "Medium"
                case high = "High"
                case critical = "Critical"
            }
        }
    }

    struct Assumption: Identifiable, Codable, Hashable, Sendable {
        let id: UUID
        let statement: String
        let criticality: Criticality
        let confidence: Double
        let testMethod: String?

        enum Criticality: String, Codable, Sendable {
            case low = "Low"
            case medium = "Medium"
            case high = "High"
        }
    }

    struct Hypothesis: Identifiable, Codable, Hashable, Sendable {
        let id: UUID
        let statement: String
        let testable: Bool
        let testMethod: String?
        let expectedOutcome: String
        let actualOutcome: String?
    }
}