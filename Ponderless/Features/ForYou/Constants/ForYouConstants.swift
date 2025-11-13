//
//  ForYouConstants.swift
//  Ponderless
//
//  Constants for ForYou feature - sizing, content, and configuration
//

import Foundation
import SwiftUI

enum ForYouConstants {

    // MARK: - Sizing

    enum Sizing {
        static let badgeCircleDiameter: CGFloat = 60
        static let weekNavigationButtonSize: CGFloat = 44
        static let calibrationChartHeight: CGFloat = 200 // Spacing.custom(50) = 4 * 50
        static let chartSymbolSize: CGFloat = 15
        static let streakIconCircleSize: CGFloat = 15
        static let dayCircleSize: CGFloat = 44
        static let progressBarHeight: CGFloat = 8
        static let progressMilestoneCircleSize: CGFloat = 32
        static let progressMilestoneInnerCircleSize: CGFloat = 28
    }

    // MARK: - Confidence Settings

    enum Confidence {
        static let minValue: Double = 0
        static let maxValue: Double = 100
        static let stepValue: Double = 5
        static let defaultValue: Double = 50
    }

    // MARK: - Calendar

    enum Calendar {
        static let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        static let daysInWeek = 7
    }

    // MARK: - Gamification

    enum Gamification {
        static let starsPerLevel = 100
        static let baseExperiencePerLevel = 100
    }

    // MARK: - Text Content (Aligned with Ponderless Mission)

    enum TextContent {
        // Daily Plan Section
        static let dailyPlanTitle = "Your Daily Plan"
        static let dailyPlanSubtitle = "Complete daily exercises to build your judgment skills"

        // Track Judgment Section
        static let trackJudgmentTitle = "Track Your Judgment"
        static let trackJudgmentSubtitle = "Monitor your prediction accuracy and calibration"

        // Badges
        static let inProgressLabel = "In Progress"
        static let completedLabel = "Completed"

        // Exercise Progress
        static let stepFormat = "Step %d of %d"
        static let exerciseComplete = "Exercise Complete!"

        // Streak
        static let streakTitle = "Streak"
        static let streakSubtitle = "You're doing great, practice today to keep the momentum going"
        static let streakMotivation = "Building consistent practice habits strengthens critical thinking over time"

        // Stars
        static let starsTitle = "Stars"
        static let starsSubtitleFormat = "You have earned %d stars!"
        static let starsMotivation = "Each star represents progress in overcoming overthinking patterns"

        // Navigation
        static let nextButton = "Next"
        static let previousButton = "Previous"
        static let completeButton = "Complete"
        static let cancelButton = "Cancel"
        static let retryButton = "Retry"

        // Errors
        static let loadingError = "Unable to load your training plan"
        static let completionError = "Unable to complete exercise. Please try again."
        static let genericError = "Something went wrong. Please try again."
    }

    // MARK: - Calibration Questions
    // Designed to build micro-learning habits and judgment skills

    enum CalibrationQuestions {
        static let questions: [Int: String] = [
            1: "Will it rain tomorrow in your city?",
            2: "Will the stock market close higher tomorrow?",
            3: "Will you complete all your planned tasks today?",
            4: "Will your favorite sports team win their next game?",
            5: "Will you learn something new in the next 24 hours?"
        ]

        static func question(for step: Int) -> String {
            questions[step] ?? "Make a prediction about an uncertain future event"
        }

        static let instructionText = "Calibration helps you understand how well your confidence matches reality. This builds self-awareness and reduces overthinking."
    }

    // MARK: - Bias Scenarios
    // Educational content for recognizing thinking patterns

    enum BiasScenarios {
        static let scenarios: [Int: BiasScenario] = [
            1: BiasScenario(
                text: "Sarah invested in a stock that lost 20% of its value. Instead of reconsidering, she doubled down on her investment, convinced it would bounce back because she had researched it thoroughly.",
                options: [
                    "Sunk Cost Fallacy",
                    "Confirmation Bias",
                    "Anchoring Bias",
                    "Availability Heuristic"
                ],
                correctAnswer: 0,
                explanation: "Sunk Cost Fallacy: Sarah is letting past investment influence future decisions, rather than evaluating the current situation objectively."
            ),
            2: BiasScenario(
                text: "Mike always remembers the times his hunches were correct but forgets all the times he was wrong. He now believes he has a 'sixth sense' for predicting outcomes.",
                options: [
                    "Hindsight Bias",
                    "Selection Bias",
                    "Survivorship Bias",
                    "Dunning-Kruger Effect"
                ],
                correctAnswer: 2,
                explanation: "Survivorship Bias: Mike only remembers the successes ('survivors'), ignoring the failures, leading to overconfidence in his intuition."
            ),
            3: BiasScenario(
                text: "Emma sees a news article confirming her political views and immediately shares it. She ignores three other well-researched articles that present contradicting evidence.",
                options: [
                    "Confirmation Bias",
                    "Bandwagon Effect",
                    "Recency Bias",
                    "Framing Effect"
                ],
                correctAnswer: 0,
                explanation: "Confirmation Bias: Emma is seeking and accepting information that confirms her existing beliefs while dismissing contradictory evidence."
            )
        ]

        static func scenario(for step: Int) -> BiasScenario? {
            scenarios[step]
        }

        static let instructionText = "Recognizing cognitive biases is key to overcoming overthinking and making better decisions."
    }

    struct BiasScenario {
        let text: String
        let options: [String]
        let correctAnswer: Int
        let explanation: String
    }

    // MARK: - Decision Framework Prompts
    // Micro-learning application of critical thinking

    enum DecisionFramework {
        static let prompts: [Int: FrameworkPrompt] = [
            1: FrameworkPrompt(
                title: "Identify the Decision",
                question: "What decision are you considering today? (Keep it small - practice with micro-decisions)",
                placeholder: "e.g., Should I attend this meeting? Should I start this project now?",
                hint: "Start small. Micro-practice builds macro-skills."
            ),
            2: FrameworkPrompt(
                title: "Evidence Check",
                question: "What evidence do you have for and against this decision?",
                placeholder: "List facts, not feelings. What do you actually know?",
                hint: "Separate data from assumptions. This reduces overthinking."
            ),
            3: FrameworkPrompt(
                title: "Alternative Options",
                question: "What are 2-3 alternatives you haven't considered?",
                placeholder: "Brainstorm quickly. Don't overthink this step.",
                hint: "Expanding options often reveals better paths."
            ),
            4: FrameworkPrompt(
                title: "Quick Decision",
                question: "Based on the evidence, what's your decision?",
                placeholder: "Commit to one choice. You can always adjust later.",
                hint: "Done is better than perfect. This is about building judgment, not perfection."
            )
        ]

        static func prompt(for step: Int) -> FrameworkPrompt? {
            prompts[step]
        }

        static let completionMessage = "Great work! You've practiced applying evidence-based thinking to a real decision. This is how you overcome overthinking - with structure and practice."
    }

    struct FrameworkPrompt {
        let title: String
        let question: String
        let placeholder: String
        let hint: String
    }

    // MARK: - Metrics

    enum Metrics {
        static let brierScoreTitle = "Brier Score"
        static let brierScoreHelp = "Lower is better (0-1). Measures prediction accuracy."

        static let calibrationTitle = "Calibration"
        static let calibrationHelp = "How well your confidence matches reality"

        static let confidenceTitle = "Confidence"
        static let confidenceHelp = "Average confidence level in predictions"

        static let predictionsTitle = "Predictions"
        static let predictionsHelp = "Total number of predictions made"

        // Trend descriptions
        static let improvingTrend = "Trending upward"
        static let decliningTrend = "Needs attention"
        static let stableTrend = "Maintaining pace"
        static let neutralTrend = "No change yet"
    }

    // MARK: - Accessibility Labels

    enum AccessibilityLabels {
        static let streakBadge = "Daily streak"
        static let starsBadge = "Total stars earned"
        static let todoCard = "Training exercise"
        static let calibrationChart = "Calibration Chart"
        static let metricCard = "Performance metric"

        // Hints
        static let todoCardHint = "Double tap to start exercise"
        static let badgeHint = "Double tap to view details"
        static let completedHint = "Already completed"
        static let chartHint = "Shows how well your predictions match reality"
    }

    // MARK: - Animation Durations

    enum Animation {
        static let springResponse: Double = 0.3
        static let springDamping: Double = 0.7
        static let standardDuration: Double = 0.25
        static let slowDuration: Double = 0.5
    }

    // MARK: - Input Validation

    enum Validation {
        static let maxTextLength = 5000
        static let minTextLength = 1
        static let allowedCharacterSet: CharacterSet = {
            var set = CharacterSet.alphanumerics
            set.formUnion(.whitespaces)
            set.formUnion(.punctuationCharacters)
            return set
        }()
    }
}
