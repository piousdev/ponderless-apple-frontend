//
//  ErrorStateView.swift
//  Ponderless
//
//  Reusable error state component with retry functionality
//

import SwiftUI

struct ErrorStateView: View {
    let message: String
    let suggestion: String?
    let canRetry: Bool
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?

    @ScaledMetric private var iconSize: CGFloat = 48

    init(
        message: String,
        suggestion: String? = nil,
        canRetry: Bool = false,
        onRetry: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.message = message
        self.suggestion = suggestion
        self.canRetry = canRetry
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Error Icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.destructive.opacity(0.1))
                    .frame(width: iconSize + 24, height: iconSize + 24)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: iconSize))
                    .foregroundStyle(DesignSystem.Colors.destructive)
            }
            .accessibilityLabel("Error icon")

            VStack(spacing: Spacing.sm) {
                // Error Message
                Text(message)
                    .font(Typography.body)
                    .foregroundStyle(DesignSystem.Colors.foreground)
                    .multilineTextAlignment(.center)

                // Recovery Suggestion
                if let suggestion = suggestion {
                    Text(suggestion)
                        .font(Typography.caption1)
                        .foregroundStyle(DesignSystem.Colors.mutedForeground)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, Spacing.lg)

            // Action Buttons
            HStack(spacing: Spacing.md) {
                // Retry Button (if retryable)
                if canRetry, let onRetry = onRetry {
                    CompactPrimaryButton("Retry") {
                        onRetry()
                    }
                    .accessibilityLabel("Retry operation")
                }

                // Dismiss Button
                if let onDismiss = onDismiss {
                    CompactSecondaryButton(canRetry ? "Cancel" : "Dismiss") {
                        onDismiss()
                    }
                    .accessibilityLabel(canRetry ? "Cancel retry" : "Dismiss error")
                }
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.background)
        .cardCorners()
        .overlay(
            RoundedRectangle(cornerRadius: Corners.Component.card)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Convenience Initializers

extension ErrorStateView {
    /// Create error view from ErrorHandler
    init(errorHandler: ErrorHandler, onRetry: @escaping () -> Void) {
        self.init(
            message: errorHandler.errorMessage,
            suggestion: errorHandler.canRetry ? errorHandler.recoverySuggestion : nil,
            canRetry: errorHandler.canRetry,
            onRetry: errorHandler.canRetry ? onRetry : nil,
            onDismiss: { errorHandler.clearError() }
        )
    }

    /// Create error view from ForYouError
    init(error: ForYouError, onRetry: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.init(
            message: error.userMessage,
            suggestion: error.recoverySuggestion,
            canRetry: error.isRetryable,
            onRetry: onRetry,
            onDismiss: onDismiss
        )
    }
}

// MARK: - Inline Error Banner

struct ErrorBannerView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(Typography.body)
                .foregroundStyle(DesignSystem.Colors.destructive)

            Text(message)
                .font(Typography.caption1)
                .foregroundStyle(DesignSystem.Colors.foreground)
                .lineLimit(2)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(Typography.caption2)
                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
            }
            .accessibilityLabel("Dismiss error")
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(DesignSystem.Colors.destructive.opacity(0.1))
        .cornerRadiusDesign(Corners.md)
        .overlay(
            RoundedRectangle(cornerRadius: Corners.md)
                .stroke(DesignSystem.Colors.destructive.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Previews

#Preview("Error State - Retryable") {
    ErrorStateView(
        message: "Failed to load data",
        suggestion: "Please check your internet connection and try again.",
        canRetry: true,
        onRetry: { print("Retry tapped") },
        onDismiss: { print("Dismiss tapped") }
    )
    .padding()
}

#Preview("Error State - Non-Retryable") {
    ErrorStateView(
        message: "Invalid input provided",
        suggestion: "Please correct the input and try again.",
        canRetry: false,
        onRetry: nil,
        onDismiss: { print("Dismiss tapped") }
    )
    .padding()
}

#Preview("Error State - From ForYouError") {
    ErrorStateView(
        error: .networkUnavailable,
        onRetry: { print("Retry") },
        onDismiss: { print("Dismiss") }
    )
    .padding()
}

#Preview("Error Banner") {
    VStack(spacing: Spacing.md) {
        ErrorBannerView(
            message: "Failed to save changes",
            onDismiss: { print("Dismiss") }
        )

        ErrorBannerView(
            message: "Network connection lost. Some features may not be available.",
            onDismiss: { print("Dismiss") }
        )
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.xl) {
        ErrorStateView(
            message: "Failed to load data",
            suggestion: "Please check your internet connection and try again.",
            canRetry: true,
            onRetry: { print("Retry") },
            onDismiss: { print("Dismiss") }
        )

        ErrorBannerView(
            message: "Network connection lost",
            onDismiss: { print("Dismiss") }
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
    .preferredColorScheme(.dark)
}
