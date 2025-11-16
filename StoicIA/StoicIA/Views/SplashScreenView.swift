//
//  SplashScreenView.swift
//  Stoic IA
//
//  Elegant splash screen with liquid glass design
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showOnboarding = false
    @State private var logoOpacity = 0.0
    @State private var glowIntensity = 0.0

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [.black, Color(white: 0.1), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Animated particles
            ParticleField()
                .opacity(isAnimating ? 0.3 : 0)

            VStack(spacing: 40) {
                Spacer()

                // Logo and Title
                VStack(spacing: 20) {
                    // Logo symbol
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.1), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: isAnimating ? 0 : 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )

                        Image(systemName: "soccerball.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .white.opacity(glowIntensity), radius: 20)
                    }
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .rotation3DEffect(
                        .degrees(isAnimating ? 0 : 180),
                        axis: (x: 0, y: 1, z: 0)
                    )

                    // App name
                    Text("STOIC IA")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(logoOpacity)
                        .shadow(color: .white.opacity(0.3), radius: 10)

                    Text("Professional Soccer Analysis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .opacity(logoOpacity)
                }

                Spacer()

                // Powered by Apple Intelligence badge
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14))
                    Text("Powered by Apple Intelligence")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.6))
                .opacity(logoOpacity)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAnimation()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
        }
    }

    private func startAnimation() {
        withAnimation(.easeOut(duration: 1.0)) {
            isAnimating = true
            logoOpacity = 1.0
        }

        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowIntensity = 0.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showOnboarding = true
            }
        }
    }
}

// MARK: - Particle Field Effect

struct ParticleField: View {
    @State private var particles: [Particle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .blur(radius: 2)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
            }
        }
    }

    private func generateParticles(in size: CGSize) {
        particles = (0..<30).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 2...6)
            )
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
}

#Preview {
    SplashScreenView()
}
