//
//  TodoPointsView.swift
//  Ponderless
//
//  Points display for todo items
//

import SwiftUI

struct TodoPointsView: View {
    let points: Int
    let isCompleted: Bool

    var body: some View {
        Text("+\(points)")
            .font(Typography.footnote.bold())
            .foregroundStyle(isCompleted ? DesignSystem.Colors.chart2 : DesignSystem.Colors.mutedForeground)
            .accessibilityLabel("\(points) points")
    }
}

#Preview {
    HStack(spacing: Spacing.lg) {
        TodoPointsView(points: 10, isCompleted: false)
        TodoPointsView(points: 15, isCompleted: false)
        TodoPointsView(points: 20, isCompleted: true)
    }
    .padding()
}

#Preview("Dark Mode") {
    HStack(spacing: Spacing.lg) {
        TodoPointsView(points: 10, isCompleted: false)
        TodoPointsView(points: 15, isCompleted: false)
        TodoPointsView(points: 20, isCompleted: true)
    }
    .padding()
    .preferredColorScheme(.dark)
}
