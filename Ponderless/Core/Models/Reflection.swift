//
//  Reflection.swift
//  Ponderless
//
//  Guided journaling and reflection prompts
//

import Foundation

/// Represents a reflection or journaling prompt
struct Reflection: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let prompt: String
    let category: ReflectionCategory
    let guidingQuestions: [String]
    let suggestedDuration: TimeInterval
    let mood: MoodCategory?
    let tags: [String]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        prompt: String,
        category: ReflectionCategory,
        guidingQuestions: [String] = [],
        suggestedDuration: TimeInterval = 600,
        mood: MoodCategory? = nil,
        tags: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.prompt = prompt
        self.category = category
        self.guidingQuestions = guidingQuestions
        self.suggestedDuration = suggestedDuration
        self.mood = mood
        self.tags = tags
        self.createdAt = createdAt
    }
}

/// Categories for reflection prompts
enum ReflectionCategory: String, Codable, CaseIterable, Sendable {
    case daily = "Daily"
    case gratitude = "Gratitude"
    case goals = "Goals"
    case relationships = "Relationships"
    case challenges = "Challenges"
    case growth = "Growth"
    case values = "Values"
    case decisions = "Decisions"

    var icon: String {
        switch self {
        case .daily: return "calendar.day.timeline.left"
        case .gratitude: return "heart.circle"
        case .goals: return "target"
        case .relationships: return "person.2.circle"
        case .challenges: return "mountain.2"
        case .growth: return "arrow.up.forward.circle"
        case .values: return "star.circle"
        case .decisions: return "arrow.triangle.branch"
        }
    }
}

/// Mood categories for reflection context
enum MoodCategory: String, Codable, CaseIterable, Sendable {
    case anxious = "Anxious"
    case stressed = "Stressed"
    case calm = "Calm"
    case excited = "Excited"
    case confused = "Confused"
    case motivated = "Motivated"
    case thoughtful = "Thoughtful"
    case overwhelmed = "Overwhelmed"

    var color: String {
        switch self {
        case .anxious: return "orange"
        case .stressed: return "red"
        case .calm: return "blue"
        case .excited: return "yellow"
        case .confused: return "purple"
        case .motivated: return "green"
        case .thoughtful: return "indigo"
        case .overwhelmed: return "gray"
        }
    }

    var emoji: String {
        switch self {
        case .anxious: return "😰"
        case .stressed: return "😣"
        case .calm: return "😌"
        case .excited: return "🤗"
        case .confused: return "🤔"
        case .motivated: return "💪"
        case .thoughtful: return "🧐"
        case .overwhelmed: return "😵"
        }
    }
}

/// User's journal entry for a reflection
struct JournalEntry: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let reflectionId: UUID
    let userId: UUID
    let content: String
    let mood: MoodCategory?
    let insights: [String]
    let actionItems: [String]
    let isPrivate: Bool
    let createdAt: Date
    let updatedAt: Date
    let wordCount: Int

    init(
        id: UUID = UUID(),
        reflectionId: UUID,
        userId: UUID,
        content: String,
        mood: MoodCategory? = nil,
        insights: [String] = [],
        actionItems: [String] = [],
        isPrivate: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.reflectionId = reflectionId
        self.userId = userId
        self.content = content
        self.mood = mood
        self.insights = insights
        self.actionItems = actionItems
        self.isPrivate = isPrivate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.wordCount = content.split(separator: " ").count
    }
}

/// Template for guided reflections
struct ReflectionTemplate: Codable, Hashable, Sendable {
    let name: String
    let description: String
    let sections: [TemplateSection]
    let estimatedTime: TimeInterval

    struct TemplateSection: Codable, Hashable, Sendable {
        let title: String
        let prompt: String
        let placeholderText: String?
        let minWords: Int?
        let maxWords: Int?
    }
}

/// Analytics for reflection patterns
struct ReflectionAnalytics: Codable, Hashable, Sendable {
    let userId: UUID
    let totalEntries: Int
    let averageWordCount: Int
    let favoriteCategory: ReflectionCategory?
    let commonMoods: [MoodCategory]
    let streakDays: Int
    let insightsGenerated: Int
    let actionItemsCompleted: Int
    let lastEntryDate: Date?
}