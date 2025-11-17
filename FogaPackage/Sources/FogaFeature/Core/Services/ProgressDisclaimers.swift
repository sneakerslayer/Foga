import Foundation

/// Service for generating honest, evidence-based disclaimers for progress predictions and measurements
/// 
/// **Critical Purpose**: Ensures all predictions and measurements include appropriate disclaimers
/// that explain limitations, individual variation, and measurement accuracy. Never promises exact results.
/// 
/// **Key Principles**:
/// - Always explain the basis of predictions (population-level data, not individual guarantees)
/// - Note individual variation (results vary significantly between people)
/// - Clarify measurement limitations (±5° accuracy, lighting/pose dependencies)
/// - Never promise fat loss or dramatic transformations
/// - Position as general wellness tool, not medical device
@MainActor
public class ProgressDisclaimers: ObservableObject {
    
    // MARK: - Disclaimer Types
    
    /// Type of disclaimer to generate
    public enum DisclaimerType {
        case measurement
        case prediction
        case progressTracking
        case generalWellness
    }
    
    // MARK: - Disclaimer Generation
    
    /// Generate disclaimer for a measurement result
    /// 
    /// - Parameters:
    ///   - measurementType: Type of measurement (e.g., "cervico-mental angle")
    ///   - confidence: Confidence score (0.0-1.0)
    ///   - angle: Measured angle value (optional, for context)
    /// - Returns: Formatted disclaimer text
    public func generateMeasurementDisclaimer(
        measurementType: String,
        confidence: Double,
        angle: Double? = nil
    ) -> String {
        var disclaimer = "Measurement Disclaimer\n\n"
        
        // Basis of measurement
        disclaimer += "This \(measurementType) measurement is calculated using ARKit's 3D face tracking technology "
        disclaimer += "with 1,220 facial mesh points. "
        
        // Accuracy information
        disclaimer += "Measurements have an accuracy of approximately ±5° and may vary based on:\n"
        disclaimer += "• Lighting conditions\n"
        disclaimer += "• Facial pose and head position\n"
        disclaimer += "• Facial expression (neutral expression recommended)\n"
        disclaimer += "• Measurement quality (Frankfurt horizontal plane alignment)\n\n"
        
        // Confidence information
        if confidence < 0.8 {
            disclaimer += "⚠️ This measurement has lower confidence (\(Int(confidence * 100))%) "
            disclaimer += "and should be interpreted with caution. "
            disclaimer += "Consider retaking the measurement under better conditions.\n\n"
        } else {
            disclaimer += "✓ This measurement has high confidence (\(Int(confidence * 100))%) "
            disclaimer += "and is reliable for tracking purposes.\n\n"
        }
        
        // Angle context (if provided)
        if let angle = angle {
            if angle >= 90 && angle <= 105 {
                disclaimer += "Your current measurement (\(Int(angle))°) is in the optimal range (90-105°).\n\n"
            } else if angle > 120 {
                disclaimer += "Your current measurement (\(Int(angle))°) indicates submental fat. "
                disclaimer += "Consider consulting with a healthcare provider about evidence-based treatment options.\n\n"
            }
        }
        
        // Limitations
        disclaimer += "Important Limitations:\n"
        disclaimer += "• Facial exercises may improve muscle tone but have no scientific evidence for fat reduction\n"
        disclaimer += "• Individual results vary significantly and are not guaranteed\n"
        disclaimer += "• This app is for general wellness purposes only and is not a medical device\n"
        disclaimer += "• For evidence-based treatments, consult with a healthcare provider"
        
        return disclaimer
    }
    
    /// Generate disclaimer for a progress prediction
    /// 
    /// - Parameters:
    ///   - timeFrame: Time frame for prediction (e.g., "3 months")
    ///   - confidenceInterval: Confidence interval range (e.g., (5.0, 15.0))
    ///   - confidence: Confidence level (0.0-1.0)
    ///   - responderType: Responder type classification (optional)
    /// - Returns: Formatted disclaimer text
    public func generatePredictionDisclaimer(
        timeFrame: String,
        confidenceInterval: (lower: Double, upper: Double),
        confidence: Double,
        responderType: String? = nil
    ) -> String {
        var disclaimer = "Prediction Disclaimer\n\n"
        
        // Basis of prediction
        disclaimer += "This prediction shows a potential improvement range of \(Int(confidenceInterval.lower))-\(Int(confidenceInterval.upper))° "
        disclaimer += "over \(timeFrame) with \(Int(confidence * 100))% confidence.\n\n"
        
        disclaimer += "Basis of Prediction:\n"
        disclaimer += "• Predictions are based on population-level data from similar users\n"
        disclaimer += "• Uses Linear Mixed-Effects model combining population trends and individual patterns\n"
        disclaimer += "• Confidence intervals account for uncertainty and individual variation\n"
        disclaimer += "• Predictions are probabilistic, not guarantees\n\n"
        
        // Responder type context (if provided)
        if let responderType = responderType {
            disclaimer += "Your Responder Type: \(responderType)\n"
            disclaimer += "This classification is based on your progress patterns. "
            disclaimer += "Responder types help set realistic expectations but do not guarantee results.\n\n"
        }
        
        // Individual variation
        disclaimer += "Individual Variation:\n"
        disclaimer += "• Results vary significantly between individuals\n"
        disclaimer += "• Some users may see faster progress, others may see slower progress\n"
        disclaimer += "• Some users may see minimal or no measurable changes\n"
        disclaimer += "• Genetic factors, age, and other variables affect outcomes\n\n"
        
        // Limitations
        disclaimer += "Important Limitations:\n"
        disclaimer += "• Facial exercises have limited scientific evidence for fat reduction\n"
        disclaimer += "• No controlled studies demonstrate fat loss from facial exercises\n"
        disclaimer += "• Predictions are estimates based on population averages, not individual guarantees\n"
        disclaimer += "• This app is for general wellness purposes only and is not a medical device\n\n"
        
        disclaimer += "For evidence-based treatments for submental fat reduction, consult with a healthcare provider."
        
        return disclaimer
    }
    
    /// Generate disclaimer for progress tracking feature
    /// 
    /// - Returns: Formatted disclaimer text
    public func generateProgressTrackingDisclaimer() -> String {
        var disclaimer = "Progress Tracking Disclaimer\n\n"
        
        disclaimer += "What This App Tracks:\n"
        disclaimer += "• Cervico-mental angle (primary metric, 90-105° optimal)\n"
        disclaimer += "• Submental-cervical length\n"
        disclaimer += "• Jaw definition index\n"
        disclaimer += "• Facial adiposity index\n\n"
        
        disclaimer += "Measurement Accuracy:\n"
        disclaimer += "• 3D measurements are 10x more accurate than 2D photos\n"
        disclaimer += "• ARKit provides ±5° accuracy for cervico-mental angle\n"
        disclaimer += "• Measurements may vary based on lighting, pose, and expression\n"
        disclaimer += "• Test-retest reliability: ICC >0.90 (highly reliable)\n\n"
        
        disclaimer += "What Changes Mean:\n"
        disclaimer += "• Improvements in measurements may reflect muscle tone changes\n"
        disclaimer += "• Changes may also reflect posture improvements or measurement variation\n"
        disclaimer += "• No scientific evidence links facial exercises to fat reduction\n"
        disclaimer += "• Individual results vary significantly\n\n"
        
        disclaimer += "Important Notes:\n"
        disclaimer += "• This app is for general wellness purposes only\n"
        disclaimer += "• Not a medical device and does not diagnose or treat medical conditions\n"
        disclaimer += "• For evidence-based treatments, consult with a healthcare provider\n"
        disclaimer += "• If you have concerns about your appearance, consider mental health resources"
        
        return disclaimer
    }
    
    /// Generate general wellness disclaimer
    /// 
    /// - Returns: Formatted disclaimer text
    public func generateGeneralWellnessDisclaimer() -> String {
        var disclaimer = "General Wellness Disclaimer\n\n"
        
        disclaimer += "App Purpose:\n"
        disclaimer += "This app is designed as a general wellness tool to help users track facial measurements "
        disclaimer += "and engage in facial exercises. It is not intended to diagnose, treat, cure, or prevent "
        disclaimer += "any medical condition.\n\n"
        
        disclaimer += "Scientific Evidence:\n"
        disclaimer += "• Facial exercises have limited scientific evidence for fat reduction\n"
        disclaimer += "• Systematic reviews found zero controlled studies supporting fat loss claims\n"
        disclaimer += "• Facial exercises may improve muscle tone but not reduce subcutaneous fat\n"
        disclaimer += "• Individual results vary significantly and are not guaranteed\n\n"
        
        disclaimer += "Measurement Limitations:\n"
        disclaimer += "• Measurements have ±5° accuracy and may vary based on conditions\n"
        disclaimer += "• Progress predictions are based on population averages, not individual guarantees\n"
        disclaimer += "• 3D measurements are more accurate than 2D photos but still have limitations\n\n"
        
        disclaimer += "Medical Advice:\n"
        disclaimer += "• This app does not provide medical advice\n"
        disclaimer += "• Consult with a healthcare provider for evidence-based treatments\n"
        disclaimer += "• If you have concerns about your appearance, consider mental health resources\n"
        disclaimer += "• For submental fat reduction, evidence-based options include:\n"
        disclaimer += "  - Deoxycholic acid injection (Kybella)\n"
        disclaimer += "  - Cryolipolysis (CoolSculpting)\n"
        disclaimer += "  - Surgical options (liposuction, neck lift)\n\n"
        
        disclaimer += "By using this app, you acknowledge that:\n"
        disclaimer += "• You understand the limitations of facial exercises\n"
        disclaimer += "• You will not rely solely on this app for medical decisions\n"
        disclaimer += "• You will consult healthcare providers for medical concerns\n"
        disclaimer += "• Results are not guaranteed and vary between individuals"
        
        return disclaimer
    }
    
    // MARK: - Context-Specific Disclaimers
    
    /// Generate disclaimer based on measurement quality
    /// 
    /// - Parameters:
    ///   - qualityFlags: Measurement quality flags
    ///   - confidence: Confidence score
    /// - Returns: Formatted disclaimer text
    public func generateQualityBasedDisclaimer(
        qualityFlags: [String],
        confidence: Double
    ) -> String {
        var disclaimer = "Measurement Quality Assessment\n\n"
        
        if qualityFlags.isEmpty && confidence >= 0.8 {
            disclaimer += "✓ High Quality Measurement\n"
            disclaimer += "This measurement meets all quality criteria:\n"
            disclaimer += "• Proper lighting conditions\n"
            disclaimer += "• Neutral facial expression\n"
            disclaimer += "• Correct head pose alignment\n"
            disclaimer += "• High confidence score (\(Int(confidence * 100))%)\n\n"
            disclaimer += "This measurement is reliable for tracking purposes."
        } else {
            disclaimer += "⚠️ Quality Issues Detected\n"
            disclaimer += "This measurement has the following quality concerns:\n"
            
            for flag in qualityFlags {
                disclaimer += "• \(flag)\n"
            }
            
            disclaimer += "\nConfidence Score: \(Int(confidence * 100))%\n\n"
            disclaimer += "Recommendations:\n"
            disclaimer += "• Retake measurement under better conditions\n"
            disclaimer += "• Ensure proper lighting and neutral expression\n"
            disclaimer += "• Align head to Frankfurt horizontal plane\n"
            disclaimer += "• This measurement may not be reliable for tracking"
        }
        
        return disclaimer
    }
    
    /// Generate disclaimer for missing data scenarios
    /// 
    /// - Parameters:
    ///   - gapDays: Number of days since last measurement
    ///   - impact: Impact on prediction uncertainty
    /// - Returns: Formatted disclaimer text
    public func generateMissingDataDisclaimer(
        gapDays: Int,
        impact: String
    ) -> String {
        var disclaimer = "Missing Data Notice\n\n"
        
        disclaimer += "Gap Detected: \(gapDays) days since last measurement\n\n"
        
        disclaimer += "Impact on Predictions:\n"
        disclaimer += "\(impact)\n\n"
        
        disclaimer += "Recommendations:\n"
        disclaimer += "• Regular measurements improve prediction accuracy\n"
        disclaimer += "• Aim for measurements every 1-2 weeks for best tracking\n"
        disclaimer += "• Missing data increases prediction uncertainty\n"
        disclaimer += "• Consider retaking baseline measurement if gap is >30 days\n\n"
        
        disclaimer += "Note: Predictions with missing data have wider confidence intervals "
        disclaimer += "and should be interpreted with greater caution."
        
        return disclaimer
    }
    
    // MARK: - Short Disclaimers (for UI cards)
    
    /// Generate short disclaimer for UI cards
    /// 
    /// - Parameter type: Type of disclaimer
    /// - Returns: Short disclaimer text (1-2 sentences)
    public func generateShortDisclaimer(for type: DisclaimerType) -> String {
        switch type {
        case .measurement:
            return "Measurements have ±5° accuracy and may vary. Facial exercises have no scientific evidence for fat reduction."
        case .prediction:
            return "Predictions are based on population averages, not individual guarantees. Results vary significantly between people."
        case .progressTracking:
            return "This app tracks measurements for wellness purposes only. Not a medical device. Consult healthcare providers for medical concerns."
        case .generalWellness:
            return "This app is for general wellness purposes only. Not a medical device. Facial exercises have limited scientific evidence."
        }
    }
}

