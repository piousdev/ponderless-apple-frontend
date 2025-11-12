//
//  Lesson.swift
//  Ponderless
//
//  Core data model for micro-learning lessons
//

import Foundation
import SwiftUI

/// Represents a micro-learning lesson with content and metadata
struct Lesson: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let content: LessonContent
    let category: LessonCategory
    let difficulty: Difficulty
    let estimatedDuration: TimeInterval
    let tags: [String]
    let isLocked: Bool
    let isPremium: Bool
    let order: Int
    let createdAt: Date
    let updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        content: LessonContent,
        category: LessonCategory,
        difficulty: Difficulty = .beginner,
        estimatedDuration: TimeInterval = 300,
        tags: [String] = [],
        isLocked: Bool = false,
        isPremium: Bool = false,
        order: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.category = category
        self.difficulty = difficulty
        self.estimatedDuration = estimatedDuration
        self.tags = tags
        self.isLocked = isLocked
        self.isPremium = isPremium
        self.order = order
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Content structure for lessons
struct LessonContent: Codable, Hashable, Sendable {
    let introduction: String
    let mainContent: [ContentBlock]
    let keyTakeaways: [String]
    let resources: [Resource]

    struct ContentBlock: Codable, Hashable, Sendable {
        let type: BlockType
        let content: String
        let metadata: [String: String]

        enum BlockType: String, Codable, Sendable {
            case text
            case quote
            case example
            case tip
            case warning
            case interactive
        }
    }

    struct Resource: Codable, Hashable, Sendable {
        let title: String
        let url: URL
        let type: ResourceType

        enum ResourceType: String, Codable, Sendable {
            case article
            case video
            case podcast
            case book
        }
    }
}

/// Lesson categories for organization
enum LessonCategory: String, Codable, CaseIterable, Sendable {
    case decisionMaking = "Decision Making"
    case criticalThinking = "Critical Thinking"
    case emotionalRegulation = "Emotional Regulation"
    case problemSolving = "Problem Solving"
    case mindfulness = "Mindfulness"
    case productivity = "Productivity"

    var icon: String {
        switch self {
        case .decisionMaking: return "brain.head.profile"
        case .criticalThinking: return "lightbulb.circle"
        case .emotionalRegulation: return "heart.text.square"
        case .problemSolving: return "puzzlepiece"
        case .mindfulness: return "leaf.circle"
        case .productivity: return "chart.line.uptrend.xyaxis"
        }
    }

    var color: Color {
        switch self {
        case .decisionMaking: return DesignSystem.Colors.chart4
        case .criticalThinking: return DesignSystem.Colors.primary
        case .emotionalRegulation: return DesignSystem.Colors.chart5
        case .problemSolving: return DesignSystem.Colors.warning
        case .mindfulness: return DesignSystem.Colors.success
        case .productivity: return DesignSystem.Colors.chart3
        }
    }
}