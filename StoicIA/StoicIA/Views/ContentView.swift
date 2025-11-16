//
//  ContentView.swift
//  Stoic IA
//
//  Main navigation and content view
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AnalysisViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            VideoAnalysisView()
                .tabItem {
                    Label("Analyze", systemImage: "video.badge.checkmark")
                }
                .tag(1)

            AnalysisResultsView()
                .tabItem {
                    Label("Results", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
        .accentColor(.white)
        .onAppear {
            setupTabBarAppearance()
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        // Apply blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .environmentObject(AnalysisViewModel())
}
