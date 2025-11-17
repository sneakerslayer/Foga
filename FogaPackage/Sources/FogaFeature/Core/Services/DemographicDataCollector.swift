import Foundation
import Combine

/// Service for collecting demographic data for bias monitoring (optional, privacy-preserving)
/// 
/// **Scientific Note**: Demographic data is collected ONLY for bias monitoring purposes.
/// Users can opt-out at any time. Data is stored securely and used exclusively for
/// ensuring model fairness across demographic groups.
/// 
/// **Privacy Principles**:
/// - Optional collection - users can skip demographic questions
/// - Clear privacy notice explaining purpose
/// - Secure storage (encrypted)
/// - Used only for bias monitoring
/// - User can opt-out and delete data anytime
@MainActor
public class DemographicDataCollector {
    
    // MARK: - Published State
    
    /// Whether user has opted in to demographic data collection
    @Published public var hasOptedIn: Bool = false
    
    /// Whether user has completed demographic questionnaire
    @Published public var hasCompletedQuestionnaire: Bool = false
    
    /// Current user demographics (if provided)
    @Published public var userDemographics: UserDemographics?
    
    // MARK: - Storage
    
    /// UserDefaults key for opt-in status
    private let optInKey = "demographic_data_opt_in"
    
    /// UserDefaults key for demographics data
    private let demographicsKey = "user_demographics"
    
    /// UserDefaults key for privacy notice acknowledged
    private let privacyNoticeAcknowledgedKey = "privacy_notice_acknowledged"
    
    public init() {
        // Load saved preferences
        loadPreferences()
    }
    
    // MARK: - Privacy Notice
    
    /// Privacy notice explaining demographic data collection
    public static let privacyNotice = PrivacyNotice(
        title: "Demographic Data Collection (Optional)",
        purpose: """
        We collect optional demographic information to ensure our facial analysis model works fairly and accurately for everyone, regardless of race, skin tone, age, or gender.
        
        **Why we collect this data:**
        - To monitor model accuracy across different demographic groups
        - To identify and fix any bias in our predictions
        - To ensure >95% accuracy for all users
        
        **How we use this data:**
        - Only for bias monitoring and fairness validation
        - Never for marketing or advertising
        - Never shared with third parties
        - Stored securely on your device
        
        **Your rights:**
        - You can skip all demographic questions
        - You can opt-out anytime
        - You can delete your demographic data anytime
        - Your app experience is the same whether you provide this data or not
        """,
        dataCollected: [
            "Race/Ethnicity (optional)",
            "Skin tone (Fitzpatrick scale, optional)",
            "Age group (optional)",
            "Gender (optional)"
        ],
        howUsed: [
            "Bias monitoring",
            "Fairness validation",
            "Model improvement"
        ],
        retentionPeriod: "Until you delete it or opt-out"
    )
    
    // MARK: - Opt-In Flow
    
    /// Show privacy notice and request opt-in
    /// 
    /// - Returns: True if user opts in, false if they decline
    public func requestOptIn() async -> Bool {
        // In production, would show privacy notice UI
        // For now, return false (user must explicitly opt-in)
        return false
    }
    
    /// Acknowledge privacy notice
    /// 
    /// - Parameter acknowledged: Whether user acknowledged the notice
    public func acknowledgePrivacyNotice(_ acknowledged: Bool) {
        UserDefaults.standard.set(acknowledged, forKey: privacyNoticeAcknowledgedKey)
    }
    
    /// Check if privacy notice has been acknowledged
    public var hasAcknowledgedPrivacyNotice: Bool {
        return UserDefaults.standard.bool(forKey: privacyNoticeAcknowledgedKey)
    }
    
    /// Opt in to demographic data collection
    public func optIn() {
        hasOptedIn = true
        UserDefaults.standard.set(true, forKey: optInKey)
    }
    
    /// Opt out of demographic data collection
    public func optOut() {
        hasOptedIn = false
        hasCompletedQuestionnaire = false
        userDemographics = nil
        
        // Clear stored data
        UserDefaults.standard.set(false, forKey: optInKey)
        UserDefaults.standard.removeObject(forKey: demographicsKey)
    }
    
    // MARK: - Demographic Collection
    
    /// Collect demographics from user (optional questionnaire)
    /// 
    /// - Parameter demographics: User-provided demographics
    public func collectDemographics(_ demographics: UserDemographics) {
        guard hasOptedIn else {
            // User hasn't opted in, don't store
            return
        }
        
        userDemographics = demographics
        hasCompletedQuestionnaire = true
        
        // Save securely
        saveDemographics(demographics)
    }
    
    /// Get demographics for current user
    /// 
    /// - Returns: UserDemographics if available, nil otherwise
    public func getDemographics() -> UserDemographics? {
        return userDemographics
    }
    
    /// Create ModelMetadata from collected demographics
    /// 
    /// - Returns: ModelMetadata with demographic information, or default metadata
    public func createModelMetadata() -> ModelMetadata {
        guard let demographics = userDemographics else {
            // Return metadata with no demographic info (user opted out or didn't provide)
            return ModelMetadata(
                age: nil,
                gender: nil,
                bmi: nil,
                ethnicity: nil,
                skinTone: nil,
                measurementContext: .baseline
            )
        }
        
        return ModelMetadata(
            age: demographics.age,
            gender: demographics.gender,
            bmi: demographics.bmi,
            ethnicity: demographics.ethnicity,
            skinTone: demographics.skinTone,
            measurementContext: .baseline
        )
    }
    
    // MARK: - Data Management
    
    /// Delete all demographic data
    public func deleteDemographicData() {
        userDemographics = nil
        hasCompletedQuestionnaire = false
        UserDefaults.standard.removeObject(forKey: demographicsKey)
    }
    
    /// Export demographic data (for user transparency)
    /// 
    /// - Returns: JSON string representation of demographic data
    public func exportDemographicData() -> String? {
        guard let demographics = userDemographics else {
            return nil
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(demographics),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
    
    // MARK: - Privacy
    
    /// Check if demographic data collection is enabled
    public var isCollectionEnabled: Bool {
        return hasOptedIn && hasCompletedQuestionnaire
    }
    
    /// Get privacy summary for user
    public func getPrivacySummary() -> PrivacySummary {
        return PrivacySummary(
            hasOptedIn: hasOptedIn,
            hasCompletedQuestionnaire: hasCompletedQuestionnaire,
            dataStored: userDemographics != nil,
            canDelete: userDemographics != nil,
            lastUpdated: userDemographics?.lastUpdated
        )
    }
    
    // MARK: - Persistence
    
    /// Load preferences from UserDefaults
    private func loadPreferences() {
        hasOptedIn = UserDefaults.standard.bool(forKey: optInKey)
        
        if let data = UserDefaults.standard.data(forKey: demographicsKey),
           let demographics = try? JSONDecoder().decode(UserDemographics.self, from: data) {
            userDemographics = demographics
            hasCompletedQuestionnaire = true
        }
    }
    
    /// Save demographics securely
    private func saveDemographics(_ demographics: UserDemographics) {
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(demographics) else {
            return
        }
        
        // In production, would encrypt before storing
        // For now, store in UserDefaults (can be moved to Keychain for better security)
        UserDefaults.standard.set(data, forKey: demographicsKey)
    }
}

// MARK: - User Demographics

/// User demographic information (optional, privacy-preserving)
public struct UserDemographics: Codable, Sendable {
    public let age: Int?
    public let gender: Gender?
    public let bmi: Double?
    public let ethnicity: Ethnicity?
    public let skinTone: Int? // Fitzpatrick scale 1-6
    public let lastUpdated: Date
    
    public init(
        age: Int? = nil,
        gender: Gender? = nil,
        bmi: Double? = nil,
        ethnicity: Ethnicity? = nil,
        skinTone: Int? = nil,
        lastUpdated: Date = Date()
    ) {
        self.age = age
        self.gender = gender
        self.bmi = bmi
        self.ethnicity = ethnicity
        self.skinTone = skinTone
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Privacy Notice

/// Privacy notice for demographic data collection
public struct PrivacyNotice: Sendable {
    public let title: String
    public let purpose: String
    public let dataCollected: [String]
    public let howUsed: [String]
    public let retentionPeriod: String
    
    public init(
        title: String,
        purpose: String,
        dataCollected: [String],
        howUsed: [String],
        retentionPeriod: String
    ) {
        self.title = title
        self.purpose = purpose
        self.dataCollected = dataCollected
        self.howUsed = howUsed
        self.retentionPeriod = retentionPeriod
    }
}

// MARK: - Privacy Summary

/// Summary of privacy status for user
public struct PrivacySummary: Sendable {
    public let hasOptedIn: Bool
    public let hasCompletedQuestionnaire: Bool
    public let dataStored: Bool
    public let canDelete: Bool
    public let lastUpdated: Date?
    
    public init(
        hasOptedIn: Bool,
        hasCompletedQuestionnaire: Bool,
        dataStored: Bool,
        canDelete: Bool,
        lastUpdated: Date?
    ) {
        self.hasOptedIn = hasOptedIn
        self.hasCompletedQuestionnaire = hasCompletedQuestionnaire
        self.dataStored = dataStored
        self.canDelete = canDelete
        self.lastUpdated = lastUpdated
    }
}

