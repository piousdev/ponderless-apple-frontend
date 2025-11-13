//
//  InputValidator.swift
//  Ponderless
//
//  Input validation utility with sanitization and validation methods
//

import Foundation

/// Utility for validating and sanitizing user input
enum InputValidator {

    // MARK: - Validation Rules

    enum ValidationRule {
        case minLength(Int)
        case maxLength(Int)
        case allowedCharacters(CharacterSet)
        case notEmpty
        case noLeadingTrailingWhitespace
        case alphanumeric
        case numeric
        case email
        case url
        case custom((String) -> Bool)
    }

    struct ValidationResult {
        let isValid: Bool
        let sanitizedValue: String
        let errors: [String]

        static func valid(_ value: String) -> ValidationResult {
            ValidationResult(isValid: true, sanitizedValue: value, errors: [])
        }

        static func invalid(_ value: String, errors: [String]) -> ValidationResult {
            ValidationResult(isValid: false, sanitizedValue: value, errors: errors)
        }
    }

    // MARK: - Public Validation Methods

    /// Validate a string against multiple rules
    /// - Parameters:
    ///   - input: The input string to validate
    ///   - rules: Array of validation rules to apply
    ///   - sanitize: Whether to sanitize the input first
    /// - Returns: ValidationResult with isValid flag, sanitized value, and errors
    static func validate(
        _ input: String,
        rules: [ValidationRule],
        sanitize: Bool = true
    ) -> ValidationResult {
        var value = sanitize ? self.sanitize(input) : input
        var errors: [String] = []

        for rule in rules {
            switch rule {
            case .minLength(let min):
                if value.count < min {
                    errors.append("Must be at least \(min) characters")
                }

            case .maxLength(let max):
                if value.count > max {
                    value = String(value.prefix(max))
                    errors.append("Exceeds maximum length of \(max) characters")
                }

            case .allowedCharacters(let charset):
                let filtered = value.unicodeScalars.filter { charset.contains($0) }
                let filteredString = String(String.UnicodeScalarView(filtered))
                if filteredString != value {
                    value = filteredString
                    errors.append("Contains invalid characters")
                }

            case .notEmpty:
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    errors.append("Cannot be empty")
                }

            case .noLeadingTrailingWhitespace:
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed != value {
                    value = trimmed
                    errors.append("Leading or trailing whitespace removed")
                }

            case .alphanumeric:
                let filtered = value.filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
                if filtered != value {
                    value = filtered
                    errors.append("Only letters, numbers, and spaces allowed")
                }

            case .numeric:
                let filtered = value.filter { $0.isNumber }
                if filtered != value {
                    value = filtered
                    errors.append("Only numbers allowed")
                }

            case .email:
                if !isValidEmail(value) {
                    errors.append("Invalid email format")
                }

            case .url:
                if !isValidURL(value) {
                    errors.append("Invalid URL format")
                }

            case .custom(let validator):
                if !validator(value) {
                    errors.append("Custom validation failed")
                }
            }
        }

        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, sanitizedValue: value, errors: errors)
    }

    // MARK: - Sanitization

    /// Sanitize input by removing potentially dangerous characters
    /// - Parameter input: The input string to sanitize
    /// - Returns: Sanitized string
    static func sanitize(_ input: String) -> String {
        var sanitized = input

        // Remove null bytes
        sanitized = sanitized.replacingOccurrences(of: "\0", with: "")

        // Remove control characters (except newline and tab)
        sanitized = sanitized.filter { char in
            let scalar = char.unicodeScalars.first!
            return !CharacterSet.controlCharacters.contains(scalar)
                || char == "\n"
                || char == "\t"
        }

        // Normalize whitespace
        sanitized = sanitized.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )

        return sanitized
    }

    /// Remove all HTML tags from input
    /// - Parameter input: The input string
    /// - Returns: String with HTML tags removed
    static func stripHTMLTags(_ input: String) -> String {
        input.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
    }

    /// Escape special characters for safe display
    /// - Parameter input: The input string
    /// - Returns: String with special characters escaped
    static func escapeSpecialCharacters(_ input: String) -> String {
        var escaped = input
        let specialChars: [String: String] = [
            "<": "&lt;",
            ">": "&gt;",
            "&": "&amp;",
            "\"": "&quot;",
            "'": "&#39;"
        ]

        for (char, escape) in specialChars {
            escaped = escaped.replacingOccurrences(of: char, with: escape)
        }

        return escaped
    }

    // MARK: - Specific Validators

    /// Validate text input for exercises (user responses)
    /// - Parameter input: The text input
    /// - Returns: ValidationResult
    static func validateExerciseInput(_ input: String) -> ValidationResult {
        validate(
            input,
            rules: [
                .notEmpty,
                .minLength(ForYouConstants.Validation.minTextLength),
                .maxLength(ForYouConstants.Validation.maxTextLength),
                .allowedCharacters(ForYouConstants.Validation.allowedCharacterSet)
            ]
        )
    }

    /// Validate confidence slider value
    /// - Parameter value: The slider value (0-100)
    /// - Returns: Whether the value is valid
    static func validateConfidence(_ value: Double) -> Bool {
        value >= ForYouConstants.Confidence.minValue
            && value <= ForYouConstants.Confidence.maxValue
    }

    /// Clamp confidence value to valid range
    /// - Parameter value: The input value
    /// - Returns: Clamped value within valid range
    static func clampConfidence(_ value: Double) -> Double {
        min(
            max(value, ForYouConstants.Confidence.minValue),
            ForYouConstants.Confidence.maxValue
        )
    }

    // MARK: - Format Validators

    private static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme != nil && url.host != nil
    }
}

// MARK: - Content Sanitizer

/// Sanitizer for display content to prevent XSS and injection attacks
enum ContentSanitizer {

    /// Sanitize content for safe display in UI
    /// - Parameter content: The content to sanitize
    /// - Returns: Sanitized content safe for display
    static func sanitizeForDisplay(_ content: String) -> String {
        var sanitized = InputValidator.sanitize(content)
        sanitized = InputValidator.stripHTMLTags(sanitized)
        sanitized = InputValidator.escapeSpecialCharacters(sanitized)
        return sanitized
    }

    /// Sanitize content while preserving basic formatting
    /// - Parameter content: The content to sanitize
    /// - Returns: Sanitized content with basic formatting preserved
    static func sanitizePreservingFormatting(_ content: String) -> String {
        var sanitized = InputValidator.sanitize(content)

        // Allow certain safe HTML tags for formatting
        let allowedTags = ["<b>", "</b>", "<i>", "</i>", "<br>", "<p>", "</p>"]
        let tagPattern = "<[^>]+>"

        // Remove all tags except allowed ones
        let regex = try! NSRegularExpression(pattern: tagPattern, options: [])
        let range = NSRange(sanitized.startIndex..., in: sanitized)

        let matches = regex.matches(in: sanitized, options: [], range: range)

        for match in matches.reversed() {
            let matchRange = match.range
            if let swiftRange = Range(matchRange, in: sanitized) {
                let tag = String(sanitized[swiftRange])
                if !allowedTags.contains(tag.lowercased()) {
                    sanitized.removeSubrange(swiftRange)
                }
            }
        }

        return sanitized
    }

    /// Truncate content to maximum length with ellipsis
    /// - Parameters:
    ///   - content: The content to truncate
    ///   - maxLength: Maximum length
    /// - Returns: Truncated content
    static func truncate(_ content: String, maxLength: Int) -> String {
        guard content.count > maxLength else { return content }

        let truncated = String(content.prefix(maxLength - 3))
        return truncated + "..."
    }
}
