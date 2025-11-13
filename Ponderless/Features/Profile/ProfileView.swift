//
//  ProfileView.swift
//  Ponderless
//
//  Profile tab with settings and analytics
//

import SwiftUI
import Charts

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var showingEditProfile = false
    @State private var showingSubscription = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    // Profile Header
                    ProfileHeaderSection()
                        .padding(.horizontal, Spacing.lg)

                    // Analytics Dashboard
                    AnalyticsDashboardSection()
                        .padding(.horizontal, Spacing.lg)

                    // Settings Sections
                    VStack(spacing: Spacing.lg) {
                        // Account Section
                        SettingsSection(title: "Account") {
                            SettingsRow(
                                icon: "person.circle",
                                title: "Edit Profile",
                                color: DesignSystem.Colors.primary
                            ) {
                                showingEditProfile = true
                            }

                            SettingsRow(
                                icon: "creditcard.circle",
                                title: "Subscription",
                                color: DesignSystem.Colors.accent,
                                badge: appState.isPremiumUser ? "Premium" : "Free"
                            ) {
                                showingSubscription = true
                            }
                        }

                        // Preferences Section
                        SettingsSection(title: "Preferences") {
                            SettingsRow(
                                icon: "bell.circle",
                                title: "Notifications",
                                color: DesignSystem.Colors.warning
                            ) {
                                // Handle notifications
                            }

                            AppearanceRow()

                            SettingsRow(
                                icon: "globe",
                                title: "Language",
                                color: DesignSystem.Colors.info,
                                value: "English"
                            ) {
                                // Handle language
                            }
                        }

                        // Support Section
                        SettingsSection(title: "Support") {
                            SettingsRow(
                                icon: "questionmark.circle",
                                title: "Help Center",
                                color: DesignSystem.Colors.success
                            ) {
                                // Handle help
                            }

                            SettingsRow(
                                icon: "envelope.circle",
                                title: "Contact Us",
                                color: DesignSystem.Colors.primary
                            ) {
                                // Handle contact
                            }

                            SettingsRow(
                                icon: "doc.text",
                                title: "Terms & Privacy",
                                color: DesignSystem.Colors.secondaryForeground
                            ) {
                                // Handle terms
                            }
                        }

                        // Account Actions
                        VStack(spacing: Spacing.md) {
                            SecondaryButton("Log Out") {
                                // Handle logout
                            }
                            
                            Button {
                                showingDeleteConfirmation = true
                            } label: {
                                Text("Delete Account")
                                    .font(Typography.caption)
                                    .foregroundStyle(DesignSystem.Colors.destructive.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                    }
                }
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
            .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Handle account deletion
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Profile Header

struct ProfileHeaderSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: Spacing.custom(25), height: Spacing.custom(25))

                Text(appState.currentUser?.name.prefix(2).uppercased() ?? "PA")
                    .font(Typography.largeTitle.bold())
                    .foregroundStyle(DesignSystem.Colors.onPrimary)
            }

            // User Info
            VStack(spacing: Spacing.xs) {
                Text(appState.currentUser?.name ?? "Pious Alpha")
                    .font(Typography.title2.bold())

                Text(appState.currentUser?.email ?? "pious@example.com")
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }

            // Stats
            HStack(spacing: Spacing.xl) {
                ProfileStat(value: "\(appState.trainingProgress.dailyStreak)", label: "Day Streak")
                ProfileStat(value: "\(appState.trainingProgress.totalExercisesCompleted)", label: "Exercises")
                ProfileStat(value: "\(Int(appState.trainingProgress.averageAccuracy * 100))%", label: "Accuracy")
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.secondary)
            .cornerRadius(Corners.lg)
        }
    }
}

struct ProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(Typography.title3.bold())

            Text(label)
                .font(Typography.caption)
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
        }
    }
}

// MARK: - Analytics Dashboard

struct AnalyticsDashboardSection: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTimeRange: TimeRange = .week

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                Text("Analytics")
                    .font(Typography.title3.bold())

                Spacer()

                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: Spacing.custom(45))
            }

            // Activity Chart
            ActivityChart()
                .frame(height: Spacing.custom(50))
                .padding(Spacing.lg)
                .background(DesignSystem.Colors.background)
                .cardCorners()
                .cardShadow()

            // Skill Progress Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.md) {
                ForEach(SkillCategory.allCases, id: \.self) { category in
                    SkillProgressCard(category: category)
                }
            }
        }
    }
}

struct ActivityChart: View {
    // Sample data
    let data = [
        ActivityData(day: "Mon", exercises: 3),
        ActivityData(day: "Tue", exercises: 5),
        ActivityData(day: "Wed", exercises: 2),
        ActivityData(day: "Thu", exercises: 4),
        ActivityData(day: "Fri", exercises: 6),
        ActivityData(day: "Sat", exercises: 3),
        ActivityData(day: "Sun", exercises: 4)
    ]

    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Day", item.day),
                y: .value("Exercises", item.exercises)
            )
            .foregroundStyle(DesignSystem.Colors.primary.gradient)
            .cornerRadius(Corners.xs)
        }
        .chartYAxisLabel("Exercises Completed")
    }
}

struct ActivityData: Identifiable {
    let id = UUID()
    let day: String
    let exercises: Int
}

struct SkillProgressCard: View {
    let category: SkillCategory
    @Environment(AppState.self) private var appState

    var progress: TrainingProgress.SkillProgress? {
        appState.trainingProgress.skillProgress[category]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: category.icon)
                    .font(Typography.caption)
                    .foregroundStyle(category.color)

                Text(category.rawValue)
                    .font(Typography.caption.bold())
                    .lineLimit(1)

                Spacer()
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Corners.xs)
                        .fill(DesignSystem.Colors.secondary)

                    RoundedRectangle(cornerRadius: Corners.xs)
                        .fill(category.color)
                        .frame(width: geometry.size.width * (progress?.accuracy ?? 0))
                }
            }
            .frame(height: Spacing.xs + Spacing.xxs)

            HStack {
                Text("Lvl \(progress?.level ?? 0)")
                    .font(Typography.caption2)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)

                Spacer()

                Text("\(Int((progress?.accuracy ?? 0) * 100))%")
                    .font(Typography.caption2.bold())
                    .foregroundStyle(category.color)
            }
        }
        .padding(Spacing.lg)
        .background(DesignSystem.Colors.background)
        .cardCorners()
        .cardShadow()
    }
}

// MARK: - Settings Components

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                .textCase(.uppercase)
                .padding(.horizontal, Spacing.lg)

            VStack(spacing: 1) {
                content
            }
            .background(DesignSystem.Colors.background)
            .cornerRadius(Corners.lg)
            .padding(.horizontal, Spacing.lg)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    var value: String? = nil
    var badge: String? = nil
    var hasToggle: Bool = false
    let action: () -> Void

    @State private var isToggled = false

    var body: some View {
        Button(action: hasToggle ? {} : action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: Spacing.xl + Spacing.md)

                Text(title)
                    .foregroundStyle(DesignSystem.Colors.foreground)

                Spacer()

                if let badge = badge {
                    Text(badge)
                        .font(Typography.caption)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xxs)
                        .background(color.opacity(0.1))
                        .foregroundStyle(color)
                        .cornerRadius(Corners.xs)
                }

                if let value = value {
                    Text(value)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                }

                if hasToggle {
                    Toggle("", isOn: $isToggled)
                        .labelsHidden()
                } else {
                    Image(systemName: "chevron.right")
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Appearance Row

struct AppearanceRow: View {
    @Environment(AppState.self) private var appState
    @State private var showingThemeSheet = false

    var body: some View {
        Button {
            showingThemeSheet = true
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: themeIcon)
                    .font(.title3)
                    .foregroundStyle(DesignSystem.Colors.primary)
                    .frame(width: Spacing.xl + Spacing.md)

                Text("Appearance")
                    .foregroundStyle(DesignSystem.Colors.foreground)

                Spacer()

                Text(currentThemeDescription)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)

                Image(systemName: "chevron.right")
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingThemeSheet) {
            ThemePickerSheet()
                .presentationDetents([.height(Spacing.custom(75))])
        }
    }

    private var themeIcon: String {
        switch appState.preferredColorScheme {
        case .dark:
            return "moon.circle.fill"
        case .light:
            return "sun.max.circle.fill"
        default:
            return "circle.lefthalf.filled"
        }
    }

    private var currentThemeDescription: String {
        switch appState.preferredColorScheme {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        default:
            return "System"
        }
    }
}

// MARK: - Theme Picker Sheet

struct ThemePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // System Option
                ThemeOption(
                    icon: "circle.lefthalf.filled",
                    title: "System",
                    description: "Match device settings",
                    isSelected: appState.preferredColorScheme == nil
                ) {
                    appState.preferredColorScheme = nil
                    appState.saveThemePreference()
                    dismiss()
                }

                Divider()
                    .padding(.leading, Spacing.xl * 2 + Spacing.lg)

                // Light Option
                ThemeOption(
                    icon: "sun.max.circle.fill",
                    title: "Light",
                    description: "Always use light mode",
                    isSelected: appState.preferredColorScheme == .light
                ) {
                    appState.preferredColorScheme = .light
                    appState.saveThemePreference()
                    dismiss()
                }

                Divider()
                    .padding(.leading, Spacing.xl * 2 + Spacing.lg)

                // Dark Option
                ThemeOption(
                    icon: "moon.circle.fill",
                    title: "Dark",
                    description: "Always use dark mode",
                    isSelected: appState.preferredColorScheme == .dark
                ) {
                    appState.preferredColorScheme = .dark
                    appState.saveThemePreference()
                    dismiss()
                }
            }
            .padding(.vertical, Spacing.sm)
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Theme Option

struct ThemeOption: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Colors.primary)
                    .frame(width: Spacing.xl * 2)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(Typography.body)
                        .foregroundStyle(DesignSystem.Colors.foreground)

                    Text(description)
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(DesignSystem.Colors.primary)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save changes
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

// MARK: - Subscription View

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Text("Upgrade to Premium")
                    .font(Typography.largeTitle)

                Text("Unlock all features and accelerate your growth")
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)

                Spacer()
            }
            .padding(Spacing.lg)
            .navigationTitle("Subscription")
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
    ProfileView()
        .environment(AppState())
}