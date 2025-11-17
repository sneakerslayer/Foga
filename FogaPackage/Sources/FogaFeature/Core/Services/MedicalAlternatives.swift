import Foundation

/// Service for providing information about evidence-based medical alternatives for submental fat reduction
/// 
/// **Critical Purpose**: Provides honest, evidence-based information about medical treatments
/// for submental fat reduction. Positions app as informational only and recommends healthcare provider consultation.
/// 
/// **Key Principles**:
/// - Provides information about evidence-based treatments (deoxycholic acid, cryolipolysis, surgical options)
/// - Recommends healthcare provider consultation
/// - Positions as informational only (not medical advice)
/// - Never promotes specific treatments or providers
/// - Emphasizes that app is not a substitute for medical consultation
@MainActor
public class MedicalAlternatives: ObservableObject {
    
    // MARK: - Treatment Types
    
    /// Type of medical treatment
    public enum TreatmentType: String, Codable, Sendable {
        case deoxycholicAcid = "deoxycholic_acid"
        case cryolipolysis = "cryolipolysis"
        case liposuction = "liposuction"
        case neckLift = "neck_lift"
        case radiofrequency = "radiofrequency"
        
        public var displayName: String {
            switch self {
            case .deoxycholicAcid:
                return "Deoxycholic Acid Injection"
            case .cryolipolysis:
                return "Cryolipolysis (CoolSculpting)"
            case .liposuction:
                return "Liposuction"
            case .neckLift:
                return "Neck Lift Surgery"
            case .radiofrequency:
                return "Radiofrequency Treatment"
            }
        }
        
        public var commonBrandName: String? {
            switch self {
            case .deoxycholicAcid:
                return "Kybella"
            case .cryolipolysis:
                return "CoolSculpting"
            case .radiofrequency:
                return "ThermiRF"
            default:
                return nil
            }
        }
    }
    
    /// Treatment information
    public struct TreatmentInfo: Identifiable, Codable, Sendable {
        public let id: UUID
        public let type: TreatmentType
        public let description: String
        public let howItWorks: String
        public let effectiveness: String
        public let sideEffects: [String]
        public let recoveryTime: String
        public let costRange: String
        public let evidenceLevel: String
        public let fdaApproved: Bool
        public let suitableFor: [String]
        public let notSuitableFor: [String]
        public let consultationRequired: Bool
        
        public init(
            id: UUID = UUID(),
            type: TreatmentType,
            description: String,
            howItWorks: String,
            effectiveness: String,
            sideEffects: [String],
            recoveryTime: String,
            costRange: String,
            evidenceLevel: String,
            fdaApproved: Bool,
            suitableFor: [String],
            notSuitableFor: [String],
            consultationRequired: Bool = true
        ) {
            self.id = id
            self.type = type
            self.description = description
            self.howItWorks = howItWorks
            self.effectiveness = effectiveness
            self.sideEffects = sideEffects
            self.recoveryTime = recoveryTime
            self.costRange = costRange
            self.evidenceLevel = evidenceLevel
            self.fdaApproved = fdaApproved
            self.suitableFor = suitableFor
            self.notSuitableFor = notSuitableFor
            self.consultationRequired = consultationRequired
        }
    }
    
    // MARK: - Published Properties
    
    /// Available treatment options
    @Published public var treatments: [TreatmentInfo] = []
    
    // MARK: - Initialization
    
    public init() {
        loadTreatmentInformation()
    }
    
    // MARK: - Treatment Information Loading
    
    /// Load treatment information
    private func loadTreatmentInformation() {
        treatments = [
            TreatmentInfo(
                type: .deoxycholicAcid,
                description: "Injectable treatment that destroys fat cells in the submental area. FDA-approved for moderate to severe submental fat.",
                howItWorks: "Deoxycholic acid is a naturally occurring molecule that breaks down fat cells. When injected into the submental area, it destroys fat cells, which are then naturally eliminated by the body over several weeks.",
                effectiveness: "Clinical studies show 68-82% of patients achieve visible improvement after 2-4 treatment sessions. Results typically appear 4-6 weeks after treatment.",
                sideEffects: [
                    "Temporary swelling, bruising, and pain at injection site",
                    "Numbness or hardness in treated area",
                    "Rare: nerve injury, difficulty swallowing",
                    "Side effects usually resolve within 1-2 weeks"
                ],
                recoveryTime: "Minimal downtime. Most people return to normal activities immediately. Swelling may last 1-2 weeks.",
                costRange: "$1,200 - $2,400 per treatment session (typically 2-4 sessions needed)",
                evidenceLevel: "Strong - FDA-approved with multiple randomized controlled trials",
                fdaApproved: true,
                suitableFor: [
                    "Moderate to severe submental fat",
                    "Good skin elasticity",
                    "Realistic expectations",
                    "Ability to tolerate injections"
                ],
                notSuitableFor: [
                    "Pregnancy or breastfeeding",
                    "Active infection in treatment area",
                    "Bleeding disorders",
                    "Allergy to deoxycholic acid"
                ]
            ),
            TreatmentInfo(
                type: .cryolipolysis,
                description: "Non-invasive fat reduction using controlled cooling to freeze and destroy fat cells. FDA-cleared for submental fat reduction.",
                howItWorks: "Controlled cooling is applied to the submental area, which freezes fat cells without damaging surrounding tissue. The frozen fat cells are gradually eliminated by the body's natural processes over 2-4 months.",
                effectiveness: "Clinical studies show 20-25% fat reduction after single treatment. Results appear gradually over 2-4 months. Some patients may need multiple treatments.",
                sideEffects: [
                    "Temporary redness, swelling, and bruising",
                    "Numbness or tingling in treated area",
                    "Rare: paradoxical adipose hyperplasia (fat increase)",
                    "Side effects usually resolve within 1-2 weeks"
                ],
                recoveryTime: "No downtime. Most people return to normal activities immediately. Mild swelling may last a few days.",
                costRange: "$750 - $1,500 per treatment session (typically 1-2 sessions needed)",
                evidenceLevel: "Moderate - FDA-cleared with clinical studies",
                fdaApproved: true,
                suitableFor: [
                    "Mild to moderate submental fat",
                    "Good skin elasticity",
                    "Realistic expectations",
                    "Preference for non-invasive treatment"
                ],
                notSuitableFor: [
                    "Severe submental fat",
                    "Poor skin elasticity",
                    "Cold sensitivity disorders",
                    "Pregnancy"
                ]
            ),
            TreatmentInfo(
                type: .liposuction,
                description: "Surgical procedure that removes fat through small incisions using suction. Most effective for submental fat reduction.",
                howItWorks: "Small incisions are made under the chin or behind the ears. A thin tube (cannula) is inserted to break up and suction out fat cells. Can be performed under local or general anesthesia.",
                effectiveness: "Highly effective with immediate, permanent results. 80-90% of patients achieve significant improvement. Results are long-lasting if weight is maintained.",
                sideEffects: [
                    "Swelling, bruising, and pain",
                    "Temporary numbness",
                    "Scarring at incision sites",
                    "Rare: infection, bleeding, nerve injury",
                    "Side effects usually resolve within 2-4 weeks"
                ],
                recoveryTime: "1-2 weeks for initial recovery. Full recovery takes 4-6 weeks. Compression garment required for 1-2 weeks.",
                costRange: "$2,500 - $5,000 (varies by surgeon and location)",
                evidenceLevel: "Strong - Well-established surgical procedure with decades of clinical use",
                fdaApproved: false, // Surgical procedure, not FDA-regulated
                suitableFor: [
                    "Moderate to severe submental fat",
                    "Good skin elasticity",
                    "Realistic expectations",
                    "Ability to undergo surgery"
                ],
                notSuitableFor: [
                    "Poor skin elasticity (may need neck lift)",
                    "Bleeding disorders",
                    "Active infection",
                    "Unrealistic expectations"
                ]
            ),
            TreatmentInfo(
                type: .neckLift,
                description: "Surgical procedure that removes excess skin and fat, tightens muscles, and improves neck contour. Most comprehensive treatment for submental area.",
                howItWorks: "Incisions are made behind the ears or under the chin. Excess skin and fat are removed, underlying muscles are tightened, and remaining skin is repositioned for a smoother, more defined neck contour.",
                effectiveness: "Highly effective with dramatic, long-lasting results. 85-95% of patients achieve significant improvement. Results typically last 10+ years.",
                sideEffects: [
                    "Swelling, bruising, and pain",
                    "Temporary numbness",
                    "Scarring (usually well-hidden)",
                    "Rare: infection, bleeding, nerve injury",
                    "Side effects usually resolve within 2-4 weeks"
                ],
                recoveryTime: "2-3 weeks for initial recovery. Full recovery takes 6-8 weeks. Compression garment required for 1-2 weeks.",
                costRange: "$5,000 - $15,000 (varies by surgeon and location)",
                evidenceLevel: "Strong - Well-established surgical procedure with decades of clinical use",
                fdaApproved: false, // Surgical procedure, not FDA-regulated
                suitableFor: [
                    "Significant submental fat and loose skin",
                    "Poor skin elasticity",
                    "Age-related changes",
                    "Realistic expectations"
                ],
                notSuitableFor: [
                    "Active infection",
                    "Bleeding disorders",
                    "Unrealistic expectations",
                    "Inability to undergo surgery"
                ]
            ),
            TreatmentInfo(
                type: .radiofrequency,
                description: "Non-invasive treatment using radiofrequency energy to heat and tighten skin while reducing fat. Less evidence than other treatments.",
                howItWorks: "Radiofrequency energy is applied to the submental area, which heats the tissue to promote collagen production and skin tightening. May also reduce fat through thermal effects.",
                effectiveness: "Moderate effectiveness. Clinical studies show variable results. More effective for skin tightening than fat reduction. Multiple treatments typically needed.",
                sideEffects: [
                    "Temporary redness and swelling",
                    "Mild discomfort during treatment",
                    "Rare: burns or skin damage",
                    "Side effects usually resolve within a few days"
                ],
                recoveryTime: "Minimal downtime. Most people return to normal activities immediately. Mild redness may last a few hours.",
                costRange: "$500 - $1,500 per treatment session (typically 3-6 sessions needed)",
                evidenceLevel: "Limited - Some clinical studies but less evidence than other treatments",
                fdaApproved: true, // Some devices FDA-cleared
                suitableFor: [
                    "Mild submental fat",
                    "Skin laxity concerns",
                    "Preference for non-invasive treatment",
                    "Realistic expectations"
                ],
                notSuitableFor: [
                    "Moderate to severe submental fat",
                    "Metal implants in treatment area",
                    "Pregnancy",
                    "Unrealistic expectations"
                ]
            )
        ]
    }
    
    // MARK: - Treatment Information Access
    
    /// Get treatment by type
    /// 
    /// - Parameter type: Treatment type
    /// - Returns: Treatment info if found
    public func treatment(for type: TreatmentType) -> TreatmentInfo? {
        return treatments.first { $0.type == type }
    }
    
    /// Get FDA-approved treatments only
    /// 
    /// - Returns: FDA-approved treatments
    public func fdaApprovedTreatments() -> [TreatmentInfo] {
        return treatments.filter { $0.fdaApproved }
    }
    
    /// Get non-invasive treatments only
    /// 
    /// - Returns: Non-invasive treatments
    public func nonInvasiveTreatments() -> [TreatmentInfo] {
        return treatments.filter { treatment in
            treatment.type == .deoxycholicAcid ||
            treatment.type == .cryolipolysis ||
            treatment.type == .radiofrequency
        }
    }
    
    /// Get surgical treatments only
    /// 
    /// - Returns: Surgical treatments
    public func surgicalTreatments() -> [TreatmentInfo] {
        return treatments.filter { treatment in
            treatment.type == .liposuction ||
            treatment.type == .neckLift
        }
    }
    
    // MARK: - Consultation Recommendations
    
    /// Generate consultation recommendation message
    /// 
    /// - Parameters:
    ///   - userAngle: User's current cervico-mental angle
    ///   - includeTreatments: Whether to include treatment information
    /// - Returns: Formatted recommendation message
    public func generateConsultationRecommendation(
        userAngle: Double?,
        includeTreatments: Bool = true
    ) -> String {
        var message = "Consultation Recommendation\n\n"
        
        // Angle-based recommendation
        if let angle = userAngle {
            if angle > 120 {
                message += "Your current measurement (\(Int(angle))°) indicates significant submental fat. "
                message += "Consider consulting with a healthcare provider about evidence-based treatment options.\n\n"
            } else if angle >= 105 && angle <= 120 {
                message += "Your current measurement (\(Int(angle))°) is above optimal range. "
                message += "You may benefit from consulting with a healthcare provider about treatment options.\n\n"
            } else {
                message += "Your current measurement (\(Int(angle))°) is in the optimal range. "
                message += "If you're still concerned about your appearance, consider consulting with a healthcare provider.\n\n"
            }
        } else {
            message += "If you're concerned about submental fat, consider consulting with a healthcare provider "
            message += "about evidence-based treatment options.\n\n"
        }
        
        // Treatment information (if requested)
        if includeTreatments {
            message += "Evidence-Based Treatment Options:\n\n"
            
            let fdaApproved = fdaApprovedTreatments()
            for treatment in fdaApproved.prefix(2) {
                message += "• \(treatment.type.displayName)"
                if let brandName = treatment.type.commonBrandName {
                    message += " (\(brandName))"
                }
                message += ": \(treatment.effectiveness)\n"
            }
            
            message += "\n"
        }
        
        // Important disclaimers
        message += "Important Notes:\n"
        message += "• This information is for educational purposes only and not medical advice\n"
        message += "• Consult with a qualified healthcare provider before pursuing any treatment\n"
        message += "• Treatment suitability depends on individual factors (health, skin condition, expectations)\n"
        message += "• Costs and results vary between providers and individuals\n"
        message += "• This app is not a substitute for professional medical consultation"
        
        return message
    }
    
    /// Generate general information message about medical alternatives
    /// 
    /// - Returns: Formatted information message
    public func generateGeneralInformation() -> String {
        var message = "Medical Alternatives for Submental Fat Reduction\n\n"
        
        message += "This app focuses on facial exercises for general wellness. "
        message += "However, if you're interested in evidence-based medical treatments for submental fat reduction, "
        message += "there are several options available.\n\n"
        
        message += "FDA-Approved Non-Invasive Treatments:\n"
        let nonInvasive = nonInvasiveTreatments()
        for treatment in nonInvasive {
            message += "• \(treatment.type.displayName)"
            if let brandName = treatment.type.commonBrandName {
                message += " (\(brandName))"
            }
            message += "\n"
        }
        
        message += "\nSurgical Options:\n"
        let surgical = surgicalTreatments()
        for treatment in surgical {
            message += "• \(treatment.type.displayName)\n"
        }
        
        message += "\nImportant:\n"
        message += "• All treatments require consultation with a qualified healthcare provider\n"
        message += "• Treatment suitability depends on individual factors\n"
        message += "• This information is for educational purposes only, not medical advice\n"
        message += "• Consult with a healthcare provider to determine the best option for you"
        
        return message
    }
    
    // MARK: - Disclaimer Generation
    
    /// Generate disclaimer for medical alternatives information
    /// 
    /// - Returns: Formatted disclaimer text
    public func generateDisclaimer() -> String {
        var disclaimer = "Medical Alternatives Information Disclaimer\n\n"
        
        disclaimer += "Purpose:\n"
        disclaimer += "This information is provided for educational purposes only and is not intended as medical advice. "
        disclaimer += "It is not a substitute for professional medical consultation, diagnosis, or treatment.\n\n"
        
        disclaimer += "Not Medical Advice:\n"
        disclaimer += "• This app does not provide medical advice\n"
        disclaimer += "• Treatment information is general and may not apply to your specific situation\n"
        disclaimer += "• Always consult with a qualified healthcare provider before pursuing any treatment\n"
        disclaimer += "• Do not delay seeking medical advice because of information in this app\n\n"
        
        disclaimer += "Treatment Suitability:\n"
        disclaimer += "• Treatment suitability depends on individual factors (health, skin condition, expectations)\n"
        disclaimer += "• Only a qualified healthcare provider can determine if a treatment is right for you\n"
        disclaimer += "• Results vary between individuals and are not guaranteed\n"
        disclaimer += "• Costs and availability vary by location and provider\n\n"
        
        disclaimer += "Provider Selection:\n"
        disclaimer += "• Choose qualified, licensed healthcare providers\n"
        disclaimer += "• Research providers and read reviews\n"
        disclaimer += "• Ask about experience, credentials, and before/after photos\n"
        disclaimer += "• Get multiple consultations before making a decision\n\n"
        
        disclaimer += "By using this information, you acknowledge that:\n"
        disclaimer += "• You understand this is not medical advice\n"
        disclaimer += "• You will consult with healthcare providers before pursuing treatments\n"
        disclaimer += "• You will not rely solely on this app for medical decisions"
        
        return disclaimer
    }
}

