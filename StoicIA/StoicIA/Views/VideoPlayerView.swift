//
//  VideoPlayerView.swift
//  Stoic IA
//
//  Custom video player with analysis overlay
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()

                // Controls overlay
                VStack {
                    // Close button
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            GlassmorphicCard(cornerRadius: 20) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                            }
                        }
                        .padding()

                        Spacer()
                    }

                    Spacer()
                }
            }
        }
        .onAppear {
            player = AVPlayer(url: videoURL)
            player?.play()
            isPlaying = true
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

#Preview {
    VideoPlayerView(videoURL: URL(string: "https://example.com/video.mp4")!)
}
