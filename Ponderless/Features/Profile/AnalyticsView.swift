//
//  AnalyticsView.swift
//  Ponderless
//
//  Comprehensive analytics page with various chart types
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var selectedTimeRange: TimeRange = .month
    @State private var selectedDataPoint: ActivityDataPoint?
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxl) {
                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, Spacing.lg)
                
                // SECTION 1: Overview
                // High-level summary metrics
                OverviewStatsSection()
                    .padding(.horizontal, Spacing.lg)
                
                // SECTION 2: Activity Patterns
                // Shows engagement and time investment trends
                
                // Primary activity trend over time
                ActivityOverTimeSection(selectedDataPoint: $selectedDataPoint)
                    .padding(.horizontal, Spacing.lg)
                
                // Daily breakdown for the current week
                WeeklyProgressSection()
                    .padding(.horizontal, Spacing.lg)
                
                // Time investment patterns
                DailyTimeSpentSection()
                    .padding(.horizontal, Spacing.lg)
                
                // SECTION 3: Performance Metrics
                // Shows quality and skill development
                
                // Accuracy improvement over time
                AccuracyTrendSection()
                    .padding(.horizontal, Spacing.lg)
                
                // Multi-dimensional skill analysis
                SkillPerformanceSection()
                    .padding(.horizontal, Spacing.lg)
                
                // SECTION 4: Distribution & Goals
                // Shows what you're doing and how you're achieving goals
                
                // Category breakdown of exercises
                ExerciseDistributionSection()
                    .padding(.horizontal, Spacing.lg)
                
                // Goal achievement metrics
                CompletionRateSection()
                    .padding(.horizontal, Spacing.lg)
            }
            .padding(.vertical, Spacing.xl)
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Overview Stats Section

struct OverviewStatsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Overview")
                .font(Typography.title3.bold())
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.md) {
                StatCard(
                    title: "Total Exercises",
                    value: "1,247",
                    change: "+12.5%",
                    isPositive: true,
                    icon: "chart.bar.fill",
                    color: DesignSystem.Colors.chart1
                )
                
                StatCard(
                    title: "Avg Accuracy",
                    value: "87.3%",
                    change: "+5.2%",
                    isPositive: true,
                    icon: "target",
                    color: DesignSystem.Colors.chart2
                )
                
                StatCard(
                    title: "Time Invested",
                    value: "42.5h",
                    change: "+8.1%",
                    isPositive: true,
                    icon: "clock.fill",
                    color: DesignSystem.Colors.chart3
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "18 days",
                    change: "Best: 25",
                    isPositive: true,
                    icon: "flame.fill",
                    color: DesignSystem.Colors.chart4
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(Typography.caption)
                    .foregroundStyle(color)
                
                Spacer()
                
                Text(change)
                    .font(Typography.caption2)
                    .foregroundStyle(isPositive ? DesignSystem.Colors.success : DesignSystem.Colors.destructive)
            }
            
            Text(value)
                .font(Typography.title2.bold())
                .foregroundStyle(DesignSystem.Colors.foreground)
            
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
        }
        .padding(Spacing.lg)
        .background(DesignSystem.Colors.background)
        .cardCorners()
        .cardShadow()
    }
}

// MARK: - Activity Over Time (Area Chart)

struct ActivityOverTimeSection: View {
    @Binding var selectedDataPoint: ActivityDataPoint?
    
    let activityData = [
        ActivityDataPoint(date: Date().addingTimeInterval(-30 * 86400), exercises: 5),
        ActivityDataPoint(date: Date().addingTimeInterval(-27 * 86400), exercises: 8),
        ActivityDataPoint(date: Date().addingTimeInterval(-24 * 86400), exercises: 12),
        ActivityDataPoint(date: Date().addingTimeInterval(-21 * 86400), exercises: 10),
        ActivityDataPoint(date: Date().addingTimeInterval(-18 * 86400), exercises: 15),
        ActivityDataPoint(date: Date().addingTimeInterval(-15 * 86400), exercises: 18),
        ActivityDataPoint(date: Date().addingTimeInterval(-12 * 86400), exercises: 14),
        ActivityDataPoint(date: Date().addingTimeInterval(-9 * 86400), exercises: 20),
        ActivityDataPoint(date: Date().addingTimeInterval(-6 * 86400), exercises: 22),
        ActivityDataPoint(date: Date().addingTimeInterval(-3 * 86400), exercises: 25),
        ActivityDataPoint(date: Date(), exercises: 28)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Activity Over Time")
                .font(Typography.title3.bold())
            
            VStack(spacing: Spacing.md) {
                Chart(activityData, id: \.id) { dataPoint in
                    AreaMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Exercises", dataPoint.exercises)
                    )
                    .foregroundStyle(DesignSystem.Gradients.chart1)
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Exercises", dataPoint.exercises)
                    )
                    .foregroundStyle(DesignSystem.Colors.chart1)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: Spacing.xxxxxxl * 3)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                
                if let selectedDataPoint {
                    VStack(spacing: Spacing.xs) {
                        Text("\(selectedDataPoint.exercises) exercises")
                            .font(Typography.body.bold())
                            .foregroundStyle(DesignSystem.Colors.foreground)
                        
                        Text(selectedDataPoint.date, format: .dateTime.month().day().year())
                            .font(Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    }
                    .padding(Spacing.md)
                    .background(DesignSystem.Colors.secondary)
                    .cornerRadiusDesign(Corners.md)
                }
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.background)
            .cardCorners()
            .cardShadow()
        }
    }
}

struct ActivityDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let exercises: Int
}

// MARK: - Exercise Distribution (Pie Chart)

struct ExerciseDistributionSection: View {
    let distributionData = [
        ExerciseDistribution(category: "Cognitive", count: 342, color: DesignSystem.Colors.chart1),
        ExerciseDistribution(category: "Behavioral", count: 298, color: DesignSystem.Colors.chart2),
        ExerciseDistribution(category: "Emotional", count: 267, color: DesignSystem.Colors.chart3),
        ExerciseDistribution(category: "Social", count: 189, color: DesignSystem.Colors.chart4),
        ExerciseDistribution(category: "Physical", count: 151, color: DesignSystem.Colors.chart5)
    ]
    
    var totalExercises: Int {
        distributionData.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Exercise Distribution")
                .font(Typography.title3.bold())
            
            VStack(spacing: Spacing.lg) {
                Chart(distributionData, id: \.id) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(item.color)
                }
                .frame(height: Spacing.xxxxxxl * 3)
                
                // Legend
                VStack(spacing: Spacing.sm) {
                    ForEach(distributionData) { item in
                        HStack(spacing: Spacing.md) {
                            Circle()
                                .fill(item.color)
                                .frame(width: Spacing.md, height: Spacing.md)
                            
                            Text(item.category)
                                .font(Typography.body)
                                .foregroundStyle(DesignSystem.Colors.foreground)
                            
                            Spacer()
                            
                            Text("\(item.count)")
                                .font(Typography.body.bold())
                                .foregroundStyle(DesignSystem.Colors.foreground)
                            
                            Text("(\(Int(Double(item.count) / Double(totalExercises) * 100))%)")
                                .font(Typography.caption)
                                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        }
                    }
                }
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.background)
            .cardCorners()
            .cardShadow()
        }
    }
}

struct ExerciseDistribution: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
    let color: Color
}

// MARK: - Skill Performance (Radar Chart)

struct SkillPerformanceSection: View {
    let skillData = [
        SkillPerformance(skill: "Focus", score: 85),
        SkillPerformance(skill: "Memory", score: 78),
        SkillPerformance(skill: "Logic", score: 92),
        SkillPerformance(skill: "Creativity", score: 73),
        SkillPerformance(skill: "Emotional", score: 88),
        SkillPerformance(skill: "Social", score: 81)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Skill Performance")
                .font(Typography.title3.bold())
            
            VStack(spacing: Spacing.lg) {
                // Radar Chart using Angular Gradient
                RadarChartView(data: skillData)
                    .frame(height: Spacing.xxxxxxl * 3.5)
                
                // Skills Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Spacing.sm) {
                    ForEach(skillData) { skill in
                        HStack {
                            Text(skill.skill)
                                .font(Typography.caption)
                                .foregroundStyle(DesignSystem.Colors.foreground)
                            
                            Spacer()
                            
                            Text("\(skill.score)%")
                                .font(Typography.caption.bold())
                                .foregroundStyle(DesignSystem.Colors.chart1)
                        }
                    }
                }
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.background)
            .cardCorners()
            .cardShadow()
        }
    }
}

struct SkillPerformance: Identifiable {
    let id = UUID()
    let skill: String
    let score: Int
}

struct RadarChartView: View {
    let data: [SkillPerformance]
    
    private func angle(for index: Int) -> Double {
        (2 * .pi / Double(data.count)) * Double(index) - .pi / 2
    }
    
    private func point(for skill: SkillPerformance, index: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let angleValue = angle(for: index)
        let distance = radius * (Double(skill.score) / 100.0)
        return CGPoint(
            x: center.x + cos(angleValue) * distance,
            y: center.y + sin(angleValue) * distance
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2.5
            
            ZStack {
                backgroundCircles(radius: radius)
                axisLines(center: center, radius: radius)
                dataPolygonFilled(center: center, radius: radius)
                dataPolygonStroke(center: center, radius: radius)
                dataPoints(center: center, radius: radius)
            }
        }
    }
    
    @ViewBuilder
    private func backgroundCircles(radius: CGFloat) -> some View {
        ForEach([0.2, 0.4, 0.6, 0.8, 1.0], id: \.self) { scale in
            Circle()
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                .frame(width: radius * 2 * scale, height: radius * 2 * scale)
        }
    }
    
    @ViewBuilder
    private func axisLines(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<data.count, id: \.self) { index in
            let angleValue = angle(for: index)
            let endPoint = CGPoint(
                x: center.x + cos(angleValue) * radius,
                y: center.y + sin(angleValue) * radius
            )
            
            Path { path in
                path.move(to: center)
                path.addLine(to: endPoint)
            }
            .stroke(DesignSystem.Colors.border, lineWidth: 1)
            
            Text(data[index].skill)
                .font(Typography.caption2)
                .foregroundStyle(DesignSystem.Colors.foreground)
                .position(
                    x: center.x + cos(angleValue) * (radius + 20),
                    y: center.y + sin(angleValue) * (radius + 20)
                )
        }
    }
    
    @ViewBuilder
    private func dataPolygonFilled(center: CGPoint, radius: CGFloat) -> some View {
        Path { path in
            for (index, skill) in data.enumerated() {
                let pt = point(for: skill, index: index, center: center, radius: radius)
                if index == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
            path.closeSubpath()
        }
        .fill(DesignSystem.Colors.chart1.opacity(0.3))
    }
    
    @ViewBuilder
    private func dataPolygonStroke(center: CGPoint, radius: CGFloat) -> some View {
        Path { path in
            for (index, skill) in data.enumerated() {
                let pt = point(for: skill, index: index, center: center, radius: radius)
                if index == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
            path.closeSubpath()
        }
        .stroke(DesignSystem.Colors.chart1, lineWidth: 3)
    }
    
    @ViewBuilder
    private func dataPoints(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<data.count, id: \.self) { index in
            let pt = point(for: data[index], index: index, center: center, radius: radius)
            Circle()
                .fill(DesignSystem.Colors.chart1)
                .frame(width: 8, height: 8)
                .position(pt)
        }
    }
}



// MARK: - Weekly Progress (Bar Chart)

struct WeeklyProgressSection: View {
    let weeklyData = [
        WeeklyProgress(day: "Mon", completed: 12, target: 15),
        WeeklyProgress(day: "Tue", completed: 15, target: 15),
        WeeklyProgress(day: "Wed", completed: 10, target: 15),
        WeeklyProgress(day: "Thu", completed: 14, target: 15),
        WeeklyProgress(day: "Fri", completed: 18, target: 15),
        WeeklyProgress(day: "Sat", completed: 13, target: 15),
        WeeklyProgress(day: "Sun", completed: 16, target: 15)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Weekly Progress")
                .font(Typography.title3.bold())
            
            VStack(spacing: Spacing.md) {
                Chart {
                    ForEach(weeklyData, id: \.id) { item in
                        BarMark(
                            x: .value("Day", item.day),
                            y: .value("Completed", item.completed)
                        )
                        .foregroundStyle(DesignSystem.Gradients.chart2)
                    }
                    
                    RuleMark(y: .value("Target", 15))
                        .foregroundStyle(DesignSystem.Colors.chart3)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Target")
                                .font(Typography.caption2)
                                .foregroundStyle(DesignSystem.Colors.chart3)
                        }
                }
                .frame(height: Spacing.xxxxxxl * 2.5)
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                
                HStack {
                    HStack(spacing: Spacing.xs) {
                        RoundedRectangle(cornerRadius: Corners.xs)
                            .fill(DesignSystem.Colors.chart2)
                            .frame(width: Spacing.md, height: Spacing.md)
                        
                        Text("Completed")
                            .font(Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.foreground)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: Spacing.xs) {
                        Rectangle()
                            .fill(DesignSystem.Colors.chart3)
                            .frame(width: Spacing.md, height: 2)
                        
                        Text("Target")
                            .font(Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.foreground)
                    }
                }
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.background)
            .cardCorners()
            .cardShadow()
        }
    }
}

struct WeeklyProgress: Identifiable {
    let id = UUID()
    let day: String
    let completed: Int
    let target: Int
}

// MARK: - Accuracy Trend (Line Chart)

struct AccuracyTrendSection: View {
    @State private var selectedPoint: AccuracyPoint?
    
    let accuracyData = [
        AccuracyPoint(date: Date().addingTimeInterval(-20 * 86400), accuracy: 72),
        AccuracyPoint(date: Date().addingTimeInterval(-18 * 86400), accuracy: 75),
        AccuracyPoint(date: Date().addingTimeInterval(-16 * 86400), accuracy: 78),
        AccuracyPoint(date: Date().addingTimeInterval(-14 * 86400), accuracy: 76),
        AccuracyPoint(date: Date().addingTimeInterval(-12 * 86400), accuracy: 80),
        AccuracyPoint(date: Date().addingTimeInterval(-10 * 86400), accuracy: 82),
        AccuracyPoint(date: Date().addingTimeInterval(-8 * 86400), accuracy: 84),
        AccuracyPoint(date: Date().addingTimeInterval(-6 * 86400), accuracy: 83),
        AccuracyPoint(date: Date().addingTimeInterval(-4 * 86400), accuracy: 86),
        AccuracyPoint(date: Date().addingTimeInterval(-2 * 86400), accuracy: 87),
        AccuracyPoint(date: Date(), accuracy: 89)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Accuracy Trend")
                .font(Typography.title3.bold())
            
            VStack(spacing: Spacing.md) {
                Chart(accuracyData, id: \.id) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Accuracy", point.accuracy)
                    )
                    .foregroundStyle(DesignSystem.Colors.chart4)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Accuracy", point.accuracy)
                    )
                    .foregroundStyle(DesignSystem.Colors.chart4)
                }
                .frame(height: Spacing.xxxxxxl * 2.5)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 4)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)%")
                            }
                        }
                    }
                }
                .chartYScale(domain: 60...100)
                
                Text("Tap on data points to see details")
                    .font(Typography.caption2)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.background)
            .cardCorners()
            .cardShadow()
        }
    }
}

struct AccuracyPoint: Identifiable {
    let id = UUID()
    let date: Date
    let accuracy: Int
}

// MARK: - Completion Rate (Radial Chart)

struct CompletionRateSection: View {
    let completionData = [
        CompletionMetric(category: "Daily Goals", percentage: 0.92, color: DesignSystem.Colors.chart2),
        CompletionMetric(category: "Weekly Targets", percentage: 0.85, color: DesignSystem.Colors.chart1),
        CompletionMetric(category: "Lesson Progress", percentage: 0.78, color: DesignSystem.Colors.chart3),
        CompletionMetric(category: "Skill Mastery", percentage: 0.67, color: DesignSystem.Colors.chart4)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Completion Metrics")
                .font(Typography.title3.bold())
            
            VStack(spacing: Spacing.lg) {
                ForEach(completionData) { metric in
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text(metric.category)
                                .font(Typography.body)
                                .foregroundStyle(DesignSystem.Colors.foreground)
                            
                            Spacer()
                            
                            Text("\(Int(metric.percentage * 100))%")
                                .font(Typography.body.bold())
                                .foregroundStyle(metric.color)
                        }
                        
                        // Radial Progress
                        ZStack {
                            Circle()
                                .stroke(DesignSystem.Colors.secondary, lineWidth: 12)
                            
                            Circle()
                                .trim(from: 0, to: metric.percentage)
                                .stroke(
                                    metric.color,
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: metric.percentage)
                        }
                        .frame(height: Spacing.xxxxxxl)
                    }
                    .padding(Spacing.lg)
                    .background(DesignSystem.Colors.background)
                    .cardCorners()
                    .cardShadow()
                }
            }
        }
    }
}

struct CompletionMetric: Identifiable {
    let id = UUID()
    let category: String
    let percentage: Double
    let color: Color
}

// MARK: - Daily Time Spent (Area Chart)

struct DailyTimeSpentSection: View {
    let timeData = [
        TimeSpent(date: Date().addingTimeInterval(-13 * 86400), minutes: 25),
        TimeSpent(date: Date().addingTimeInterval(-12 * 86400), minutes: 32),
        TimeSpent(date: Date().addingTimeInterval(-11 * 86400), minutes: 28),
        TimeSpent(date: Date().addingTimeInterval(-10 * 86400), minutes: 45),
        TimeSpent(date: Date().addingTimeInterval(-9 * 86400), minutes: 38),
        TimeSpent(date: Date().addingTimeInterval(-8 * 86400), minutes: 42),
        TimeSpent(date: Date().addingTimeInterval(-7 * 86400), minutes: 35),
        TimeSpent(date: Date().addingTimeInterval(-6 * 86400), minutes: 50),
        TimeSpent(date: Date().addingTimeInterval(-5 * 86400), minutes: 48),
        TimeSpent(date: Date().addingTimeInterval(-4 * 86400), minutes: 52),
        TimeSpent(date: Date().addingTimeInterval(-3 * 86400), minutes: 46),
        TimeSpent(date: Date().addingTimeInterval(-2 * 86400), minutes: 55),
        TimeSpent(date: Date().addingTimeInterval(-1 * 86400), minutes: 60),
        TimeSpent(date: Date(), minutes: 58)
    ]
    
    var averageTime: Int {
        timeData.reduce(0) { $0 + $1.minutes } / timeData.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Daily Time Spent")
                .font(Typography.title3.bold())
            
            VStack(spacing: Spacing.md) {
                Chart {
                    ForEach(timeData, id: \.id) { item in
                        AreaMark(
                            x: .value("Date", item.date),
                            y: .value("Minutes", item.minutes)
                        )
                        .foregroundStyle(DesignSystem.Gradients.chart3)
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Minutes", item.minutes)
                        )
                        .foregroundStyle(DesignSystem.Colors.chart3)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                    }
                    
                    RuleMark(y: .value("Average", averageTime))
                        .foregroundStyle(DesignSystem.Colors.chart5)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
                .frame(height: Spacing.xxxxxxl * 2.5)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 3)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)m")
                            }
                        }
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Average")
                            .font(Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        
                        Text("\(averageTime) min/day")
                            .font(Typography.body.bold())
                            .foregroundStyle(DesignSystem.Colors.foreground)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: Spacing.xxs) {
                        Text("Total This Week")
                            .font(Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        
                        Text("\(timeData.suffix(7).reduce(0) { $0 + $1.minutes }) min")
                            .font(Typography.body.bold())
                            .foregroundStyle(DesignSystem.Colors.foreground)
                    }
                }
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.background)
            .cardCorners()
            .cardShadow()
        }
    }
}

struct TimeSpent: Identifiable {
    let id = UUID()
    let date: Date
    let minutes: Int
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AnalyticsView()
            .environment(AppState())
    }
}
