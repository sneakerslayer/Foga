import Foundation

/// Service for managing age restrictions and age-based safeguards
/// 
/// **Critical Purpose**: Implements age verification and stricter safeguards for younger users.
/// Research shows users under 25 are at higher risk for body dysmorphia and eating disorders.
/// 
/// **Age-Based Safeguards**:
/// - 18+ recommended (strict enforcement)
/// - Stricter monitoring for users under 25
/// - Parental controls for minors (if allowed by app policy)
/// - Age-appropriate content filtering
/// - Enhanced mental health resources for younger users
@available(iOS 15.0, *)
@MainActor
public class AgeRestrictions: ObservableObject {
    
    // MARK: - Age Thresholds
    
    /// Minimum recommended age (18 years)
    public static let minimumRecommendedAge: Int = 18
    
    /// Age threshold for stricter safeguards (25 years)
    public static let stricterSafeguardsAgeThreshold: Int = 25
    
    /// Age threshold for enhanced monitoring (21 years)
    public static let enhancedMonitoringAgeThreshold: Int = 21
    
    // MARK: - Age Verification
    
    /// Age verification result
    public struct AgeVerificationResult: Sendable {
        public let isVerified: Bool
        public let age: Int?
        public let verificationMethod: VerificationMethod
        public let requiresParentalConsent: Bool
        public let restrictions: [AgeRestriction]
        
        public init(
            isVerified: Bool,
            age: Int? = nil,
            verificationMethod: VerificationMethod,
            requiresParentalConsent: Bool = false,
            restrictions: [AgeRestriction] = []
        ) {
            self.isVerified = isVerified
            self.age = age
            self.verificationMethod = verificationMethod
            self.requiresParentalConsent = requiresParentalConsent
            self.restrictions = restrictions
        }
    }
    
    /// Method used for age verification
    public enum VerificationMethod: String, Codable, Sendable {
        case selfReported = "self_reported"
        case appStoreAge = "app_store_age"
        case parentalConsent = "parental_consent"
        case notVerified = "not_verified"
    }
    
    /// Age-based restrictions
    public struct AgeRestriction: Identifiable, Sendable {
        public let id: UUID
        public let type: RestrictionType
        public let description: String
        public let severity: RestrictionSeverity
        
        public init(
            id: UUID = UUID(),
            type: RestrictionType,
            description: String,
            severity: RestrictionSeverity
        ) {
            self.id = id
            self.type = type
            self.description = description
            self.severity = severity
        }
    }
    
    /// Type of age restriction
    public enum RestrictionType: String, Codable, Sendable {
        case measurementFrequencyLimit = "measurement_frequency_limit"
        case enhancedMonitoring = "enhanced_monitoring"
        case contentFiltering = "content_filtering"
        case requiresParentalConsent = "requires_parental_consent"
        case mentalHealthResources = "mental_health_resources"
        case accessRestriction = "access_restriction"
    }
    
    /// Severity of restriction
    public enum RestrictionSeverity: String, Codable, Sendable {
        case critical = "critical" // Blocks access
        case high = "high" // Significant limitations
        case medium = "medium" // Moderate limitations
        case low = "low" // Minor limitations
    }
    
    // MARK: - State
    
    /// User's verified age (if available)
    @Published public var verifiedAge: Int?
    
    /// Age verification status
    @Published public var verificationStatus: AgeVerificationResult?
    
    /// Whether user has provided parental consent (if applicable)
    @Published public var hasParentalConsent: Bool = false
    
    /// Current age-based restrictions
    @Published public var currentRestrictions: [AgeRestriction] = []
    
    public init() {
        // Try to get age from App Store (if available)
        // In production, would integrate with App Store Connect age rating
        loadAgeFromStorage()
    }
    
    // MARK: - Age Verification
    
    /// Verify user's age
    /// 
    /// - Parameters:
    ///   - age: User's self-reported age
    ///   - method: Verification method used
    /// - Returns: Age verification result
    @discardableResult
    public func verifyAge(_ age: Int, method: VerificationMethod = .selfReported) -> AgeVerificationResult {
        verifiedAge = age
        
        // Check if age meets minimum requirement
        let meetsMinimum = age >= Self.minimumRecommendedAge
        let requiresConsent = age < Self.minimumRecommendedAge
        
        // Determine restrictions based on age
        let restrictions = getRestrictionsForAge(age)
        
        let result = AgeVerificationResult(
            isVerified: meetsMinimum,
            age: age,
            verificationMethod: method,
            requiresParentalConsent: requiresConsent,
            restrictions: restrictions
        )
        
        verificationStatus = result
        currentRestrictions = restrictions
        
        // Persist age
        persistAge()
        
        return result
    }
    
    /// Get restrictions for a specific age
    /// 
    /// - Parameter age: User's age
    /// - Returns: List of restrictions applicable to this age
    private func getRestrictionsForAge(_ age: Int) -> [AgeRestriction] {
        var restrictions: [AgeRestriction] = []
        
        if age < Self.minimumRecommendedAge {
            // Under 18: Critical restrictions
            restrictions.append(AgeRestriction(
                type: .accessRestriction,
                description: "This app is recommended for users 18 and older. Parental consent required for users under 18.",
                severity: .critical
            ))
            
            restrictions.append(AgeRestriction(
                type: .requiresParentalConsent,
                description: "Parental consent required before using this app.",
                severity: .critical
            ))
        } else if age < Self.enhancedMonitoringAgeThreshold {
            // 18-20: Enhanced monitoring
            restrictions.append(AgeRestriction(
                type: .enhancedMonitoring,
                description: "Enhanced monitoring and safeguards apply due to age.",
                severity: .high
            ))
            
            restrictions.append(AgeRestriction(
                type: .mentalHealthResources,
                description: "Additional mental health resources available due to age.",
                severity: .medium
            ))
        } else if age < Self.stricterSafeguardsAgeThreshold {
            // 21-24: Stricter safeguards
            restrictions.append(AgeRestriction(
                type: .enhancedMonitoring,
                description: "Stricter safeguards apply due to age (under 25).",
                severity: .medium
            ))
            
            restrictions.append(AgeRestriction(
                type: .measurementFrequencyLimit,
                description: "Measurement frequency limits apply (max 3 per day for users under 25).",
                severity: .medium
            ))
            
            restrictions.append(AgeRestriction(
                type: .mentalHealthResources,
                description: "Additional mental health resources recommended.",
                severity: .low
            ))
        }
        
        return restrictions
    }
    
    /// Check if user can access app features
    /// 
    /// - Returns: Whether user can access app (considering age restrictions)
    public func canAccessApp() -> Bool {
        guard let age = verifiedAge else {
            // Age not verified - require verification
            return false
        }
        
        if age < Self.minimumRecommendedAge {
            // Under 18 requires parental consent
            return hasParentalConsent
        }
        
        return true
    }
    
    /// Get maximum measurements per day for user's age
    /// 
    /// - Returns: Maximum measurements allowed per day
    public func getMaxMeasurementsPerDay() -> Int {
        guard let age = verifiedAge else {
            return 5 // Default
        }
        
        if age < Self.enhancedMonitoringAgeThreshold {
            // 18-20: Moderate limit
            return 4
        } else if age < Self.stricterSafeguardsAgeThreshold {
            // 21-24: Stricter limit
            return 3
        }
        
        return 5 // Standard limit (25+)
    }
    
    /// Get maximum measurements per week for user's age
    /// 
    /// - Returns: Maximum measurements allowed per week
    public func getMaxMeasurementsPerWeek() -> Int {
        guard let age = verifiedAge else {
            return 20 // Default
        }
        
        if age < Self.enhancedMonitoringAgeThreshold {
            // 18-20: Moderate limit
            return 15
        } else if age < Self.stricterSafeguardsAgeThreshold {
            // 21-24: Stricter limit
            return 10
        }
        
        return 20 // Standard limit (25+)
    }
    
    // MARK: - Parental Consent
    
    /// Record parental consent for minor user
    /// 
    /// - Parameter consentProvided: Whether consent was provided
    public func recordParentalConsent(_ consentProvided: Bool) {
        hasParentalConsent = consentProvided
        persistAge()
        
        // Reassess restrictions
        if let age = verifiedAge {
            _ = verifyAge(age, method: .parentalConsent)
        }
    }
    
    /// Check if parental consent is required
    /// 
    /// - Returns: Whether parental consent is required
    public func requiresParentalConsent() -> Bool {
        guard let age = verifiedAge else {
            return true // Require verification first
        }
        
        return age < Self.minimumRecommendedAge
    }
    
    // MARK: - Content Filtering
    
    /// Check if content should be filtered based on age
    /// 
    /// - Parameters:
    ///   - content: Content to check
    ///   - contentType: Type of content
    /// - Returns: Whether content should be shown to user
    public func shouldShowContent(_ content: String, contentType: String) -> Bool {
        guard let age = verifiedAge else {
            return false // Require age verification first
        }
        
        // Additional filtering for users under 25
        if age < Self.stricterSafeguardsAgeThreshold {
            // Filter out content that promises dramatic transformations
            let lowercased = content.lowercased()
            let filteredPhrases = [
                "dramatic transformation",
                "extreme makeover",
                "guaranteed results"
            ]
            
            for phrase in filteredPhrases {
                if lowercased.contains(phrase) {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// Get age-appropriate disclaimer
    /// 
    /// - Returns: Disclaimer message appropriate for user's age
    public func getAgeAppropriateDisclaimer() -> String {
        guard let age = verifiedAge else {
            return getDefaultDisclaimer()
        }
        
        if age < Self.minimumRecommendedAge {
            return """
            This app is designed for users 18 and older.
            Parental consent is required for users under 18.
            
            If you're experiencing body image concerns, please speak with a trusted adult or healthcare provider.
            """
        } else if age < Self.stricterSafeguardsAgeThreshold {
            return """
            This app focuses on facial muscle toning and general wellness.
            
            If you're experiencing body image concerns or eating disorders, please consider speaking with a mental health professional or healthcare provider.
            Support resources are available in the app.
            """
        }
        
        return getDefaultDisclaimer()
    }
    
    /// Get default disclaimer
    private func getDefaultDisclaimer() -> String {
        return """
        This app is for general wellness only and is not a medical device.
        Individual results may vary. Consult with a healthcare provider for personalized guidance.
        """
    }
    
    // MARK: - Data Persistence
    
    /// Persist age information to storage
    private func persistAge() {
        // In production, would persist to secure storage (Keychain)
        // For now, keep in memory
        if let age = verifiedAge {
            UserDefaults.standard.set(age, forKey: "verifiedAge")
            UserDefaults.standard.set(hasParentalConsent, forKey: "hasParentalConsent")
        }
    }
    
    /// Load age from storage
    private func loadAgeFromStorage() {
        let age = UserDefaults.standard.integer(forKey: "verifiedAge")
        if age > 0 {
            verifiedAge = age
        }
        
        hasParentalConsent = UserDefaults.standard.bool(forKey: "hasParentalConsent")
        
        // Reassess restrictions if age is loaded
        if let age = verifiedAge {
            _ = verifyAge(age, method: .selfReported)
        }
    }
    
    // MARK: - Data Management
    
    /// Clear age verification data (for testing or reset)
    public func clearAgeData() {
        verifiedAge = nil
        verificationStatus = nil
        hasParentalConsent = false
        currentRestrictions = []
        
        UserDefaults.standard.removeObject(forKey: "verifiedAge")
        UserDefaults.standard.removeObject(forKey: "hasParentalConsent")
    }
    
    /// Get age group category
    /// 
    /// - Returns: Age group category for user
    public func getAgeGroup() -> AgeGroup? {
        guard let age = verifiedAge else {
            return nil
        }
        
        if age < Self.minimumRecommendedAge {
            return .minor
        } else if age < Self.enhancedMonitoringAgeThreshold {
            return .youngAdult
        } else if age < Self.stricterSafeguardsAgeThreshold {
            return .adult
        }
        
        return .matureAdult
    }
    
    /// Age group categories
    public enum AgeGroup: String, Codable, Sendable {
        case minor = "minor" // Under 18
        case youngAdult = "young_adult" // 18-20
        case adult = "adult" // 21-24
        case matureAdult = "mature_adult" // 25+
    }
}

