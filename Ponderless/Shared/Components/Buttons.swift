//
//  Buttons.swift
//  Ponderless
//
//  3D button components with Duolingo-style pressed effect
//

import SwiftUI

// MARK: - Primary Button

/// Primary button with 3D effect and pressed animation
/// Primary button with 3D effect and pressed animation
public struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .padding(.horizontal, Spacing.xl)
                .foregroundStyle(DesignSystem.Colors.primaryForeground)
        }
        .buttonStyle(PressedButton3DStyle(
            backgroundColor: DesignSystem.Colors.primary,
            shadowColor: DesignSystem.Colors.primary.opacity(0.6),
            hapticStyle: .medium
        ))
    }
}

// MARK: - Secondary Button

/// Secondary button with 3D effect
/// Secondary button with 3D effect
public struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .padding(.horizontal, Spacing.xl)
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
        }
        .buttonStyle(PressedButton3DStyle(
            backgroundColor: DesignSystem.Colors.secondary,
            shadowColor: DesignSystem.Colors.secondary.opacity(0.5),
            hapticStyle: .light
        ))
    }
}

// MARK: - Icon Button (Primary)

/// Primary icon button with 3D effect
/// Primary icon button with 3D effect
public struct PrimaryIconButton: View {
    let icon: String
    let action: () -> Void
    let size: CGFloat
    
    
    public init(icon: String, size: CGFloat = 48, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.primaryForeground)
                .frame(width: size, height: size)
        }
        .buttonStyle(PressedIconButton3DStyle(
            size: size,
            backgroundColor: DesignSystem.Colors.primary,
            shadowColor: DesignSystem.Colors.primary.opacity(0.6),
            hapticStyle: .medium
        ))
    }
}

// MARK: - Icon Button (Secondary)

/// Secondary icon button with 3D effect
/// Secondary icon button with 3D effect
public struct SecondaryIconButton: View {
    let icon: String
    let action: () -> Void
    let size: CGFloat
    
    
    public init(icon: String, size: CGFloat = 48, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                .frame(width: size, height: size)
        }
        .buttonStyle(PressedIconButton3DStyle(
            size: size,
            backgroundColor: DesignSystem.Colors.secondary,
            shadowColor: DesignSystem.Colors.secondary.opacity(0.5),
            hapticStyle: .light
        ))
    }
}

// MARK: - Compact Primary Button

/// Compact primary button (doesn't expand to full width)
/// Compact primary button (doesn't expand to full width)
public struct CompactPrimaryButton: View {
    let title: String
    let action: () -> Void
    
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .fontWeight(.semibold)
                .padding(.vertical, Spacing.md)
                .padding(.horizontal, Spacing.xl)
                .foregroundStyle(DesignSystem.Colors.primaryForeground)
        }
        .buttonStyle(PressedButton3DStyle(
            backgroundColor: DesignSystem.Colors.primary,
            shadowColor: DesignSystem.Colors.primary.opacity(0.6),
            hapticStyle: .medium
        ))
    }
}

// MARK: - Compact Secondary Button

/// Compact secondary button (doesn't expand to full width)
/// Compact secondary button (doesn't expand to full width)
public struct CompactSecondaryButton: View {
    let title: String
    let action: () -> Void
    
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .fontWeight(.semibold)
                .padding(.vertical, Spacing.md)
                .padding(.horizontal, Spacing.xl)
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)
        }
        .buttonStyle(PressedButton3DStyle(
            backgroundColor: DesignSystem.Colors.secondary,
            shadowColor: DesignSystem.Colors.secondary.opacity(0.5),
            hapticStyle: .light
        ))
    }
}

// MARK: - Destructive Button

/// Destructive button with 3D effect
/// Destructive button with 3D effect
public struct DestructiveButton: View {
    let title: String
    let action: () -> Void
    
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .padding(.horizontal, Spacing.xl)
                .foregroundStyle(DesignSystem.Colors.destructiveForeground)
        }
        .buttonStyle(PressedButton3DStyle(
            backgroundColor: DesignSystem.Colors.destructive,
            shadowColor: DesignSystem.Colors.destructive.opacity(0.6),
            hapticStyle: .medium
        ))
    }
}

// MARK: - Button Styles

/// Custom button style for circular icon buttons with 3D pressed effect
private struct PressedIconButton3DStyle: ButtonStyle {
    let size: CGFloat
    let backgroundColor: Color
    let shadowColor: Color
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    // Bottom shadow layer
                    Circle()
                        .fill(shadowColor)
                        .offset(y: configuration.isPressed ? 1 : 4)
                    
                    // Top button layer
                    Circle()
                        .fill(backgroundColor)
                }
            )
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    let impact = UIImpactFeedbackGenerator(style: hapticStyle)
                    impact.impactOccurred()
                }
            }
    }
}

// MARK: - Button Styles

/// Custom button style that creates 3D pressed effect
public struct PressedButton3DStyle: ButtonStyle {
    public let backgroundColor: Color
    public let shadowColor: Color
    public let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    
    public init(backgroundColor: Color, shadowColor: Color, hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.hapticStyle = hapticStyle
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    // Bottom shadow layer
                    RoundedRectangle(cornerRadius: Corners.xxxxl)
                        .fill(shadowColor)
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
                    let impact = UIImpactFeedbackGenerator(style: hapticStyle)
                    impact.impactOccurred()
                }
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.xxl) {
        PrimaryButton("Primary Button") {
            print("Primary tapped")
        }
        
        SecondaryButton("Secondary Button") {
            print("Secondary tapped")
        }
        
        HStack(spacing: Spacing.lg) {
            CompactPrimaryButton("Compact") {
                print("Compact primary tapped")
            }
            
            CompactSecondaryButton("Compact") {
                print("Compact secondary tapped")
            }
        }
        
        HStack(spacing: Spacing.lg) {
            PrimaryIconButton(icon: "plus") {
                print("Icon tapped")
            }
            
            SecondaryIconButton(icon: "heart.fill") {
                print("Icon tapped")
            }
        }
        
        DestructiveButton("Delete Account") {
            print("Destructive tapped")
        }
    }
    .padding(Spacing.xxl)
}
