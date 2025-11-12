//
//  CoachView.swift
//  Ponderless
//
//  Coach tab with 3 AI coaches interface
//

import SwiftUI

struct CoachView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedCoach: CoachType?
    @State private var showingChat = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    // Coach Selection
                    CoachSelectionSection(selectedCoach: $selectedCoach)
                        .padding(.horizontal, Spacing.lg)

                    // Active Sessions
                    if !appState.activeChatSessions.isEmpty {
                        ActiveSessionsSection()
                            .padding(.horizontal, Spacing.lg)
                    }

                    // Coach Features
                    CoachFeaturesSection()
                        .padding(.horizontal, Spacing.lg)
                }
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Coach")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedCoach) { coachType in
                CoachChatView(coachType: coachType)
            }
        }
    }
}

// MARK: - Coach Selection

struct CoachSelectionSection: View {
    @Binding var selectedCoach: CoachType?
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Choose Your Coach")
                .font(Typography.title3.bold())

            VStack(spacing: Spacing.md) {
                ForEach(appState.coaches, id: \.id) { coach in
                    CoachCard(coach: coach) {
                        selectedCoach = coach.type
                    }
                }
            }
        }
    }
}

struct CoachCard: View {
    let coach: Coach
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.lg) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(coach.type.color.gradient)
                        .frame(width: Spacing.custom(15), height: Spacing.custom(15))

                    Image(systemName: coach.avatar)
                        .font(.title2)
                        .foregroundStyle(DesignSystem.Colors.onPrimary)
                }

                // Info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(coach.name)
                        .font(Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.foreground)

                    Text(coach.tagline)
                        .font(Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        .multilineTextAlignment(.leading)

                    // Specialties
                    HStack(spacing: Spacing.xs) {
                        ForEach(coach.specialties.prefix(2), id: \.self) { specialty in
                            Text(specialty.rawValue)
                                .font(Typography.caption2)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xxs)
                                .background(coach.type.color.opacity(0.1))
                                .foregroundStyle(coach.type.color)
                                .cornerRadius(Corners.xs)
                        }
                    }
                    .padding(.top, Spacing.xxs)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.background)
            .cardCorners()
            .cardShadow()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Active Sessions

struct ActiveSessionsSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Active Sessions")
                .font(Typography.title3.bold())

            ForEach(Array(appState.activeChatSessions.values), id: \.id) { session in
                ActiveSessionCard(session: session)
            }
        }
    }
}

struct ActiveSessionCard: View {
    let session: ChatSession

    var body: some View {
        HStack {
            // Coach Icon
            Image(systemName: session.coachType.icon)
                .font(.title3)
                .foregroundStyle(session.coachType.color)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(session.coachType.rawValue)
                    .font(Typography.subheadline.bold())

                Text("\(session.messages.count) messages")
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }

            Spacer()

            Text(session.startedAt, style: .relative)
                .font(Typography.caption2)
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
        }
        .padding(Spacing.lg)
        .background(DesignSystem.Colors.secondary)
        .cornerRadius(Corners.sm)
    }
}

// MARK: - Coach Features

struct CoachFeaturesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("How Coaches Help")
                .font(Typography.title3.bold())

            VStack(spacing: Spacing.md) {
                FeatureRow(
                    icon: "shield.lefthalf.filled",
                    title: "Challenge Your Thinking",
                    description: "Test assumptions and identify blind spots",
                    color: DesignSystem.Colors.destructive
                )

                FeatureRow(
                    icon: "location.north.circle.fill",
                    title: "Navigate Complexity",
                    description: "Break down problems systematically",
                    color: DesignSystem.Colors.primary
                )

                FeatureRow(
                    icon: "binoculars.fill",
                    title: "Explore New Angles",
                    description: "Discover creative alternatives",
                    color: DesignSystem.Colors.success
                )
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: Spacing.xl + Spacing.md)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(Typography.subheadline.bold())

                Text(description)
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }

            Spacer()
        }
    }
}

// MARK: - Coach Chat View

struct CoachChatView: View {
    let coachType: CoachType
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool

    var session: ChatSession? {
        appState.activeChatSessions[coachType]
    }

    var coach: Coach? {
        appState.coaches.first { $0.type == coachType }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Coach Header
                if let coach = coach {
                    CoachChatHeader(coach: coach)
                        .padding(Spacing.lg)
                        .background(DesignSystem.Colors.background)
                        .cardShadow()
                }

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: Spacing.md) {
                            // Introduction
                            if session?.messages.isEmpty ?? true {
                                if let coach = coach {
                                    ChatBubble(
                                        message: coach.introduction,
                                        isUser: false,
                                        coachType: coachType
                                    )
                                    .id("intro")
                                }
                            }

                            // Messages
                            ForEach(session?.messages ?? [], id: \.id) { message in
                                ChatBubble(
                                    message: message.content,
                                    isUser: message.sender == .user,
                                    coachType: coachType
                                )
                                .id(message.id)
                            }
                        }
                        .padding(Spacing.lg)
                    }
                    .onChange(of: session?.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(session?.messages.last?.id, anchor: .bottom)
                        }
                    }
                }

                // Input Bar
                ChatInputBar(
                    messageText: $messageText,
                    isInputFocused: _isInputFocused
                ) {
                    Task {
                        await appState.sendMessage(messageText, to: coachType)
                        messageText = ""
                    }
                }
            }
            .navigationTitle(coachType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            if appState.activeChatSessions[coachType] == nil {
                await appState.startChatSession(with: coachType)
            }
        }
    }
}

struct CoachChatHeader: View {
    let coach: Coach

    var body: some View {
        HStack {
            Image(systemName: coach.avatar)
                .font(.title2)
                .foregroundStyle(coach.type.color)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(coach.name)
                    .font(Typography.headline)

                Text(coach.tagline)
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            }

            Spacer()
        }
    }
}

struct ChatBubble: View {
    let message: String
    let isUser: Bool
    let coachType: CoachType

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: Spacing.custom(15)) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: Spacing.xs) {
                if !isUser {
                    Text(coachType.rawValue)
                        .font(Typography.caption2)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                }

                Text(message)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        isUser ?
                        DesignSystem.Colors.primary :
                        DesignSystem.Colors.secondary
                    )
                    .foregroundStyle(isUser ? DesignSystem.Colors.onPrimary : DesignSystem.Colors.foreground)
                    .cornerRadius(Corners.lg)
            }

            if !isUser { Spacer(minLength: Spacing.custom(15)) }
        }
    }
}

struct ChatInputBar: View {
    @Binding var messageText: String
    @FocusState var isInputFocused: Bool
    let sendAction: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            TextField("Type your message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isInputFocused)
                .onSubmit {
                    if !messageText.isEmpty {
                        sendAction()
                    }
                }

            Button(action: sendAction) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(messageText.isEmpty ? DesignSystem.Colors.secondaryForeground : DesignSystem.Colors.primary)
            }
            .disabled(messageText.isEmpty)
        }
        .padding(Spacing.lg)
        .background(DesignSystem.Colors.background)
        .cardShadow()
    }
}

#Preview {
    CoachView()
        .environment(AppState())
}