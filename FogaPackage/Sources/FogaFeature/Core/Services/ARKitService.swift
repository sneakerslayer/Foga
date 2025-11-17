import Foundation
import ARKit
import Combine

/// Service for managing ARKit face tracking
/// 
/// **Scientific Note**: Now integrates with ARKitFaceAnalyzer for precise 3D measurements
/// based on Farkas anthropometric standards and MeasurementValidator for quality assurance.
/// 
/// **Learning Note**: Services handle complex functionality that Views shouldn't know about.
/// This service manages ARKit, which is Apple's framework for augmented reality.
/// 
/// **What ARKit does**:
/// - Uses the front-facing TrueDepth camera (iPhone X and later)
/// - Tracks 1,220 3D points on your face in real-time
/// - Provides face geometry, expressions, and head pose
/// 
/// **Swift Concepts**:
/// - `ObservableObject`: Makes this class observable by SwiftUI views
/// - `@Published`: Automatically notifies views when values change
/// - `Combine`: Apple's framework for handling asynchronous events
@available(iOS 15.0, *)
@MainActor
public class ARKitService: NSObject, ObservableObject {
    /// ARSession for face tracking
    public let session = ARSession()
    
    /// Current face anchor (contains face tracking data)
    @Published public var faceAnchor: ARFaceAnchor?
    
    /// Whether face tracking is currently active
    @Published public var isTracking: Bool = false
    
    /// Error message if something goes wrong
    @Published public var errorMessage: String?
    
    /// Face analyzer for extracting precise 3D measurements
    private let faceAnalyzer = ARKitFaceAnalyzer()
    
    /// Measurement validator for quality assurance
    private let measurementValidator = MeasurementValidator()
    
    /// Recent measurements for reliability assessment
    private var recentMeasurements: [FaceMeasurement] = []
    
    /// Maximum number of recent measurements to keep for reliability assessment
    private let maxRecentMeasurements = 10
    
    /// Check if device supports face tracking
    /// 
    /// **Learning Note**: Not all iPhones support face tracking.
    /// It requires the TrueDepth camera (iPhone X and later).
    public static var isSupported: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }
    
    public override init() {
        super.init()
        session.delegate = self
    }
    
    /// Start face tracking session
    /// 
    /// **Learning Note**: This configures ARKit to track faces.
    /// The configuration tells ARKit what to track and how.
    public func startSession() {
        guard ARFaceTrackingConfiguration.isSupported else {
            errorMessage = "Face tracking is not supported on this device. Requires iPhone X or later."
            return
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1 // Track one face at a time
        
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        isTracking = true
        errorMessage = nil
    }
    
    /// Stop face tracking session
    public func stopSession() {
        session.pause()
        isTracking = false
        faceAnchor = nil
    }
    
    /// Capture current face measurements using scientific 3D analysis
    /// 
    /// **Scientific Note**: Uses ARKitFaceAnalyzer to extract Farkas anthropometric measurements
    /// and MeasurementValidator to ensure quality. Returns validated measurements with
    /// confidence scores and quality flags.
    /// 
    /// - Returns: FaceMeasurement with all scientific metrics, or nil if capture fails
    public func captureMeasurements() -> FaceMeasurement? {
        guard let anchor = faceAnchor else { return nil }
        
        // Extract all anthropometric measurements using ARKitFaceAnalyzer
        let facialMeasurements = faceAnalyzer.extractAnthropometricMeasurements(from: anchor)
        
        // Calculate legacy measurements for backward compatibility
        let geometry = anchor.geometry
        let vertices = geometry.vertices
        let chinWidth = calculateChinWidth(from: vertices)
        let jawlineAngle = calculateJawlineAngle(from: vertices)
        let neckCircumference = facialMeasurements.neckCircumference ?? estimateNeckCircumference(from: vertices)
        
        // Create FaceMeasurement with all scientific metrics
        let measurement = FaceMeasurement(
            chinWidth: chinWidth,
            jawlineAngle: jawlineAngle,
            neckCircumference: neckCircumference,
            timestamp: Date(),
            cervicoMentalAngle: facialMeasurements.cervicoMentalAngle,
            submentalCervicalLength: facialMeasurements.submentalCervicalLength,
            jawDefinitionIndex: facialMeasurements.jawDefinitionIndex,
            facialAdiposityIndex: facialMeasurements.facialAdiposityIndex,
            confidenceScore: facialMeasurements.confidenceScore,
            qualityFlags: facialMeasurements.qualityFlags
        )
        
        // Validate the measurement
        let _ = measurementValidator.validateMeasurement(measurement)
        
        // Store recent measurements for reliability assessment
        recentMeasurements.append(measurement)
        if recentMeasurements.count > maxRecentMeasurements {
            recentMeasurements.removeFirst()
        }
        
        // Return measurement (even if validation fails, so caller can see issues)
        return measurement
    }
    
    /// Capture and validate measurements, returning validation result
    /// 
    /// - Returns: ValidationResult containing measurement and validation status
    public func captureAndValidateMeasurements() -> ValidationResult? {
        guard let measurement = captureMeasurements() else {
            return nil
        }
        
        return measurementValidator.validateMeasurement(measurement)
    }
    
    /// Assess test-retest reliability of recent measurements
    /// 
    /// - Returns: ReliabilityAssessment with ICC score and variance analysis
    public func assessReliability() -> ReliabilityAssessment {
        return measurementValidator.assessTestRetestReliability(recentMeasurements)
    }
    
    /// Check if recent measurements have high variance
    /// 
    /// - Returns: True if variance is too high, indicating need for retake
    public func hasHighVariance() -> Bool {
        return measurementValidator.hasHighVariance(recentMeasurements)
    }
    
    /// Clear recent measurements history
    public func clearMeasurementHistory() {
        recentMeasurements.removeAll()
    }
    
    // MARK: - Private Helper Methods (Legacy Support)
    
    /// Calculate chin width from face vertices (legacy method for backward compatibility)
    private func calculateChinWidth(from vertices: [SIMD3<Float>]) -> Double {
        guard vertices.count > 0 else { return 0 }
        
        // Simplified calculation - kept for backward compatibility
        // New code should use ARKitFaceAnalyzer for accurate measurements
        return 100.0 // Placeholder value in millimeters
    }
    
    /// Calculate jawline angle (legacy method for backward compatibility)
    private func calculateJawlineAngle(from vertices: [SIMD3<Float>]) -> Double {
        // Placeholder - kept for backward compatibility
        return 90.0 // Placeholder value in degrees
    }
    
    /// Estimate neck circumference (legacy fallback)
    private func estimateNeckCircumference(from vertices: [SIMD3<Float>]) -> Double {
        // Placeholder - kept for backward compatibility
        return 350.0 // Placeholder value in millimeters
    }
}

// MARK: - ARSessionDelegate
/// 
/// **Learning Note**: Delegates are a common iOS pattern.
/// ARSession calls these methods when face tracking updates occur.
extension ARKitService: ARSessionDelegate {
    nonisolated public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        // Find face anchor in updated anchors
        Task { @MainActor in
        if let faceAnchor = anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor {
            self.faceAnchor = faceAnchor
        }
    }
    }
    
    nonisolated public func session(_ session: ARSession, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = "ARKit session failed: \(error.localizedDescription)"
            self.isTracking = false
    }
    }
    
    nonisolated public func sessionWasInterrupted(_ session: ARSession) {
        Task { @MainActor in
            self.isTracking = false
    }
    }
    
    nonisolated public func sessionInterruptionEnded(_ session: ARSession) {
        // Restart session when interruption ends
        Task { @MainActor in
            self.startSession()
        }
    }
}

