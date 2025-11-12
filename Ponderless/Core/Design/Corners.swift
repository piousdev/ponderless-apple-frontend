//
//  Corners.swift
//  Ponderless
//
//  Corner radius tokens for consistent rounded corners
//

import SwiftUI

/// Corner radius system for Ponderless app
public enum Corners {

    // MARK: - Corner Radius Scale

    /// No corner radius (0pt) - Sharp corners
    public static let none: CGFloat = 0

    /// Extra small corner radius (2pt)
    public static let xs: CGFloat = 2

    /// Small corner radius (4pt) - Subtle rounding
    public static let sm: CGFloat = 4

    /// Medium corner radius (8pt) - Default for most components
    public static let md: CGFloat = 8

    /// Large corner radius (12pt) - For cards and containers
    public static let lg: CGFloat = 12

    /// Extra large corner radius (16pt) - For prominent elements
    public static let xl: CGFloat = 16

    /// 2x large corner radius (20pt) - For large cards
    public static let xxl: CGFloat = 20

    /// 3x large corner radius (24pt) - For hero elements
    public static let xxxl: CGFloat = 24

    /// 4x large corner radius (32pt) - Equivalent to 2rem (more rounded edges)
    public static let xxxxl: CGFloat = 32

    /// Full corner radius (9999pt) - Creates circular/pill shapes
    public static let full: CGFloat = 9999

    // MARK: - Component-Specific Radii

    /// Component-specific corner radius presets
    public enum Component {
        /// Corner radius for buttons
        public static let button: CGFloat = md

        /// Corner radius for text fields
        public static let textField: CGFloat = md

        /// Corner radius for cards (2rem = 32pt for more rounded edges)
        public static let card: CGFloat = xxxxl

        /// Corner radius for modals/sheets
        public static let modal: CGFloat = xl

        /// Corner radius for badges
        public static let badge: CGFloat = full

        /// Corner radius for chips/tags
        public static let chip: CGFloat = full

        /// Corner radius for avatars
        public static let avatar: CGFloat = full

        /// Corner radius for thumbnails
        public static let thumbnail: CGFloat = sm

        /// Corner radius for tooltips
        public static let tooltip: CGFloat = sm

        /// Corner radius for dropdown menus
        public static let dropdown: CGFloat = md
    }

    // MARK: - Corner Style

    /// Defines which corners to round
    public struct CornerStyle {
        let topLeft: CGFloat
        let topRight: CGFloat
        let bottomLeft: CGFloat
        let bottomRight: CGFloat

        /// All corners with same radius
        public static func all(_ radius: CGFloat) -> CornerStyle {
            CornerStyle(
                topLeft: radius,
                topRight: radius,
                bottomLeft: radius,
                bottomRight: radius
            )
        }

        /// Only top corners
        public static func top(_ radius: CGFloat) -> CornerStyle {
            CornerStyle(
                topLeft: radius,
                topRight: radius,
                bottomLeft: 0,
                bottomRight: 0
            )
        }

        /// Only bottom corners
        public static func bottom(_ radius: CGFloat) -> CornerStyle {
            CornerStyle(
                topLeft: 0,
                topRight: 0,
                bottomLeft: radius,
                bottomRight: radius
            )
        }

        /// Only left corners
        public static func left(_ radius: CGFloat) -> CornerStyle {
            CornerStyle(
                topLeft: radius,
                topRight: 0,
                bottomLeft: radius,
                bottomRight: 0
            )
        }

        /// Only right corners
        public static func right(_ radius: CGFloat) -> CornerStyle {
            CornerStyle(
                topLeft: 0,
                topRight: radius,
                bottomLeft: 0,
                bottomRight: radius
            )
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply corner radius using design tokens
    public func cornerRadiusDesign(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// Apply button-style corner radius
    public func buttonCorners() -> some View {
        cornerRadiusDesign(Corners.Component.button)
    }

    /// Apply card-style corner radius
    public func cardCorners() -> some View {
        cornerRadiusDesign(Corners.Component.card)
    }

    /// Apply modal-style corner radius
    public func modalCorners() -> some View {
        cornerRadiusDesign(Corners.Component.modal)
    }

    /// Apply circular/pill shape
    public func circular() -> some View {
        cornerRadiusDesign(Corners.full)
    }

    /// Apply specific corners with UnevenRoundedRectangle (iOS 16+)
    @available(iOS 16.0, macOS 13.0, *)
    public func corners(_ style: Corners.CornerStyle) -> some View {
        self.clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: style.topLeft,
                bottomLeadingRadius: style.bottomLeft,
                bottomTrailingRadius: style.bottomRight,
                topTrailingRadius: style.topRight
            )
        )
    }

    /// Apply top corners only (iOS 16+)
    @available(iOS 16.0, macOS 13.0, *)
    public func topCorners(_ radius: CGFloat = Corners.lg) -> some View {
        corners(Corners.CornerStyle.top(radius))
    }

    /// Apply bottom corners only (iOS 16+)
    @available(iOS 16.0, macOS 13.0, *)
    public func bottomCorners(_ radius: CGFloat = Corners.lg) -> some View {
        corners(Corners.CornerStyle.bottom(radius))
    }
}

// MARK: - Shape Extensions

extension RoundedRectangle {
    /// Create rounded rectangle with design token
    public static func corner(_ radius: CGFloat) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }

    /// Create card-shaped rounded rectangle
    public static var card: RoundedRectangle {
        corner(Ponderless.Corners.Component.card)
    }

    /// Create button-shaped rounded rectangle
    public static var button: RoundedRectangle {
        corner(Ponderless.Corners.Component.button)
    }
}

// MARK: - Custom Corner Shape (Fallback for iOS 15)

/// Custom shape for selective corner rounding (iOS 15 fallback)
public struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// iOS 15 fallback extension
extension View {
    /// Apply specific corners (iOS 15 compatible)
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    /// Apply top corners only (iOS 15 compatible)
    public func topCornersCompat(_ radius: CGFloat = Corners.lg) -> some View {
        cornerRadius(radius, corners: [.topLeft, .topRight])
    }

    /// Apply bottom corners only (iOS 15 compatible)
    public func bottomCornersCompat(_ radius: CGFloat = Corners.lg) -> some View {
        cornerRadius(radius, corners: [.bottomLeft, .bottomRight])
    }
}

// MARK: - Border with Corners

extension View {
    /// Apply border with corner radius
    public func borderedCorners(
        radius: CGFloat = Corners.md,
        borderColor: Color = DesignSystem.Colors.border,
        borderWidth: CGFloat = 1
    ) -> some View {
        self
            .cornerRadiusDesign(radius)
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }

    /// Apply card-style border with corners
    public func cardBorder() -> some View {
        borderedCorners(
            radius: Corners.Component.card,
            borderColor: DesignSystem.Colors.border
        )
    }

    /// Apply button-style border with corners
    public func buttonBorder() -> some View {
        borderedCorners(
            radius: Corners.Component.button,
            borderColor: DesignSystem.Colors.border
        )
    }
}