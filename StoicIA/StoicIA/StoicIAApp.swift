//
//  StoicIAApp.swift
//  Stoic IA
//
//  Professional Soccer Analysis powered by Apple Intelligence
//

import SwiftUI

@main
struct StoicIAApp: App {
    @StateObject private var analysisViewModel = AnalysisViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(analysisViewModel)
                    .preferredColorScheme(.dark)
            } else {
                SplashScreenView()
                    .environmentObject(analysisViewModel)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
