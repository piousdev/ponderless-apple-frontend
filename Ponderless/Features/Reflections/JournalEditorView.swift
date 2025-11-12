//
//  JournalEditorView.swift
//  Ponderless
//
//  Journal entry editor with guided prompts
//

import SwiftUI

struct JournalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let reflection: Reflection?
    let mood: MoodCategory?

    @State private var journalText = ""
    @State private var selectedMood: MoodCategory?
    @State private var insights: [String] = []
    @State private var actionItems: [String] = []
    @State private var currentInsight = ""
    @State private var currentActionItem = ""
    @State private var isSaving = false
    @FocusState private var isTextFieldFocused: Bool

    init(reflection: Reflection? = nil, mood: MoodCategory? = nil) {
        self.reflection = reflection
        self.mood = mood
        self._selectedMood = State(initialValue: mood)
    }

    var wordCount: Int {
        journalText.split(separator: " ").count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Reflection Prompt
                    if let reflection = reflection {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text(reflection.prompt)
                                .font(.headline)
                                .foregroundStyle(DesignSystem.Colors.foreground)

                            if !reflection.guidingQuestions.isEmpty {
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    Text("Consider these questions:")
                                        .font(.subheadline)
                                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)

                                    ForEach(reflection.guidingQuestions, id: \.self) { question in
                                        HStack(alignment: .top) {
                                            Text("•")
                                            Text(question)
                                                .font(.subheadline)
                                                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(DesignSystem.Colors.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: Corners.lg))
                    }

                    // Mood Selection
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Current Mood")
                            .font(.subheadline)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.md) {
                                ForEach(MoodCategory.allCases, id: \.self) { mood in
                                    MoodChip(
                                        mood: mood,
                                        isSelected: selectedMood == mood
                                    ) {
                                        selectedMood = mood
                                    }
                                }
                            }
                        }
                    }

                    // Journal Entry
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text("Your Thoughts")
                                .font(.subheadline)
                                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                            Spacer()
                            Text("\(wordCount) words")
                                .font(.caption)
                                .foregroundStyle(DesignSystem.Colors.mutedForeground)
                        }

                        TextEditor(text: $journalText)
                            .focused($isTextFieldFocused)
                            .frame(minHeight: Spacing.custom(50))
                            .padding(Spacing.sm)
                            .background(DesignSystem.Colors.muted)
                            .clipShape(RoundedRectangle(cornerRadius: Corners.md))
                    }

                    // Insights
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Key Insights (Optional)")
                            .font(.subheadline)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)

                        ForEach(insights, id: \.self) { insight in
                            InsightRow(text: insight) {
                                insights.removeAll { $0 == insight }
                            }
                        }

                        HStack {
                            TextField("Add an insight...", text: $currentInsight)
                                .textFieldStyle(.roundedBorder)
                            Button("Add") {
                                if !currentInsight.isEmpty {
                                    insights.append(currentInsight)
                                    currentInsight = ""
                                }
                            }
                            .disabled(currentInsight.isEmpty)
                        }
                    }

                    // Action Items
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Action Items (Optional)")
                            .font(.subheadline)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)

                        ForEach(actionItems, id: \.self) { item in
                            ActionItemRow(text: item) {
                                actionItems.removeAll { $0 == item }
                            }
                        }

                        HStack {
                            TextField("Add an action item...", text: $currentActionItem)
                                .textFieldStyle(.roundedBorder)
                            Button("Add") {
                                if !currentActionItem.isEmpty {
                                    actionItems.append(currentActionItem)
                                    currentActionItem = ""
                                }
                            }
                            .disabled(currentActionItem.isEmpty)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(journalText.isEmpty || isSaving)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isTextFieldFocused = false
                    }
                }
            }
        }
    }

    private func saveEntry() {
        isSaving = true

        let entry = JournalEntry(
            reflectionId: reflection?.id ?? UUID(),
            userId: appState.currentUser?.id ?? UUID(),
            content: journalText,
            mood: selectedMood,
            insights: insights,
            actionItems: actionItems
        )

        Task {
            await appState.saveJournalEntry(entry)
            await MainActor.run {
                dismiss()
            }
        }
    }
}

// MARK: - Subviews

struct MoodChip: View {
    let mood: MoodCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Text(mood.emoji)
                Text(mood.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs + Spacing.xxs)
            .background(
                isSelected ? Color(mood.color).opacity(0.2) : DesignSystem.Colors.muted
            )
            .foregroundStyle(isSelected ? Color(mood.color) : DesignSystem.Colors.foreground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color(mood.color) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct InsightRow: View {
    let text: String
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(DesignSystem.Colors.warning)
                .font(.caption)
            Text(text)
                .font(.subheadline)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    .font(.caption)
            }
        }
        .padding(Spacing.sm)
        .background(DesignSystem.Colors.muted)
        .clipShape(RoundedRectangle(cornerRadius: Corners.md))
    }
}

struct ActionItemRow: View {
    let text: String
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .foregroundStyle(DesignSystem.Colors.success)
                .font(.caption)
            Text(text)
                .font(.subheadline)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    .font(.caption)
            }
        }
        .padding(Spacing.sm)
        .background(DesignSystem.Colors.muted)
        .clipShape(RoundedRectangle(cornerRadius: Corners.md))
    }
}