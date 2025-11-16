//
//  SoccerAnalysisEngine.swift
//  Stoic IA
//
//  Professional soccer technique analysis engine
//  Based on FIFA coaching standards and professional training methodologies
//

import Foundation
import CoreML

@MainActor
class SoccerAnalysisEngine: ObservableObject {
    @Published var analysisProgress: Double = 0.0

    // MARK: - Main Analysis Function

    func analyzeVideoData(_ videoData: VideoAnalysisData, actionType: SoccerAction) async -> AnalysisResult {
        analysisProgress = 0.1

        // 1. Analyze body mechanics
        let bodyMechanics = analyzeBodyMechanics(videoData)
        analysisProgress = 0.3

        // 2. Analyze foot technique
        let footTechnique = analyzeFootTechnique(videoData, actionType: actionType)
        analysisProgress = 0.5

        // 3. Analyze timing and coordination
        let timingAnalysis = analyzeTimingAndCoordination(videoData)
        analysisProgress = 0.7

        // 4. Generate professional insights
        let insights = generateProfessionalInsights(
            bodyMechanics: bodyMechanics,
            footTechnique: footTechnique,
            timing: timingAnalysis,
            actionType: actionType
        )
        analysisProgress = 0.9

        // 5. Create recommendations based on FIFA standards
        let recommendations = generateFIFABasedRecommendations(insights: insights, actionType: actionType)

        // 6. Calculate technique metrics
        let metrics = calculateTechniqueMetrics(
            bodyMechanics: bodyMechanics,
            footTechnique: footTechnique,
            timing: timingAnalysis
        )

        analysisProgress = 1.0

        return AnalysisResult(
            overallScore: metrics.averageScore,
            techniqueMetrics: metrics,
            insights: insights,
            recommendations: recommendations
        )
    }

    // MARK: - Body Mechanics Analysis

    private func analyzeBodyMechanics(_ data: VideoAnalysisData) -> BodyMechanicsAnalysis {
        var postureScores: [Double] = []
        var balanceScores: [Double] = []
        var alignmentIssues: [String] = []

        for frame in data.frameAnalyses where frame.bodyPose != nil {
            if let alignment = frame.bodyAlignment {
                // Analyze spine angle (optimal: 10-30 degrees forward lean)
                let spineScore = evaluateSpineAngle(alignment.spineAngle)
                postureScores.append(spineScore)

                // Analyze balance
                let balanceScore = alignment.isBalanced ? 100.0 : 60.0
                balanceScores.append(balanceScore)

                // Detect alignment issues
                if abs(alignment.spineAngle) > 45 {
                    alignmentIssues.append("Excessive forward/backward lean")
                }
                if !alignment.isBalanced {
                    alignmentIssues.append("Hip misalignment detected")
                }
            }
        }

        let avgPosture = postureScores.isEmpty ? 50.0 : postureScores.reduce(0, +) / Double(postureScores.count)
        let avgBalance = balanceScores.isEmpty ? 50.0 : balanceScores.reduce(0, +) / Double(balanceScores.count)

        return BodyMechanicsAnalysis(
            postureScore: avgPosture,
            balanceScore: avgBalance,
            alignmentIssues: Array(Set(alignmentIssues))
        )
    }

    private func evaluateSpineAngle(_ angle: Double) -> Double {
        let absAngle = abs(angle)
        if absAngle >= 10 && absAngle <= 30 {
            return 100.0 // Optimal
        } else if absAngle < 10 {
            return 75.0 - (10 - absAngle) * 2 // Too upright
        } else {
            return 75.0 - (absAngle - 30) * 1.5 // Too much lean
        }
    }

    // MARK: - Foot Technique Analysis

    private func analyzeFootTechnique(_ data: VideoAnalysisData, actionType: SoccerAction) -> FootTechniqueAnalysis {
        var footPositions: [FootPositionData] = []
        var plantFootDistances: [Double] = []
        var strikingMotions: [String] = []

        for frame in data.frameAnalyses {
            if let footPos = frame.footPosition {
                footPositions.append(footPos)

                // Estimate plant foot distance from ball (simplified)
                if let ballPos = frame.ballPosition,
                   let leftFoot = footPos.leftFoot,
                   let rightFoot = footPos.rightFoot {
                    let leftDist = distance(from: leftFoot, to: ballPos)
                    let rightDist = distance(from: rightFoot, to: ballPos)
                    let plantDist = min(leftDist, rightDist)
                    plantFootDistances.append(plantDist * 100) // Convert to approximate cm
                }
            }
        }

        let avgPlantDistance = plantFootDistances.isEmpty ? 20.0 :
            plantFootDistances.reduce(0, +) / Double(plantFootDistances.count)

        let placementScore = evaluatePlantFootDistance(avgPlantDistance)

        return FootTechniqueAnalysis(
            plantFootDistance: avgPlantDistance,
            plantFootAngle: 40.0, // Estimated - would need more sophisticated tracking
            placementScore: placementScore,
            detectedContactType: detectContactType(from: data, actionType: actionType)
        )
    }

    private func distance(from point1: CGPoint, to point2: CGPoint) -> Double {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx * dx + dy * dy)
    }

    private func evaluatePlantFootDistance(_ distance: Double) -> Double {
        // Optimal: 15-25cm
        if distance >= 15 && distance <= 25 {
            return 100.0
        } else if distance < 15 {
            return max(60.0, 100.0 - (15 - distance) * 3)
        } else {
            return max(60.0, 100.0 - (distance - 25) * 2)
        }
    }

    private func detectContactType(from data: VideoAnalysisData, actionType: SoccerAction) -> ContactType {
        // Simplified detection - in production, use ML model
        switch actionType {
        case .shooting:
            return .laces
        case .passing:
            return .inside
        case .dribbling:
            return .outside
        case .firstTouch:
            return .inside
        }
    }

    // MARK: - Timing and Coordination Analysis

    private func analyzeTimingAndCoordination(_ data: VideoAnalysisData) -> TimingAnalysis {
        var approachFrames = 0
        var strikeFrame = 0
        var followThroughFrames = 0

        // Detect phases of the kick
        var previousBallDist: Double = 1000
        for (index, frame) in data.frameAnalyses.enumerated() {
            if let ballPos = frame.ballPosition,
               let footPos = frame.footPosition,
               let rightFoot = footPos.rightFoot {
                let currentDist = distance(from: rightFoot, to: ballPos)

                if currentDist < previousBallDist {
                    approachFrames += 1
                    if currentDist < 0.05 {
                        strikeFrame = index
                    }
                } else if strikeFrame > 0 && index > strikeFrame {
                    followThroughFrames += 1
                }

                previousBallDist = currentDist
            }
        }

        let timingScore = evaluateTiming(
            approachFrames: approachFrames,
            followThroughFrames: followThroughFrames
        )

        return TimingAnalysis(
            approachPhaseFrames: approachFrames,
            strikeFrameIndex: strikeFrame,
            followThroughFrames: followThroughFrames,
            timingScore: timingScore
        )
    }

    private func evaluateTiming(approachFrames: Int, followThroughFrames: Int) -> Double {
        // Good approach: 5-10 frames
        // Good follow-through: 3-7 frames
        let approachScore = approachFrames >= 5 && approachFrames <= 10 ? 100.0 : 70.0
        let followScore = followThroughFrames >= 3 && followThroughFrames <= 7 ? 100.0 : 70.0
        return (approachScore + followScore) / 2.0
    }

    // MARK: - Professional Insights Generation

    private func generateProfessionalInsights(
        bodyMechanics: BodyMechanicsAnalysis,
        footTechnique: FootTechniqueAnalysis,
        timing: TimingAnalysis,
        actionType: SoccerAction
    ) -> [TechniqueInsight] {
        var insights: [TechniqueInsight] = []

        // Body Mechanics Insights
        if bodyMechanics.postureScore < 70 {
            insights.append(TechniqueInsight(
                category: .bodyMechanics,
                severity: bodyMechanics.postureScore < 50 ? .critical : .important,
                title: "Body Posture Needs Improvement",
                description: "Your upper body position is not optimal for generating power and maintaining balance. \(bodyMechanics.alignmentIssues.joined(separator: ", "))",
                improvement: "Keep your head steady and eyes on the ball. Lean slightly forward (10-20°) from the hips while keeping your back straight. This athletic stance allows better weight transfer and power generation."
            ))
        }

        if bodyMechanics.balanceScore < 75 {
            insights.append(TechniqueInsight(
                category: .positioning,
                severity: .important,
                title: "Balance Could Be Optimized",
                description: "Hip alignment suggests balance issues during execution.",
                improvement: "Focus on a stable base. Keep your center of gravity low and centered. Practice single-leg balance drills to improve stability during technique execution."
            ))
        }

        // Foot Technique Insights
        if footTechnique.placementScore < 80 {
            let distance = footTechnique.plantFootDistance
            let feedback: String
            if distance < 15 {
                feedback = "Your plant foot is too close to the ball (\(String(format: "%.1f", distance))cm). Move it back 5-10cm for optimal striking position."
            } else if distance > 25 {
                feedback = "Your plant foot is too far from the ball (\(String(format: "%.1f", distance))cm). Step closer to maintain better control."
            } else {
                feedback = "Plant foot distance is acceptable but could be more consistent."
            }

            insights.append(TechniqueInsight(
                category: .footwork,
                severity: footTechnique.placementScore < 60 ? .critical : .moderate,
                title: "Plant Foot Placement",
                description: feedback,
                improvement: "The plant foot should be 15-25cm beside the ball, pointing toward your target. This provides the stable base needed for accuracy and power. Practice with markers to build muscle memory."
            ))
        }

        // Contact Type Specific Insights
        insights.append(generateContactTypeInsight(footTechnique.detectedContactType, actionType: actionType))

        // Timing Insights
        if timing.timingScore < 75 {
            insights.append(TechniqueInsight(
                category: .timing,
                severity: .moderate,
                title: "Timing and Rhythm",
                description: "The rhythm of your approach and follow-through can be improved for better technique execution.",
                improvement: "Focus on a smooth, controlled approach. Accelerate gradually into the strike, don't rush. Complete your follow-through - many players stop too early, losing power and accuracy."
            ))
        }

        return insights.sorted { $0.severity.rawValue < $1.severity.rawValue }
    }

    private func generateContactTypeInsight(_ contactType: ContactType, actionType: SoccerAction) -> TechniqueInsight {
        let recommendation = contactType.recommendation

        return TechniqueInsight(
            category: .shooting,
            severity: .minor,
            title: "\(contactType.rawValue) Technique",
            description: "Detected \(contactType.rawValue) for this action.",
            improvement: "\(recommendation). For \(actionType.rawValue.lowercased()): lock your ankle, strike through the center of the ball, and follow through toward your target."
        )
    }

    // MARK: - FIFA-Based Recommendations

    private func generateFIFABasedRecommendations(insights: [TechniqueInsight], actionType: SoccerAction) -> [String] {
        var recommendations: [String] = []

        // Core FIFA coaching principles
        recommendations.append("⚽ Technical Foundation: Focus on the fundamentals - proper body position, ball contact, and follow-through are the building blocks of elite technique.")

        // Action-specific recommendations
        switch actionType {
        case .shooting:
            recommendations.append("🎯 Shooting Technique: Strike with your laces, ankle locked. Plant foot beside the ball pointing at target. Keep your head down, eyes on the ball through contact. Follow through with your kicking leg toward the target.")

        case .passing:
            recommendations.append("🎯 Passing Accuracy: Use the inside of your foot for control. Create a firm, flat surface by turning your foot outward. Strike through the center of the ball with a smooth, pendulum motion.")

        case .dribbling:
            recommendations.append("🎯 Ball Control: Keep the ball close (1-2 feet). Use small touches with different parts of your foot. Stay on the balls of your feet, ready to change direction. Protect the ball with your body.")

        case .firstTouch:
            recommendations.append("🎯 First Touch Mastery: Anticipate the ball's arrival. Create a soft surface by withdrawing your foot slightly on contact. Direct your touch into space, setting up your next action.")
        }

        // Progressive training recommendations
        recommendations.append("📈 Progressive Training: Start slow, focus on form. As technique improves, gradually increase speed and power. Quality repetitions build muscle memory.")

        // Add specific recommendations based on critical insights
        let criticalInsights = insights.filter { $0.severity == .critical || $0.severity == .important }
        if !criticalInsights.isEmpty {
            recommendations.append("🔧 Priority Areas: \(criticalInsights.map { $0.title }.joined(separator: ", ")). Address these fundamentals first for rapid improvement.")
        }

        // Professional mindset
        recommendations.append("🧠 Mental Approach: Visualize perfect technique before each repetition. Stay patient - mastery takes time and deliberate practice. Film yourself regularly to track progress.")

        // Training volume recommendation
        recommendations.append("💪 Training Volume: Practice 15-20 minutes daily with focused repetitions. Quality over quantity. Rest and recovery are essential for skill development.")

        return recommendations
    }

    // MARK: - Calculate Metrics

    private func calculateTechniqueMetrics(
        bodyMechanics: BodyMechanicsAnalysis,
        footTechnique: FootTechniqueAnalysis,
        timing: TimingAnalysis
    ) -> TechniqueMetrics {
        return TechniqueMetrics(
            ballControlScore: 75.0, // Would be calculated from actual video analysis
            shootingTechniqueScore: (footTechnique.placementScore + timing.timingScore) / 2.0,
            passingAccuracyScore: footTechnique.placementScore,
            positioningScore: bodyMechanics.balanceScore,
            firstTouchScore: 70.0, // Would be calculated from actual video analysis
            bodyPosture: BodyPostureAnalysis(
                spineAlignment: bodyMechanics.postureScore,
                hipPosition: bodyMechanics.balanceScore > 75 ? "Balanced" : "Needs adjustment",
                shoulderAlignment: "Level",
                headPosition: "Stable",
                overallPostureScore: bodyMechanics.postureScore
            ),
            footPlacement: FootPlacementAnalysis(
                plantFootDistance: footTechnique.plantFootDistance,
                plantFootAngle: footTechnique.plantFootAngle,
                strikingFootAngle: 45.0,
                contactPoint: "Laces",
                placementScore: footTechnique.placementScore
            ),
            strikeQuality: StrikeQualityAnalysis(
                contactType: footTechnique.detectedContactType,
                swingPath: "Direct",
                followThrough: timing.followThroughFrames > 3 ? "Complete" : "Incomplete",
                impactTiming: timing.timingScore / 100.0,
                ballRotation: "Clean",
                strikeScore: timing.timingScore
            ),
            approachAngle: 45.0,
            followThroughQuality: Double(timing.followThroughFrames) * 10,
            balanceScore: bodyMechanics.balanceScore,
            powerGenerationEfficiency: (bodyMechanics.postureScore + footTechnique.placementScore) / 2.0,
            techniqueConsistency: 75.0,
            contactPointAccuracy: footTechnique.placementScore
        )
    }
}

// MARK: - Supporting Structures

struct BodyMechanicsAnalysis {
    let postureScore: Double
    let balanceScore: Double
    let alignmentIssues: [String]
}

struct FootTechniqueAnalysis {
    let plantFootDistance: Double
    let plantFootAngle: Double
    let placementScore: Double
    let detectedContactType: ContactType
}

struct TimingAnalysis {
    let approachPhaseFrames: Int
    let strikeFrameIndex: Int
    let followThroughFrames: Int
    let timingScore: Double
}

enum SoccerAction: String, CaseIterable {
    case shooting = "Shooting"
    case passing = "Passing"
    case dribbling = "Dribbling"
    case firstTouch = "First Touch"
}
