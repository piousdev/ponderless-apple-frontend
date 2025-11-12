//
//  ReflectView.swift
//  Ponderless
//
//  Reflection and journaling view
//

import SwiftUI

struct ReflectView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedCategory: ReflectionCategory?
    @State private var currentReflection: Reflection?
    @State private var journalText = ""
    @State private var selectedMood: MoodCategory?
    @State private var showingJournalEditor = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    // Daily Reflection Card
                    if let reflection = currentReflection {
                        DailyReflectionCard(
                            reflection: reflection,
                            onStart: {
                                showingJournalEditor = true
                            }
                        )
                        .padding(.horizontal)
                    }

                    // Mood Tracker
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("How are you feeling?")
                            .font(.headline)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: Spacing.md) {
                            ForEach(MoodCategory.allCases, id: \.self) { mood in
                                MoodButton(
                                    mood: mood,
                                    isSelected: selectedMood == mood
                                ) {
                                    selectedMood = mood
                                }
                            }
                        }
                    }
                    .padding()
                    .background(DesignSystem.Colors.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: Corners.lg))
                    .padding(.horizontal)

                    // Reflection Categories
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Reflection Topics")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                            ForEach(ReflectionCategory.allCases, id: \.self) { category in
                                ReflectionCategoryCard(category: category) {
                                    selectedCategory = category
                                    loadReflectionsForCategory(category)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Recent Entries
                    if !appState.journalEntries.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack {
                                Text("Recent Entries")
                                    .font(.headline)
                                Spacer()
                                Button("See All") {
                                    // Navigate to journal history
                                }
                                .font(.subheadline)
                            }

                            ForEach(appState.journalEntries.prefix(5)) { entry in
                                JournalEntryRow(entry: entry)
                                    .onTapGesture {
                                        appState.navigate(to: .journalEntry(entry))
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Reflect")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingJournalEditor = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingJournalEditor) {
                JournalEditorView(
                    reflection: currentReflection,
                    mood: selectedMood
                )
            }
            .task {
                await loadDailyReflection()
            }
        }
    }

    private func loadDailyReflection() async {
        do {
            currentReflection = try await APIService.shared.fetchDailyReflection()
        } catch {
            // Use cached or default reflection
            currentReflection = Reflection(
                title: "Daily Check-in",
                prompt: "Take a moment to reflect on your day. What went well? What could be improved?",
                category: .daily,
                guidingQuestions: [
                    "What am I grateful for today?",
                    "What challenged me?",
                    "What did I learn?"
                ]
            )
        }
    }

    private func loadReflectionsForCategory(_ category: ReflectionCategory) {
        Task {
            do {
                let reflections = try await APIService.shared.fetchReflections(category: category)
                if let first = reflections.first {
                    currentReflection = first
                    showingJournalEditor = true
                }
            } catch {
                print("Failed to load reflections: \(error)")
            }
        }
    }
}

// MARK: - Subviews

struct DailyReflectionCard: View {
    let reflection: Reflection
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                Image(systemName: reflection.category.icon)
                    .foregroundStyle(DesignSystem.Colors.primary)
                Text("Today's Reflection")
                    .font(.subheadline)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                Spacer()
            }

            Text(reflection.title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(reflection.prompt)
                .font(.body)
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onStart) {
                HStack {
                    Text("Start Reflecting")
                    Image(systemName: "arrow.right")
                }
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Colors.primaryForeground)
                .frame(maxWidth: .infinity)
                .padding()
                .background(DesignSystem.Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: Corners.md))
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.primary.opacity(0.1),
                    DesignSystem.Colors.primary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Corners.xl))
    }
}

struct MoodButton: View {
    let mood: MoodCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text(mood.emoji)
                    .font(.title2)
                Text(mood.rawValue)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(
                isSelected ? Color(mood.color).opacity(0.2) : DesignSystem.Colors.muted
            )
            .clipShape(RoundedRectangle(cornerRadius: Corners.md))
            .overlay(
                RoundedRectangle(cornerRadius: Corners.md)
                    .stroke(isSelected ? Color(mood.color) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ReflectionCategoryCard: View {
    let category: ReflectionCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Colors.primary)

                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Colors.foreground)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.custom(20))
            .background(DesignSystem.Colors.secondary)
            .clipShape(RoundedRectangle(cornerRadius: Corners.lg))
        }
        .buttonStyle(.plain)
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            if let mood = entry.mood {
                Text(mood.emoji)
                    .font(.title3)
            } else {
                Image(systemName: "doc.text")
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(entry.content)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundStyle(DesignSystem.Colors.foreground)

                HStack {
                    Text(entry.createdAt, style: .date)
                    Text("•")
                    Text("\(entry.wordCount) words")
                }
                .font(.caption)
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(DesignSystem.Colors.mutedForeground)
        }
        .padding()
        .background(DesignSystem.Colors.muted)
        .clipShape(RoundedRectangle(cornerRadius: Corners.md))
    }
}