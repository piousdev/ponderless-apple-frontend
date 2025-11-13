//
//  CoachModels.swift
//  Ponderless
//
//  Updated AI coach models with only 3 specialized coaches
//

import Foundation
import SwiftUI

// MARK: - Coach Types

enum CoachType: String, CaseIterable, Codable, Sendable, Identifiable {
    var id: String { self.rawValue }
    case challenger = "The Challenger"
    case navigator = "The Navigator"
    case explorer = "The Explorer"

    var tagline: String {
        switch self {
        case .challenger:
            return "Help test arguments and assumptions"
        case .navigator:
            return "Help think through complexity"
        case .explorer:
            return "Explore alternative angles and perspectives"
        }
    }

    var description: String {
        switch self {
        case .challenger:
            return "Stress-test your ideas and identify blind spots"
        case .navigator:
            return "Break down complex problems systematically"
        case .explorer:
            return "Discover creative alternatives and new perspectives"
        }
    }

    var icon: String {
        switch self {
        case .challenger: return "shield.lefthalf.filled"
        case .navigator: return "location.north.circle.fill"
        case .explorer: return "binoculars.fill"
        }
    }

    var color: Color {
        switch self {
        case .challenger: return DesignSystem.Colors.destructive
        case .navigator: return DesignSystem.Colors.primary
        case .explorer: return DesignSystem.Colors.success
        }
    }
}

// MARK: - New Coach Model

struct Coach: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let type: CoachType
    let name: String
    let tagline: String
    let personality: CoachPersonality
    let specialties: [Specialty]
    let communicationStyle: CommunicationStyle
    let introduction: String
    let avatar: String // SF Symbol name
    let isAvailable: Bool

    init(
        id: UUID = UUID(),
        type: CoachType,
        personality: CoachPersonality,
        specialties: [Specialty],
        communicationStyle: CommunicationStyle,
        isAvailable: Bool = true
    ) {
        self.id = id
        self.type = type
        self.name = type.rawValue
        self.tagline = type.tagline
        self.personality = personality
        self.specialties = specialties
        self.communicationStyle = communicationStyle
        self.introduction = personality.introduction
        self.avatar = type.icon
        self.isAvailable = isAvailable
    }

    enum Specialty: String, Codable, CaseIterable, Sendable {
        case criticalAnalysis = "Critical Analysis"
        case assumptionTesting = "Assumption Testing"
        case devilsAdvocate = "Devil's Advocate"
        case systemsThinking = "Systems Thinking"
        case complexityMapping = "Complexity Mapping"
        case decisionTrees = "Decision Trees"
        case creativeProblemSolving = "Creative Problem Solving"
        case lateralThinking = "Lateral Thinking"
        case perspectiveTaking = "Perspective Taking"
    }
}

// MARK: - Coach Personality

struct CoachPersonality: Codable, Hashable, Sendable {
    let traits: [Trait]
    let approach: ApproachStyle
    let tone: ToneStyle
    let introduction: String
    let typicalQuestions: [String]

    enum Trait: String, Codable, Sendable {
        // Challenger traits
        case analytical = "Analytical"
        case skeptical = "Skeptical"
        case rigorous = "Rigorous"
        case provocative = "Provocative"

        // Navigator traits
        case methodical = "Methodical"
        case structured = "Structured"
        case patient = "Patient"
        case clarifying = "Clarifying"

        // Explorer traits
        case curious = "Curious"
        case creative = "Creative"
        case openMinded = "Open-minded"
        case imaginative = "Imaginative"
    }

    enum ApproachStyle: String, Codable, Sendable {
        case socratic = "Socratic"
        case collaborative = "Collaborative"
        case challenging = "Challenging"
        case exploratory = "Exploratory"
    }

    enum ToneStyle: String, Codable, Sendable {
        case professional = "Professional"
        case friendly = "Friendly"
        case provocative = "Provocative"
        case encouraging = "Encouraging"
    }
}

// MARK: - Communication Style

struct CommunicationStyle: Codable, Hashable, Sendable {
    let preferredLength: ResponseLength
    let questioningStyle: QuestioningStyle
    let feedbackStyle: FeedbackStyle
    let useAnalogies: Bool
    let useExamples: Bool

    enum ResponseLength: String, Codable, Sendable {
        case concise = "Concise"
        case balanced = "Balanced"
        case detailed = "Detailed"
    }

    enum QuestioningStyle: String, Codable, Sendable {
        case direct = "Direct"
        case probing = "Probing"
        case openEnded = "Open-ended"
        case hypothetical = "Hypothetical"
    }

    enum FeedbackStyle: String, Codable, Sendable {
        case constructive = "Constructive"
        case challenging = "Challenging"
        case supportive = "Supportive"
        case balanced = "Balanced"
    }
}

// MARK: - Chat Models

struct ChatSession: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let coachType: CoachType
    let userId: UUID
    var messages: [ChatMessage]
    let startedAt: Date
    var endedAt: Date?
    var topic: String?
    var insights: [String]
    var isActive: Bool

    init(
        id: UUID = UUID(),
        coachType: CoachType,
        userId: UUID,
        messages: [ChatMessage] = [],
        startedAt: Date = Date(),
        topic: String? = nil,
        insights: [String] = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.coachType = coachType
        self.userId = userId
        self.messages = messages
        self.startedAt = startedAt
        self.endedAt = nil
        self.topic = topic
        self.insights = insights
        self.isActive = isActive
    }

    mutating func endSession() {
        self.endedAt = Date()
        self.isActive = false
    }
}

struct ChatMessage: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let sender: MessageSender
    let content: String
    let timestamp: Date
    let metadata: MessageMetadata?

    enum MessageSender: Codable, Hashable, Sendable {
        case user
        case coach(CoachType)
    }

    struct MessageMetadata: Codable, Hashable, Sendable {
        let questionType: QuestionType?
        let insightGenerated: Bool
        let followUpSuggestions: [String]

        enum QuestionType: String, Codable, Sendable {
            case clarifying = "Clarifying"
            case challenging = "Challenging"
            case exploratory = "Exploratory"
            case hypothetical = "Hypothetical"
        }
    }

    init(
        id: UUID = UUID(),
        sender: MessageSender,
        content: String,
        timestamp: Date = Date(),
        metadata: MessageMetadata? = nil
    ) {
        self.id = id
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

// MARK: - Coach Factory

struct CoachFactory {
    static func createDefaultCoaches() -> [Coach] {
        [
            createChallenger(),
            createNavigator(),
            createExplorer()
        ]
    }

    static func createChallenger() -> Coach {
        Coach(
            type: .challenger,
            personality: CoachPersonality(
                traits: [.analytical, .skeptical, .rigorous, .provocative],
                approach: .challenging,
                tone: .provocative,
                introduction: "I'm here to stress-test your thinking. I'll challenge your assumptions, play devil's advocate, and help you identify blind spots in your reasoning. Ready to put your ideas to the test?",
                typicalQuestions: [
                    "What evidence supports that assumption?",
                    "Have you considered the opposite might be true?",
                    "What would someone who disagrees say?",
                    "Where might your reasoning be flawed?",
                    "What are you not seeing?"
                ]
            ),
            specialties: [.criticalAnalysis, .assumptionTesting, .devilsAdvocate],
            communicationStyle: CommunicationStyle(
                preferredLength: .balanced,
                questioningStyle: .probing,
                feedbackStyle: .challenging,
                useAnalogies: true,
                useExamples: true
            )
        )
    }

    static func createNavigator() -> Coach {
        Coach(
            type: .navigator,
            personality: CoachPersonality(
                traits: [.methodical, .structured, .patient, .clarifying],
                approach: .collaborative,
                tone: .professional,
                introduction: "I help you navigate through complex problems systematically. Together, we'll map out the terrain, identify key decision points, and find the clearest path forward through uncertainty.",
                typicalQuestions: [
                    "Let's break this down - what are the key components?",
                    "How do these pieces connect to each other?",
                    "What's the logical sequence here?",
                    "Which factors are most critical?",
                    "What dependencies should we consider?"
                ]
            ),
            specialties: [.systemsThinking, .complexityMapping, .decisionTrees],
            communicationStyle: CommunicationStyle(
                preferredLength: .detailed,
                questioningStyle: .direct,
                feedbackStyle: .constructive,
                useAnalogies: true,
                useExamples: true
            )
        )
    }

    static func createExplorer() -> Coach {
        Coach(
            type: .explorer,
            personality: CoachPersonality(
                traits: [.curious, .creative, .openMinded, .imaginative],
                approach: .exploratory,
                tone: .encouraging,
                introduction: "I'm your guide to seeing things from new angles. We'll explore unconventional perspectives, generate creative alternatives, and discover possibilities you might not have considered.",
                typicalQuestions: [
                    "What if we looked at this completely differently?",
                    "How would someone from a different field approach this?",
                    "What creative alternatives haven't we explored?",
                    "What patterns do you notice from this angle?",
                    "If constraints didn't exist, what would be possible?"
                ]
            ),
            specialties: [.creativeProblemSolving, .lateralThinking, .perspectiveTaking],
            communicationStyle: CommunicationStyle(
                preferredLength: .balanced,
                questioningStyle: .openEnded,
                feedbackStyle: .supportive,
                useAnalogies: true,
                useExamples: true
            )
        )
    }
}