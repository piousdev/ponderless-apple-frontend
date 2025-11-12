//
//  EmptyStateView.swift
//  Ponderless
//
//  Reusable empty state component
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: Spacing.custom(15)))
                .foregroundStyle(DesignSystem.Colors.secondaryForeground)

            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(Typography.title2)

                Text(message)
                    .font(Typography.body)
                    .foregroundStyle(DesignSystem.Colors.secondaryForeground)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.medium)
                        .padding(.horizontal, Spacing.xxl)
                        .padding(.vertical, Spacing.md)
                        .background(DesignSystem.Colors.primary)
                        .foregroundStyle(DesignSystem.Colors.primaryForeground)
                        .clipShape(Capsule())
                }
                .padding(.top, Spacing.sm)
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: Spacing.custom(75))
    }
}