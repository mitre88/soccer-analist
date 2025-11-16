//
//  GlassmorphicCard.swift
//  Stoic IA
//
//  Glassmorphic card component with liquid glass effect
//

import SwiftUI

struct GlassmorphicCard<Content: View>: View {
    let cornerRadius: CGFloat
    let content: Content

    init(cornerRadius: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .background(
                ZStack {
                    // Main glass background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )

                    // Top highlight
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 15, y: 10)
    }
}

// MARK: - Variants

struct AnalysisCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GlassmorphicCard(cornerRadius: 24) {
            content
                .padding(20)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        GlassmorphicCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)

                    Spacer()

                    Text(value)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
        }
    }
}

struct InsightCard: View {
    let insight: TechniqueInsight

    var body: some View {
        GlassmorphicCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: insight.icon)
                        .font(.system(size: 18))
                        .foregroundColor(insight.color)

                    Text(insight.severity.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(insight.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(insight.color.opacity(0.2))
                        )

                    Spacer()

                    Image(systemName: insight.category.icon)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }

                Text(insight.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text(insight.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(4)

                Divider()
                    .background(Color.white.opacity(0.2))

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)

                        Text("How to Improve")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.yellow)
                    }

                    Text(insight.improvement)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(4)
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            MetricCard(
                title: "Shooting Technique",
                value: "85",
                icon: "target",
                color: .green
            )

            MetricCard(
                title: "Ball Control",
                value: "72",
                icon: "soccerball.circle.fill",
                color: .orange
            )
        }
        .padding()
    }
}
