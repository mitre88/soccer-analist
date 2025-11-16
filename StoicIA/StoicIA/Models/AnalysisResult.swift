//
//  AnalysisResult.swift
//  Stoic IA
//
//  Data model for soccer technique analysis results
//

import Foundation
import SwiftUI

struct AnalysisResult: Identifiable, Codable {
    let id: UUID
    let videoURL: URL?
    let timestamp: Date
    let overallScore: Double
    let techniqueMetrics: TechniqueMetrics
    let insights: [TechniqueInsight]
    let recommendations: [String]

    init(
        id: UUID = UUID(),
        videoURL: URL? = nil,
        timestamp: Date = Date(),
        overallScore: Double,
        techniqueMetrics: TechniqueMetrics,
        insights: [TechniqueInsight],
        recommendations: [String]
    ) {
        self.id = id
        self.videoURL = videoURL
        self.timestamp = timestamp
        self.overallScore = overallScore
        self.techniqueMetrics = techniqueMetrics
        self.insights = insights
        self.recommendations = recommendations
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

struct TechniqueInsight: Identifiable, Codable {
    let id: UUID
    let category: TechniqueCategory
    let severity: InsightSeverity
    let title: String
    let description: String
    let improvement: String

    init(
        id: UUID = UUID(),
        category: TechniqueCategory,
        severity: InsightSeverity,
        title: String,
        description: String,
        improvement: String
    ) {
        self.id = id
        self.category = category
        self.severity = severity
        self.title = title
        self.description = description
        self.improvement = improvement
    }

    var color: Color {
        switch severity {
        case .critical:
            return .red
        case .important:
            return .orange
        case .moderate:
            return .yellow
        case .minor:
            return .green
        }
    }

    var icon: String {
        switch severity {
        case .critical:
            return "exclamationmark.triangle.fill"
        case .important:
            return "exclamationmark.circle.fill"
        case .moderate:
            return "info.circle.fill"
        case .minor:
            return "checkmark.circle.fill"
        }
    }
}

enum TechniqueCategory: String, Codable, CaseIterable {
    case ballControl = "Ball Control"
    case shooting = "Shooting"
    case passing = "Passing"
    case positioning = "Positioning"
    case firstTouch = "First Touch"
    case bodyMechanics = "Body Mechanics"
    case footwork = "Footwork"
    case timing = "Timing"
    case power = "Power Generation"
    case accuracy = "Accuracy"

    var icon: String {
        switch self {
        case .ballControl:
            return "soccerball.circle.fill"
        case .shooting:
            return "target"
        case .passing:
            return "arrow.triangle.swap"
        case .positioning:
            return "location.fill"
        case .firstTouch:
            return "hand.tap.fill"
        case .bodyMechanics:
            return "figure.walk"
        case .footwork:
            return "shoe.fill"
        case .timing:
            return "timer"
        case .power:
            return "bolt.fill"
        case .accuracy:
            return "scope"
        }
    }
}

enum InsightSeverity: String, Codable {
    case critical = "Critical"
    case important = "Important"
    case moderate = "Moderate"
    case minor = "Minor"
}
