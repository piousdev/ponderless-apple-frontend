//
//  ErrorHandler.swift
//  Ponderless
//
//  Centralized error handling with retry logic and user notifications
//

import Foundation
import Observation

/// Centralized error handler for managing and displaying errors
@MainActor
@Observable
final class ErrorHandler {

    // MARK: - Properties

    /// Current error being displayed
    private(set) var currentError: ForYouError?

    /// Whether an error is currently being shown
    var hasError: Bool {
        currentError != nil
    }

    /// Error message for display
    var errorMessage: String {
        currentError?.userMessage ?? ""
    }

    /// Whether the current error is retryable
    var canRetry: Bool {
        currentError?.isRetryable ?? false
    }

    /// Recovery suggestion for the current error
    var recoverySuggestion: String {
        currentError?.recoverySuggestion ?? ""
    }

    // MARK: - Error History

    /// Recent errors for debugging (max 10)
    private var errorHistory: [ErrorRecord] = []

    private struct ErrorRecord {
        let error: ForYouError
        let timestamp: Date
        let context: String?
    }

    // MARK: - Retry State

    /// Current retry attempt count
    private(set) var retryCount: Int = 0

    /// Maximum retry attempts before giving up
    private let maxRetries: Int = 3

    /// Delay between retries (in seconds)
    private let retryDelay: TimeInterval = 1.0

    // MARK: - Initialization

    init() {}

    // MARK: - Error Handling

    /// Handle an error and optionally display it to the user
    /// - Parameters:
    ///   - error: The error to handle
    ///   - context: Optional context information for debugging
    ///   - silent: If true, logs error but doesn't display to user
    func handle(_ error: ForYouError, context: String? = nil, silent: Bool = false) {
        // Log error
        logError(error, context: context)

        // Add to history
        addToHistory(error, context: context)

        // Display to user unless silent
        if !silent {
            currentError = error
        }
    }

    /// Handle a generic Error by converting it to ForYouError
    func handle(_ error: Error, context: String? = nil, silent: Bool = false) {
        let forYouError = ForYouError.from(error)
        handle(forYouError, context: context, silent: silent)
    }

    /// Clear the current error
    func clearError() {
        currentError = nil
        retryCount = 0
    }

    // MARK: - Retry Logic

    /// Attempt to retry an operation with exponential backoff
    /// - Parameter operation: The async operation to retry
    /// - Returns: True if operation succeeded, false if max retries reached
    @discardableResult
    func retry(operation: @escaping () async throws -> Void) async -> Bool {
        guard let error = currentError, error.isRetryable else {
            return false
        }

        // Check if we've exceeded max retries
        guard retryCount < maxRetries else {
            handle(.operationNotAllowed, context: "Max retries exceeded")
            return false
        }

        retryCount += 1

        // Calculate exponential backoff delay
        let delay = retryDelay * pow(2.0, Double(retryCount - 1))

        do {
            // Wait before retrying
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

            // Attempt operation
            try await operation()

            // Success - clear error
            clearError()
            return true
        } catch {
            // Retry failed
            handle(error, context: "Retry attempt \(retryCount) failed")
            return false
        }
    }

    // MARK: - Safe Operation Execution

    /// Execute an operation with automatic error handling
    /// - Parameters:
    ///   - operation: The async operation to execute
    ///   - context: Context information for error logging
    ///   - onError: Optional callback when error occurs
    func execute(
        _ operation: @escaping () async throws -> Void,
        context: String? = nil,
        onError: ((ForYouError) -> Void)? = nil
    ) async {
        do {
            try await operation()
        } catch let error as ForYouError {
            handle(error, context: context)
            onError?(error)
        } catch {
            let forYouError = ForYouError.from(error)
            handle(forYouError, context: context)
            onError?(forYouError)
        }
    }

    /// Execute an operation with automatic error handling and return result
    /// - Parameters:
    ///   - operation: The async operation to execute
    ///   - context: Context information for error logging
    ///   - defaultValue: Value to return if operation fails
    /// - Returns: Result of operation or default value
    func execute<T>(
        _ operation: @escaping () async throws -> T,
        context: String? = nil,
        defaultValue: T
    ) async -> T {
        do {
            return try await operation()
        } catch let error as ForYouError {
            handle(error, context: context)
            return defaultValue
        } catch {
            handle(ForYouError.from(error), context: context)
            return defaultValue
        }
    }

    // MARK: - Error Logging

    private func logError(_ error: ForYouError, context: String?) {
        var logMessage = "❌ [ForYou] \(error.errorDescription ?? "Unknown error")"

        if let context = context {
            logMessage += " | Context: \(context)"
        }

        if let failureReason = error.failureReason {
            logMessage += " | Reason: \(failureReason)"
        }

        print(logMessage)

        #if DEBUG
        // In debug builds, print full error details
        if let suggestion = error.recoverySuggestion {
            print("  ↳ Suggestion: \(suggestion)")
        }
        print("  ↳ Retryable: \(error.isRetryable)")
        #endif
    }

    private func addToHistory(_ error: ForYouError, context: String?) {
        let record = ErrorRecord(
            error: error,
            timestamp: Date(),
            context: context
        )

        errorHistory.append(record)

        // Keep only last 10 errors
        if errorHistory.count > 10 {
            errorHistory.removeFirst()
        }
    }

    // MARK: - Debugging

    /// Get recent error history for debugging
    func getErrorHistory() -> [(error: ForYouError, timestamp: Date, context: String?)] {
        errorHistory.map { ($0.error, $0.timestamp, $0.context) }
    }

    /// Clear error history
    func clearHistory() {
        errorHistory.removeAll()
    }
}

// MARK: - Preview Helper

extension ErrorHandler {
    static let preview: ErrorHandler = {
        let handler = ErrorHandler()
        handler.handle(.dataLoadingFailed(reason: "Network timeout"))
        return handler
    }()

    static let previewWithRetryable: ErrorHandler = {
        let handler = ErrorHandler()
        handler.handle(.networkUnavailable)
        return handler
    }()
}
