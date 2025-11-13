//
//  StreakSheetView.swift
//  Ponderless
//
//  Refactored streak sheet with ViewModel and calendar logic
//

import SwiftUI

struct StreakSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: StreakCalendarViewModel

    @ScaledMetric private var iconSize: CGFloat = 30
    @ScaledMetric private var circleDiameter: CGFloat = ForYouConstants.Sizing.badgeCircleDiameter
    @ScaledMetric private var navigationButtonSize: CGFloat = ForYouConstants.Sizing.weekNavigationButtonSize
    @ScaledMetric private var dayCircleSize: CGFloat = ForYouConstants.Sizing.dayCircleSize

    init(viewModel: StreakCalendarViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    // Fire Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.chart3, DesignSystem.Colors.chart5],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: circleDiameter, height: circleDiameter)
                            .overlay(
                                Circle()
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )
                            .shadow(style: .sm)

                        Image(systemName: "flame.fill")
                            .font(.system(size: iconSize))
                            .foregroundStyle(DesignSystem.Colors.primaryForeground)
                    }
                    .accessibilityLabel("Streak flame icon")

                    // Streak Count
                    HStack(spacing: Spacing.xs) {
                        Text("\(viewModel.dailyStreak)")
                            .font(Typography.title2.bold())
                            .foregroundStyle(DesignSystem.Colors.foreground)

                        Text(viewModel.dailyStreak == 1 ? "Day Streak" : "Days Streak")
                            .font(Typography.title2)
                            .foregroundStyle(DesignSystem.Colors.foreground)
                    }
                    .accessibilityLabel("\(viewModel.dailyStreak) day streak")

                    // Motivational Message
                    Text(viewModel.motivationalMessage)
                        .font(Typography.body)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)

                    // Week Calendar
                    VStack(spacing: Spacing.lg) {
                        // Week Navigation Header
                        HStack {
                            // Left Chevron
                            Button {
                                withAnimation {
                                    viewModel.navigateToPreviousWeek()
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(DesignSystem.Colors.secondary)
                                        .frame(width: navigationButtonSize, height: navigationButtonSize)
                                        .overlay(
                                            Circle()
                                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                                        )
                                        .shadow(style: .xs)

                                    Image(systemName: "chevron.left")
                                        .font(Typography.body.bold())
                                        .foregroundStyle(DesignSystem.Colors.foreground)
                                }
                            }
                            .accessibilityLabel("Previous week")

                            Spacer()

                            Text(viewModel.weekDateRange)
                                .font(Typography.headline)
                                .foregroundStyle(DesignSystem.Colors.foreground)

                            Spacer()

                            // Right Chevron
                            Button {
                                withAnimation {
                                    viewModel.navigateToNextWeek()
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(viewModel.canGoToNextWeek ? DesignSystem.Colors.secondary : DesignSystem.Colors.muted)
                                        .frame(width: navigationButtonSize, height: navigationButtonSize)
                                        .overlay(
                                            Circle()
                                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                                        )
                                        .shadow(style: viewModel.canGoToNextWeek ? .xs : .none)

                                    Image(systemName: "chevron.right")
                                        .font(Typography.body.bold())
                                        .foregroundStyle(viewModel.canGoToNextWeek ? DesignSystem.Colors.foreground : DesignSystem.Colors.mutedForeground)
                                }
                            }
                            .disabled(!viewModel.canGoToNextWeek)
                            .opacity(viewModel.canGoToNextWeek ? 1.0 : 0.5)
                            .accessibilityLabel("Next week")
                            .accessibilityHint(viewModel.canGoToNextWeek ? "" : "Cannot view future weeks")
                        }
                        .padding(.horizontal)

                        // Week Calendar Grid
                        HStack(spacing: Spacing.sm) {
                            ForEach(0..<ForYouConstants.Calendar.daysInWeek, id: \.self) { dayIndex in
                                if let date = viewModel.dateForDayInWeek(dayIndex) {
                                    let hasActivity = viewModel.hasActivityForDate(date)

                                    VStack(spacing: Spacing.sm) {
                                        // Day of week label
                                        Text(viewModel.dayOfWeekLabel(for: dayIndex))
                                            .font(Typography.caption2)
                                            .foregroundStyle(DesignSystem.Colors.mutedForeground)

                                        // Day circle with indicator
                                        ZStack {
                                            Circle()
                                                .fill(hasActivity ? DesignSystem.Colors.chart2.opacity(0.1) : DesignSystem.Colors.secondary)
                                                .frame(width: dayCircleSize, height: dayCircleSize)
                                                .overlay(
                                                    Circle()
                                                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                                                )
                                                .shadow(style: hasActivity ? .xs : .none)

                                            if hasActivity {
                                                Image(systemName: "checkmark")
                                                    .font(Typography.headline)
                                                    .foregroundStyle(DesignSystem.Colors.chart2)
                                            } else if viewModel.isFutureDate(date) {
                                                // Future dates - empty
                                            } else {
                                                Image(systemName: "xmark")
                                                    .font(Typography.headline)
                                                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
                                            }
                                        }

                                        // Day number
                                        Text("\(Calendar.current.component(.day, from: date))")
                                            .font(Typography.caption2)
                                            .foregroundStyle(DesignSystem.Colors.mutedForeground)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel("\(viewModel.dayOfWeekLabel(for: dayIndex)), day \(Calendar.current.component(.day, from: date))")
                                    .accessibilityValue(hasActivity ? "Activity completed" : viewModel.isFutureDate(date) ? "Future date" : "No activity")
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, Spacing.xl)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle(ForYouConstants.TextContent.streakTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    StreakSheetView(viewModel: .preview)
}

#Preview("High Streak") {
    StreakSheetView(viewModel: .previewHighStreak)
}

#Preview("New User") {
    StreakSheetView(viewModel: .previewNewUser)
}

#Preview("Dark Mode") {
    StreakSheetView(viewModel: .preview)
        .preferredColorScheme(.dark)
}
