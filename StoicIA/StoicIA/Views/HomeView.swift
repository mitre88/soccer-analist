//
//  HomeView.swift
//  Stoic IA
//
//  Home screen with overview and quick actions
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AnalysisViewModel
    @State private var showingActionSheet = false

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

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Quick stats if analyses exist
                        if !viewModel.analysisResults.isEmpty {
                            quickStatsSection
                        }

                        // Main action
                        analyzeVideoSection

                        // Recent analyses
                        if !viewModel.analysisResults.isEmpty {
                            recentAnalysesSection
                        } else {
                            emptyStateSection
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome to")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))

                    Text("Stoic IA")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                // Profile icon
                GlassmorphicCard(cornerRadius: 25) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 50, height: 50)
                }
            }

            Text("Professional Soccer Analysis")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.vertical, 10)
    }

    // MARK: - Quick Stats

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Progress")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 12) {
                MetricCard(
                    title: "Analyses",
                    value: "\(viewModel.analysisResults.count)",
                    icon: "chart.bar.fill",
                    color: .blue
                )

                if let latestScore = viewModel.analysisResults.first?.overallScore {
                    MetricCard(
                        title: "Latest Score",
                        value: String(format: "%.0f", latestScore),
                        icon: "star.fill",
                        color: .yellow
                    )
                }
            }
        }
    }

    // MARK: - Analyze Video Section

    private var analyzeVideoSection: some View {
        GlassmorphicCard {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 20))
                                .foregroundColor(.purple)

                            Text("AI Analysis")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.purple)
                        }

                        Text("Analyze Your\nSoccer Technique")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "soccerball.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                LiquidGlassButton(title: "Start Analysis", icon: "video.fill") {
                    viewModel.selectVideo()
                }
            }
            .padding(20)
        }
    }

    // MARK: - Recent Analyses

    private var recentAnalysesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Analyses")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                NavigationLink {
                    AnalysisResultsView()
                        .environmentObject(viewModel)
                } label: {
                    Text("View All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
            }

            ForEach(viewModel.analysisResults.prefix(3)) { result in
                RecentAnalysisRow(result: result)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 40)

            Text("No Analyses Yet")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text("Record a video of your soccer technique\nand let AI analyze your performance")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Recent Analysis Row

struct RecentAnalysisRow: View {
    let result: AnalysisResult

    var body: some View {
        GlassmorphicCard {
            HStack(spacing: 16) {
                // Score circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: result.overallScore / 100)
                        .stroke(scoreColor, lineWidth: 3)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))

                    Text(String(format: "%.0f", result.overallScore))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(result.formattedDate)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text("\(result.insights.count) insights • \(result.recommendations.count) tips")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
        }
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

#Preview {
    HomeView()
        .environmentObject(AnalysisViewModel())
}
