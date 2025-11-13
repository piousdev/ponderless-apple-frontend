//
//  CoachView.swift
//  Ponderless
//
//  Coach tab with 3 AI coaches interface
//

import SwiftUI

struct CoachView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedCoach: CoachType = .challenger
    @State private var messageText = ""
    @State private var showHistory = false
    @State private var showCoachSelector = false
    @State private var isNewChat = false
    @FocusState private var isInputFocused: Bool
    
    var currentCoach: Coach? {
        appState.coaches.first { $0.type == selectedCoach }
    }
    
    var session: ChatSession? {
        appState.activeChatSessions[selectedCoach]
    }
    
    var body: some View {
        contentView
            .task {
                if appState.activeChatSessions[selectedCoach] == nil {
                    await appState.startChatSession(with: selectedCoach)
                }
            }
            .sheet(isPresented: $showHistory) {
                ChatHistoryView(selectedCoach: $selectedCoach)
            }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                // History button
                Button(action: {
                    showHistory = true
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.body)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                        .frame(width: 40, height: 40)
                        .background(DesignSystem.Colors.secondary)
                        .clipShape(Circle())
                }
                
                Spacer()

                // Coach selector button
                Button(action: {
                    showCoachSelector = true
                }) {
                    HStack(spacing: Spacing.xs) {
                        if let coach = currentCoach {
                            Image(systemName: coach.avatar)
                                .font(.subheadline)
                                .foregroundStyle(coach.type.color)

                            Text(coach.name)
                                .font(Typography.subheadline.bold())
                                .foregroundStyle(DesignSystem.Colors.foreground)

                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        }
                    }
                }

                Spacer()
                
                // New chat button
                Button(action: {
                    // Haptic feedback
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()

                    // Reset chat session
                    isNewChat = true
                    messageText = ""
                    Task {
                        appState.endChatSession(for: selectedCoach)
                        await appState.startChatSession(with: selectedCoach)
                        // Focus keyboard after a short delay
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        isInputFocused = true
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.body.bold())
                        .foregroundStyle(DesignSystem.Colors.foreground)
                        .frame(width: 40, height: 40)
                        .background(DesignSystem.Colors.secondary)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(DesignSystem.Colors.background)
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
            
            // Messages
            ScrollViewReader { proxy in
                GeometryReader { geometry in
                    ScrollView {
                        if isNewChat {
                            // Centered welcome view for new chat
                            VStack(spacing: Spacing.xl) {
                                // Coach icon
                                Image(systemName: currentCoach?.avatar ?? "shield.lefthalf.filled")
                                    .font(.system(size: 64))
                                    .foregroundStyle(currentCoach?.type.color ?? DesignSystem.Colors.primary)
                                    .frame(width: 100, height: 100)
                                    .background(
                                        Circle()
                                            .fill((currentCoach?.type.color ?? DesignSystem.Colors.primary).opacity(0.1))
                                    )

                                // Welcome message
                                VStack(spacing: Spacing.sm) {
                                    Text(currentCoach?.name ?? "Coach")
                                        .font(Typography.title2.bold())
                                        .foregroundStyle(DesignSystem.Colors.foreground)

                                    Text(currentCoach?.tagline ?? "How can I help you today?")
                                        .font(Typography.body)
                                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.horizontal, Spacing.xl)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // Mock messages for design
                        LazyVStack(spacing: Spacing.lg) {
                            ChatMessageRow(
                                message: "Welcome! I'm here to help you challenge your thinking and test your assumptions. What would you like to explore today?",
                                isUser: false,
                                avatarIcon: currentCoach?.avatar ?? "shield.lefthalf.filled",
                                coachColor: currentCoach?.type.color ?? DesignSystem.Colors.primary
                            )
                            .id("mock1")

                            ChatMessageRow(
                                message: "I've been thinking about switching careers to tech, but I'm not sure if it's the right move.",
                                isUser: true,
                                avatarIcon: "person.circle.fill",
                                coachColor: nil
                            )
                            .id("mock2")

                            ChatMessageRow(
                                message: "That's an interesting consideration. Before we dive deeper, what evidence are you basing this uncertainty on? Is it concrete data about job prospects, or is it more about your feelings and assumptions?",
                                isUser: false,
                                avatarIcon: currentCoach?.avatar ?? "shield.lefthalf.filled",
                                coachColor: currentCoach?.type.color ?? DesignSystem.Colors.primary
                            )
                            .id("mock3")

                            ChatMessageRow(
                                message: "I guess it's mostly fear. I'm worried I'm too old to learn coding at 35.",
                                isUser: true,
                                avatarIcon: "person.circle.fill",
                                coachColor: nil
                            )
                            .id("mock4")

                            ChatMessageRow(
                                message: "Interesting. Let's challenge that assumption. What specific evidence do you have that 35 is 'too old' to learn coding? Have you researched successful career changers in tech who started later?",
                                isUser: false,
                                avatarIcon: currentCoach?.avatar ?? "shield.lefthalf.filled",
                                coachColor: currentCoach?.type.color ?? DesignSystem.Colors.primary
                            )
                            .id("mock5")

                            // Actual session messages
                            ForEach(session?.messages ?? [], id: \.id) { message in
                                ChatMessageRow(
                                    message: message.content,
                                    isUser: message.sender == .user,
                                    avatarIcon: message.sender == .user ? "person.circle.fill" : (currentCoach?.avatar ?? "shield.lefthalf.filled"),
                                    coachColor: message.sender == .user ? nil : currentCoach?.type.color
                                )
                                .id(message.id)
                            }
                        }
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.md)
                        }
                    }
                }
                .onTapGesture {
                    isInputFocused = false
                }
                .onChange(of: session?.messages.count) { _, _ in
                    if let lastMessage = session?.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isInputFocused) { _, focused in
                    if focused {
                        // Scroll to bottom when keyboard appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                if let lastMessage = session?.messages.last {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                } else {
                                    proxy.scrollTo("mock5", anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
            
            // Input bar
            EnhancedChatInputBar(
                messageText: $messageText,
                isInputFocused: $isInputFocused,
                primaryColor: currentCoach?.type.color ?? DesignSystem.Colors.primary
            ) {
                // Send action
                guard !messageText.isEmpty else { return }
                isNewChat = false
                Task {
                    await appState.sendMessage(messageText, to: selectedCoach)
                    messageText = ""
                }
            } onAudioTap: {
                // TODO: Audio recording
                print("Audio tapped")
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(DesignSystem.Colors.background)
            .shadow(color: Color.black.opacity(0.1), radius: 4, y: -2)
        }
        .background(DesignSystem.Colors.background)
        .sheet(isPresented: $showCoachSelector) {
            CoachSelectorSheet(selectedCoach: $selectedCoach, coaches: appState.coaches)
        }
    }
}

// MARK: - Coach Selector Sheet

struct CoachSelectorSheet: View {
    @Binding var selectedCoach: CoachType
    let coaches: [Coach]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ForEach(coaches, id: \.id) { coach in
                    Button(action: {
                        selectedCoach = coach.type
                        dismiss()
                    }) {
                        HStack(spacing: Spacing.md) {
                            // Coach icon
                            Image(systemName: coach.avatar)
                                .font(.title2)
                                .foregroundStyle(coach.type.color)
                                .frame(width: 48, height: 48)
                                .background(coach.type.color.opacity(0.1))
                                .clipShape(Circle())

                            // Coach info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(coach.name)
                                    .font(Typography.headline)
                                    .foregroundStyle(DesignSystem.Colors.foreground)

                                Text(coach.type.description)
                                    .font(Typography.caption)
                                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer()

                            // Checkmark if selected
                            if selectedCoach == coach.type {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(coach.type.color)
                            }
                        }
                        .padding(Spacing.md)
                        .background(
                            selectedCoach == coach.type ?
                            coach.type.color.opacity(0.05) :
                            Color.clear
                        )
                        .cornerRadius(Corners.md)
                    }
                    .buttonStyle(PlainButtonStyle())

                    if coach.id != coaches.last?.id {
                        Divider()
                            .padding(.leading, Spacing.lg + 48 + Spacing.md)
                    }
                }

                Spacer()
            }
            .padding(Spacing.lg)
            .background(DesignSystem.Colors.background)
            .navigationTitle("Choose Your Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}



// MARK: - Chat Message Row

struct ChatMessageRow: View {
    let message: String
    let isUser: Bool
    let avatarIcon: String
    let coachColor: Color?
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            if isUser {
                Spacer(minLength: Spacing.custom(10))
            }
            
            if !isUser {
                // Coach avatar on left
                Image(systemName: avatarIcon)
                    .font(.title3)
                    .foregroundStyle(coachColor ?? DesignSystem.Colors.primary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill((coachColor ?? DesignSystem.Colors.primary).opacity(0.1))
                    )
            }
            
            // Message bubble
            Text(message)
                .font(Typography.body)
                .foregroundStyle(
                    isUser ?
                    DesignSystem.Colors.onPrimary :
                    DesignSystem.Colors.foreground
                )
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm + 2)
                .background(
                    isUser ?
                    (coachColor ?? DesignSystem.Colors.primary) :
                    DesignSystem.Colors.secondary
                )
                .cornerRadius(Corners.lg)
            
            if isUser {
                // User avatar on right
                Image(systemName: avatarIcon)
                    .font(.title3)
                    .foregroundStyle(DesignSystem.Colors.onPrimary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.primary)
                    )
            }
            
            if !isUser {
                Spacer(minLength: Spacing.custom(10))
            }
        }
    }
}


// MARK: - Enhanced Chat Input Bar

struct EnhancedChatInputBar: View {
    @Binding var messageText: String
    var isInputFocused: FocusState<Bool>.Binding
    let primaryColor: Color
    let sendAction: () -> Void
    let onAudioTap: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Text input with icons inside
            HStack(alignment: .bottom, spacing: Spacing.sm) {
                TextField("Type your message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused(isInputFocused)
                    .lineLimit(1...5)
                    .onSubmit {
                        if !messageText.isEmpty {
                            sendAction()
                        }
                    }

                // Audio button
                Button(action: onAudioTap) {
                    Image(systemName: "mic.fill")
                        .font(.title3)
                        .foregroundStyle(primaryColor)
                }

                // Send button
                Button(action: sendAction) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            messageText.isEmpty ?
                            DesignSystem.Colors.secondaryForeground :
                            primaryColor
                        )
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(DesignSystem.Colors.secondary)
            .cornerRadius(Corners.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Corners.xl)
                    .stroke(
                        isInputFocused.wrappedValue ? primaryColor : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
    }
}

// MARK: - Chat History View

struct ChatHistoryView: View {
    @Binding var selectedCoach: CoachType
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    // Placeholder history data
    let historyItems: [HistoryItem] = [
        HistoryItem(
            title: "Career Change Discussion",
            preview: "I've been thinking about switching careers to tech, but I'm not sure if it's the right move...",
            date: Date().addingTimeInterval(-86400 * 2),
            coachType: .challenger
        ),
        HistoryItem(
            title: "Project Planning Session",
            preview: "I need help organizing my thoughts for a complex project with multiple stakeholders...",
            date: Date().addingTimeInterval(-86400 * 5),
            coachType: .navigator
        ),
        HistoryItem(
            title: "Creative Problem Solving",
            preview: "Looking for alternative approaches to solve a design challenge I'm facing...",
            date: Date().addingTimeInterval(-86400 * 7),
            coachType: .explorer
        ),
        HistoryItem(
            title: "Decision Analysis",
            preview: "Trying to decide between two job offers. Need help weighing the pros and cons...",
            date: Date().addingTimeInterval(-86400 * 10),
            coachType: .challenger
        ),
        HistoryItem(
            title: "Strategy Development",
            preview: "Working on a go-to-market strategy and need to map out all the dependencies...",
            date: Date().addingTimeInterval(-86400 * 14),
            coachType: .navigator
        )
    ]
    
    var filteredHistory: [HistoryItem] {
        if searchText.isEmpty {
            return historyItems
        }
        return historyItems.filter { item in
            item.title.localizedCaseInsensitiveContains(searchText) ||
            item.preview.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    
                    TextField("Search conversations...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(Spacing.md)
                .background(DesignSystem.Colors.secondary)
                .cornerRadius(Corners.md)
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                
                // History list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredHistory) { item in
                            Button(action: {
                                selectedCoach = item.coachType
                                dismiss()
                            }) {
                                HistoryItemRow(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if item.id != filteredHistory.last?.id {
                                Divider()
                                    .padding(.leading, Spacing.lg)
                            }
                        }
                    }
                }
                
                if filteredHistory.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                        
                        Text("No conversations found")
                            .font(Typography.headline)
                            .foregroundStyle(DesignSystem.Colors.foreground)
                        
                        Text("Try a different search term")
                            .font(Typography.caption)
                            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(Spacing.xl)
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Chat History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

struct HistoryItem: Identifiable {
    let id = UUID()
    let title: String
    let preview: String
    let date: Date
    let coachType: CoachType
}

struct HistoryItemRow: View {
    let item: HistoryItem
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // Coach icon
            Image(systemName: item.coachType.icon)
                .font(.title3)
                .foregroundStyle(item.coachType.color)
                .frame(width: 40, height: 40)
                .background(item.coachType.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(item.title)
                        .font(Typography.subheadline.bold())
                        .foregroundStyle(DesignSystem.Colors.foreground)
                    
                    Spacer()
                    
                    Text(item.date, style: .relative)
                        .font(Typography.caption2)
                        .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                }
                
                Text(item.preview)
                    .font(Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    .lineLimit(2)
                
                Text(item.coachType.rawValue)
                    .font(Typography.caption2)
                    .foregroundStyle(item.coachType.color)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .contentShape(Rectangle())
    }
}

#Preview {
    CoachView()
        .environment(AppState())
}