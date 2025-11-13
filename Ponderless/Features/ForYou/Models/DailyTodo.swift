//
//  DailyTodo.swift
//  Ponderless
//
//  Daily training exercise model
//

import Foundation

struct DailyTodo: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: TodoIcon
    let isCompleted: Bool
    let points: Int
    let exerciseType: ExerciseType

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        icon: TodoIcon,
        isCompleted: Bool,
        points: Int,
        exerciseType: ExerciseType
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isCompleted = isCompleted
        self.points = points
        self.exerciseType = exerciseType
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DailyTodo, rhs: DailyTodo) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Exercise Type

extension DailyTodo {
    enum ExerciseType: String, Codable, CaseIterable {
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

        var displayName: String {
            switch self {
            case .calibration: return "Calibration Exercise"
            case .biasRecognition: return "Bias Recognition"
            case .decisionFramework: return "Decision Framework"
            }
        }
    }
}

// MARK: - Preview Helpers

extension DailyTodo {
    static let preview = DailyTodo(
        title: "Morning Calibration",
        description: "Test your confidence on 5 predictions",
        icon: .waveSignal,
        isCompleted: false,
        points: 10,
        exerciseType: .calibration
    )

    static let previewCompleted = DailyTodo(
        title: "Morning Calibration",
        description: "Test your confidence on 5 predictions",
        icon: .waveSignal,
        isCompleted: true,
        points: 10,
        exerciseType: .calibration
    )

    static let previewList: [DailyTodo] = [
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
            isCompleted: true,
            points: 20,
            exerciseType: .decisionFramework
        )
    ]
}
