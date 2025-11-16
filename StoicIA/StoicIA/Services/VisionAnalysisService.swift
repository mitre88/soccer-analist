//
//  VisionAnalysisService.swift
//  Stoic IA
//
//  Vision framework integration for real-time video analysis
//

import Foundation
import Vision
import AVFoundation
import CoreML
import UIKit

@MainActor
class VisionAnalysisService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var progress: Double = 0.0
    @Published var currentFrame: Int = 0
    @Published var totalFrames: Int = 0

    private var frameAnalysisResults: [FrameAnalysis] = []

    // MARK: - Video Analysis

    func analyzeVideo(at url: URL) async throws -> VideoAnalysisData {
        isAnalyzing = true
        progress = 0.0

        let asset = AVAsset(url: url)
        let duration = try await asset.load(.duration)
        let videoTrack = try await asset.loadTracks(withMediaType: .video).first

        guard let track = videoTrack else {
            throw AnalysisError.noVideoTrack
        }

        // Extract frames at key intervals
        let frames = try await extractKeyFrames(from: asset, track: track)
        totalFrames = frames.count

        // Analyze each frame using Vision
        for (index, frame) in frames.enumerated() {
            currentFrame = index + 1
            let frameAnalysis = try await analyzeFrame(frame, timestamp: Double(index) / 30.0)
            frameAnalysisResults.append(frameAnalysis)
            progress = Double(index + 1) / Double(frames.count)
        }

        // Compile results
        let analysisData = compileAnalysisData(from: frameAnalysisResults)
        isAnalyzing = false

        return analysisData
    }

    // MARK: - Frame Extraction

    private func extractKeyFrames(from asset: AVAsset, track: AVAssetTrack) async throws -> [CGImage] {
        var frames: [CGImage] = []
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero

        let duration = try await asset.load(.duration)
        let frameInterval: Double = 0.1 // Extract frame every 0.1 seconds

        var currentTime: Double = 0
        while currentTime < CMTimeGetSeconds(duration) {
            let time = CMTime(seconds: currentTime, preferredTimescale: 600)
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                frames.append(cgImage)
            } catch {
                print("Failed to extract frame at \(currentTime)s: \(error)")
            }
            currentTime += frameInterval
        }

        return frames
    }

    // MARK: - Frame Analysis with Vision

    private func analyzeFrame(_ image: CGImage, timestamp: Double) async throws -> FrameAnalysis {
        return try await withCheckedThrowingContinuation { continuation in
            // Person detection
            let personRequest = VNDetectHumanBodyPoseRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNHumanBodyPoseObservation],
                      let observation = observations.first else {
                    continuation.resume(returning: FrameAnalysis(
                        timestamp: timestamp,
                        bodyPose: nil,
                        ballDetected: false,
                        ballPosition: nil,
                        footPosition: nil,
                        bodyAlignment: nil
                    ))
                    return
                }

                // Extract body pose information
                let bodyPose = self.extractBodyPose(from: observation)

                // Detect ball (using object detection)
                self.detectBall(in: image) { ballInfo in
                    let frameAnalysis = FrameAnalysis(
                        timestamp: timestamp,
                        bodyPose: bodyPose,
                        ballDetected: ballInfo.detected,
                        ballPosition: ballInfo.position,
                        footPosition: self.extractFootPosition(from: observation),
                        bodyAlignment: self.calculateBodyAlignment(from: observation)
                    )
                    continuation.resume(returning: frameAnalysis)
                }
            }

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([personRequest])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Body Pose Extraction

    private func extractBodyPose(from observation: VNHumanBodyPoseObservation) -> BodyPoseData {
        var joints: [String: CGPoint] = [:]

        // Extract key joints
        let jointNames: [VNHumanBodyPoseObservation.JointName] = [
            .neck, .leftShoulder, .rightShoulder,
            .leftHip, .rightHip,
            .leftKnee, .rightKnee,
            .leftAnkle, .rightAnkle
        ]

        for jointName in jointNames {
            if let joint = try? observation.recognizedPoint(jointName),
               joint.confidence > 0.3 {
                joints[jointName.rawValue.rawValue] = joint.location
            }
        }

        return BodyPoseData(
            joints: joints,
            confidence: observation.confidence
        )
    }

    private func extractFootPosition(from observation: VNHumanBodyPoseObservation) -> FootPositionData? {
        guard let leftAnkle = try? observation.recognizedPoint(.leftAnkle),
              let rightAnkle = try? observation.recognizedPoint(.rightAnkle),
              leftAnkle.confidence > 0.3 || rightAnkle.confidence > 0.3 else {
            return nil
        }

        return FootPositionData(
            leftFoot: leftAnkle.confidence > 0.3 ? leftAnkle.location : nil,
            rightFoot: rightAnkle.confidence > 0.3 ? rightAnkle.location : nil
        )
    }

    private func calculateBodyAlignment(from observation: VNHumanBodyPoseObservation) -> BodyAlignmentData? {
        guard let neck = try? observation.recognizedPoint(.neck),
              let leftHip = try? observation.recognizedPoint(.leftHip),
              let rightHip = try? observation.recognizedPoint(.rightHip),
              neck.confidence > 0.3 && leftHip.confidence > 0.3 && rightHip.confidence > 0.3 else {
            return nil
        }

        let hipCenter = CGPoint(
            x: (leftHip.location.x + rightHip.location.x) / 2,
            y: (leftHip.location.y + rightHip.location.y) / 2
        )

        let spineAngle = atan2(neck.location.y - hipCenter.y, neck.location.x - hipCenter.x) * 180 / .pi

        return BodyAlignmentData(
            spineAngle: spineAngle,
            hipAlignment: abs(leftHip.location.y - rightHip.location.y),
            isBalanced: abs(leftHip.location.y - rightHip.location.y) < 0.05
        )
    }

    // MARK: - Ball Detection

    private func detectBall(in image: CGImage, completion: @escaping (BallDetectionInfo) -> Void) {
        // Use object detection to find the soccer ball
        let request = VNDetectRectanglesRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRectangleObservation] else {
                completion(BallDetectionInfo(detected: false, position: nil, confidence: 0))
                return
            }

            // Find circular objects that could be the ball
            // This is a simplified version - in production, use custom Core ML model
            if let ballObservation = observations.first {
                completion(BallDetectionInfo(
                    detected: true,
                    position: CGPoint(
                        x: ballObservation.boundingBox.midX,
                        y: ballObservation.boundingBox.midY
                    ),
                    confidence: ballObservation.confidence
                ))
            } else {
                completion(BallDetectionInfo(detected: false, position: nil, confidence: 0))
            }
        }

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
    }

    // MARK: - Compile Analysis Data

    private func compileAnalysisData(from frames: [FrameAnalysis]) -> VideoAnalysisData {
        let detectedFrames = frames.filter { $0.bodyPose != nil }

        return VideoAnalysisData(
            frameAnalyses: frames,
            totalFrames: frames.count,
            framesWithPerson: detectedFrames.count,
            framesWithBall: frames.filter { $0.ballDetected }.count,
            averageConfidence: detectedFrames.reduce(0.0) { $0 + ($1.bodyPose?.confidence ?? 0) } / Double(max(detectedFrames.count, 1))
        )
    }
}

// MARK: - Supporting Data Structures

struct FrameAnalysis {
    let timestamp: Double
    let bodyPose: BodyPoseData?
    let ballDetected: Bool
    let ballPosition: CGPoint?
    let footPosition: FootPositionData?
    let bodyAlignment: BodyAlignmentData?
}

struct BodyPoseData {
    let joints: [String: CGPoint]
    let confidence: Float
}

struct FootPositionData {
    let leftFoot: CGPoint?
    let rightFoot: CGPoint?
}

struct BodyAlignmentData {
    let spineAngle: Double
    let hipAlignment: Double
    let isBalanced: Bool
}

struct BallDetectionInfo {
    let detected: Bool
    let position: CGPoint?
    let confidence: Float
}

struct VideoAnalysisData {
    let frameAnalyses: [FrameAnalysis]
    let totalFrames: Int
    let framesWithPerson: Int
    let framesWithBall: Int
    let averageConfidence: Double
}

enum AnalysisError: Error {
    case noVideoTrack
    case analysisFailedcase invalidVideo
    case visionError(Error)
}
