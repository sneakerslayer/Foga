import Foundation

// MARK: - Prediction Result

/// Model prediction output with uncertainty quantification
/// 
/// **Scientific Note**: Always includes confidence intervals to avoid false precision.
/// Never promises exact results - predictions are probabilistic.
public struct PredictionResult: Sendable {
    /// Predicted cervico-mental angle (degrees)
    public let cervicoMentalAngle: Double
    
    /// Confidence interval for angle prediction (lower, upper)
    /// Represents 95% confidence interval
    public let angleConfidenceInterval: (lower: Double, upper: Double)
    
    /// Fat category classification
    public let fatCategory: FatCategory
    
    /// Confidence score for category classification (0.0-1.0)
    public let categoryConfidence: Double
    
    /// Overall prediction confidence (0.0-1.0)
    /// Combines angle and category confidence
    public let overallConfidence: Double
    
    /// Uncertainty quantification (0.0-1.0)
    /// Higher values indicate more uncertainty in prediction
    public let uncertainty: Double
    
    public init(
        cervicoMentalAngle: Double,
        angleConfidenceInterval: (lower: Double, upper: Double),
        fatCategory: FatCategory,
        categoryConfidence: Double,
        overallConfidence: Double,
        uncertainty: Double
    ) {
        self.cervicoMentalAngle = cervicoMentalAngle
        self.angleConfidenceInterval = angleConfidenceInterval
        self.fatCategory = fatCategory
        self.categoryConfidence = categoryConfidence
        self.overallConfidence = overallConfidence
        self.uncertainty = uncertainty
    }
    
    // MARK: - Computed Properties
    
    /// Check if angle is in optimal range (90-105°)
    public var isAngleOptimal: Bool {
        return cervicoMentalAngle >= 90 && cervicoMentalAngle <= 105
    }
    
    /// Check if angle indicates concern (>120°)
    public var isAngleConcerning: Bool {
        return cervicoMentalAngle > 120
    }
    
    /// Angle range string for display (e.g., "95-105°")
    public var angleRangeString: String {
        let lower = Int(angleConfidenceInterval.lower)
        let upper = Int(angleConfidenceInterval.upper)
        return "\(lower)-\(upper)°"
    }
    
    /// Formatted prediction string for UI
    /// Example: "95-105° (80% confidence)"
    public var formattedPrediction: String {
        return "\(angleRangeString) (\(Int(overallConfidence * 100))% confidence)"
    }
}

// MARK: - Fat Category

/// Facial fat category classification
/// 
/// **Scientific Note**: Categories are based on cervico-mental angle ranges
/// and validated against clinical assessment standards.
public enum FatCategory: String, Codable, Sendable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    
    /// Display name for UI
    public var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .moderate:
            return "Moderate"
        case .high:
            return "High"
        }
    }
    
    /// Description for user education
    public var description: String {
        switch self {
        case .low:
            return "Minimal submental fat. Angle is in optimal range."
        case .moderate:
            return "Moderate submental fat. Some improvement possible."
        case .high:
            return "Significant submental fat. Consider consultation with healthcare provider."
        }
    }
    
    /// Color for UI display
    public var colorHex: String {
        switch self {
        case .low:
            return "#4ECDC4" // Teal (good)
        case .moderate:
            return "#FFD93D" // Yellow (moderate)
        case .high:
            return "#FF6B6B" // Coral (concern)
        }
    }
    
    /// Initialize from cervico-mental angle
    /// 
    /// - Parameter angle: Cervico-mental angle in degrees
    public init(from angle: Double) {
        if angle < 100 {
            self = .low
        } else if angle <= 120 {
            self = .moderate
        } else {
            self = .high
        }
    }
}

// MARK: - Model Performance Metrics

/// Model performance metrics for bias monitoring
/// 
/// **Scientific Note**: Used to track model accuracy across demographic groups
/// and ensure fairness (>95% accuracy, <5% gap between groups).
public struct ModelPerformanceMetrics {
    /// Overall accuracy (0.0-1.0)
    public let overallAccuracy: Double
    
    /// Accuracy by demographic group
    public let accuracyByGroup: [String: Double]
    
    /// Maximum gap between best and worst performing groups
    public let maxAccuracyGap: Double
    
    /// Number of predictions used for metrics
    public let sampleSize: Int
    
    /// Whether metrics meet fairness criteria
    public var meetsFairnessCriteria: Bool {
        return overallAccuracy >= 0.95 && maxAccuracyGap <= 0.05
    }
    
    public init(
        overallAccuracy: Double,
        accuracyByGroup: [String: Double],
        maxAccuracyGap: Double,
        sampleSize: Int
    ) {
        self.overallAccuracy = overallAccuracy
        self.accuracyByGroup = accuracyByGroup
        self.maxAccuracyGap = maxAccuracyGap
        self.sampleSize = sampleSize
    }
}


