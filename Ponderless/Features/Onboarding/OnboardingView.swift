//
//  OnboardingView.swift
//  Ponderless
//
//  Initial onboarding experience for new users
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Ponderless",
            subtitle: "Stop overthinking, start thinking clearly",
            imageName: "brain.head.profile",
            description: "Build critical thinking skills through micro-learning and guided reflection.",
            color: DesignSystem.Colors.primary
        ),
        OnboardingPage(
            title: "Daily Micro-Lessons",
            subtitle: "Learn in bite-sized chunks",
            imageName: "book.fill",
            description: "Short, focused lessons that fit into your busy schedule.",
            color: DesignSystem.Colors.chart4
        ),
        OnboardingPage(
            title: "Guided Reflection",
            subtitle: "Journal with purpose",
            imageName: "pencil.and.outline",
            description: "Structured prompts help you process thoughts and make better decisions.",
            color: DesignSystem.Colors.success
        ),
        OnboardingPage(
            title: "AI Coaches",
            subtitle: "Personalized guidance",
            imageName: "message.fill",
            description: "Get support from specialized AI coaches whenever you need it.",
            color: DesignSystem.Colors.warning
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Page View
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Bottom Section
            VStack(spacing: Spacing.xl) {
                // Page Indicator
                HStack(spacing: Spacing.sm) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? DesignSystem.Colors.primary : DesignSystem.Colors.border)
                            .frame(width: Spacing.sm, height: Spacing.sm)
                            .animation(.easeInOut, value: currentPage)
                    }
                }

                // Action Button
                PrimaryButton(currentPage < pages.count - 1 ? "Next" : "Get Started") {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }

                // Skip Button
                if currentPage < pages.count - 1 {
                    CompactSecondaryButton("Skip") {
                        completeOnboarding()
                    }
                }
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.bottom, Spacing.xl)
        }
    }

    private func completeOnboarding() {
        appState.showOnboarding = false
        dismiss()

        // Set up initial user preferences
        Task {
            await appState.refreshData()
        }
    }
}

// MARK: - Supporting Types

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Spacing.xxxl) {
            Spacer()

            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: Spacing.custom(20)))
                .foregroundStyle(page.color)
                .frame(height: Spacing.custom(30))

            // Text Content
            VStack(spacing: Spacing.lg) {
                Text(page.title)
                    .font(Typography.largeTitle)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(Typography.title3)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(Typography.body)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }

            Spacer()
            Spacer()
        }
        .padding(Spacing.lg)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environment(AppState())
}