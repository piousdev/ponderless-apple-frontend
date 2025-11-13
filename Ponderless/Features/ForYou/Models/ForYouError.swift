//
//  ForYouError.swift
//  Ponderless
//
//  Domain-specific error types for ForYou feature
//

import Foundation

/// Domain-specific errors for the ForYou feature
enum ForYouError: LocalizedError {

    // MARK: - Data Loading Errors

    case dataLoadingFailed(reason: String)
    case todoNotFound(id: UUID)
    case invalidTodoData

    // MARK: - Calculation Errors

    case calculationFailed(reason: String)
    case insufficientData(required: Int, actual: Int)
    case invalidCalibrationData

    // MARK: - Network Errors

    case networkUnavailable
    case requestTimeout
    case serverError(statusCode: Int)

    // MARK: - Validation Errors

    case invalidInput(field: String, reason: String)
    case inputTooLong(field: String, maxLength: Int)
    case inputTooShort(field: String, minLength: Int)

    // MARK: - Date/Time Errors

    case invalidDate
    case dateCalculationFailed
    case futureDate

    // MARK: - State Errors

    case invalidState(current: String, expected: String)
    case operationNotAllowed

    // MARK: - Generic Errors

    case unknown(error: Error?)

    // MARK: - LocalizedError Conformance

    var errorDescription: String? {
        switch self {
        case .dataLoadingFailed(let reason):
            return "Failed to load data: \(reason)"
        case .todoNotFound(let id):
            return "Todo not found with ID: \(id)"
        case .invalidTodoData:
            return "Invalid todo data format"

        case .calculationFailed(let reason):
            return "Calculation failed: \(reason)"
        case .insufficientData(let required, let actual):
            return "Insufficient data: requires \(required) items, got \(actual)"
        case .invalidCalibrationData:
            return "Invalid calibration data"

        case .networkUnavailable:
            return "Network connection unavailable"
        case .requestTimeout:
            return "Request timed out"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"

        case .invalidInput(let field, let reason):
            return "Invalid \(field): \(reason)"
        case .inputTooLong(let field, let maxLength):
            return "\(field) exceeds maximum length of \(maxLength) characters"
        case .inputTooShort(let field, let minLength):
            return "\(field) must be at least \(minLength) characters"

        case .invalidDate:
            return "Invalid date"
        case .dateCalculationFailed:
            return "Date calculation failed"
        case .futureDate:
            return "Date cannot be in the future"

        case .invalidState(let current, let expected):
            return "Invalid state: expected \(expected), got \(current)"
        case .operationNotAllowed:
            return "Operation not allowed in current state"

        case .unknown(let error):
            if let error = error {
                return "An unexpected error occurred: \(error.localizedDescription)"
            }
            return "An unexpected error occurred"
        }
    }

    var failureReason: String? {
        switch self {
        case .dataLoadingFailed, .todoNotFound, .invalidTodoData:
            return "Data access failed"
        case .calculationFailed, .insufficientData, .invalidCalibrationData:
            return "Calculation error"
        case .networkUnavailable, .requestTimeout, .serverError:
            return "Network error"
        case .invalidInput, .inputTooLong, .inputTooShort:
            return "Validation error"
        case .invalidDate, .dateCalculationFailed, .futureDate:
            return "Date/time error"
        case .invalidState, .operationNotAllowed:
            return "State error"
        case .unknown:
            return "Unknown error"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .dataLoadingFailed, .todoNotFound, .invalidTodoData:
            return "Please try refreshing the data."
        case .calculationFailed, .insufficientData, .invalidCalibrationData:
            return "Please ensure you have sufficient data and try again."
        case .networkUnavailable:
            return "Please check your internet connection and try again."
        case .requestTimeout:
            return "The request took too long. Please try again."
        case .serverError:
            return "The server encountered an error. Please try again later."
        case .invalidInput, .inputTooLong, .inputTooShort:
            return "Please correct the input and try again."
        case .invalidDate, .dateCalculationFailed, .futureDate:
            return "Please select a valid date."
        case .invalidState, .operationNotAllowed:
            return "This operation is not available right now."
        case .unknown:
            return "Please restart the app or contact support."
        }
    }

    // MARK: - User-Friendly Messages

    /// User-friendly message for display in UI
    var userMessage: String {
        errorDescription ?? "Something went wrong"
    }

    /// Whether this error is retryable
    var isRetryable: Bool {
        switch self {
        case .dataLoadingFailed, .calculationFailed, .networkUnavailable, .requestTimeout, .serverError:
            return true
        case .todoNotFound, .invalidTodoData, .insufficientData, .invalidCalibrationData,
             .invalidInput, .inputTooLong, .inputTooShort, .invalidDate, .dateCalculationFailed,
             .futureDate, .invalidState, .operationNotAllowed, .unknown:
            return false
        }
    }
}

// MARK: - Error Conversion

extension ForYouError {
    /// Convert a generic Error to ForYouError
    static func from(_ error: Error) -> ForYouError {
        if let forYouError = error as? ForYouError {
            return forYouError
        }
        return .unknown(error: error)
    }
}

// MARK: - Equatable Conformance

extension ForYouError: Equatable {
    static func == (lhs: ForYouError, rhs: ForYouError) -> Bool {
        switch (lhs, rhs) {
        case (.dataLoadingFailed(let lReason), .dataLoadingFailed(let rReason)):
            return lReason == rReason
        case (.todoNotFound(let lId), .todoNotFound(let rId)):
            return lId == rId
        case (.invalidTodoData, .invalidTodoData):
            return true
        case (.calculationFailed(let lReason), .calculationFailed(let rReason)):
            return lReason == rReason
        case (.insufficientData(let lReq, let lAct), .insufficientData(let rReq, let rAct)):
            return lReq == rReq && lAct == rAct
        case (.invalidCalibrationData, .invalidCalibrationData):
            return true
        case (.networkUnavailable, .networkUnavailable):
            return true
        case (.requestTimeout, .requestTimeout):
            return true
        case (.serverError(let lCode), .serverError(let rCode)):
            return lCode == rCode
        case (.invalidInput(let lField, let lReason), .invalidInput(let rField, let rReason)):
            return lField == rField && lReason == rReason
        case (.inputTooLong(let lField, let lMax), .inputTooLong(let rField, let rMax)):
            return lField == rField && lMax == rMax
        case (.inputTooShort(let lField, let lMin), .inputTooShort(let rField, let rMin)):
            return lField == rField && lMin == rMin
        case (.invalidDate, .invalidDate):
            return true
        case (.dateCalculationFailed, .dateCalculationFailed):
            return true
        case (.futureDate, .futureDate):
            return true
        case (.invalidState(let lCur, let lExp), .invalidState(let rCur, let rExp)):
            return lCur == rCur && lExp == rExp
        case (.operationNotAllowed, .operationNotAllowed):
            return true
        case (.unknown, .unknown):
            // Compare unknown errors by their localized description
            return true
        default:
            return false
        }
    }
}
