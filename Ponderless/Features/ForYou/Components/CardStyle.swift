//
//  CardStyle.swift
//  Ponderless
//
//  Reusable card styling view modifier
//

import SwiftUI

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var backgroundColor: Color = DesignSystem.Colors.secondary
    var hasBorder: Bool = true

    func body(content: Content) -> some View {
        content
            .cardPadding()
            .background(backgroundColor)
            .cardCorners()
            .overlay(
                hasBorder ?
                    RoundedRectangle(cornerRadius: Corners.Component.card)
                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                    : nil
            )
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.5)
                    : Color.black.opacity(0.1),
                radius: colorScheme == .dark ? 8 : 4,
                x: 0,
                y: 2
            )
    }
}

extension View {
    func cardStyle(
        backgroundColor: Color = DesignSystem.Colors.secondary,
        hasBorder: Bool = true
    ) -> some View {
        modifier(CardStyle(backgroundColor: backgroundColor, hasBorder: hasBorder))
    }
}

#Preview("Card Style") {
    VStack(spacing: Spacing.lg) {
        Text("Card with default styling")
            .cardStyle()

        Text("Card without border")
            .cardStyle(hasBorder: false)

        Text("Card with custom background")
            .cardStyle(backgroundColor: DesignSystem.Colors.primary.opacity(0.1))
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.lg) {
        Text("Card in dark mode")
            .cardStyle()

        Text("Custom background in dark mode")
            .cardStyle(backgroundColor: DesignSystem.Colors.primary.opacity(0.2))
    }
    .padding()
    .preferredColorScheme(.dark)
}
