//
//  AnalysisResultsView.swift
//  Stoic IA
//
//  Detailed analysis results and history
//

import SwiftUI

struct AnalysisResultsView: View {
    @EnvironmentObject var viewModel: AnalysisViewModel
    @State private var selectedResult: AnalysisResult?
    @State private var showingShareSheet = false
    @State private var shareText = ""

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.black, Color(white: 0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if viewModel.analysisResults.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            headerSection

                            // Latest analysis detail
                            if let latest = viewModel.analysisResults.first {
                                latestAnalysisSection(latest)
                            }

                            // History
                            if viewModel.analysisResults.count > 1 {
                                historySection
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedResult) { result in
                DetailedAnalysisView(result: result)
                    .environmentObject(viewModel)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analysis Results")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("\(viewModel.analysisResults.count) total analyses")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Latest Analysis

    private func latestAnalysisSection(_ result: AnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Latest Analysis")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            // Overall score
            AnalysisCard {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(result.formattedDate)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))

                            Text("Overall Technique")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        // Score circle
                        ScoreCircle(score: result.overallScore, size: 80)
                    }

                    // Quick metrics
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickMetric(
                            title: "Ball Control",
                            value: result.techniqueMetrics.ballControlScore,
                            icon: "soccerball.circle.fill"
                        )
                        QuickMetric(
                            title: "Shooting",
                            value: result.techniqueMetrics.shootingTechniqueScore,
                            icon: "target"
                        )
                        QuickMetric(
                            title: "Positioning",
                            value: result.techniqueMetrics.positioningScore,
                            icon: "location.fill"
                        )
                        QuickMetric(
                            title: "First Touch",
                            value: result.techniqueMetrics.firstTouchScore,
                            icon: "hand.tap.fill"
                        )
                    }
                }
            }

            // Insights preview
            if !result.insights.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key Insights")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    ForEach(result.insights.prefix(2)) { insight in
                        InsightCard(insight: insight)
                    }

                    Button {
                        selectedResult = result
                    } label: {
                        HStack {
                            Text("View Full Analysis")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            GlassmorphicCard {
                                Color.clear
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Previous Analyses")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            ForEach(Array(viewModel.analysisResults.dropFirst().enumerated()), id: \.element.id) { index, result in
                Button {
                    selectedResult = result
                } label: {
                    HistoryRow(result: result)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))

            Text("No Results Yet")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text("Complete your first video analysis\nto see your results here")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Supporting Views

struct ScoreCircle: View {
    let score: Double
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: size * 0.08)

            Circle()
                .trim(from: 0, to: score / 100)
                .stroke(
                    scoreGradient,
                    style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text(String(format: "%.0f", score))
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundColor(.white)

                Text("Score")
                    .font(.system(size: size * 0.12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(width: size, height: size)
    }

    private var scoreGradient: LinearGradient {
        if score >= 80 {
            return LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        } else if score >= 60 {
            return LinearGradient(colors: [.orange, .orange.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.red, .red.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        }
    }
}

struct QuickMetric: View {
    let title: String
    let value: Double
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(colorForValue(value))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))

                Text(String(format: "%.0f", value))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func colorForValue(_ value: Double) -> Color {
        if value >= 80 {
            return .green
        } else if value >= 60 {
            return .orange
        } else {
            return .red
        }
    }
}

struct HistoryRow: View {
    let result: AnalysisResult

    var body: some View {
        GlassmorphicCard {
            HStack(spacing: 16) {
                // Date
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Text(formattedTime)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                // Score
                Text(String(format: "%.0f", result.overallScore))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(scoreColor)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: result.timestamp)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: result.timestamp)
    }

    private var scoreColor: Color {
        if result.overallScore >= 80 {
            return .green
        } else if result.overallScore >= 60 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Detailed Analysis View

struct DetailedAnalysisView: View {
    let result: AnalysisResult
    @EnvironmentObject var viewModel: AnalysisViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [.black, Color(white: 0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Overall score
                        ScoreCircle(score: result.overallScore, size: 120)
                            .padding(.top, 20)

                        // All insights
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Professional Insights")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            ForEach(result.insights) { insight in
                                InsightCard(insight: insight)
                            }
                        }

                        // Recommendations
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Expert Recommendations")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            ForEach(result.recommendations.indices, id: \.self) { index in
                                RecommendationCard(
                                    number: index + 1,
                                    text: result.recommendations[index]
                                )
                            }
                        }

                        // Share button
                        LiquidGlassButton(title: "Export Analysis", icon: "square.and.arrow.up") {
                            shareAnalysis()
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Analysis Details")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func shareAnalysis() {
        let exportText = viewModel.exportResults(result)
        let activityVC = UIActivityViewController(
            activityItems: [exportText],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct RecommendationCard: View {
    let number: Int
    let text: String

    var body: some View {
        GlassmorphicCard {
            HStack(alignment: .top, spacing: 12) {
                Text("\(number)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.blue.opacity(0.2)))

                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(4)
            }
            .padding(16)
        }
    }
}

#Preview {
    AnalysisResultsView()
        .environmentObject(AnalysisViewModel())
}
