//
//  LessonsView.swift
//  Ponderless
//
//  Main lessons view with category filtering
//

import SwiftUI

struct LessonsView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedCategory: LessonCategory?
    @State private var searchText = ""
    @State private var sortOrder = SortOrder.newest

    enum SortOrder: String, CaseIterable {
        case newest = "Newest"
        case difficulty = "Difficulty"
        case duration = "Duration"
        case category = "Category"
    }

    var filteredLessons: [Lesson] {
        var lessons = appState.lessons

        // Filter by category
        if let category = selectedCategory {
            lessons = lessons.filter { $0.category == category }
        }

        // Filter by search
        if !searchText.isEmpty {
            lessons = lessons.filter { lesson in
                lesson.title.localizedCaseInsensitiveContains(searchText) ||
                lesson.subtitle.localizedCaseInsensitiveContains(searchText) ||
                lesson.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        // Sort
        switch sortOrder {
        case .newest:
            lessons.sort { $0.createdAt > $1.createdAt }
        case .difficulty:
            lessons.sort { $0.difficulty.rawValue < $1.difficulty.rawValue }
        case .duration:
            lessons.sort { $0.estimatedDuration < $1.estimatedDuration }
        case .category:
            lessons.sort { $0.category.rawValue < $1.category.rawValue }
        }

        return lessons
    }

    var body: some View {
        NavigationStack(path: .constant(appState.navigationPath)) {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.md) {
                            CategoryChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )

                            ForEach(LessonCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    color: category.color,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }

                    // Lessons Grid
                    if filteredLessons.isEmpty {
                        EmptyStateView(
                            icon: "book.closed",
                            title: "No Lessons Found",
                            message: "Try adjusting your filters or check back later for new content."
                        )
                        .padding(.top, Spacing.xxxxxl)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.flexible())],
                            spacing: Spacing.lg
                        ) {
                            ForEach(filteredLessons) { lesson in
                                LessonCard(lesson: lesson)
                                    .onTapGesture {
                                        appState.navigate(to: .lesson(lesson))
                                    }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                }
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Lessons")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search lessons...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $sortOrder) {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                Label(order.rawValue, systemImage: sortIcon(for: order))
                                    .tag(order)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .refreshable {
                await appState.refreshData()
            }
        }
    }

    private func sortIcon(for order: SortOrder) -> String {
        switch order {
        case .newest: return "calendar"
        case .difficulty: return "graduationcap"
        case .duration: return "clock"
        case .category: return "folder"
        }
    }
}

// MARK: - Preview

#Preview {
    LessonsView()
        .environment(AppState())
}