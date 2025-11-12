//
//  DesignSystem.swift
//  Ponderless
//
//  Central design system with color tokens for light and dark modes
//

import SwiftUI

/// Central design system for Ponderless app
public enum DesignSystem {

    /// Color tokens with automatic light/dark mode adaptation
    public enum Colors {

        // MARK: - Core Colors

        /// Main background color (#ffffff light, #21242c dark)
        public static let background = Color.dynamic(
            light: Color(hex: "#ffffff"),
            dark: Color(hex: "#21242c")
        )

        /// Main text color (#2e3138 light, #d1d9e0 dark)
        public static let foreground = Color.dynamic(
            light: Color(hex: "#2e3138"),
            dark: Color(hex: "#d1d9e0")
        )

        /// Primary brand color (#0a66c2 light, #308ce8 dark)
        public static let primary = Color.dynamic(
            light: Color(hex: "#0a66c2"),
            dark: Color(hex: "#308ce8")
        )

        /// Text color on primary background (#fafafa light, #f9fafa dark)
        public static let primaryForeground = Color.dynamic(
            light: Color(hex: "#fafafa"),
            dark: Color(hex: "#f9fafa")
        )

        /// Secondary background color (#f1f5f9 light, #33404d dark)
        public static let secondary = Color.dynamic(
            light: Color(hex: "#f1f5f9"),
            dark: Color(hex: "#33404d")
        )

        /// Text color on secondary background (#2e3338 light, #d1d9e0 dark)
        public static let secondaryForeground = Color.dynamic(
            light: Color(hex: "#2e3338"),
            dark: Color(hex: "#d1d9e0")
        )

        /// Muted background color (#f1f5f9 light, #33404d dark)
        public static let muted = Color.dynamic(
            light: Color(hex: "#f1f5f9"),
            dark: Color(hex: "#33404d")
        )

        /// Muted text color (#52667a light, #8f99a3 dark)
        public static let mutedForeground = Color.dynamic(
            light: Color(hex: "#52667a"),
            dark: Color(hex: "#8f99a3")
        )

        /// Accent color (#f1f5f9 light, #33404d dark)
        public static let accent = Color.dynamic(
            light: Color(hex: "#f1f5f9"),
            dark: Color(hex: "#33404d")
        )

        /// Text color on accent background (#2e3338 light, #d1d9e0 dark)
        public static let accentForeground = Color.dynamic(
            light: Color(hex: "#2e3338"),
            dark: Color(hex: "#d1d9e0")
        )

        /// Destructive/error color (#eb4747 light, #d92626 dark)
        public static let destructive = Color.dynamic(
            light: Color(hex: "#eb4747"),
            dark: Color(hex: "#d92626")
        )

        /// Text color on destructive background (#fafafa light, #f9fafa dark)
        public static let destructiveForeground = Color.dynamic(
            light: Color(hex: "#fafafa"),
            dark: Color(hex: "#f9fafa")
        )

        /// Border color (#dbe6f0 light, #3d4d5c dark)
        public static let border = Color.dynamic(
            light: Color(hex: "#dbe6f0"),
            dark: Color(hex: "#3d4d5c")
        )

        /// Input border color (#dbe6f0 light, #3d4d5c dark)
        public static let input = Color.dynamic(
            light: Color(hex: "#dbe6f0"),
            dark: Color(hex: "#3d4d5c")
        )

        /// Focus ring color (#0a66c2 light, #308ce8 dark)
        public static let ring = Color.dynamic(
            light: Color(hex: "#0a66c2"),
            dark: Color(hex: "#308ce8")
        )

        // MARK: - Chart Colors

        /// Chart color 1 (#0a66c2 light, #308ce8 dark)
        public static let chart1 = Color.dynamic(
            light: Color(hex: "#0a66c2"),
            dark: Color(hex: "#308ce8")
        )

        /// Chart color 2 (#26d962 light, #2eb85c dark)
        public static let chart2 = Color.dynamic(
            light: Color(hex: "#26d962"),
            dark: Color(hex: "#2eb85c")
        )

        /// Chart color 3 (#f2a60d light, #cf9117 dark)
        public static let chart3 = Color.dynamic(
            light: Color(hex: "#f2a60d"),
            dark: Color(hex: "#cf9117")
        )

        /// Chart color 4 (#9952e0 light, #8c47d1 dark)
        public static let chart4 = Color.dynamic(
            light: Color(hex: "#9952e0"),
            dark: Color(hex: "#8c47d1")
        )

        /// Chart color 5 (#eb6347 light, #dd573c dark)
        public static let chart5 = Color.dynamic(
            light: Color(hex: "#eb6347"),
            dark: Color(hex: "#dd573c")
        )

        // MARK: - Semantic Colors

        /// Success color (green)
        public static let success = Color.dynamic(
            light: Color(hex: "#26d962"),
            dark: Color(hex: "#2eb85c")
        )

        /// Warning color (orange)
        public static let warning = Color.dynamic(
            light: Color(hex: "#f2a60d"),
            dark: Color(hex: "#cf9117")
        )

        /// Info color (teal)
        public static let info = Color.dynamic(
            light: Color(hex: "#17a2b8"),
            dark: Color(hex: "#1ca8c6")
        )

        /// On primary color (text on primary background)
        public static let onPrimary = primaryForeground

        /// Shadow color
        public static let shadowColor = Color.black.opacity(0.05)
    }

    // MARK: - Gradient Helpers

    /// Common gradient definitions
    public enum Gradients {
        /// Primary gradient
        public static let primary = LinearGradient(
            colors: [Colors.primary, Colors.primary.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Secondary gradient
        public static let secondary = LinearGradient(
            colors: [Colors.secondary, Colors.muted],
            startPoint: .top,
            endPoint: .bottom
        )

        /// Background gradient
        public static let background = LinearGradient(
            colors: [Colors.background, Colors.secondary.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )

        /// Chart gradient 1
        public static let chart1 = LinearGradient(
            colors: [Colors.chart1, Colors.chart1.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )

        /// Chart gradient 2
        public static let chart2 = LinearGradient(
            colors: [Colors.chart2, Colors.chart2.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )

        /// Chart gradient 3
        public static let chart3 = LinearGradient(
            colors: [Colors.chart3, Colors.chart3.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Color Extensions

extension Color {
    /// Initialize color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Create a dynamic color that adapts to color scheme
    static func dynamic(light: Color, dark: Color) -> Color {
        #if os(iOS)
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
        #elseif os(macOS)
        // For macOS, we'll use a different approach
        return Color(NSColor(name: nil, dynamicProvider: { appearance in
            switch appearance.name {
            case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
                return NSColor(dark)
            default:
                return NSColor(light)
            }
        }))
        #else
        // Fallback for other platforms
        return light
        #endif
    }
}

// MARK: - View Extensions

extension View {
    /// Apply primary style to a view
    public func primaryStyle() -> some View {
        self
            .foregroundStyle(DesignSystem.Colors.primaryForeground)
            .background(DesignSystem.Colors.primary)
    }

    /// Apply secondary style to a view
    public func secondaryStyle() -> some View {
        self
            .foregroundStyle(DesignSystem.Colors.secondaryForeground)
            .background(DesignSystem.Colors.secondary)
    }

    /// Apply muted style to a view
    public func mutedStyle() -> some View {
        self
            .foregroundStyle(DesignSystem.Colors.mutedForeground)
            .background(DesignSystem.Colors.muted)
    }

    /// Apply destructive style to a view
    public func destructiveStyle() -> some View {
        self
            .foregroundStyle(DesignSystem.Colors.destructiveForeground)
            .background(DesignSystem.Colors.destructive)
    }

    /// Apply standard border
    public func standardBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: Corners.md)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
    }
}