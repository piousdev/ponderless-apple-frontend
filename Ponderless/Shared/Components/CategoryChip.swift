//
//  CategoryChip.swift
//  Ponderless
//
//  Reusable category filter chip
//

import SwiftUI

struct CategoryChip: View {
    let title: String
    var icon: String? = nil
    var color: Color = DesignSystem.Colors.primary
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs + Spacing.xxs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(Typography.caption)
                }
                Text(title)
                    .font(Typography.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                isSelected ? color : DesignSystem.Colors.muted
            )
            .foregroundStyle(
                isSelected ? DesignSystem.Colors.primaryForeground : DesignSystem.Colors.foreground
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : DesignSystem.Colors.border,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}