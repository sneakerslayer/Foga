import Foundation

/// Face measurement data captured from ARKit scanning
/// 
/// **Scientific Note**: Based on Farkas anthropometric standards and clinical research.
/// Primary metric: Cervico-mental angle (90-105° optimal, >120° indicates concern).
/// 3D measurements are 10x more accurate than 2D photos.
/// 
/// **Learning Note**: This stores quantitative measurements of the face.
/// These measurements help track progress over time.
public struct FaceMeasurement: Codable {
    // MARK: - Existing Properties (Maintained for backward compatibility)
    /// Width of chin area (in millimeters)
    public var chinWidth: Double
    
    /// Angle of jawline (in degrees)
    public var jawlineAngle: Double
    
    /// Circumference of neck (in millimeters)
    public var neckCircumference: Double
    
    /// Timestamp when measurement was taken
    public var timestamp: Date
    
    // MARK: - New Scientific Metrics (Farkas Anthropometric Standards)
    
    /// Cervico-mental angle - PRIMARY METRIC (in degrees)
    /// Optimal range: 90-105°, >120° indicates double chin concern
    /// This is the most scientifically validated metric for submental fat assessment
    public var cervicoMentalAngle: Double?
    
    /// Submental-cervical length (in millimeters)
    /// Distance from submental point to cervical point
    public var submentalCervicalLength: Double?
    
    /// Jaw definition index (dimensionless ratio)
    /// Calculated as: bigonial breadth / face width
    /// Higher values indicate better jaw definition
    public var jawDefinitionIndex: Double?
    
    /// Facial adiposity index (composite score, 0-100)
    /// Combines multiple measurements into single indicator
    /// Lower values indicate less facial adiposity
    public var facialAdiposityIndex: Double?
    
    // MARK: - Measurement Quality & Confidence
    
    /// Overall confidence score (0.0-1.0)
    /// 1.0 = highest confidence, <0.8 = low confidence (may need retake)
    public var confidenceScore: Double?
    
    /// Measurement quality flags
    public var qualityFlags: MeasurementQualityFlags?
    
    // MARK: - Initializers
    
    public init(
        chinWidth: Double = 0,
        jawlineAngle: Double = 0,
        neckCircumference: Double = 0,
        timestamp: Date = Date(),
        cervicoMentalAngle: Double? = nil,
        submentalCervicalLength: Double? = nil,
        jawDefinitionIndex: Double? = nil,
        facialAdiposityIndex: Double? = nil,
        confidenceScore: Double? = nil,
        qualityFlags: MeasurementQualityFlags? = nil
    ) {
        self.chinWidth = chinWidth
        self.jawlineAngle = jawlineAngle
        self.neckCircumference = neckCircumference
        self.timestamp = timestamp
        self.cervicoMentalAngle = cervicoMentalAngle
        self.submentalCervicalLength = submentalCervicalLength
        self.jawDefinitionIndex = jawDefinitionIndex
        self.facialAdiposityIndex = facialAdiposityIndex
        self.confidenceScore = confidenceScore
        self.qualityFlags = qualityFlags
    }
    
    // MARK: - Computed Properties
    
    /// Check if cervico-mental angle is in optimal range (90-105°)
    public var isCervicoMentalAngleOptimal: Bool {
        guard let angle = cervicoMentalAngle else { return false }
        return angle >= 90 && angle <= 105
    }
    
    /// Check if cervico-mental angle indicates concern (>120°)
    public var isCervicoMentalAngleConcerning: Bool {
        guard let angle = cervicoMentalAngle else { return false }
        return angle > 120
    }
    
    /// Check if measurement has sufficient confidence for use
    public var hasSufficientConfidence: Bool {
        guard let confidence = confidenceScore else { return false }
        return confidence >= 0.8
    }
    
    /// Check if measurement quality is acceptable
    public var hasAcceptableQuality: Bool {
        guard let flags = qualityFlags else { return false }
        return flags.isAcceptable
    }
    
    // MARK: - Progress Calculation
    
    /// Calculate improvement percentage compared to baseline
    /// 
    /// **Scientific Note**: Uses cervico-mental angle as primary metric if available,
    /// falls back to chinWidth for backward compatibility.
    /// 
    /// **Safety**: Validates both angles are within reasonable anatomical bounds (>50° and <180°)
    /// to prevent misleading results from invalid data.
    public func improvementPercentage(from baseline: FaceMeasurement) -> Double {
        // Prefer cervico-mental angle if both measurements have it
        if let currentAngle = cervicoMentalAngle,
           let baselineAngle = baseline.cervicoMentalAngle,
           baselineAngle > 50 && baselineAngle < 180,
           currentAngle > 50 && currentAngle < 180 {
            // Improvement = reduction in angle (closer to optimal 90-105°)
            // Note: This is simplified - actual improvement depends on starting angle
            let angleChange = baselineAngle - currentAngle
            // Normalize to percentage (assuming max improvement of 30°)
            let normalizedImprovement = (angleChange / 30.0) * 100
            return max(0, min(100, normalizedImprovement))
        }
        
        // Fallback to chinWidth for backward compatibility
        guard baseline.chinWidth > 0 else {
            return 0
        }
        
        let widthImprovement = ((baseline.chinWidth - chinWidth) / baseline.chinWidth) * 100
        return max(0, widthImprovement)
    }
}

// MARK: - Measurement Quality Flags

/// Measurement quality indicators based on capture conditions
public struct MeasurementQualityFlags: Codable {
    /// Frankfurt horizontal plane alignment (±10° deviation acceptable)
    public var frankfurtPlaneAlignment: Double // degrees deviation
    
    /// Neutral expression detected (blendshapes < 0.2)
    public var isNeutralExpression: Bool
    
    /// Lighting uniformity score (0.0-1.0, histogram analysis)
    public var lightingUniformity: Double
    
    /// Face visibility completeness (0.0-1.0)
    public var faceVisibility: Double
    
    /// Overall quality is acceptable for use
    public var isAcceptable: Bool {
        return frankfurtPlaneAlignment <= 10.0 &&
               isNeutralExpression &&
               lightingUniformity >= 0.7 &&
               faceVisibility >= 0.9
    }
    
    public init(
        frankfurtPlaneAlignment: Double = 0,
        isNeutralExpression: Bool = true,
        lightingUniformity: Double = 1.0,
        faceVisibility: Double = 1.0
    ) {
        self.frankfurtPlaneAlignment = frankfurtPlaneAlignment
        self.isNeutralExpression = isNeutralExpression
        self.lightingUniformity = lightingUniformity
        self.faceVisibility = faceVisibility
    }
}

