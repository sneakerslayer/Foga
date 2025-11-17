import Foundation
#if canImport(ARKit)
import ARKit
#endif

// MARK: - Model Metadata Input

/// User metadata for model input (6 features)
/// 
/// **Scientific Note**: Demographic and contextual information used for
/// bias mitigation and personalized predictions.
public struct ModelMetadata: Sendable {
    /// Age in years (18-80)
    public let age: Int?
    
    /// Gender identity
    public let gender: Gender?
    
    /// Body Mass Index (15-40)
    public let bmi: Double?
    
    /// Ethnicity (for bias monitoring, optional for privacy)
    public let ethnicity: Ethnicity?
    
    /// Skin tone (Fitzpatrick scale 1-6, for bias monitoring)
    public let skinTone: Int?
    
    /// Measurement context (baseline, progress, followup)
    public let measurementContext: MeasurementContext
    
    public init(
        age: Int? = nil,
        gender: Gender? = nil,
        bmi: Double? = nil,
        ethnicity: Ethnicity? = nil,
        skinTone: Int? = nil,
        measurementContext: MeasurementContext = .baseline
    ) {
        self.age = age
        self.gender = gender
        self.bmi = bmi
        self.ethnicity = ethnicity
        self.skinTone = skinTone
        self.measurementContext = measurementContext
    }
}

// MARK: - Gender Enumeration

public enum Gender: String, Codable, Sendable {
    case male
    case female
    case other
}

// MARK: - Ethnicity Enumeration

public enum Ethnicity: String, Codable, Sendable {
    case africanAmerican = "african_american"
    case asian
    case caucasian
    case hispanic
    case middleEastern = "middle_eastern"
    case nativeAmerican = "native_american"
    case pacificIslander = "pacific_islander"
    case mixed
    case other
    case preferNotToSay = "prefer_not_to_say"
}

// MARK: - Measurement Context

public enum MeasurementContext: String, Codable, Sendable {
    case baseline
    case progress
    case followup
}

// MARK: - ARKit Features Input

/// ARKit 3D measurements for model input (10 features)
/// 
/// **Scientific Note**: Extracted from ARKit face mesh (1,220 vertices).
/// These features provide precise 3D geometric information that complements
/// the 2D image analysis.
public struct ARKitFeatures: Codable {
    /// Cervico-mental angle (degrees)
    public let cervicoMentalAngle: Double?
    
    /// Submental-cervical length (millimeters)
    public let submentalCervicalLength: Double?
    
    /// Jaw definition index (dimensionless ratio)
    public let jawDefinitionIndex: Double?
    
    /// Neck circumference estimate (millimeters)
    public let neckCircumference: Double?
    
    /// Facial adiposity index (0-100 composite score)
    public let facialAdiposityIndex: Double?
    
    /// Face width (millimeters, bigonial breadth)
    public let faceWidth: Double?
    
    /// Face height (millimeters, nasion-gnathion distance)
    public let faceHeight: Double?
    
    /// Head pose pitch angle (degrees, rotation around X-axis)
    public let headPosePitch: Double?
    
    /// Head pose yaw angle (degrees, rotation around Y-axis)
    public let headPoseYaw: Double?
    
    /// Head pose roll angle (degrees, rotation around Z-axis)
    public let headPoseRoll: Double?
    
    public init(
        cervicoMentalAngle: Double? = nil,
        submentalCervicalLength: Double? = nil,
        jawDefinitionIndex: Double? = nil,
        neckCircumference: Double? = nil,
        facialAdiposityIndex: Double? = nil,
        faceWidth: Double? = nil,
        faceHeight: Double? = nil,
        headPosePitch: Double? = nil,
        headPoseYaw: Double? = nil,
        headPoseRoll: Double? = nil
    ) {
        self.cervicoMentalAngle = cervicoMentalAngle
        self.submentalCervicalLength = submentalCervicalLength
        self.jawDefinitionIndex = jawDefinitionIndex
        self.neckCircumference = neckCircumference
        self.facialAdiposityIndex = facialAdiposityIndex
        self.faceWidth = faceWidth
        self.faceHeight = faceHeight
        self.headPosePitch = headPosePitch
        self.headPoseYaw = headPoseYaw
        self.headPoseRoll = headPoseRoll
    }
    
    /// Create ARKitFeatures from FaceMeasurement and ARFaceAnchor
    /// 
    /// Convenience initializer that extracts features from existing measurement data
    #if canImport(ARKit)
    public init(from measurement: FaceMeasurement, faceAnchor: ARFaceAnchor? = nil) {
        self.cervicoMentalAngle = measurement.cervicoMentalAngle
        self.submentalCervicalLength = measurement.submentalCervicalLength
        self.jawDefinitionIndex = measurement.jawDefinitionIndex
        self.neckCircumference = measurement.neckCircumference
        self.facialAdiposityIndex = measurement.facialAdiposityIndex
        
        // Extract additional features from face anchor if available
        if let anchor = faceAnchor {
            let geometry = anchor.geometry
            let vertices = geometry.vertices
            
            // Calculate face width (bigonial breadth)
            if vertices.count > 397 && vertices.count > 172 {
                let leftJaw = vertices[172]
                let rightJaw = vertices[397]
                let dx = rightJaw.x - leftJaw.x
                let dy = rightJaw.y - leftJaw.y
                let dz = rightJaw.z - leftJaw.z
                let dx2 = dx * dx
                let dy2 = dy * dy
                let dz2 = dz * dz
                let distanceSquared: Float = dx2 + dy2 + dz2
                let distance = sqrtf(distanceSquared)
                self.faceWidth = Double(distance * 1000) // Convert to mm
            } else {
                self.faceWidth = nil
            }
            
            // Calculate face height (simplified - would use nasion-gnathion in production)
            if vertices.count > 9 {
                // Use chin point as reference
                let chinPoint = vertices[9]
                // Estimate height from mesh bounds
                let faceHeightEstimate = Double(abs(chinPoint.y) * 2000) // Rough estimate
                self.faceHeight = faceHeightEstimate
            } else {
                self.faceHeight = nil
            }
            
            // Extract head pose angles from transform
            let transform = anchor.transform
            let rotation = simd_quatf(transform)
            
            // Convert quaternion to Euler angles
            // Pitch (rotation around X-axis)
            let pitch = asin(max(-1.0, min(1.0, 2.0 * (rotation.vector.w * rotation.vector.y - rotation.vector.z * rotation.vector.x))))
            self.headPosePitch = Double(pitch * 180.0 / .pi)
            
            // Yaw (rotation around Y-axis)
            let yaw = atan2(2.0 * (rotation.vector.w * rotation.vector.z + rotation.vector.x * rotation.vector.y),
                           1.0 - 2.0 * (rotation.vector.y * rotation.vector.y + rotation.vector.z * rotation.vector.z))
            self.headPoseYaw = Double(yaw * 180.0 / .pi)
            
            // Roll (rotation around Z-axis)
            let roll = atan2(2.0 * (rotation.vector.w * rotation.vector.x + rotation.vector.y * rotation.vector.z),
                           1.0 - 2.0 * (rotation.vector.x * rotation.vector.x + rotation.vector.y * rotation.vector.y))
            self.headPoseRoll = Double(roll * 180.0 / .pi)
        } else {
            self.faceWidth = nil
            self.faceHeight = nil
            self.headPosePitch = nil
            self.headPoseYaw = nil
            self.headPoseRoll = nil
        }
    }
    #else
    public init(from measurement: FaceMeasurement, faceAnchor: Any? = nil) {
        self.cervicoMentalAngle = measurement.cervicoMentalAngle
        self.submentalCervicalLength = measurement.submentalCervicalLength
        self.jawDefinitionIndex = measurement.jawDefinitionIndex
        self.neckCircumference = measurement.neckCircumference
        self.facialAdiposityIndex = measurement.facialAdiposityIndex
        
        // ARKit not available - set all ARKit-derived features to nil
        self.faceWidth = nil
        self.faceHeight = nil
        self.headPosePitch = nil
        self.headPoseYaw = nil
        self.headPoseRoll = nil
    }
    #endif
}

