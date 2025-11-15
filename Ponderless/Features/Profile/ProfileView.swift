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
    @State private var navigateToAnalytics = false
    @State private var notificationsEnabled = true

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

                    // Analytics Navigation Button
                    NavigationLink(destination: AnalyticsView()) {
                        HStack {
                            Text("View Full Analytics")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Spacing.lg)
                                .padding(.horizontal, Spacing.xl)
                                .foregroundStyle(DesignSystem.Colors.primaryForeground)
                        }
                    }
                    .buttonStyle(PressedButton3DStyle(
                        backgroundColor: DesignSystem.Colors.primary,
                        shadowColor: DesignSystem.Colors.primary.opacity(0.6),
                        hapticStyle: .medium
                    ))
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
                                color: DesignSystem.Colors.warning,
                                hasToggle: true,
                                toggleState: $notificationsEnabled
                            ) {
                                // Toggle handled by binding
                            }

                            AppearanceRow()
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
                                    .foregroundStyle(DesignSystem.Colors.destructive)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                    }
                }
                .padding(.vertical, Spacing.lg)
            }
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
                    .fill(avatarGradient)
                    .frame(width: Spacing.xxxxxxl + Spacing.xl, height: Spacing.xxxxxxl + Spacing.xl)

                Text(appState.currentUser?.name.prefix(2).uppercased() ?? "PA")
                    .font(Typography.largeTitle.bold())
                    .foregroundStyle(DesignSystem.Colors.onPrimary)
            }
            .shadow(style: .md)

            // User Info
            VStack(spacing: Spacing.xs) {
                Text(appState.currentUser?.name ?? "Pious Alpha")
                    .font(Typography.title2.bold())

                Text(appState.currentUser?.email ?? "pious@example.com")
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                
                if let bio = appState.currentUser?.bio, !bio.isEmpty {
                    Text(bio)
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        .multilineTextAlignment(.center)
                        .padding(.top, Spacing.xxs)
                }
            }

            // Stats
            HStack(spacing: Spacing.xl) {
                ProfileStat(value: "\(appState.trainingProgress.dailyStreak)", label: "Day Streak")
                ProfileStat(value: "\(appState.trainingProgress.totalExercisesCompleted)", label: "Exercises")
                ProfileStat(value: "\(Int(appState.trainingProgress.averageAccuracy * 100))%", label: "Accuracy")
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.secondary)
            .cardCorners()
            .cardShadow()
        }
    }
    
    private var avatarGradient: LinearGradient {
        let colorName = appState.currentUser?.avatarColor ?? "blue"
        let gradients: [String: LinearGradient] = [
            "blue": DesignSystem.Gradients.primary,
            "purple": DesignSystem.Gradients.secondary,
            "green": LinearGradient(
                colors: [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            "orange": LinearGradient(
                colors: [DesignSystem.Colors.warning, DesignSystem.Colors.warning.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            "red": LinearGradient(
                colors: [DesignSystem.Colors.destructive, DesignSystem.Colors.destructive.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            "pink": LinearGradient(
                colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accent.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ]
        return gradients[colorName] ?? DesignSystem.Gradients.primary
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
            .foregroundStyle(DesignSystem.Gradients.chart1)
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
            .cardCorners()
            .cardShadow()
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
    var toggleState: Binding<Bool>? = nil
    let action: () -> Void

    @State private var localToggleState = false
    @State private var isPressed = false
    
    private var toggleBinding: Binding<Bool> {
        toggleState ?? $localToggleState
    }

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
                        .cornerRadiusDesign(Corners.Component.badge)
                }

                if let value = value {
                    Text(value)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                }

                if hasToggle {
                    Toggle("", isOn: toggleBinding)
                        .labelsHidden()
                } else {
                    Image(systemName: "chevron.right")
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .contentShape(Rectangle())
            .background(
                DesignSystem.Colors.secondary.opacity(isPressed ? 0.5 : 0)
            )
        }
        .buttonStyle(SettingsButtonStyle(isPressed: $isPressed))
    }
}

// MARK: - Settings Button Style

struct SettingsButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = newValue
                }
            }
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
    @Environment(AppState.self) private var appState
    
    @State private var name: String
    @State private var email: String
    @State private var bio: String
    @State private var dailyGoal: Int
    @State private var preferredDifficulty: Difficulty
    @State private var focusAreas: Set<SkillCategory>
    @State private var preferredSessionDuration: SessionDuration
    @State private var selectedTimeZone: TimeZone
    @State private var learningStyle: LearningStyle?
    @State private var currentRole: String
    @State private var primaryGoal: PrimaryGoal?
    @State private var avatarColor: String
    
    @State private var showingImagePicker = false
    @State private var showingColorPicker = false
    
    init() {
        // Initialize with current user data or defaults
        let user = AppState().currentUser
        _name = State(initialValue: user?.name ?? "")
        _email = State(initialValue: user?.email ?? "")
        _bio = State(initialValue: user?.bio ?? "")
        _dailyGoal = State(initialValue: user?.dailyGoal ?? 3)
        _preferredDifficulty = State(initialValue: user?.preferredDifficulty ?? .intermediate)
        _focusAreas = State(initialValue: user?.focusAreas ?? [])
        _preferredSessionDuration = State(initialValue: user?.preferredSessionDuration ?? .medium)
        _selectedTimeZone = State(initialValue: user?.timeZone ?? .current)
        _learningStyle = State(initialValue: user?.learningStyle)
        _currentRole = State(initialValue: user?.currentRole ?? "")
        _primaryGoal = State(initialValue: user?.primaryGoal)
        _avatarColor = State(initialValue: user?.avatarColor ?? "blue")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Profile Photo Section
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: Spacing.md) {
                            // Avatar Display
                            ZStack {
                                Circle()
                                    .fill(avatarColorGradient)
                                    .frame(width: Spacing.xxxxxxl, height: Spacing.xxxxxxl)
                                
                                Text(name.prefix(2).uppercased())
                                    .font(Typography.title1.bold())
                                    .foregroundStyle(DesignSystem.Colors.onPrimary)
                            }
                            .shadow(style: .md)
                            
                            // Photo Actions
                            HStack(spacing: Spacing.md) {
                                Button {
                                    showingColorPicker = true
                                } label: {
                                    Label("Change Color", systemImage: "paintpalette")
                                        .font(Typography.caption)
                                }
                                .buttonStyle(.bordered)
                                
                                Button {
                                    showingImagePicker = true
                                } label: {
                                    Label("Upload Photo", systemImage: "photo")
                                        .font(Typography.caption)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                // Personal Information
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        TextField("Bio (optional)", text: $bio, axis: .vertical)
                            .lineLimit(2...4)
                        
                        HStack {
                            Spacer()
                            Text("\(bio.count)/100")
                                .font(Typography.caption2)
                                .foregroundStyle(bio.count > 100 ? DesignSystem.Colors.destructive : DesignSystem.Colors.secondaryForeground)
                        }
                    }
                }
                
                // Learning Preferences
                Section("Learning Preferences") {
                    // Daily Goal
                    Stepper(value: $dailyGoal, in: 1...20) {
                        HStack {
                            Text("Daily Goal")
                            Spacer()
                            Text("\(dailyGoal) exercise\(dailyGoal == 1 ? "" : "s")")
                                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        }
                    }
                    
                    // Preferred Difficulty
                    Picker("Preferred Difficulty", selection: $preferredDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    
                    // Preferred Session Duration
                    Picker("Session Duration", selection: $preferredSessionDuration) {
                        ForEach(SessionDuration.allCases, id: \.self) { duration in
                            Text(duration.rawValue).tag(duration)
                        }
                    }
                }
                
                // Focus Areas
                Section {
                    ForEach(SkillCategory.allCases, id: \.self) { category in
                        FocusAreaRow(
                            category: category,
                            isSelected: focusAreas.contains(category)
                        ) {
                            if focusAreas.contains(category) {
                                focusAreas.remove(category)
                            } else {
                                focusAreas.insert(category)
                            }
                        }
                    }
                } header: {
                    Text("Focus Areas")
                } footer: {
                    Text("Select the skills you want to prioritize in your training")
                }
                
                // Optional Details
                Section("Additional Details") {
                    // Time Zone
                    NavigationLink {
                        TimeZonePickerView(selectedTimeZone: $selectedTimeZone)
                    } label: {
                        HStack {
                            Text("Time Zone")
                            Spacer()
                            Text(selectedTimeZone.abbreviation() ?? "")
                                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        }
                    }
                    
                    // Learning Style
                    Picker("Learning Style", selection: $learningStyle) {
                        Text("Not Selected").tag(nil as LearningStyle?)
                        ForEach(LearningStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style as LearningStyle?)
                        }
                    }
                    
                    // Current Role
                    TextField("Current Role (optional)", text: $currentRole)
                    
                    // Primary Goal
                    Picker("Primary Goal", selection: $primaryGoal) {
                        Text("Not Selected").tag(nil as PrimaryGoal?)
                        ForEach(PrimaryGoal.allCases, id: \.self) { goal in
                            Text(goal.rawValue).tag(goal as PrimaryGoal?)
                        }
                    }
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
                        saveProfile()
                    }
                    .bold()
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingColorPicker) {
                AvatarColorPickerView(selectedColor: $avatarColor)
            }
            .sheet(isPresented: $showingImagePicker) {
                // TODO: Implement photo picker
                Text("Photo picker coming soon")
            }
        }
    }
    
    private var avatarColorGradient: LinearGradient {
        let gradients: [String: LinearGradient] = [
            "blue": DesignSystem.Gradients.primary,
            "purple": DesignSystem.Gradients.secondary,
            "green": LinearGradient(
                colors: [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            "orange": LinearGradient(
                colors: [DesignSystem.Colors.warning, DesignSystem.Colors.warning.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            "red": LinearGradient(
                colors: [DesignSystem.Colors.destructive, DesignSystem.Colors.destructive.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            "pink": LinearGradient(
                colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accent.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ]
        return gradients[avatarColor] ?? DesignSystem.Gradients.primary
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        bio.count <= 100
    }
    
    private func saveProfile() {
        // Update user in AppState
        guard var user = appState.currentUser else { return }
        
        user.name = name.trimmingCharacters(in: .whitespaces)
        user.email = email.trimmingCharacters(in: .whitespaces)
        user.bio = bio.isEmpty ? nil : bio.trimmingCharacters(in: .whitespaces)
        user.dailyGoal = dailyGoal
        user.preferredDifficulty = preferredDifficulty
        user.focusAreas = focusAreas
        user.preferredSessionDuration = preferredSessionDuration
        user.timeZone = selectedTimeZone
        user.learningStyle = learningStyle
        user.currentRole = currentRole.isEmpty ? nil : currentRole
        user.primaryGoal = primaryGoal
        user.avatarColor = avatarColor
        
        // Save to AppState
        appState.currentUser = user
        // TODO: Persist to backend/storage
        
        dismiss()
    }
}

// MARK: - Focus Area Row

struct FocusAreaRow: View {
    let category: SkillCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(category.color)
                    .frame(width: Spacing.xl)
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(category.rawValue)
                        .font(Typography.body)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                    
                    Text(category.description)
                        .font(Typography.caption2)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? category.color : DesignSystem.Colors.secondaryForeground)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Avatar Color Picker

struct AvatarColorPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: String
    
    let colors = [
        ("blue", DesignSystem.Gradients.primary),
        ("purple", DesignSystem.Gradients.secondary),
        ("green", LinearGradient(
            colors: [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )),
        ("orange", LinearGradient(
            colors: [DesignSystem.Colors.warning, DesignSystem.Colors.warning.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )),
        ("red", LinearGradient(
            colors: [DesignSystem.Colors.destructive, DesignSystem.Colors.destructive.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )),
        ("pink", LinearGradient(
            colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accent.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Spacing.lg) {
                    ForEach(colors, id: \.0) { colorName, gradient in
                        Button {
                            selectedColor = colorName
                            dismiss()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(gradient)
                                    .frame(width: Spacing.xxxxxxl, height: Spacing.xxxxxxl)
                                
                                if selectedColor == colorName {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                }
                            }
                            .shadow(style: .md)
                        }
                    }
                }
                .padding(Spacing.xl)
            }
            .navigationTitle("Choose Avatar Color")
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

// MARK: - Time Zone Picker

struct TimeZonePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTimeZone: TimeZone
    @State private var searchText = ""
    
    var filteredTimeZones: [TimeZone] {
        let allTimeZones = TimeZone.knownTimeZoneIdentifiers.compactMap { TimeZone(identifier: $0) }
        
        if searchText.isEmpty {
            return allTimeZones
        } else {
            return allTimeZones.filter {
                $0.identifier.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredTimeZones, id: \.identifier) { timeZone in
                Button {
                    selectedTimeZone = timeZone
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text(timeZone.identifier.replacingOccurrences(of: "_", with: " "))
                                .foregroundStyle(DesignSystem.Colors.foreground)
                            
                            if let abbreviation = timeZone.abbreviation() {
                                Text(abbreviation)
                                    .font(Typography.caption)
                                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                            }
                        }
                        
                        Spacer()
                        
                        if timeZone.identifier == selectedTimeZone.identifier {
                            Image(systemName: "checkmark")
                                .foregroundStyle(DesignSystem.Colors.primary)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .searchable(text: $searchText, prompt: "Search time zones")
        .navigationTitle("Time Zone")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subscription View

// MARK: - Subscription Models

enum SubscriptionTier: Equatable {
    case starter
    case premium
    
    var name: String {
        switch self {
        case .starter: return "Starter"
        case .premium: return "Premium"
        }
    }
    
    var subtitle: String {
        switch self {
        case .starter: return "Perfect for beginners"
        case .premium: return "For serious learners"
        }
    }
    
    var monthlyPrice: Decimal {
        switch self {
        case .starter: return 11.99
        case .premium: return 44.99
        }
    }
    
    var annualPrice: Decimal {
        switch self {
        case .starter: return 119.99
        case .premium: return 399.99
        }
    }
    
    var annualMonthlyEquivalent: Decimal {
        switch self {
        case .starter: return 9.99
        case .premium: return 33.33
        }
    }
    
    var annualSavingsPercent: Int {
        switch self {
        case .starter: return 17
        case .premium: return 26
        }
    }
    
    var features: [String] {
        switch self {
        case .starter:
            return [
                "30 exercises per month",
                "Basic AI guidance"
            ]
        case .premium:
            return [
                "Unlimited exercises & full AI coach",
                "Advanced analytics & priority support"
            ]
        }
    }
    
    var color: Color {
        switch self {
        case .starter: return DesignSystem.Colors.info
        case .premium: return DesignSystem.Colors.accent
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .starter:
            return LinearGradient(
                colors: [
                    DesignSystem.Colors.info,
                    DesignSystem.Colors.info.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .premium:
            return LinearGradient(
                colors: [
                    DesignSystem.Colors.primary,
                    DesignSystem.Colors.chart4
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

enum BillingPeriod: String, CaseIterable {
    case monthly = "Monthly"
    case annual = "Annual"
}

// MARK: - Subscription Card

struct SubscriptionCard: View {
    let tier: SubscriptionTier
    @Binding var billingPeriod: BillingPeriod
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text(tier.name)
                                .font(Typography.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(isSelected ? .white : DesignSystem.Colors.foreground)
                            
                            Text(tier.subtitle)
                                .font(Typography.caption)
                                .foregroundStyle(isSelected ? .white.opacity(0.85) : DesignSystem.Colors.secondaryForeground)
                        }
                        
                        Spacer()
                        
                        if isSelected && !isPremium {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.25))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    
                    // Billing Period Toggle
                    Picker("Billing Period", selection: $billingPeriod) {
                        ForEach(BillingPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Price
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                        Text("€")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(isSelected ? .white : DesignSystem.Colors.foreground)
                        
                        if billingPeriod == .monthly {
                            Text(String(format: "%.2f", NSDecimalNumber(decimal: tier.monthlyPrice).doubleValue))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(isSelected ? .white : DesignSystem.Colors.foreground)
                            
                            Text("/mo")
                                .font(Typography.body)
                                .foregroundStyle(isSelected ? .white.opacity(0.85) : DesignSystem.Colors.secondaryForeground)
                        } else {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                                    Text(String(format: "%.2f", NSDecimalNumber(decimal: tier.annualMonthlyEquivalent).doubleValue))
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundStyle(isSelected ? .white : DesignSystem.Colors.foreground)
                                    
                                    Text("/mo")
                                        .font(Typography.body)
                                        .foregroundStyle(isSelected ? .white.opacity(0.85) : DesignSystem.Colors.secondaryForeground)
                                }
                                
                                Text("€\(String(format: "%.2f", NSDecimalNumber(decimal: tier.annualPrice).doubleValue))/year")
                                    .font(Typography.caption2)
                                    .foregroundStyle(isSelected ? .white.opacity(0.75) : DesignSystem.Colors.mutedForeground)
                            }
                        }
                        
                        Spacer()
                        
                        // Savings Badge
                        if billingPeriod == .annual {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "tag.fill")
                                    .font(.caption2)
                                
                                Text("Save \(tier.annualSavingsPercent)%")
                                    .font(Typography.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(isSelected ? .white : tier.color)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                Capsule()
                                    .fill(isSelected ? .white.opacity(0.2) : tier.color.opacity(0.15))
                            )
                        }
                    }
                    
                    Divider()
                        .background(isSelected ? .white.opacity(0.3) : DesignSystem.Colors.border)
                    
                    // Features
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        ForEach(tier.features, id: \.self) { feature in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(isSelected ? .white : DesignSystem.Colors.foreground)
                                    .frame(width: 20, height: 20)
                                
                                Text(feature)
                                    .font(Typography.body)
                                    .foregroundStyle(isSelected ? .white : DesignSystem.Colors.foreground)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(Spacing.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Group {
                        if isSelected {
                            tier.gradient
                        } else {
                            DesignSystem.Colors.secondary
                        }
                    }
                )
.overlay(
                    RoundedRectangle(cornerRadius: Corners.Component.card)
                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                )
                .cornerRadius(Corners.Component.card)
                .shadow(
                    color: isSelected ? tier.color.opacity(0.3) : DesignSystem.Colors.shadowColor,
                    radius: isSelected ? 16 : 4,
                    x: 0,
                    y: isSelected ? 8 : 2
                )
                .scaleEffect(isSelected ? 1.0 : 1.0)
                
                // Most Popular Badge
                if isPremium {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "star.fill")
                            .font(.body)
                        
                        Text("MOST POPULAR")
                            .font(Typography.body)
                            .fontWeight(.bold)
                            .tracking(1.0)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        Capsule()
                            .fill(DesignSystem.Gradients.primary)
                    )
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                    .offset(x: -Spacing.md, y: -Spacing.md)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Subscription View

// MARK: - Subscription View

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @State private var selectedTier: SubscriptionTier?
    @State private var starterBillingPeriod: BillingPeriod = .monthly
    @State private var premiumBillingPeriod: BillingPeriod = .monthly

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.sm) {
                        Text("Choose Your Plan")
                            .font(Typography.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Select the subscription that fits your needs")
                            .font(Typography.body)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    }
                    .padding(.top, Spacing.lg)
                    
                    // Subscription Cards
                    VStack(spacing: Spacing.xxl) {
                        // Starter Card
                        SubscriptionCard(
                            tier: .starter,
                            billingPeriod: $starterBillingPeriod,
                            isSelected: selectedTier == .starter,
                            isPremium: false
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTier = .starter
                            }
                        }
                        
                        // Premium Card
                        SubscriptionCard(
                            tier: .premium,
                            billingPeriod: $premiumBillingPeriod,
                            isSelected: selectedTier == .premium,
                            isPremium: true
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTier = .premium
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    
                    // CTA Button
                    Button {
                        if let tier = selectedTier {
                            handleSubscriptionChange(tier)
                        }
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            if let tier = selectedTier {
                                Text("Continue with \(tier.name)")
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "arrow.right")
                                    .font(.body.weight(.semibold))
                            } else {
                                Text("Select a Plan")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                        .foregroundStyle(DesignSystem.Colors.primaryForeground)
                    }
                    .buttonStyle(PressedButton3DStyle(
                        backgroundColor: DesignSystem.Colors.primary,
                        shadowColor: DesignSystem.Colors.primary.opacity(0.6),
                        hapticStyle: .medium
                    ))
                    .disabled(selectedTier == nil)
                    .opacity(selectedTier == nil ? 0.5 : 1.0)
                    .padding(.horizontal, Spacing.lg)
                    
                    // Terms and Privacy
                    HStack(spacing: Spacing.sm) {
                        Button("Terms") {
                            // Handle terms
                        }
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        
                        Text("•")
                            .font(Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        
                        Button("Privacy") {
                            // Handle privacy
                        }
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    }
                    .padding(.bottom, Spacing.xl)
                }
            }
            .background(DesignSystem.Colors.background)
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
    
    private func handleSubscriptionChange(_ tier: SubscriptionTier) {
        // TODO: Implement subscription change logic with payment processing
        print("Changing subscription to \(tier.name)")
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}