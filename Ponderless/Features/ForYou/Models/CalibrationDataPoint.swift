//
//  CalibrationDataPoint.swift
//  Ponderless
//
//  Data point for calibration chart
//

import Foundation

struct CalibrationDataPoint: Identifiable, Hashable, Codable {
    let id: UUID
    let confidence: Int
    let accuracy: Int

    init(
        id: UUID = UUID(),
        confidence: Int,
        accuracy: Int
    ) {
        self.id = id
        self.confidence = confidence
        self.accuracy = accuracy
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CalibrationDataPoint, rhs: CalibrationDataPoint) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Preview Helpers

extension CalibrationDataPoint {
    static let previewPerfect: [CalibrationDataPoint] = {
        (0...10).map { i in
            CalibrationDataPoint(confidence: i * 10, accuracy: i * 10)
        }
    }()

    static let previewRealistic: [CalibrationDataPoint] = [
        CalibrationDataPoint(confidence: 0, accuracy: 10),
        CalibrationDataPoint(confidence: 10, accuracy: 15),
        CalibrationDataPoint(confidence: 20, accuracy: 25),
        CalibrationDataPoint(confidence: 30, accuracy: 35),
        CalibrationDataPoint(confidence: 40, accuracy: 45),
        CalibrationDataPoint(confidence: 50, accuracy: 55),
        CalibrationDataPoint(confidence: 60, accuracy: 62),
        CalibrationDataPoint(confidence: 70, accuracy: 68),
        CalibrationDataPoint(confidence: 80, accuracy: 75),
        CalibrationDataPoint(confidence: 90, accuracy: 82),
        CalibrationDataPoint(confidence: 100, accuracy: 88)
    ]
}
