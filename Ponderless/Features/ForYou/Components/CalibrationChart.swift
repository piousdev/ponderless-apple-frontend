//
//  CalibrationChart.swift
//  Ponderless
//
//  Refactored calibration chart with cached data and optimization
//

import SwiftUI
import Charts

struct CalibrationChart: View {
    let calculator: CalibrationCalculator

    @State private var selectedDataPoint: CalibrationDataPoint?

    // Cache perfect calibration line to avoid recalculating
    private static let perfectCalibrationData: [(Int, Int)] = {
        (0...10).map { i in (i * 10, i * 10) }
    }()

    private var data: [CalibrationDataPoint] {
        calculator.getCalibrationData()
    }

    // Find the closest data point to the tapped X coordinate
    private func findClosestDataPoint(to x: Int) -> CalibrationDataPoint? {
        guard !data.isEmpty else { return nil }
        return data.min(by: { abs($0.confidence - x) < abs($1.confidence - x) })
    }

    // Check if a point is selected (compare by confidence value, not UUID)
    private func isSelected(_ point: CalibrationDataPoint) -> Bool {
        guard let selected = selectedDataPoint else { return false }
        return selected.confidence == point.confidence && selected.accuracy == point.accuracy
    }

    var body: some View {
        Chart {
            // Perfect calibration line (cached)
            ForEach(Self.perfectCalibrationData, id: \.0) { point in
                LineMark(
                    x: .value("Confidence", point.0),
                    y: .value("Accuracy", point.1)
                )
                .foregroundStyle(DesignSystem.Colors.mutedForeground.opacity(0.3))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }

            // Actual calibration curve
            ForEach(data) { point in
                LineMark(
                    x: .value("Confidence", point.confidence),
                    y: .value("Accuracy", point.accuracy)
                )
                .foregroundStyle(DesignSystem.Colors.primary)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }

            ForEach(data) { point in
                PointMark(
                    x: .value("Confidence", point.confidence),
                    y: .value("Accuracy", point.accuracy)
                )
                .foregroundStyle(DesignSystem.Colors.primary)
                .symbolSize(isSelected(point) ? ForYouConstants.Sizing.chartSymbolSize * 1.5 : ForYouConstants.Sizing.chartSymbolSize)
            }

            // Selection indicator - vertical rule mark at selected point
            if let selected = selectedDataPoint {
                RuleMark(x: .value("Selected", selected.confidence))
                    .foregroundStyle(DesignSystem.Colors.primary.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .annotation(
                        position: .automatic,
                        spacing: 8,
                        overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))
                    ) {
                        VStack(spacing: Spacing.xxs) {
                            Text("Confidence: \(selected.confidence)%")
                                .font(Typography.caption2.bold())
                                .foregroundStyle(DesignSystem.Colors.foreground)
                            Text("Accuracy: \(selected.accuracy)%")
                                .font(Typography.caption2)
                                .foregroundStyle(DesignSystem.Colors.mutedForeground)
                        }
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(DesignSystem.Colors.background)
                        .cornerRadiusDesign(Corners.Component.tooltip)
                        .overlay(
                            RoundedRectangle(cornerRadius: Corners.Component.tooltip, style: .continuous)
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                        .zIndex(1000)
                    }
            }
        }
        .chartXAxisLabel("Predicted Confidence %")
        .chartYAxisLabel("Actual Accuracy %")
        .chartXScale(domain: 0...100)
        .chartYScale(domain: 0...100)
        .chartGesture { chartProxy in
            SpatialTapGesture()
                .onEnded { value in
                    // Get the X value at tap location
                    if let xValue = chartProxy.value(atX: value.location.x, as: Int.self) {
                        // Find the closest data point
                        selectedDataPoint = findClosestDataPoint(to: xValue)

                        // Auto-dismiss tooltip after 3.5 seconds
                        if selectedDataPoint != nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                selectedDataPoint = nil
                            }
                        }
                    }
                }
        }
        .accessibilityLabel(ForYouConstants.AccessibilityLabels.calibrationChart)
        .accessibilityHint(ForYouConstants.AccessibilityLabels.chartHint)
    }
}

#Preview {
    CalibrationChart(calculator: MockCalibrationCalculator.preview)
        .frame(height: ForYouConstants.Sizing.calibrationChartHeight)
        .cardStyle()
        .padding()
}

#Preview("Perfect Calibration") {
    CalibrationChart(calculator: MockCalibrationCalculator.previewPerfectCalibration)
        .frame(height: ForYouConstants.Sizing.calibrationChartHeight)
        .cardStyle()
        .padding()
}

#Preview("Poor Calibration") {
    CalibrationChart(calculator: MockCalibrationCalculator.previewPoorCalibration)
        .frame(height: ForYouConstants.Sizing.calibrationChartHeight)
        .cardStyle()
        .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.lg) {
        CalibrationChart(calculator: MockCalibrationCalculator.preview)
            .frame(height: ForYouConstants.Sizing.calibrationChartHeight)
            .cardStyle()

        CalibrationChart(calculator: MockCalibrationCalculator.previewPerfectCalibration)
            .frame(height: ForYouConstants.Sizing.calibrationChartHeight)
            .cardStyle()
    }
    .padding()
    .preferredColorScheme(.dark)
}
