//
//  Typography.swift
//  Ponderless
//
//  Typography system with font families, sizes, and styles
//

import SwiftUI

/// Typography system for Ponderless app
public enum Typography {

    // MARK: - Font Families

    /// Available font families
    public enum FontFamily: String {
        case ibmPlexSans = "IBM Plex Sans"
        case ibmPlexSansCondensed = "IBM Plex Sans Condensed"
        case jetBrainsMono = "JetBrains Mono"

        /// System font fallback
        case system = "System"

        /// Get the font for a given size and weight
        public func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            switch self {
            case .system:
                return Font.system(size: size, weight: weight, design: .default)
            case .ibmPlexSans:
                // Use specific weight file names for IBM Plex Sans
                let fontName: String
                switch weight {
                case .bold, .heavy, .black:
                    fontName = "IBMPlexSans-Bold"
                case .semibold:
                    fontName = "IBMPlexSans-SemiBold"
                case .medium:
                    fontName = "IBMPlexSans-Medium"
                case .light:
                    fontName = "IBMPlexSans-Light"
                case .thin, .ultraLight:
                    fontName = "IBMPlexSans-Thin"
                default:
                    fontName = "IBMPlexSans-Regular"
                }
                return Font.custom(fontName, size: size)
            case .ibmPlexSansCondensed:
                // Condensed variant for compact layouts
                let fontName: String
                switch weight {
                case .bold, .heavy, .black:
                    fontName = "IBMPlexSans_Condensed-Bold"
                case .semibold:
                    fontName = "IBMPlexSans_Condensed-SemiBold"
                case .medium:
                    fontName = "IBMPlexSans_Condensed-Medium"
                default:
                    fontName = "IBMPlexSans_Condensed-Regular"
                }
                return Font.custom(fontName, size: size)
            default:
                return Font.custom(self.rawValue, size: size)
            }
        }
    }

    // MARK: - Font Styles

    /// Extra large title style (36pt, bold)
    public static let largeTitle = FontFamily.ibmPlexSans.font(size: 36, weight: .bold)

    /// Title 1 style (32pt, semibold)
    public static let title1 = FontFamily.ibmPlexSans.font(size: 32, weight: .semibold)

    /// Title 2 style (28pt, semibold)
    public static let title2 = FontFamily.ibmPlexSans.font(size: 28, weight: .semibold)

    /// Title 3 style (24pt, semibold)
    public static let title3 = FontFamily.ibmPlexSans.font(size: 24, weight: .semibold)

    /// Headline style (20pt, semibold)
    public static let headline = FontFamily.ibmPlexSans.font(size: 20, weight: .semibold)

    /// Body style (16pt, regular)
    public static let body = FontFamily.ibmPlexSans.font(size: 16, weight: .regular)

    /// Body bold style (16pt, semibold)
    public static let bodyBold = FontFamily.ibmPlexSans.font(size: 16, weight: .semibold)

    /// Callout style (15pt, regular)
    public static let callout = FontFamily.ibmPlexSans.font(size: 15, weight: .regular)

    /// Subheadline style (14pt, regular)
    public static let subheadline = FontFamily.ibmPlexSans.font(size: 14, weight: .regular)

    /// Footnote style (13pt, regular)
    public static let footnote = FontFamily.ibmPlexSans.font(size: 13, weight: .regular)

    /// Caption style (12pt, regular) - alias for caption1
    public static let caption = FontFamily.ibmPlexSans.font(size: 12, weight: .regular)

    /// Caption 1 style (12pt, regular)
    public static let caption1 = FontFamily.ibmPlexSans.font(size: 12, weight: .regular)

    /// Caption 2 style (11pt, regular)
    public static let caption2 = FontFamily.ibmPlexSans.font(size: 11, weight: .regular)

    /// Monospaced code style (14pt, system monospaced)
    public static let code = Font.system(size: 14, weight: .regular, design: .monospaced)

    /// Large code style (16pt, monospaced)
    public static let codeLarge = Font.system(size: 16, weight: .regular, design: .monospaced)

    // MARK: - Letter Spacing

    /// Letter spacing values based on CSS rem units (0.25rem = 4pt base)
    public enum LetterSpacing {
        /// Tight spacing (-0.05em)
        public static let tight: CGFloat = -0.5

        /// Normal spacing (0em)
        public static let normal: CGFloat = 0

        /// Wide spacing (0.025em)
        public static let wide: CGFloat = 0.25

        /// Extra wide spacing (0.05em)
        public static let extraWide: CGFloat = 0.5

        /// Ultra wide spacing (0.1em)
        public static let ultraWide: CGFloat = 1.0
    }

    // MARK: - Line Height

    /// Line height multipliers
    public enum LineHeight {
        /// Tight line height (1.25)
        public static let tight: CGFloat = 1.25

        /// Normal line height (1.5)
        public static let normal: CGFloat = 1.5

        /// Relaxed line height (1.75)
        public static let relaxed: CGFloat = 1.75

        /// Loose line height (2.0)
        public static let loose: CGFloat = 2.0
    }

    // MARK: - Text Styles

    /// Predefined text styles with complete formatting
    public struct TextStyle {
        let font: Font
        let letterSpacing: CGFloat
        let lineHeight: CGFloat?

        /// Apply style to a Text view
        public func apply(to text: Text) -> some View {
            text
                .font(font)
                .tracking(letterSpacing)
        }
    }

    /// Predefined text styles
    public static let styles = TextStyles()

    /// Container for predefined text styles
    public struct TextStyles {
        /// Hero title style
        public let hero = TextStyle(
            font: largeTitle,
            letterSpacing: LetterSpacing.tight,
            lineHeight: LineHeight.tight
        )

        /// Section header style
        public let sectionHeader = TextStyle(
            font: title2,
            letterSpacing: LetterSpacing.normal,
            lineHeight: LineHeight.normal
        )

        /// Card title style
        public let cardTitle = TextStyle(
            font: headline,
            letterSpacing: LetterSpacing.normal,
            lineHeight: LineHeight.normal
        )

        /// Primary body text style
        public let primaryBody = TextStyle(
            font: body,
            letterSpacing: LetterSpacing.normal,
            lineHeight: LineHeight.relaxed
        )

        /// Secondary text style
        public let secondary = TextStyle(
            font: subheadline,
            letterSpacing: LetterSpacing.normal,
            lineHeight: LineHeight.normal
        )

        /// Small text style
        public let small = TextStyle(
            font: caption1,
            letterSpacing: LetterSpacing.wide,
            lineHeight: LineHeight.normal
        )

        /// Code block style
        public let codeBlock = TextStyle(
            font: code,
            letterSpacing: LetterSpacing.normal,
            lineHeight: LineHeight.relaxed
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply a typography text style
    public func textStyle(_ style: Typography.TextStyle) -> some View {
        self
            .font(style.font)
            .tracking(style.letterSpacing)
    }

    /// Apply hero text style
    public func heroStyle() -> some View {
        textStyle(Typography.styles.hero)
    }

    /// Apply section header text style
    public func sectionHeaderStyle() -> some View {
        textStyle(Typography.styles.sectionHeader)
    }

    /// Apply card title text style
    public func cardTitleStyle() -> some View {
        textStyle(Typography.styles.cardTitle)
    }

    /// Apply primary body text style
    public func primaryBodyStyle() -> some View {
        textStyle(Typography.styles.primaryBody)
    }

    /// Apply secondary text style
    public func secondaryTextStyle() -> some View {
        textStyle(Typography.styles.secondary)
    }

    /// Apply small text style
    public func smallTextStyle() -> some View {
        textStyle(Typography.styles.small)
    }

    /// Apply code text style
    public func codeStyle() -> some View {
        textStyle(Typography.styles.codeBlock)
    }
}

// MARK: - Text Extensions

extension Text {
    /// Apply typography style directly to Text
    public func style(_ style: Typography.TextStyle) -> Text {
        self
            .font(style.font)
            .tracking(style.letterSpacing)
    }

    /// Apply heading style with semantic level
    public func heading(_ level: HeadingLevel = .h2) -> Text {
        switch level {
        case .h1:
            return self.font(Typography.largeTitle)
        case .h2:
            return self.font(Typography.title1)
        case .h3:
            return self.font(Typography.title2)
        case .h4:
            return self.font(Typography.title3)
        case .h5:
            return self.font(Typography.headline)
        case .h6:
            return self.font(Typography.subheadline)
        }
    }

    /// Heading semantic levels
    public enum HeadingLevel {
        case h1, h2, h3, h4, h5, h6
    }
}