//
//  TechniqueMetrics.swift
//  Stoic IA
//
//  Detailed metrics for soccer technique evaluation
//

import Foundation

struct TechniqueMetrics: Codable {
    // Core technique scores (0-100)
    let ballControlScore: Double
    let shootingTechniqueScore: Double
    let passingAccuracyScore: Double
    let positioningScore: Double
    let firstTouchScore: Double

    // Biomechanics analysis
    let bodyPosture: BodyPostureAnalysis
    let footPlacement: FootPlacementAnalysis
    let strikeQuality: StrikeQualityAnalysis

    // Movement analysis
    let approachAngle: Double
    let followThroughQuality: Double
    let balanceScore: Double

    // Advanced metrics
    let powerGenerationEfficiency: Double
    let techniqueConsistency: Double
    let contactPointAccuracy: Double

    var averageScore: Double {
        (ballControlScore + shootingTechniqueScore + passingAccuracyScore +
         positioningScore + firstTouchScore) / 5.0
    }

    var strengthCategories: [String] {
        var strengths: [String] = []
        if ballControlScore >= 80 { strengths.append("Ball Control") }
        if shootingTechniqueScore >= 80 { strengths.append("Shooting") }
        if passingAccuracyScore >= 80 { strengths.append("Passing") }
        if positioningScore >= 80 { strengths.append("Positioning") }
        if firstTouchScore >= 80 { strengths.append("First Touch") }
        return strengths
    }

    var improvementCategories: [String] {
        var improvements: [String] = []
        if ballControlScore < 70 { improvements.append("Ball Control") }
        if shootingTechniqueScore < 70 { improvements.append("Shooting") }
        if passingAccuracyScore < 70 { improvements.append("Passing") }
        if positioningScore < 70 { improvements.append("Positioning") }
        if firstTouchScore < 70 { improvements.append("First Touch") }
        return improvements
    }
}

struct BodyPostureAnalysis: Codable {
    let spineAlignment: Double // 0-100
    let hipPosition: String
    let shoulderAlignment: String
    let headPosition: String
    let overallPostureScore: Double

    var feedback: String {
        if overallPostureScore >= 80 {
            return "Excellent posture - balanced and athletic stance"
        } else if overallPostureScore >= 60 {
            return "Good posture with minor adjustments needed"
        } else {
            return "Focus on maintaining better body alignment"
        }
    }
}

struct FootPlacementAnalysis: Codable {
    let plantFootDistance: Double // cm from ball
    let plantFootAngle: Double // degrees
    let strikingFootAngle: Double
    let contactPoint: String
    let placementScore: Double

    var isOptimal: Bool {
        // Optimal plant foot distance: 15-25cm
        // Optimal angle: 30-45 degrees
        return plantFootDistance >= 15 && plantFootDistance <= 25 &&
               plantFootAngle >= 30 && plantFootAngle <= 45
    }

    var feedback: String {
        if isOptimal {
            return "Perfect foot placement - optimal for power and accuracy"
        } else if plantFootDistance < 15 {
            return "Plant foot too close - move back 5-10cm for better strike"
        } else if plantFootDistance > 25 {
            return "Plant foot too far - step closer to the ball"
        } else {
            return "Adjust plant foot angle for better balance"
        }
    }
}

struct StrikeQualityAnalysis: Codable {
    let contactType: ContactType
    let swingPath: String
    let followThrough: String
    let impactTiming: Double
    let ballRotation: String
    let strikeScore: Double

    var professionalComparison: String {
        if strikeScore >= 90 {
            return "Elite level - comparable to professional players"
        } else if strikeScore >= 75 {
            return "Advanced - high quality strike technique"
        } else if strikeScore >= 60 {
            return "Intermediate - solid foundation with room for refinement"
        } else {
            return "Developing - focus on fundamental technique"
        }
    }
}

enum ContactType: String, Codable {
    case laces = "Laces (Power Shot)"
    case inside = "Inside Foot (Placement)"
    case outside = "Outside Foot (Curve)"
    case toe = "Toe Poke"
    case heel = "Heel Strike"
    case volley = "Volley"
    case halfVolley = "Half-Volley"
    case chip = "Chip"

    var recommendation: String {
        switch self {
        case .laces:
            return "Lock ankle, strike through center of ball for power"
        case .inside:
            return "Open hip, follow through toward target"
        case .outside:
            return "Wrap foot around ball, generate spin"
        case .toe:
            return "Generally avoid - use laces for better control"
        case .heel:
            return "Advanced technique - practice timing"
        case .volley:
            return "Keep eyes on ball, strike through center"
        case .halfVolley:
            return "Time contact just after bounce"
        case .chip:
            return "Stab under ball, minimal follow-through"
        }
    }
}
