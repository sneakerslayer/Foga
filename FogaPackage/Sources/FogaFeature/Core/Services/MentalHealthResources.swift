import Foundation

/// Service for providing mental health resources and support information
/// 
/// **Critical Purpose**: Links users to professional mental health resources when concerning
/// behavior patterns are detected. Provides information about body dysmorphia, eating disorders,
/// and general mental health support.
/// 
/// **Resources Provided**:
/// - National Eating Disorders Association (NEDA) helpline
/// - Body Dysmorphic Disorder (BDD) resources
/// - General mental health support
/// - Healthcare provider consultation recommendations
@MainActor
public class MentalHealthResources {
    
    // MARK: - Resource Types
    
    /// Mental health resource information
    public struct Resource: Identifiable, Sendable {
        public let id: UUID
        public let title: String
        public let description: String
        public let phoneNumber: String?
        public let websiteURL: String?
        public let resourceType: ResourceType
        public let isCrisisLine: Bool
        
        public init(
            id: UUID = UUID(),
            title: String,
            description: String,
            phoneNumber: String? = nil,
            websiteURL: String? = nil,
            resourceType: ResourceType,
            isCrisisLine: Bool = false
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.phoneNumber = phoneNumber
            self.websiteURL = websiteURL
            self.resourceType = resourceType
            self.isCrisisLine = isCrisisLine
        }
    }
    
    /// Type of mental health resource
    public enum ResourceType: String, Codable, Sendable {
        case helpline = "helpline"
        case website = "website"
        case supportGroup = "support_group"
        case professionalReferral = "professional_referral"
        case educational = "educational"
    }
    
    // MARK: - Available Resources
    
    /// Get resources for body dysmorphia concerns
    /// 
    /// - Returns: List of relevant mental health resources
    public static func getBodyDysmorphiaResources() -> [Resource] {
        return [
            Resource(
                title: "National Eating Disorders Association (NEDA) Helpline",
                description: "Free, confidential support for individuals and families affected by eating disorders and body image concerns.",
                phoneNumber: "1-800-931-2237",
                websiteURL: "https://www.nationaleatingdisorders.org",
                resourceType: .helpline,
                isCrisisLine: true
            ),
            Resource(
                title: "Body Dysmorphic Disorder Foundation",
                description: "Information and support for Body Dysmorphic Disorder (BDD), including treatment options and support groups.",
                websiteURL: "https://bddfoundation.org",
                resourceType: .website
            ),
            Resource(
                title: "988 Suicide & Crisis Lifeline",
                description: "24/7 free and confidential support for people in distress, prevention and crisis resources.",
                phoneNumber: "988",
                websiteURL: "https://988lifeline.org",
                resourceType: .helpline,
                isCrisisLine: true
            ),
            Resource(
                title: "Crisis Text Line",
                description: "Free 24/7 crisis support via text message. Text HOME to 741741.",
                phoneNumber: "741741",
                websiteURL: "https://www.crisistextline.org",
                resourceType: .helpline,
                isCrisisLine: true
            ),
            Resource(
                title: "International OCD Foundation - BDD Resources",
                description: "Resources specifically for Body Dysmorphic Disorder, including treatment finder and support groups.",
                websiteURL: "https://bdd.iocdf.org",
                resourceType: .website
            )
        ]
    }
    
    /// Get resources for general mental health support
    /// 
    /// - Returns: List of general mental health resources
    public static func getGeneralMentalHealthResources() -> [Resource] {
        return [
            Resource(
                title: "National Alliance on Mental Illness (NAMI)",
                description: "Provides advocacy, education, support and public awareness for people affected by mental illness.",
                phoneNumber: "1-800-950-NAMI (6264)",
                websiteURL: "https://www.nami.org",
                resourceType: .helpline
            ),
            Resource(
                title: "Mental Health America",
                description: "Resources for mental health support, screening tools, and finding local providers.",
                websiteURL: "https://www.mhanational.org",
                resourceType: .website
            ),
            Resource(
                title: "Psychology Today Therapist Finder",
                description: "Find licensed mental health professionals in your area, including therapists specializing in body image concerns.",
                websiteURL: "https://www.psychologytoday.com/us/therapists",
                resourceType: .professionalReferral
            ),
            Resource(
                title: "988 Suicide & Crisis Lifeline",
                description: "24/7 free and confidential support for people in distress, prevention and crisis resources.",
                phoneNumber: "988",
                websiteURL: "https://988lifeline.org",
                resourceType: .helpline,
                isCrisisLine: true
            )
        ]
    }
    
    /// Get resources for eating disorder concerns
    /// 
    /// - Returns: List of eating disorder-specific resources
    public static func getEatingDisorderResources() -> [Resource] {
        return [
            Resource(
                title: "National Eating Disorders Association (NEDA) Helpline",
                description: "Free, confidential support for individuals and families affected by eating disorders.",
                phoneNumber: "1-800-931-2237",
                websiteURL: "https://www.nationaleatingdisorders.org",
                resourceType: .helpline,
                isCrisisLine: true
            ),
            Resource(
                title: "NEDA Text Support",
                description: "Text NEDA to 741741 for 24/7 crisis support via text message.",
                phoneNumber: "741741",
                websiteURL: "https://www.nationaleatingdisorders.org/get-help",
                resourceType: .helpline,
                isCrisisLine: true
            ),
            Resource(
                title: "National Association of Anorexia Nervosa and Associated Disorders (ANAD)",
                description: "Support groups, treatment finder, and resources for eating disorders.",
                websiteURL: "https://anad.org",
                resourceType: .website
            ),
            Resource(
                title: "Eating Recovery Center",
                description: "Information about eating disorder treatment options and recovery resources.",
                websiteURL: "https://www.eatingrecoverycenter.com",
                resourceType: .website
            )
        ]
    }
    
    /// Get resources based on risk level
    /// 
    /// - Parameter riskLevel: User's current risk level
    /// - Returns: Appropriate resources for the risk level
    public static func getResourcesForRiskLevel(_ riskLevel: RiskLevel) -> [Resource] {
        switch riskLevel {
        case .low:
            // Low risk: Provide general wellness resources
            return [
                Resource(
                    title: "General Wellness Resources",
                    description: "If you ever feel concerned about your body image or mental health, professional support is available.",
                    websiteURL: "https://www.nami.org",
                    resourceType: .educational
                )
            ]
            
        case .medium:
            // Medium risk: Provide body dysmorphia and general mental health resources
            var resources = getBodyDysmorphiaResources()
            resources.append(contentsOf: getGeneralMentalHealthResources())
            return resources
            
        case .high:
            // High risk: Provide all resources including crisis lines
            var resources = getBodyDysmorphiaResources()
            resources.append(contentsOf: getEatingDisorderResources())
            resources.append(contentsOf: getGeneralMentalHealthResources())
            // Ensure crisis lines are at the top
            return resources.sorted { $0.isCrisisLine && !$1.isCrisisLine }
        }
    }
    
    /// Get resources for healthcare provider consultation
    /// 
    /// - Returns: Resources for finding healthcare providers
    public static func getHealthcareProviderResources() -> [Resource] {
        return [
            Resource(
                title: "Find a Healthcare Provider",
                description: "Consult with a healthcare provider about your wellness goals. They can provide personalized guidance and rule out any underlying health concerns.",
                websiteURL: "https://www.psychologytoday.com/us/therapists",
                resourceType: .professionalReferral
            ),
            Resource(
                title: "American Psychological Association - Find a Psychologist",
                description: "Find licensed psychologists in your area who specialize in body image and mental health.",
                websiteURL: "https://locator.apa.org",
                resourceType: .professionalReferral
            ),
            Resource(
                title: "American Psychiatric Association - Find a Psychiatrist",
                description: "Find board-certified psychiatrists who can provide medical evaluation and treatment.",
                websiteURL: "https://finder.psychiatry.org",
                resourceType: .professionalReferral
            )
        ]
    }
    
    // MARK: - Resource Formatting
    
    /// Format phone number for display
    /// 
    /// - Parameter phoneNumber: Raw phone number string
    /// - Returns: Formatted phone number for display
    public static func formatPhoneNumber(_ phoneNumber: String) -> String {
        // Remove non-numeric characters
        let digits = phoneNumber.filter { $0.isNumber }
        
        // Format based on length
        if digits.count == 10 {
            // Format as (XXX) XXX-XXXX
            let areaCode = String(digits.prefix(3))
            let firstPart = String(digits.dropFirst(3).prefix(3))
            let lastPart = String(digits.suffix(4))
            return "(\(areaCode)) \(firstPart)-\(lastPart)"
        } else if digits.count == 11 && digits.first == "1" {
            // Format as 1 (XXX) XXX-XXXX
            let areaCode = String(digits.dropFirst(1).prefix(3))
            let firstPart = String(digits.dropFirst(4).prefix(3))
            let lastPart = String(digits.suffix(4))
            return "1 (\(areaCode)) \(firstPart)-\(lastPart)"
        } else if digits.count <= 4 {
            // Short numbers like 988 or 741741
            return phoneNumber
        }
        
        return phoneNumber
    }
    
    /// Create action message for displaying resources
    /// 
    /// - Parameter riskLevel: User's current risk level
    /// - Returns: Message encouraging user to seek help
    public static func getActionMessage(for riskLevel: RiskLevel) -> String {
        switch riskLevel {
        case .low:
            return "Remember: If you ever feel concerned about your body image or mental health, professional support is available."
            
        case .medium:
            return "We've noticed some patterns that may indicate you're focusing too much on measurements. Consider speaking with a healthcare provider or mental health professional."
            
        case .high:
            return "We're concerned about your usage patterns. Please consider speaking with a mental health professional or healthcare provider. Crisis support is available 24/7."
        }
    }
    
    /// Get disclaimer message about app limitations
    /// 
    /// - Returns: Disclaimer about app not being a medical device
    public static func getDisclaimerMessage() -> String {
        return """
        This app is designed for general wellness and is not a medical device. 
        It does not diagnose, treat, cure, or prevent any disease or condition.
        
        If you're experiencing body image concerns, eating disorders, or other mental health issues, 
        please consult with a qualified healthcare provider or mental health professional.
        
        For immediate crisis support, call 988 or text HOME to 741741.
        """
    }
}

