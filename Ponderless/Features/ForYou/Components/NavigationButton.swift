
//
//  NavigationButton.swift
//  Ponderless
//
//  Reusable navigation button for exercise sheets
//

import SwiftUI

struct NavigationButton: View {
    enum Style {
        case primary
        case secondary
        case success

        var backgroundColor: Color {
            switch self {
            case .primary: return DesignSystem.Colors.primary
            case .secondary: return DesignSystem.Colors.secondary
            case .success: return DesignSystem.Colors.chart2
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary: return DesignSystem.Colors.primaryForeground
            case .secondary: return DesignSystem.Colors.foreground
            case .success: return DesignSystem.Colors.primaryForeground
            }
        }

        var font: Font {
            switch self {
            case .primary, .success: return Typography.body.bold()
            case .secondary: return Typography.body
            }
        }
    }

    let title: String
    let icon: String?
    let style: Style
    let action: () -> Void

    @ScaledMetric private var minHeight: CGFloat = Spacing.Layout.minTouchTarget

    init(
        title: String,
        icon: String? = nil,
        style: Style = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Text(title)
                if let icon = icon {
                    Image(systemName: icon)
                }
            }
            .font(style.font)
            .foregroundStyle(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(minHeight: minHeight)
            .padding(.vertical, Spacing.md)
        }
        .buttonStyle(NavigationButton3DStyle(
            backgroundColor: style.backgroundColor,
            shadowOpacity: style == .secondary ? 0.5 : 0.6
        ))
        .accessibilityLabel(title)
    }
}

// MARK: - Button Style

/// Custom button style for navigation buttons with 3D pressed effect
private struct NavigationButton3DStyle: ButtonStyle {
    let backgroundColor: Color
    let shadowOpacity: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    // Bottom shadow layer
                    RoundedRectangle(cornerRadius: Corners.xxxxl)
                        .fill(backgroundColor.opacity(shadowOpacity))
                        .offset(y: configuration.isPressed ? 2 : 6)
                    
                    // Top button layer
                    RoundedRectangle(cornerRadius: Corners.xxxxl)
                        .fill(backgroundColor)
                }
            )
            .offset(y: configuration.isPressed ? 4 : 0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
            }
    }
}

// MARK: - Previews

#Preview("Primary Button") {
    VStack(spacing: Spacing.md) {
        NavigationButton(title: "Next", style: .primary, action: {})
        NavigationButton(title: "Complete", icon: "checkmark.circle.fill", style: .primary, action: {})
    }
    .padding()
}

#Preview("Secondary Button") {
    NavigationButton(title: "Previous", style: .secondary, action: {})
        .padding()
}

#Preview("Success Button") {
    NavigationButton(title: "Complete", icon: "checkmark.circle.fill", style: .success, action: {})
        .padding()
}

#Preview("All Styles") {
    VStack(spacing: Spacing.md) {
        NavigationButton(title: "Primary", style: .primary, action: {})
        NavigationButton(title: "Secondary", style: .secondary, action: {})
        NavigationButton(title: "Success", icon: "checkmark.circle.fill", style: .success, action: {})
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.md) {
        NavigationButton(title: "Primary", style: .primary, action: {})
        NavigationButton(title: "Secondary", style: .secondary, action: {})
        NavigationButton(title: "Success", icon: "checkmark.circle.fill", style: .success, action: {})
    }
    .padding()
    .preferredColorScheme(.dark)
}
