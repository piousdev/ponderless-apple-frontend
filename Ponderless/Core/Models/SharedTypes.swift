//
//  SharedTypes.swift
//  Ponderless
//
//  Shared types and enums used across multiple models
//

import Foundation
import SwiftUI

/// Difficulty levels for lessons and exercises
public enum Difficulty: String, Codable, CaseIterable, Sendable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    public var color: Color {
        switch self {
        case .beginner: return DesignSystem.Colors.success
        case .intermediate: return DesignSystem.Colors.warning
        case .advanced: return DesignSystem.Colors.destructive
        }
    }
}
