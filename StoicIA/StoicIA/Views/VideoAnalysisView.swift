//
//  VideoAnalysisView.swift
//  Stoic IA
//
//  Video selection and analysis view
//

import SwiftUI
import PhotosUI
import AVKit

struct VideoAnalysisView: View {
    @EnvironmentObject var viewModel: AnalysisViewModel
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedVideoURL: URL?
    @State private var showingPlayer = false
    @State private var isProcessing = false

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

                if viewModel.isAnalyzing {
                    analysisInProgressView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            headerSection

                            // Action type selector
                            actionTypeSelectorSection

                            // Video picker
                            videoPickerSection

                            // Selected video preview
                            if let url = selectedVideoURL {
                                selectedVideoSection(url: url)
                            }

                            // Instructions
                            instructionsSection

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                await loadVideo(from: newItem)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Video Analysis")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Upload a video to get professional feedback")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Action Type Selector

    private var actionTypeSelectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What are you working on?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(SoccerAction.allCases, id: \.self) { action in
                    ActionTypeButton(
                        action: action,
                        isSelected: viewModel.selectedActionType == action
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedActionType = action
                        }
                    }
                }
            }
        }
    }

    // MARK: - Video Picker

    private var videoPickerSection: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $selectedItem, matching: .videos) {
                GlassmorphicCard {
                    VStack(spacing: 16) {
                        Image(systemName: "video.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.6))

                        VStack(spacing: 6) {
                            Text("Select Video")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Text("Choose from your library")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                }
            }
        }
    }

    // MARK: - Selected Video

    private func selectedVideoSection(url: URL) -> some View {
        VStack(spacing: 16) {
            GlassmorphicCard {
                VStack(spacing: 16) {
                    // Video preview
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Info
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Video selected")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        Button {
                            selectedVideoURL = nil
                            selectedItem = nil
                        } label: {
                            Text("Change")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding(16)
            }

            // Analyze button
            LiquidGlassButton(title: "Analyze Video", icon: "brain.head.profile") {
                Task {
                    await viewModel.analyzeVideo(url: url)
                }
            }
        }
    }

    // MARK: - Instructions

    private var instructionsSection: some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Tips for Best Results")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 12) {
                    InstructionRow(
                        icon: "camera.fill",
                        text: "Record in good lighting from a side angle"
                    )
                    InstructionRow(
                        icon: "person.fill",
                        text: "Ensure full body is visible in the frame"
                    )
                    InstructionRow(
                        icon: "timer",
                        text: "Keep video between 5-30 seconds"
                    )
                    InstructionRow(
                        icon: "figure.soccer",
                        text: "Focus on one action or technique at a time"
                    )
                }
            }
            .padding(20)
        }
    }

    // MARK: - Analysis In Progress

    private var analysisInProgressView: some View {
        VStack(spacing: 30) {
            Spacer()

            // Animated logo
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: viewModel.analysisProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: viewModel.analysisProgress)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }

            VStack(spacing: 12) {
                Text("Analyzing Your Technique")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text(String(format: "%.0f%%", viewModel.analysisProgress * 100))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))

                Text("Our AI is examining your biomechanics,\nfoot placement, and technique")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Helper Methods

    private func loadVideo(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        isProcessing = true
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                // Save to temporary URL
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mov")

                try data.write(to: tempURL)
                selectedVideoURL = tempURL
            }
        } catch {
            print("Failed to load video: \(error)")
        }
        isProcessing = false
    }
}

// MARK: - Supporting Views

struct ActionTypeButton: View {
    let action: SoccerAction
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: iconForAction(action))
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .blue : .white.opacity(0.6))

                Text(action.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                GlassmorphicCard {
                    Color.clear
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func iconForAction(_ action: SoccerAction) -> String {
        switch action {
        case .shooting:
            return "target"
        case .passing:
            return "arrow.triangle.swap"
        case .dribbling:
            return "figure.soccer"
        case .firstTouch:
            return "hand.tap.fill"
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

#Preview {
    VideoAnalysisView()
        .environmentObject(AnalysisViewModel())
}
