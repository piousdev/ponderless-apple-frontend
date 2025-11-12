//
//  DesignSystemPreview.swift
//  Ponderless
//
//  Preview showcasing all design tokens
//

import SwiftUI

struct DesignSystemPreview: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView {
            ColorsPreview()
                .tabItem { Label("Colors", systemImage: "paintpalette") }

            TypographyPreview()
                .tabItem { Label("Typography", systemImage: "textformat") }

            SpacingPreview()
                .tabItem { Label("Spacing", systemImage: "square.grid.3x3") }

            ShadowsPreview()
                .tabItem { Label("Shadows", systemImage: "shadow") }

            CornersPreview()
                .tabItem { Label("Corners", systemImage: "rounded.rectangle") }

            ComponentsPreview()
                .tabItem { Label("Components", systemImage: "uiwindow.split.2x1") }
        }
    }
}

// MARK: - Colors Preview

struct ColorsPreview: View {
    @Environment(\.colorScheme) var colorScheme

    let colorPairs: [(String, Color, Color)] = [
        ("Background", DesignSystem.Colors.background, DesignSystem.Colors.foreground),
        ("Primary", DesignSystem.Colors.primary, DesignSystem.Colors.primaryForeground),
        ("Secondary", DesignSystem.Colors.secondary, DesignSystem.Colors.secondaryForeground),
        ("Muted", DesignSystem.Colors.muted, DesignSystem.Colors.mutedForeground),
        ("Accent", DesignSystem.Colors.accent, DesignSystem.Colors.accentForeground),
        ("Destructive", DesignSystem.Colors.destructive, DesignSystem.Colors.destructiveForeground)
    ]

    let utilityColors: [(String, Color)] = [
        ("Border", DesignSystem.Colors.border),
        ("Input", DesignSystem.Colors.input),
        ("Ring", DesignSystem.Colors.ring)
    ]

    let chartColors: [(String, Color)] = [
        ("Chart 1", DesignSystem.Colors.chart1),
        ("Chart 2", DesignSystem.Colors.chart2),
        ("Chart 3", DesignSystem.Colors.chart3),
        ("Chart 4", DesignSystem.Colors.chart4),
        ("Chart 5", DesignSystem.Colors.chart5)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("Color System")
                    .font(Typography.largeTitle)
                    .foregroundStyle(DesignSystem.Colors.foreground)
                    .padding(.horizontal)

                // Main color pairs
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Main Colors")
                        .font(Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                        .padding(.horizontal)

                    ForEach(colorPairs, id: \.0) { name, background, foreground in
                        ColorRow(name: name, background: background, foreground: foreground)
                    }
                }

                // Utility colors
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Utility Colors")
                        .font(Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                        .padding(.horizontal)

                    ForEach(utilityColors, id: \.0) { name, color in
                        UtilityColorRow(name: name, color: color)
                    }
                }

                // Chart colors
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Chart Colors")
                        .font(Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.foreground)
                        .padding(.horizontal)

                    HStack(spacing: Spacing.md) {
                        ForEach(chartColors, id: \.0) { name, color in
                            VStack {
                                RoundedRectangle(cornerRadius: Corners.md)
                                    .fill(color)
                                    .frame(width: 60, height: 60)
                                Text(name)
                                    .font(Typography.caption1)
                                    .foregroundStyle(DesignSystem.Colors.mutedForeground)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(DesignSystem.Colors.background)
    }
}

struct ColorRow: View {
    let name: String
    let background: Color
    let foreground: Color

    var body: some View {
        HStack {
            Text(name)
                .font(Typography.body)
                .foregroundStyle(DesignSystem.Colors.foreground)
                .frame(width: 120, alignment: .leading)

            RoundedRectangle(cornerRadius: Corners.md)
                .fill(background)
                .overlay(
                    Text("Aa")
                        .font(Typography.bodyBold)
                        .foregroundStyle(foreground)
                )
                .frame(height: 60)
        }
        .padding(.horizontal)
    }
}

struct UtilityColorRow: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            Text(name)
                .font(Typography.body)
                .foregroundStyle(DesignSystem.Colors.foreground)
                .frame(width: 120, alignment: .leading)

            RoundedRectangle(cornerRadius: Corners.md)
                .stroke(color, lineWidth: 2)
                .frame(height: 40)
        }
        .padding(.horizontal)
    }
}

// MARK: - Typography Preview

struct TypographyPreview: View {
    let styles: [(String, Font)] = [
        ("Large Title", Typography.largeTitle),
        ("Title 1", Typography.title1),
        ("Title 2", Typography.title2),
        ("Title 3", Typography.title3),
        ("Headline", Typography.headline),
        ("Body", Typography.body),
        ("Body Bold", Typography.bodyBold),
        ("Callout", Typography.callout),
        ("Subheadline", Typography.subheadline),
        ("Footnote", Typography.footnote),
        ("Caption 1", Typography.caption1),
        ("Caption 2", Typography.caption2),
        ("Code", Typography.code),
        ("Code Large", Typography.codeLarge)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("Typography System")
                    .font(Typography.largeTitle)
                    .foregroundStyle(DesignSystem.Colors.foreground)

                VStack(alignment: .leading, spacing: Spacing.lg) {
                    ForEach(styles, id: \.0) { name, font in
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(name)
                                .font(Typography.caption1)
                                .foregroundStyle(DesignSystem.Colors.mutedForeground)
                            Text("The quick brown fox jumps over the lazy dog")
                                .font(font)
                                .foregroundStyle(DesignSystem.Colors.foreground)
                        }
                        .padding(.vertical, Spacing.xs)
                    }
                }
            }
            .padding()
        }
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Spacing Preview

struct SpacingPreview: View {
    let spacings: [(String, CGFloat)] = [
        ("none", Spacing.none),
        ("xxs", Spacing.xxs),
        ("xs", Spacing.xs),
        ("sm", Spacing.sm),
        ("md", Spacing.md),
        ("lg", Spacing.lg),
        ("xl", Spacing.xl),
        ("xxl", Spacing.xxl),
        ("xxxl", Spacing.xxxl),
        ("xxxxl", Spacing.xxxxl)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("Spacing System")
                    .font(Typography.largeTitle)
                    .foregroundStyle(DesignSystem.Colors.foreground)

                VStack(alignment: .leading, spacing: Spacing.lg) {
                    ForEach(spacings, id: \.0) { name, spacing in
                        HStack {
                            Text(name)
                                .font(Typography.body)
                                .foregroundStyle(DesignSystem.Colors.foreground)
                                .frame(width: 60, alignment: .leading)

                            Text("\(Int(spacing))pt")
                                .font(Typography.caption1)
                                .foregroundStyle(DesignSystem.Colors.mutedForeground)
                                .frame(width: 40)

                            Rectangle()
                                .fill(DesignSystem.Colors.primary)
                                .frame(width: spacing, height: 20)

                            Spacer()
                        }
                    }
                }
            }
            .padding()
        }
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Shadows Preview

struct ShadowsPreview: View {
    let shadows: [(String, Shadows.Style)] = [
        ("None", .none),
        ("XS", .xs),
        ("SM", .sm),
        ("MD", .md),
        ("LG", .lg),
        ("XL", .xl),
        ("XXL", .xxl)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("Shadow System")
                    .font(Typography.largeTitle)
                    .foregroundStyle(DesignSystem.Colors.foreground)

                VStack(spacing: Spacing.xxl) {
                    ForEach(shadows, id: \.0) { name, style in
                        VStack {
                            RoundedRectangle(cornerRadius: Corners.lg)
                                .fill(DesignSystem.Colors.background)
                                .frame(height: 80)
                                .shadow(style: style)
                                .overlay(
                                    Text(name)
                                        .font(Typography.bodyBold)
                                        .foregroundStyle(DesignSystem.Colors.foreground)
                                )
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(DesignSystem.Colors.secondary)
    }
}

// MARK: - Corners Preview

struct CornersPreview: View {
    let corners: [(String, CGFloat)] = [
        ("None", Corners.none),
        ("XS", Corners.xs),
        ("SM", Corners.sm),
        ("MD", Corners.md),
        ("LG", Corners.lg),
        ("XL", Corners.xl),
        ("XXL", Corners.xxl),
        ("XXXL", Corners.xxxl)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("Corner Radius System")
                    .font(Typography.largeTitle)
                    .foregroundStyle(DesignSystem.Colors.foreground)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.lg) {
                    ForEach(corners, id: \.0) { name, radius in
                        VStack {
                            RoundedRectangle(cornerRadius: radius)
                                .fill(DesignSystem.Colors.primary)
                                .frame(height: 80)
                                .overlay(
                                    VStack {
                                        Text(name)
                                            .font(Typography.bodyBold)
                                            .foregroundStyle(DesignSystem.Colors.primaryForeground)
                                        Text("\(Int(radius))pt")
                                            .font(Typography.caption1)
                                            .foregroundStyle(DesignSystem.Colors.primaryForeground.opacity(0.8))
                                    }
                                )
                        }
                    }
                }
                .padding(.horizontal)

                // Full/Circular example
                HStack(spacing: Spacing.lg) {
                    Circle()
                        .fill(DesignSystem.Colors.accent)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("Full")
                                .font(Typography.bodyBold)
                                .foregroundStyle(DesignSystem.Colors.accentForeground)
                        )

                    RoundedRectangle(cornerRadius: Corners.full)
                        .fill(DesignSystem.Colors.accent)
                        .frame(width: 120, height: 50)
                        .overlay(
                            Text("Pill")
                                .font(Typography.bodyBold)
                                .foregroundStyle(DesignSystem.Colors.accentForeground)
                        )
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Components Preview

struct ComponentsPreview: View {
    @State private var text = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                Text("Component Examples")
                    .font(Typography.largeTitle)
                    .foregroundStyle(DesignSystem.Colors.foreground)

                // Buttons
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Buttons")
                        .font(Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.foreground)

                    HStack(spacing: Spacing.lg) {
                        Button("Primary") {}
                            .buttonPadding()
                            .primaryStyle()
                            .cornerRadius(Corners.Component.button)

                        Button("Secondary") {}
                            .buttonPadding()
                            .secondaryStyle()
                            .cornerRadius(Corners.Component.button)

                        Button("Destructive") {}
                            .buttonPadding()
                            .destructiveStyle()
                            .cornerRadius(Corners.Component.button)
                    }
                }

                // Cards
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Cards")
                        .font(Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.foreground)

                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Card Title")
                            .cardTitleStyle()
                            .foregroundStyle(DesignSystem.Colors.foreground)
                        Text("This is card content with proper spacing and typography.")
                            .primaryBodyStyle()
                            .foregroundStyle(DesignSystem.Colors.mutedForeground)
                    }
                    .cardPadding()
                    .background(DesignSystem.Colors.secondary)
                    .cardCorners()
                    .cardShadow()
                }

                // Input Field
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Input Fields")
                        .font(Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.foreground)

                    TextField("Enter text...", text: $text)
                        .textFieldStyle(.roundedBorder)
                        .font(Typography.body)
                }
            }
            .padding()
        }
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Preview

#Preview("Design System") {
    DesignSystemPreview()
}