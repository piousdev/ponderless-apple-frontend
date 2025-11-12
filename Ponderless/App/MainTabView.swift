//
//  MainTabView.swift
//  Ponderless
//
//  Main navigation tab view with 4 tabs
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            ForYouView()
                .tabItem {
                    Label("For You", systemImage: "house")
                }
                .tag(AppTab.forYou)

            PracticeView()
                .tabItem {
                    Label("Practice", systemImage: "brain.head.profile")
                }
                .tag(AppTab.practice)

            CoachView()
                .tabItem {
                    Label("Coach", systemImage: "message")
                }
                .tag(AppTab.coach)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(AppTab.profile)
        }
        .tint(DesignSystem.Colors.primary)
        .task {
            // Load initial data if needed
            if appState.trainingExercises.isEmpty {
                await loadInitialData()
            }
        }
        .sheet(isPresented: $appState.showOnboarding) {
            OnboardingView()
        }
        .alert(
            "Error",
            isPresented: .constant(appState.error != nil),
            presenting: appState.error
        ) { _ in
            Button("OK") {
                appState.error = nil
            }
            .tint(DesignSystem.Colors.destructive)
        } message: { error in
            Text(error.localizedDescription)
                .foregroundStyle(DesignSystem.Colors.foreground)
        }
    }

    private func loadInitialData() async {
        // In a real app, this would load from API or cache
        // For now, we'll create some sample data
        createSampleData()
    }

    private func createSampleData() {
        // Create sample training exercises
        appState.trainingExercises = [
            TrainingExercise(
                title: "Identify the Bias",
                skillCategory: .biasRecognition,
                scenario: "A manager says: 'We hired John last time and he was great, so we should hire another person from his university.'",
                exercises: [],
                learningPoints: ["Recognize availability bias", "Question generalizations"]
            ),
            TrainingExercise(
                title: "Evaluate the Evidence",
                skillCategory: .evidenceLiteracy,
                scenario: "A news article claims a new diet leads to 50% weight loss based on a study of 10 people.",
                exercises: [],
                learningPoints: ["Check sample size", "Look for peer review"]
            )
        ]

        // Create sample framework templates
        appState.frameworkTemplates = [
            FrameworkTemplate(
                type: .evidenceToDecision,
                title: "Career Decision Template",
                description: "Evaluate job opportunities systematically",
                steps: []
            ),
            FrameworkTemplate(
                type: .toulminArgumentation,
                title: "Argument Builder",
                description: "Structure persuasive arguments",
                steps: []
            )
        ]
    }
}