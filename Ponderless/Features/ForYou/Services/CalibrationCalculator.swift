//
//  CalibrationCalculator.swift
//  Ponderless
//
//  Protocol for calibration calculations and data access
//

import Foundation

/// Protocol for providing calibration data and calculations
/// Enables dependency injection and testability
protocol CalibrationCalculator {
    func getCalibrationData() -> [CalibrationDataPoint]
    func getBrierScore() -> Double
    func getCalibrationPercentage() -> Int
    func getAverageConfidence() -> Int
    func getTotalPredictions() -> Int
}

// MARK: - Default Implementation

final class DefaultCalibrationCalculator: CalibrationCalculator {
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func getCalibrationData() -> [CalibrationDataPoint] {
        // In a real app, this would calculate from calibrationRecords
        // For now, return sample data
        return [
            CalibrationDataPoint(confidence: 0, accuracy: 0),
            CalibrationDataPoint(confidence: 10, accuracy: 12),
            CalibrationDataPoint(confidence: 20, accuracy: 18),
            CalibrationDataPoint(confidence: 30, accuracy: 35),
            CalibrationDataPoint(confidence: 40, accuracy: 42),
            CalibrationDataPoint(confidence: 50, accuracy: 48),
            CalibrationDataPoint(confidence: 60, accuracy: 58),
            CalibrationDataPoint(confidence: 70, accuracy: 72),
            CalibrationDataPoint(confidence: 80, accuracy: 78),
            CalibrationDataPoint(confidence: 90, accuracy: 85),
            CalibrationDataPoint(confidence: 100, accuracy: 95)
        ]
    }

    func getBrierScore() -> Double {
        // Calculate from calibrationRecords
        guard !appState.calibrationRecords.isEmpty else { return 0.18 }

        let recentRecords = appState.calibrationRecords.suffix(7) // Last week
        let totalScore = recentRecords.reduce(0.0) { $0 + $1.brierScore }
        return totalScore / Double(recentRecords.count)
    }

    func getCalibrationPercentage() -> Int {
        // Calculate calibration accuracy from records
        guard !appState.calibrationRecords.isEmpty else { return 85 }

        let recentRecords = appState.calibrationRecords.suffix(7)
        let predictions = recentRecords.flatMap { $0.predictions }
        guard !predictions.isEmpty else { return 85 }

        let correct = predictions.filter { $0.wasCorrect }.count
        return Int((Double(correct) / Double(predictions.count)) * 100)
    }

    func getAverageConfidence() -> Int {
        // Calculate average confidence from records
        guard !appState.calibrationRecords.isEmpty else { return 72 }

        let recentRecords = appState.calibrationRecords.suffix(7)
        let predictions = recentRecords.flatMap { $0.predictions }
        guard !predictions.isEmpty else { return 72 }

        let totalConfidence = predictions.reduce(0) { $0 + $1.confidence }
        return totalConfidence / predictions.count
    }

    func getTotalPredictions() -> Int {
        // Count total predictions this week
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        let thisWeekRecords = appState.calibrationRecords.filter { $0.date >= weekAgo }
        return thisWeekRecords.reduce(0) { $0 + $1.predictions.count }
    }
}

// MARK: - Mock Implementation

final class MockCalibrationCalculator: CalibrationCalculator {
    var calibrationData: [CalibrationDataPoint]
    var brierScore: Double
    var calibrationPercentage: Int
    var averageConfidence: Int
    var totalPredictions: Int

    init(
        calibrationData: [CalibrationDataPoint] = CalibrationDataPoint.previewRealistic,
        brierScore: Double = 0.18,
        calibrationPercentage: Int = 85,
        averageConfidence: Int = 72,
        totalPredictions: Int = 47
    ) {
        self.calibrationData = calibrationData
        self.brierScore = brierScore
        self.calibrationPercentage = calibrationPercentage
        self.averageConfidence = averageConfidence
        self.totalPredictions = totalPredictions
    }

    func getCalibrationData() -> [CalibrationDataPoint] {
        calibrationData
    }

    func getBrierScore() -> Double {
        brierScore
    }

    func getCalibrationPercentage() -> Int {
        calibrationPercentage
    }

    func getAverageConfidence() -> Int {
        averageConfidence
    }

    func getTotalPredictions() -> Int {
        totalPredictions
    }

    // Convenience for previews
    static let preview = MockCalibrationCalculator()

    static let previewPerfectCalibration = MockCalibrationCalculator(
        calibrationData: CalibrationDataPoint.previewPerfect,
        brierScore: 0.05,
        calibrationPercentage: 98,
        averageConfidence: 75,
        totalPredictions: 100
    )

    static let previewPoorCalibration = MockCalibrationCalculator(
        brierScore: 0.45,
        calibrationPercentage: 55,
        averageConfidence: 90,
        totalPredictions: 15
    )
}
