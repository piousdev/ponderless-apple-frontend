//
//  Shadows.swift
//  Ponderless
//
//  Shadow presets for consistent elevation and depth
//

import SwiftUI

/// Shadow system for Ponderless app
public enum Shadows {

    // MARK: - Shadow Styles

    /// Available shadow styles with different elevations
    public enum Style {
        case none
        case xs
        case sm
        case md
        case lg
        case xl
        case xxl

        /// Get shadow parameters for the style
        var parameters: ShadowParameters {
            switch self {
            case .none:
                return ShadowParameters(radius: 0, x: 0, y: 0, opacity: 0)
            case .xs:
                return ShadowParameters(radius: 2, x: 0, y: 1, opacity: 0.05)
            case .sm:
                return ShadowParameters(radius: 4, x: 0, y: 2, opacity: 0.08)
            case .md:
                return ShadowParameters(radius: 8, x: 0, y: 4, opacity: 0.10)
            case .lg:
                return ShadowParameters(radius: 12, x: 0, y: 6, opacity: 0.12)
            case .xl:
                return ShadowParameters(radius: 16, x: 0, y: 8, opacity: 0.14)
            case .xxl:
                return ShadowParameters(radius: 24, x: 0, y: 12, opacity: 0.16)
            }
        }

        /// Get shadow color for color scheme
        func color(for colorScheme: ColorScheme) -> Color {
            switch colorScheme {
            case .light:
                return Color.black.opacity(parameters.opacity)
            case .dark:
                // Darker shadows in dark mode for better visibility
                return Color.black.opacity(parameters.opacity * 1.5)
            @unknown default:
                return Color.black.opacity(parameters.opacity)
            }
        }
    }

    // MARK: - Shadow Parameters

    /// Shadow configuration parameters
    public struct ShadowParameters {
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
        let opacity: Double

        public init(radius: CGFloat, x: CGFloat, y: CGFloat, opacity: Double) {
            self.radius = radius
            self.x = x
            self.y = y
            self.opacity = opacity
        }
    }

    // MARK: - Semantic Shadows

    /// Component-specific shadow presets
    public enum Component {
        /// Shadow for cards
        public static let card = Style.sm

        /// Shadow for elevated buttons
        public static let button = Style.xs

        /// Shadow for floating action buttons
        public static let fab = Style.lg

        /// Shadow for modals/sheets
        public static let modal = Style.xl

        /// Shadow for navigation bars
        public static let navigationBar = Style.sm

        /// Shadow for popovers
        public static let popover = Style.md

        /// Shadow for tooltips
        public static let tooltip = Style.sm

        /// Shadow for dropdown menus
        public static let dropdown = Style.md
    }

    // MARK: - Colored Shadows

    /// Create a colored shadow
    public static func colored(
        _ color: Color,
        radius: CGFloat = 8,
        x: CGFloat = 0,
        y: CGFloat = 4,
        opacity: Double = 0.2
    ) -> ShadowModifier {
        ShadowModifier(
            color: color.opacity(opacity),
            radius: radius,
            x: x,
            y: y
        )
    }

    /// Create a primary colored shadow
    public static func primary(for colorScheme: ColorScheme) -> ShadowModifier {
        let primaryColor = DesignSystem.Colors.primary
        return colored(primaryColor, opacity: 0.15)
    }

    /// Create a destructive colored shadow
    public static func destructive(for colorScheme: ColorScheme) -> ShadowModifier {
        let destructiveColor = DesignSystem.Colors.destructive
        return colored(destructiveColor, opacity: 0.15)
    }
}

// MARK: - Shadow Modifier

/// Custom shadow modifier for consistent application
public struct ShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    public func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply a shadow style
    public func shadow(style: Shadows.Style) -> some View {
        self.modifier(ShadowStyleModifier(style: style))
    }

    /// Apply a card shadow
    public func cardShadow() -> some View {
        shadow(style: Shadows.Component.card)
    }

    /// Apply a button shadow
    public func buttonShadow() -> some View {
        shadow(style: Shadows.Component.button)
    }

    /// Apply a modal shadow
    public func modalShadow() -> some View {
        shadow(style: Shadows.Component.modal)
    }

    /// Apply a floating action button shadow
    public func fabShadow() -> some View {
        shadow(style: Shadows.Component.fab)
    }

    /// Apply an elevated shadow with custom elevation
    public func elevated(_ level: Int = 1) -> some View {
        let style: Shadows.Style = {
            switch level {
            case 0: return .none
            case 1: return .xs
            case 2: return .sm
            case 3: return .md
            case 4: return .lg
            case 5: return .xl
            default: return level > 5 ? .xxl : .none
            }
        }()
        return shadow(style: style)
    }

    /// Apply multiple layered shadows for more realistic depth
    public func layeredShadow(style: Shadows.Style = .md) -> some View {
        self.modifier(LayeredShadowModifier(style: style))
    }
}

// MARK: - Shadow Style Modifier

/// Modifier that applies shadow based on color scheme
struct ShadowStyleModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let style: Shadows.Style

    func body(content: Content) -> some View {
        let params = style.parameters
        content
            .shadow(
                color: style.color(for: colorScheme),
                radius: params.radius,
                x: params.x,
                y: params.y
            )
    }
}

// MARK: - Layered Shadow Modifier

/// Modifier that applies multiple shadows for realistic depth
struct LayeredShadowModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let style: Shadows.Style

    func body(content: Content) -> some View {
        let params = style.parameters
        let baseColor = style.color(for: colorScheme)

        content
            // Ambient shadow (softer, larger)
            .shadow(
                color: baseColor.opacity(0.5),
                radius: params.radius * 1.5,
                x: 0,
                y: params.y * 0.5
            )
            // Key shadow (sharper, directional)
            .shadow(
                color: baseColor,
                radius: params.radius * 0.75,
                x: params.x,
                y: params.y
            )
    }
}

// MARK: - Neumorphic Shadow Extensions

extension View {
    /// Apply neumorphic style shadows (soft UI)
    public func neumorphic(
        shape: RoundedRectangle = RoundedRectangle(cornerRadius: Ponderless.Corners.md),
        intensity: Double = 0.15
    ) -> some View {
        self.modifier(NeumorphicModifier(shape: shape, intensity: intensity))
    }
}

/// Neumorphic shadow modifier for soft UI design
struct NeumorphicModifier<S: Shape>: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let shape: S
    let intensity: Double

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Background matching the surface
                    shape
                        .fill(DesignSystem.Colors.background)

                    // Light shadow (top-left)
                    shape
                        .fill(
                            colorScheme == .light
                            ? Color.white.opacity(intensity)
                            : Color.white.opacity(intensity * 0.1)
                        )
                        .blur(radius: 4)
                        .offset(x: -4, y: -4)

                    // Dark shadow (bottom-right)
                    shape
                        .fill(
                            colorScheme == .light
                            ? Color.black.opacity(intensity)
                            : Color.black.opacity(intensity * 2)
                        )
                        .blur(radius: 4)
                        .offset(x: 4, y: 4)
                }
            )
    }
}