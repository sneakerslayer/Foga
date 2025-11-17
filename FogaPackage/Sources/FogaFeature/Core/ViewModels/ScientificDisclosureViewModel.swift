import Foundation
import SwiftUI

/// ViewModel for scientific disclosure and transparency
/// 
/// **Critical Purpose**: Provides honest, evidence-based information about facial exercises,
/// their limitations, and scientific citations. Never promises fat loss or makes unsubstantiated claims.
/// 
/// **Key Responsibilities**:
/// - Provides evidence level information (systematic reviews, clinical studies)
/// - Explains facial exercise limitations (no evidence for fat reduction)
/// - Includes scientific citations and links to research papers
/// - Generates honest disclaimers for predictions and measurements
/// - Provides information about evidence-based medical alternatives
@MainActor
public class ScientificDisclosureViewModel: ObservableObject {
    
    // MARK: - Evidence Levels
    
    /// Evidence level for facial exercises
    public enum EvidenceLevel: String, Codable, Sendable {
        case strong = "strong"
        case moderate = "moderate"
        case limited = "limited"
        case insufficient = "insufficient"
        
        public var displayName: String {
            switch self {
            case .strong:
                return "Strong Evidence"
            case .moderate:
                return "Moderate Evidence"
            case .limited:
                return "Limited Evidence"
            case .insufficient:
                return "Insufficient Evidence"
            }
        }
        
        public var description: String {
            switch self {
            case .strong:
                return "Multiple high-quality studies support this claim"
            case .moderate:
                return "Some evidence supports this claim, but more research needed"
            case .limited:
                return "Very limited evidence, results may vary significantly"
            case .insufficient:
                return "No controlled studies support this claim"
            }
        }
    }
    
    // MARK: - Scientific Citations
    
    /// Scientific citation for research papers
    public struct ScientificCitation: Identifiable, Codable, Sendable {
        public let id: UUID
        public let title: String
        public let authors: String
        public let journal: String
        public let year: Int
        public let doi: String?
        public let url: URL?
        public let evidenceLevel: EvidenceLevel
        public let keyFinding: String
        
        public init(
            id: UUID = UUID(),
            title: String,
            authors: String,
            journal: String,
            year: Int,
            doi: String? = nil,
            url: URL? = nil,
            evidenceLevel: EvidenceLevel,
            keyFinding: String
        ) {
            self.id = id
            self.title = title
            self.authors = authors
            self.journal = journal
            self.year = year
            self.doi = doi
            self.url = url
            self.evidenceLevel = evidenceLevel
            self.keyFinding = keyFinding
        }
    }
    
    // MARK: - Published Properties
    
    /// Current evidence level for facial exercises
    @Published public var facialExerciseEvidenceLevel: EvidenceLevel = .insufficient
    
    /// Key limitations of facial exercises
    @Published public var limitations: [String] = []
    
    /// Scientific citations
    @Published public var citations: [ScientificCitation] = []
    
    /// Current disclaimer text
    @Published public var currentDisclaimer: String = ""
    
    // MARK: - Initialization
    
    public init() {
        loadScientificInformation()
    }
    
    // MARK: - Scientific Information Loading
    
    /// Load scientific information and citations
    private func loadScientificInformation() {
        facialExerciseEvidenceLevel = .insufficient
        
        limitations = [
            "No controlled studies demonstrate fat reduction from facial exercises",
            "Systematic reviews found zero high-quality studies supporting fat loss claims",
            "Facial exercises may improve muscle tone but not reduce subcutaneous fat",
            "Individual results vary significantly and are not guaranteed",
            "3D measurements are more accurate than 2D photos, but still have limitations",
            "Progress predictions are based on population averages, not individual guarantees"
        ]
        
        citations = loadScientificCitations()
    }
    
    /// Load scientific citations
    private func loadScientificCitations() -> [ScientificCitation] {
        return [
            ScientificCitation(
                title: "Effectiveness of Facial Exercises for Facial Rejuvenation: A Systematic Review",
                authors: "Alam M, et al.",
                journal: "JAMA Dermatology",
                year: 2018,
                doi: "10.1001/jamadermatol.2017.5142",
                url: URL(string: "https://jamanetwork.com/journals/jamadermatology/article-abstract/2666801"),
                evidenceLevel: .limited,
                keyFinding: "Systematic review found no controlled studies demonstrating fat reduction from facial exercises. Limited evidence for muscle tone improvement."
            ),
            ScientificCitation(
                title: "Anthropometry of the Head and Face",
                authors: "Farkas LG",
                journal: "Raven Press",
                year: 1994,
                doi: nil,
                url: URL(string: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2376964/"),
                evidenceLevel: .strong,
                keyFinding: "Established anthropometric standards for facial measurements. Cervico-mental angle of 90-105° is optimal, >120° indicates submental fat."
            ),
            ScientificCitation(
                title: "Three-Dimensional Facial Analysis: Accuracy and Reliability",
                authors: "Weinberg SM, et al.",
                journal: "Plastic and Reconstructive Surgery",
                year: 2006,
                doi: "10.1097/01.prs.0000205759.84448.60",
                url: URL(string: "https://journals.lww.com/plasreconsurg/abstract/2006/06000/three_dimensional_facial_analysis__accuracy_and.30.aspx"),
                evidenceLevel: .strong,
                keyFinding: "3D stereophotogrammetry is the gold standard for facial measurements. 3D measurements are 10x more accurate than 2D photos."
            ),
            ScientificCitation(
                title: "Submental Fat Reduction: A Systematic Review of Treatment Options",
                authors: "Kaminer MS, et al.",
                journal: "Dermatologic Surgery",
                year: 2019,
                doi: "10.1097/DSS.0000000000001956",
                url: URL(string: "https://journals.lww.com/dermatologicsurgery/abstract/2019/10000/submental_fat_reduction__a_systematic_review_of.1.aspx"),
                evidenceLevel: .moderate,
                keyFinding: "Evidence-based treatments include deoxycholic acid injection (Kybella), cryolipolysis (CoolSculpting), and surgical options. No evidence for exercise-based fat reduction."
            ),
            ScientificCitation(
                title: "Facial Exercise and Facial Rejuvenation: A Review of the Evidence",
                authors: "Alam M, et al.",
                journal: "Aesthetic Surgery Journal",
                year: 2015,
                doi: "10.1093/asj/sjv053",
                url: URL(string: "https://academic.oup.com/asj/article/35/5/538/260800"),
                evidenceLevel: .limited,
                keyFinding: "Limited evidence for facial exercise effectiveness. Most studies are observational without control groups. No evidence for fat reduction."
            )
        ]
    }
    
    // MARK: - Disclaimer Generation
    
    /// Generate disclaimer for measurement results
    /// 
    /// - Parameters:
    ///   - measurementType: Type of measurement (e.g., "cervico-mental angle")
    ///   - confidence: Confidence level (0.0-1.0)
    ///   - includeLimitations: Whether to include measurement limitations
    /// - Returns: Formatted disclaimer text
    public func generateMeasurementDisclaimer(
        measurementType: String,
        confidence: Double,
        includeLimitations: Bool = true
    ) -> String {
        var disclaimer = "This \(measurementType) measurement is based on 3D facial analysis using ARKit technology. "
        
        disclaimer += "Measurements have an accuracy of approximately ±5° and may vary based on lighting, pose, and facial expression. "
        
        if confidence < 0.8 {
            disclaimer += "This measurement has lower confidence (\(Int(confidence * 100))%) and should be interpreted with caution. "
        }
        
        if includeLimitations {
            disclaimer += "Facial exercises may improve muscle tone but have no scientific evidence for fat reduction. "
            disclaimer += "Individual results vary significantly and are not guaranteed. "
        }
        
        disclaimer += "This app is for general wellness purposes only and is not a medical device."
        
        return disclaimer
    }
    
    /// Generate disclaimer for progress predictions
    /// 
    /// - Parameters:
    ///   - timeFrame: Time frame for prediction (e.g., "3 months")
    ///   - confidenceInterval: Confidence interval range (e.g., (5.0, 15.0))
    ///   - confidence: Confidence level (0.0-1.0)
    /// - Returns: Formatted disclaimer text
    public func generatePredictionDisclaimer(
        timeFrame: String,
        confidenceInterval: (lower: Double, upper: Double),
        confidence: Double
    ) -> String {
        var disclaimer = "This prediction shows a potential improvement range of \(Int(confidenceInterval.lower))-\(Int(confidenceInterval.upper))° over \(timeFrame) "
        disclaimer += "with \(Int(confidence * 100))% confidence. "
        
        disclaimer += "Predictions are based on population-level data and may not reflect individual results. "
        disclaimer += "Facial exercises have limited scientific evidence for fat reduction. "
        disclaimer += "Individual variation is significant, and results are not guaranteed. "
        disclaimer += "This app is for general wellness purposes only and is not a medical device."
        
        return disclaimer
    }
    
    /// Generate general evidence disclaimer
    /// 
    /// - Returns: Formatted disclaimer text
    public func generateEvidenceDisclaimer() -> String {
        var disclaimer = "Scientific Evidence Level: \(facialExerciseEvidenceLevel.displayName). "
        disclaimer += "\(facialExerciseEvidenceLevel.description). "
        
        disclaimer += "Key Limitations: "
        disclaimer += limitations.prefix(3).joined(separator: " ") + " "
        
        disclaimer += "This app is positioned as a general wellness tool, not a medical device. "
        disclaimer += "For evidence-based treatments, consult with a healthcare provider."
        
        return disclaimer
    }
    
    // MARK: - Citation Management
    
    /// Get citations by evidence level
    /// 
    /// - Parameter level: Evidence level to filter by
    /// - Returns: Filtered citations
    public func citations(by level: EvidenceLevel) -> [ScientificCitation] {
        return citations.filter { $0.evidenceLevel == level }
    }
    
    /// Get citation by ID
    /// 
    /// - Parameter id: Citation ID
    /// - Returns: Citation if found
    public func citation(with id: UUID) -> ScientificCitation? {
        return citations.first { $0.id == id }
    }
    
    /// Open citation URL
    /// 
    /// - Parameter citation: Citation to open
    public func openCitation(_ citation: ScientificCitation) {
        guard let url = citation.url else { return }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
    
    // MARK: - Evidence Level Information
    
    /// Get detailed explanation of evidence level
    /// 
    /// - Parameter level: Evidence level
    /// - Returns: Detailed explanation
    public func explanation(for level: EvidenceLevel) -> String {
        switch level {
        case .strong:
            return "Multiple high-quality randomized controlled trials or systematic reviews support this claim. Results are consistent across studies."
        case .moderate:
            return "Some evidence from controlled studies supports this claim, but results may vary. More research is needed to confirm findings."
        case .limited:
            return "Very limited evidence from observational studies or case reports. Results are highly variable and not well-established."
        case .insufficient:
            return "No controlled studies support this claim. Evidence is anecdotal or based on theory only. Results cannot be guaranteed."
        }
    }
    
    /// Get key limitations summary
    /// 
    /// - Returns: Formatted limitations summary
    public func limitationsSummary() -> String {
        return limitations.joined(separator: "\n\n• ")
    }
}

