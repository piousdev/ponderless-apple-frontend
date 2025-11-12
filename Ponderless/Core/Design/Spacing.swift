//
//  Spacing.swift
//  Ponderless
//
//  Consistent spacing system based on 0.25rem (4pt) scale
//

import SwiftUI

/// Spacing system for Ponderless app based on 4pt grid
public enum Spacing {

    // MARK: - Base Unit
    /// Base spacing unit (4pt = 0.25rem)
    private static let baseUnit: CGFloat = 4

    // MARK: - Spacing Scale

    /// 0px - No spacing
    public static let none: CGFloat = 0

    /// 2pt - 0.125rem - Hairline spacing
    public static let xxs: CGFloat = baseUnit * 0.5

    /// 4pt - 0.25rem - Extra small spacing
    public static let xs: CGFloat = baseUnit * 1

    /// 8pt - 0.5rem - Small spacing
    public static let sm: CGFloat = baseUnit * 2

    /// 12pt - 0.75rem - Medium-small spacing
    public static let md: CGFloat = baseUnit * 3

    /// 16pt - 1rem - Default spacing
    public static let lg: CGFloat = baseUnit * 4

    /// 20pt - 1.25rem - Large spacing
    public static let xl: CGFloat = baseUnit * 5

    /// 24pt - 1.5rem - Extra large spacing
    public static let xxl: CGFloat = baseUnit * 6

    /// 32pt - 2rem - 2x large spacing
    public static let xxxl: CGFloat = baseUnit * 8

    /// 40pt - 2.5rem - 3x large spacing
    public static let xxxxl: CGFloat = baseUnit * 10

    /// 48pt - 3rem - 4x large spacing
    public static let xxxxxl: CGFloat = baseUnit * 12

    /// 64pt - 4rem - 5x large spacing
    public static let xxxxxxl: CGFloat = baseUnit * 16

    /// 80pt - 5rem - 6x large spacing
    public static let xxxxxxxl: CGFloat = baseUnit * 20

    /// 96pt - 6rem - 7x large spacing
    public static let xxxxxxxxl: CGFloat = baseUnit * 24

    // MARK: - Semantic Spacing

    /// Component-specific spacing values
    public enum Component {
        /// Spacing inside buttons
        public static let buttonPadding = EdgeInsets(
            top: sm,
            leading: lg,
            bottom: sm,
            trailing: lg
        )

        /// Spacing inside cards
        public static let cardPadding = EdgeInsets(
            top: lg,
            leading: lg,
            bottom: lg,
            trailing: lg
        )

        /// Spacing inside list items
        public static let listItemPadding = EdgeInsets(
            top: md,
            leading: lg,
            bottom: md,
            trailing: lg
        )

        /// Spacing for sections
        public static let sectionPadding = EdgeInsets(
            top: xxl,
            leading: lg,
            bottom: xxl,
            trailing: lg
        )

        /// Spacing for screen content
        public static let screenPadding = EdgeInsets(
            top: xl,
            leading: lg,
            bottom: xl,
            trailing: lg
        )
    }

    /// Layout-specific spacing values
    public enum Layout {
        /// Spacing between elements in a stack
        public static let stackSpacing: CGFloat = md

        /// Spacing between items in a grid
        public static let gridSpacing: CGFloat = lg

        /// Spacing between sections
        public static let sectionSpacing: CGFloat = xxxl

        /// Minimum touch target size (44pt iOS guideline)
        public static let minTouchTarget: CGFloat = 44
    }

    // MARK: - Dynamic Spacing

    /// Get spacing value for a multiplier
    public static func custom(_ multiplier: CGFloat) -> CGFloat {
        baseUnit * multiplier
    }

    /// Get adaptive spacing based on size class
    public static func adaptive(
        compact: CGFloat,
        regular: CGFloat,
        sizeClass: UserInterfaceSizeClass?
    ) -> CGFloat {
        switch sizeClass {
        case .compact:
            return compact
        case .regular:
            return regular
        case .none:
            return compact
        @unknown default:
            return compact
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply consistent padding using spacing tokens
    public func paddingDesign(_ spacing: CGFloat) -> some View {
        self.padding(spacing)
    }

    /// Apply horizontal padding using spacing tokens
    public func horizontalPadding(_ spacing: CGFloat = Spacing.lg) -> some View {
        self.padding(.horizontal, spacing)
    }

    /// Apply vertical padding using spacing tokens
    public func verticalPadding(_ spacing: CGFloat = Spacing.lg) -> some View {
        self.padding(.vertical, spacing)
    }

    /// Apply card-style padding
    public func cardPadding() -> some View {
        self.padding(Spacing.Component.cardPadding)
    }

    /// Apply button-style padding
    public func buttonPadding() -> some View {
        self.padding(Spacing.Component.buttonPadding)
    }

    /// Apply section-style padding
    public func sectionPadding() -> some View {
        self.padding(Spacing.Component.sectionPadding)
    }

    /// Apply screen content padding
    public func screenPadding() -> some View {
        self.padding(Spacing.Component.screenPadding)
    }

    /// Add consistent spacing in VStack or HStack
    public func stackSpacing() -> some View {
        self.paddingDesign(Spacing.Layout.stackSpacing)
    }
}

// MARK: - Stack Extensions
// Note: VStack and HStack already have spacing parameters
// Use Spacing.Layout.stackSpacing directly:
// VStack(spacing: Spacing.Layout.stackSpacing) { ... }

// MARK: - Spacer Helpers

/// Fixed-height spacer using spacing tokens
public struct FixedSpacer: View {
    let height: CGFloat
    let width: CGFloat

    public init(height: CGFloat = Spacing.lg, width: CGFloat = 0) {
        self.height = height
        self.width = width
    }

    public var body: some View {
        Color.clear
            .frame(width: width > 0 ? width : nil, height: height > 0 ? height : nil)
    }
}

/// Vertical spacer with fixed height
public struct VSpacer: View {
    let height: CGFloat

    public init(_ height: CGFloat = Spacing.lg) {
        self.height = height
    }

    public var body: some View {
        FixedSpacer(height: height, width: 0)
    }
}

/// Horizontal spacer with fixed width
public struct HSpacer: View {
    let width: CGFloat

    public init(_ width: CGFloat = Spacing.lg) {
        self.width = width
    }

    public var body: some View {
        FixedSpacer(height: 0, width: width)
    }
}