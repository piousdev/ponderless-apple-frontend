//
//  TodoIcon.swift
//  Ponderless
//
//  Icon types for todo items
//

import Foundation

enum TodoIcon: String, Codable, CaseIterable {
    case waveSignal
    case machineLearning
    case constructionHouse

    var systemImageName: String? {
        // Returns nil - these use custom SF Symbols
        nil
    }

    var displayName: String {
        switch self {
        case .waveSignal: return "Wave Signal"
        case .machineLearning: return "Machine Learning"
        case .constructionHouse: return "Construction House"
        }
    }
}
