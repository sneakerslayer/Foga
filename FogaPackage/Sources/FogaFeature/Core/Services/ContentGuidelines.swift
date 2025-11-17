import Foundation

/// Service for enforcing content guidelines to ensure ethical messaging
/// 
/// **Critical Purpose**: Ensures all app content follows ethical guidelines:
/// - Never promises dramatic transformations
/// - Avoids unrealistic before/after photos
/// - Includes diverse body types
/// - Frames as wellness journey, not medical treatment
/// - Provides honest disclaimers about evidence limitations
/// 
/// **Guidelines Enforced**:
/// - No promises of fat loss (frame as muscle toning and wellness)
/// - No unrealistic before/after comparisons
/// - Diverse representation in imagery
/// - Scientific transparency about limitations
/// - Age-appropriate content
@MainActor
public class ContentGuidelines {
    
    // MARK: - Content Types
    
    /// Type of content being validated
    public enum ContentType: String, Codable, Sendable {
        case exerciseDescription = "exercise_description"
        case progressPrediction = "progress_prediction"
        case beforeAfterPhoto = "before_after_photo"
        case marketingCopy = "marketing_copy"
        case goalDescription = "goal_description"
        case measurementResult = "measurement_result"
        case appDescription = "app_description"
    }
    
    /// Content validation result
    public struct ValidationResult: Sendable {
        public let isValid: Bool
        public let violations: [ContentViolation]
        public let suggestions: [String]
        
        public init(
            isValid: Bool,
            violations: [ContentViolation] = [],
            suggestions: [String] = []
        ) {
            self.isValid = isValid
            self.violations = violations
            self.suggestions = suggestions
        }
    }
    
    /// Content violation detected
    public struct ContentViolation: Identifiable, Sendable {
        public let id: UUID
        public let type: ViolationType
        public let severity: ViolationSeverity
        public let message: String
        public let location: String? // Where in content the violation occurs
        
        public init(
            id: UUID = UUID(),
            type: ViolationType,
            severity: ViolationSeverity,
            message: String,
            location: String? = nil
        ) {
            self.id = id
            self.type = type
            self.severity = severity
            self.message = message
            self.location = location
        }
    }
    
    /// Type of content violation
    public enum ViolationType: String, Codable, Sendable {
        case promisesFatLoss = "promises_fat_loss"
        case unrealisticTransformation = "unrealistic_transformation"
        case medicalClaims = "medical_claims"
        case missingDisclaimer = "missing_disclaimer"
        case lacksDiversity = "lacks_diversity"
        case ageInappropriate = "age_inappropriate"
        case falsePrecision = "false_precision"
        case missingConfidenceIntervals = "missing_confidence_intervals"
    }
    
    /// Severity of violation
    public enum ViolationSeverity: String, Codable, Sendable {
        case critical = "critical" // Must fix before publishing
        case high = "high" // Should fix
        case medium = "medium" // Consider fixing
        case low = "low" // Minor issue
    }
    
    // MARK: - Prohibited Phrases
    
    /// Phrases that promise fat loss (prohibited)
    private static let prohibitedFatLossPhrases: [String] = [
        "lose fat",
        "fat reduction",
        "burn fat",
        "melt away fat",
        "eliminate fat",
        "remove fat",
        "get rid of fat",
        "fat loss",
        "reduce fat",
        "fat burning",
        "shed fat",
        "fat elimination"
    ]
    
    /// Phrases that promise dramatic transformations (prohibited)
    private static let prohibitedTransformationPhrases: [String] = [
        "dramatic transformation",
        "extreme makeover",
        "complete transformation",
        "miraculous results",
        "instant results",
        "guaranteed results",
        "guaranteed transformation",
        "overnight results",
        "quick fix",
        "easy solution"
    ]
    
    /// Phrases that make medical claims (prohibited)
    private static let prohibitedMedicalPhrases: [String] = [
        "treat",
        "cure",
        "diagnose",
        "prevent",
        "heal",
        "medical treatment",
        "clinical treatment",
        "therapeutic",
        "prescription",
        "doctor recommended",
        "clinically proven" // Only if not backed by actual clinical studies
    ]
    
    /// Phrases that promise exact results (prohibited)
    private static let prohibitedExactResultPhrases: [String] = [
        "exactly",
        "precisely",
        "guaranteed",
        "100% certain",
        "definitely will",
        "will definitely",
        "promised results"
    ]
    
    // MARK: - Required Phrases
    
    /// Phrases that should be included (wellness framing)
    private static let recommendedWellnessPhrases: [String] = [
        "wellness",
        "muscle toning",
        "facial fitness",
        "general wellness",
        "wellness journey"
    ]
    
    /// Phrases that should be included (disclaimers)
    private static let recommendedDisclaimerPhrases: [String] = [
        "not a medical device",
        "not medical treatment",
        "consult healthcare provider",
        "individual results may vary",
        "confidence interval",
        "may vary"
    ]
    
    // MARK: - Content Validation
    
    /// Validate content against guidelines
    /// 
    /// - Parameters:
    ///   - content: Content text to validate
    ///   - contentType: Type of content being validated
    /// - Returns: Validation result with violations and suggestions
    public static func validateContent(_ content: String, contentType: ContentType) -> ValidationResult {
        var violations: [ContentViolation] = []
        var suggestions: [String] = []
        
        let lowercasedContent = content.lowercased()
        
        // Check for prohibited fat loss promises
        for phrase in prohibitedFatLossPhrases {
            if lowercasedContent.contains(phrase) {
                violations.append(ContentViolation(
                    type: .promisesFatLoss,
                    severity: .critical,
                    message: "Content promises fat loss. Frame as muscle toning and wellness instead.",
                    location: findPhraseLocation(content: content, phrase: phrase)
                ))
            }
        }
        
        // Check for unrealistic transformations
        for phrase in prohibitedTransformationPhrases {
            if lowercasedContent.contains(phrase) {
                violations.append(ContentViolation(
                    type: .unrealisticTransformation,
                    severity: .high,
                    message: "Content promises dramatic or unrealistic transformations. Use realistic expectations.",
                    location: findPhraseLocation(content: content, phrase: phrase)
                ))
            }
        }
        
        // Check for medical claims
        for phrase in prohibitedMedicalPhrases {
            if lowercasedContent.contains(phrase) {
                violations.append(ContentViolation(
                    type: .medicalClaims,
                    severity: .critical,
                    message: "Content makes medical claims. This app is not a medical device.",
                    location: findPhraseLocation(content: content, phrase: phrase)
                ))
            }
        }
        
        // Check for exact result promises
        for phrase in prohibitedExactResultPhrases {
            if lowercasedContent.contains(phrase) {
                violations.append(ContentViolation(
                    type: .falsePrecision,
                    severity: .high,
                    message: "Content promises exact results. Always use confidence intervals and ranges.",
                    location: findPhraseLocation(content: content, phrase: phrase)
                ))
            }
        }
        
        // Check for missing disclaimers (required for certain content types)
        if requiresDisclaimer(contentType: contentType) {
            let hasDisclaimer = recommendedDisclaimerPhrases.contains { phrase in
                lowercasedContent.contains(phrase)
            }
            
            if !hasDisclaimer {
                violations.append(ContentViolation(
                    type: .missingDisclaimer,
                    severity: .high,
                    message: "Content should include disclaimer about app limitations and healthcare provider consultation.",
                    location: nil
                ))
            }
        }
        
        // Check for wellness framing (recommended)
        let hasWellnessFraming = recommendedWellnessPhrases.contains { phrase in
            lowercasedContent.contains(phrase)
        }
        
        if !hasWellnessFraming && contentType != .measurementResult {
            suggestions.append("Consider framing content around wellness and muscle toning rather than fat reduction.")
        }
        
        // Generate suggestions based on violations
        if violations.isEmpty {
            suggestions.append("Content follows ethical guidelines.")
        } else {
            suggestions.append("Review violations and update content to comply with guidelines.")
        }
        
        let isValid = violations.filter { $0.severity == .critical || $0.severity == .high }.isEmpty
        
        return ValidationResult(
            isValid: isValid,
            violations: violations,
            suggestions: suggestions
        )
    }
    
    /// Check if content type requires disclaimer
    private static func requiresDisclaimer(contentType: ContentType) -> Bool {
        switch contentType {
        case .progressPrediction, .beforeAfterPhoto, .marketingCopy, .appDescription:
            return true
        case .exerciseDescription, .goalDescription, .measurementResult:
            return false
        }
    }
    
    /// Find location of phrase in content (for highlighting)
    private static func findPhraseLocation(content: String, phrase: String) -> String? {
        if let range = content.lowercased().range(of: phrase.lowercased()) {
            let startIndex = content.distance(from: content.startIndex, to: range.lowerBound)
            let endIndex = content.distance(from: content.startIndex, to: range.upperBound)
            return "Position \(startIndex)-\(endIndex)"
        }
        return nil
    }
    
    // MARK: - Content Templates
    
    /// Get approved exercise description template
    public static func getExerciseDescriptionTemplate() -> String {
        return """
        This exercise focuses on toning facial muscles and improving overall facial fitness.
        Regular practice may help improve muscle definition and facial wellness.
        
        Remember: Individual results may vary. This is a general wellness tool, not medical treatment.
        Consult with a healthcare provider if you have concerns about your facial health.
        """
    }
    
    /// Get approved progress prediction template
    public static func getProgressPredictionTemplate() -> String {
        return """
        Based on population-level data, you may see improvement in the range of X-Y degrees over Z months (N% confidence).
        
        Individual results vary significantly. This prediction is based on population averages and may not reflect your personal experience.
        This app is not a medical device and does not guarantee specific results.
        
        Consult with a healthcare provider for personalized guidance.
        """
    }
    
    /// Get approved goal description template
    public static func getGoalDescriptionTemplate() -> String {
        return """
        This goal focuses on facial muscle toning and general wellness through facial exercises.
        
        Note: Facial exercises are designed for muscle toning and wellness, not fat reduction.
        Individual results may vary. Consult with a healthcare provider about your wellness goals.
        """
    }
    
    /// Get approved measurement result template
    public static func getMeasurementResultTemplate() -> String {
        return """
        Your current measurement: [value] (confidence: [confidence]%)
        
        Optimal range: 90-105 degrees. Measurements may vary based on lighting, pose, and other factors.
        This measurement is for general wellness tracking only and is not a medical diagnosis.
        """
    }
    
    /// Get approved app description template
    public static func getAppDescriptionTemplate() -> String {
        return """
        Foga is a general wellness app designed to help with facial muscle toning and facial fitness through guided exercises.
        
        Important: This app is not a medical device. It does not diagnose, treat, cure, or prevent any disease or condition.
        Facial exercises have limited scientific evidence for fat reduction. This app focuses on muscle toning and wellness.
        
        Individual results may vary. Consult with a healthcare provider if you have concerns about your facial health or body image.
        """
    }
    
    // MARK: - Content Sanitization
    
    /// Sanitize content to comply with guidelines
    /// 
    /// - Parameters:
    ///   - content: Original content
    ///   - contentType: Type of content
    /// - Returns: Sanitized content that complies with guidelines
    public static func sanitizeContent(_ content: String, contentType: ContentType) -> String {
        var sanitized = content
        let lowercased = sanitized.lowercased()
        
        // Replace prohibited fat loss phrases
        for phrase in prohibitedFatLossPhrases {
            if lowercased.contains(phrase) {
                sanitized = sanitized.replacingOccurrences(
                    of: phrase,
                    with: "muscle toning",
                    options: .caseInsensitive
                )
            }
        }
        
        // Replace prohibited transformation phrases
        for phrase in prohibitedTransformationPhrases {
            if lowercased.contains(phrase) {
                sanitized = sanitized.replacingOccurrences(
                    of: phrase,
                    with: "wellness journey",
                    options: .caseInsensitive
                )
            }
        }
        
        // Add disclaimer if required
        if requiresDisclaimer(contentType: contentType) {
            let hasDisclaimer = recommendedDisclaimerPhrases.contains { phrase in
                sanitized.lowercased().contains(phrase)
            }
            
            if !hasDisclaimer {
                sanitized += "\n\nNote: This app is for general wellness only and is not a medical device. Individual results may vary. Consult with a healthcare provider for personalized guidance."
            }
        }
        
        return sanitized
    }
    
    // MARK: - Diversity Guidelines
    
    /// Check if content includes diverse representation
    /// 
    /// **Note**: This is a placeholder for future image analysis.
    /// In production, would use image analysis to verify diverse representation.
    /// 
    /// - Parameter imageURLs: URLs of images in content
    /// - Returns: Whether content includes diverse representation
    public static func checkDiversityRepresentation(imageURLs: [String]) -> Bool {
        // Placeholder: In production, would analyze images for diversity
        // For now, assume diverse if multiple images provided
        return imageURLs.count >= 3
    }
    
    /// Get diversity guidelines message
    public static func getDiversityGuidelinesMessage() -> String {
        return """
        Content should include diverse representation:
        - Different skin tones
        - Different ages
        - Different genders
        - Different body types
        - Different ethnicities
        
        Avoid using only one demographic group in imagery or examples.
        """
    }
    
    // MARK: - Age Appropriateness
    
    /// Check if content is age-appropriate
    /// 
    /// - Parameters:
    ///   - content: Content to check
    ///   - targetAge: Target age group
    /// - Returns: Whether content is age-appropriate
    public static func isAgeAppropriate(content: String, targetAge: Int) -> Bool {
        // Content should be appropriate for all ages
        // Additional safeguards for users under 25
        if targetAge < 18 {
            // Should not be accessible to minors without parental consent
            return false
        }
        
        // Check for age-inappropriate language
        let lowercased = content.lowercased()
        let inappropriatePhrases = [
            "extreme",
            "radical",
            "drastic"
        ]
        
        for phrase in inappropriatePhrases {
            if lowercased.contains(phrase) && targetAge < 25 {
                return false
            }
        }
        
        return true
    }
}

