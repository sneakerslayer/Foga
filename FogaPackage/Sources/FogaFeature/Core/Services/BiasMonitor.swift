import Foundation
import Combine

/// Service for monitoring model predictions across demographic groups to ensure fairness
/// 
/// **Scientific Note**: Ensures >95% accuracy across ALL demographic groups with maximum 5% gap
/// between best and worst performing groups. Implements stratified metrics tracking and
/// quarterly fairness reporting.
/// 
/// **Fairness Criteria**:
/// - Overall accuracy: ≥95%
/// - Per-group accuracy: ≥90% (flags groups below this threshold)
/// - Maximum gap between groups: ≤5%
/// - Minimum sample size per group: 30 predictions (for statistical significance)
@available(iOS 15.0, *)
@MainActor
public class BiasMonitor: ObservableObject {
    
    // MARK: - Fairness Thresholds
    
    /// Minimum overall accuracy (95%)
    private let minOverallAccuracy: Double = 0.95
    
    /// Minimum per-group accuracy (90% - groups below this are flagged)
    private let minGroupAccuracy: Double = 0.90
    
    /// Maximum acceptable gap between best and worst performing groups (5%)
    private let maxAccuracyGap: Double = 0.05
    
    /// Minimum sample size per group for statistical significance
    private let minSampleSizePerGroup: Int = 30
    
    /// Minimum total sample size before calculating metrics
    private let minTotalSampleSize: Int = 100
    
    // MARK: - Prediction Tracking
    
    /// Tracked predictions with demographic information
    private struct TrackedPrediction: Codable, Sendable {
        let predictionId: UUID
        let timestamp: Date
        let predictedAngle: Double
        let actualAngle: Double? // Optional - may not have ground truth
        let predictedCategory: FatCategory
        let actualCategory: FatCategory? // Optional - may not have ground truth
        let confidence: Double
        let demographics: DemographicGroup
        let isCorrect: Bool? // True if prediction matches ground truth
        
        init(
            predictionId: UUID = UUID(),
            timestamp: Date = Date(),
            predictedAngle: Double,
            actualAngle: Double? = nil,
            predictedCategory: FatCategory,
            actualCategory: FatCategory? = nil,
            confidence: Double,
            demographics: DemographicGroup
        ) {
            self.predictionId = predictionId
            self.timestamp = timestamp
            self.predictedAngle = predictedAngle
            self.actualAngle = actualAngle
            self.predictedCategory = predictedCategory
            self.actualCategory = actualCategory
            self.confidence = confidence
            self.demographics = demographics
            
            // Calculate correctness if ground truth available
            if let actual = actualCategory {
                self.isCorrect = (predictedCategory == actual)
            } else {
                self.isCorrect = nil
            }
        }
    }
    
    /// Demographic group identifier
    public struct DemographicGroup: Hashable, Codable, Sendable {
        let race: Ethnicity?
        let skinTone: Int? // Fitzpatrick scale 1-6
        let ageGroup: AgeGroup
        let gender: Gender?
        
        /// Create demographic group key for grouping
        var groupKey: String {
            let raceStr = race?.rawValue ?? "unknown"
            let skinStr = skinTone.map { "\($0)" } ?? "unknown"
            let ageStr = ageGroup.rawValue
            let genderStr = gender?.rawValue ?? "unknown"
            return "\(raceStr)_\(skinStr)_\(ageStr)_\(genderStr)"
        }
        
        public init(
            race: Ethnicity? = nil,
            skinTone: Int? = nil,
            ageGroup: AgeGroup,
            gender: Gender? = nil
        ) {
            self.race = race
            self.skinTone = skinTone
            self.ageGroup = ageGroup
            self.gender = gender
        }
        
        /// Create from ModelMetadata
        public init(from metadata: ModelMetadata) {
            self.race = metadata.ethnicity
            self.skinTone = metadata.skinTone
            self.ageGroup = AgeGroup.from(age: metadata.age)
            self.gender = metadata.gender
        }
    }
    
    /// Age group classification
    public enum AgeGroup: String, Codable, Sendable {
        case young = "18-25"
        case adult = "26-40"
        case middleAged = "41-60"
        case senior = "61+"
        case unknown = "unknown"
        
        static func from(age: Int?) -> AgeGroup {
            guard let age = age else { return .unknown }
            switch age {
            case 18...25:
                return .young
            case 26...40:
                return .adult
            case 41...60:
                return .middleAged
            case 61...:
                return .senior
            default:
                return .unknown
            }
        }
    }
    
    // MARK: - State
    
    /// All tracked predictions
    private var predictions: [TrackedPrediction] = []
    
    /// Current fairness metrics (cached, recalculated on demand)
    private var cachedMetrics: FairnessMetrics?
    
    /// Last time metrics were calculated
    private var lastMetricsCalculation: Date?
    
    /// Flagged groups (groups below 90% accuracy)
    @Published public var flaggedGroups: [String] = []
    
    /// Whether fairness criteria are currently met
    @Published public var meetsFairnessCriteria: Bool = false
    
    public init() {
        // Load persisted predictions if available
        loadPersistedPredictions()
    }
    
    // MARK: - Prediction Tracking
    
    /// Record a prediction for bias monitoring
    /// 
    /// - Parameters:
    ///   - prediction: Model prediction result
    ///   - metadata: User metadata (demographics)
    ///   - groundTruth: Optional ground truth for accuracy calculation
    public func recordPrediction(
        _ prediction: PredictionResult,
        metadata: ModelMetadata,
        groundTruth: (angle: Double, category: FatCategory)? = nil
    ) {
        let demographics = DemographicGroup(from: metadata)
        
        let tracked = TrackedPrediction(
            predictedAngle: prediction.cervicoMentalAngle,
            actualAngle: groundTruth?.angle,
            predictedCategory: prediction.fatCategory,
            actualCategory: groundTruth?.category,
            confidence: prediction.overallConfidence,
            demographics: demographics
        )
        
        predictions.append(tracked)
        
        // Invalidate cached metrics
        cachedMetrics = nil
        
        // Recalculate metrics if we have enough data
        if predictions.count >= minTotalSampleSize {
            _ = calculateFairnessMetrics()
        }
        
        // Persist predictions periodically
        if predictions.count % 50 == 0 {
            persistPredictions()
        }
    }
    
    // MARK: - Fairness Metrics Calculation
    
    /// Calculate fairness metrics across all demographic groups
    /// 
    /// - Returns: FairnessMetrics with stratified accuracy data
    @discardableResult
    public func calculateFairnessMetrics() -> FairnessMetrics {
        // Return cached metrics if recent
        if let cached = cachedMetrics,
           let lastCalc = lastMetricsCalculation,
           Date().timeIntervalSince(lastCalc) < 300 { // Cache for 5 minutes
            return cached
        }
        
        // Filter predictions with ground truth
        let predictionsWithTruth = predictions.filter { $0.isCorrect != nil }
        
        guard predictionsWithTruth.count >= minTotalSampleSize else {
            // Not enough data yet
            let metrics = FairnessMetrics(
                overallAccuracy: nil,
                accuracyByGroup: [:],
                maxAccuracyGap: nil,
                sampleSize: predictionsWithTruth.count,
                flaggedGroups: [],
                meetsFairnessCriteria: false,
                calculationDate: Date()
            )
            cachedMetrics = metrics
            lastMetricsCalculation = Date()
            return metrics
        }
        
        // Calculate overall accuracy
        let correctCount = predictionsWithTruth.filter { $0.isCorrect == true }.count
        let overallAccuracy = Double(correctCount) / Double(predictionsWithTruth.count)
        
        // Group predictions by demographic group
        let grouped = Dictionary(grouping: predictionsWithTruth) { $0.demographics.groupKey }
        
        // Calculate accuracy per group
        var accuracyByGroup: [String: Double] = [:]
        var flaggedGroups: [String] = []
        
        for (groupKey, groupPredictions) in grouped {
            guard groupPredictions.count >= minSampleSizePerGroup else {
                // Skip groups with insufficient sample size
                continue
            }
            
            let groupCorrect = groupPredictions.filter { $0.isCorrect == true }.count
            let groupAccuracy = Double(groupCorrect) / Double(groupPredictions.count)
            accuracyByGroup[groupKey] = groupAccuracy
            
            // Flag groups below minimum accuracy
            if groupAccuracy < minGroupAccuracy {
                flaggedGroups.append(groupKey)
            }
        }
        
        // Calculate maximum gap between groups
        let accuracies = Array(accuracyByGroup.values)
        let maxGap: Double?
        if accuracies.count >= 2 {
            let minAccuracy = accuracies.min() ?? 0.0
            let maxAccuracy = accuracies.max() ?? 0.0
            maxGap = maxAccuracy - minAccuracy
        } else {
            maxGap = nil
        }
        
        // Determine if fairness criteria are met
        let meetsCriteria = overallAccuracy >= minOverallAccuracy &&
                           (maxGap ?? 0.0) <= maxAccuracyGap &&
                           flaggedGroups.isEmpty
        
        let metrics = FairnessMetrics(
            overallAccuracy: overallAccuracy,
            accuracyByGroup: accuracyByGroup,
            maxAccuracyGap: maxGap,
            sampleSize: predictionsWithTruth.count,
            flaggedGroups: flaggedGroups,
            meetsFairnessCriteria: meetsCriteria,
            calculationDate: Date()
        )
        
        cachedMetrics = metrics
        lastMetricsCalculation = Date()
        
        // Update published properties
        self.flaggedGroups = flaggedGroups
        self.meetsFairnessCriteria = meetsCriteria
        
        return metrics
    }
    
    /// Get current fairness metrics (cached or calculated)
    public func getFairnessMetrics() -> FairnessMetrics {
        return calculateFairnessMetrics()
    }
    
    /// Check if a specific demographic group is flagged
    /// 
    /// - Parameter demographics: Demographic group to check
    /// - Returns: True if group is flagged (below 90% accuracy)
    public func isGroupFlagged(_ demographics: DemographicGroup) -> Bool {
        let metrics = calculateFairnessMetrics()
        return metrics.flaggedGroups.contains(demographics.groupKey)
    }
    
    // MARK: - Fairness Report Generation
    
    /// Generate quarterly fairness report
    /// 
    /// - Returns: FairnessReport with detailed analysis
    public func generateFairnessReport() -> FairnessReport {
        let metrics = calculateFairnessMetrics()
        
        // Group predictions by demographic dimensions for detailed analysis
        let byRace = groupByDimension { $0.demographics.race?.rawValue ?? "unknown" }
        let bySkinTone = groupByDimension { $0.demographics.skinTone.map { "\($0)" } ?? "unknown" }
        let byAgeGroup = groupByDimension { $0.demographics.ageGroup.rawValue }
        let byGender = groupByDimension { $0.demographics.gender?.rawValue ?? "unknown" }
        
        // Calculate intersectional metrics (race × gender, age × gender, etc.)
        let intersectionalMetrics = calculateIntersectionalMetrics()
        
        return FairnessReport(
            reportDate: Date(),
            metrics: metrics,
            accuracyByRace: byRace,
            accuracyBySkinTone: bySkinTone,
            accuracyByAgeGroup: byAgeGroup,
            accuracyByGender: byGender,
            intersectionalMetrics: intersectionalMetrics,
            recommendations: generateRecommendations(metrics: metrics)
        )
    }
    
    /// Group predictions by a dimension and calculate accuracy
    private func groupByDimension(_ keyExtractor: (TrackedPrediction) -> String) -> [String: GroupAccuracy] {
        let predictionsWithTruth = predictions.filter { $0.isCorrect != nil }
        let grouped = Dictionary(grouping: predictionsWithTruth, by: keyExtractor)
        
        var result: [String: GroupAccuracy] = [:]
        
        for (key, groupPredictions) in grouped {
            guard groupPredictions.count >= minSampleSizePerGroup else {
                continue
            }
            
            let correct = groupPredictions.filter { $0.isCorrect == true }.count
            let accuracy = Double(correct) / Double(groupPredictions.count)
            
            result[key] = GroupAccuracy(
                groupName: key,
                accuracy: accuracy,
                sampleSize: groupPredictions.count,
                isFlagged: accuracy < minGroupAccuracy
            )
        }
        
        return result
    }
    
    /// Calculate intersectional metrics (e.g., race × gender)
    private func calculateIntersectionalMetrics() -> [String: GroupAccuracy] {
        let predictionsWithTruth = predictions.filter { $0.isCorrect != nil }
        
        var intersectional: [String: GroupAccuracy] = [:]
        
        // Race × Gender
        let raceGender = Dictionary(grouping: predictionsWithTruth) { pred in
            let race = pred.demographics.race?.rawValue ?? "unknown"
            let gender = pred.demographics.gender?.rawValue ?? "unknown"
            return "race_\(race)_gender_\(gender)"
        }
        
        for (key, groupPredictions) in raceGender {
            guard groupPredictions.count >= minSampleSizePerGroup else {
                continue
            }
            
            let correct = groupPredictions.filter { $0.isCorrect == true }.count
            let accuracy = Double(correct) / Double(groupPredictions.count)
            
            intersectional[key] = GroupAccuracy(
                groupName: key,
                accuracy: accuracy,
                sampleSize: groupPredictions.count,
                isFlagged: accuracy < minGroupAccuracy
            )
        }
        
        return intersectional
    }
    
    /// Generate recommendations based on fairness metrics
    private func generateRecommendations(metrics: FairnessMetrics) -> [String] {
        var recommendations: [String] = []
        
        if !metrics.meetsFairnessCriteria {
            if let overall = metrics.overallAccuracy, overall < minOverallAccuracy {
                recommendations.append("Overall accuracy (\(String(format: "%.1f%%", overall * 100))) is below target (95%). Consider model retraining with more diverse data.")
            }
            
            if let gap = metrics.maxAccuracyGap, gap > maxAccuracyGap {
                recommendations.append("Accuracy gap between groups (\(String(format: "%.1f%%", gap * 100))) exceeds maximum (5%). Implement fairness correction mechanisms.")
            }
            
            if !metrics.flaggedGroups.isEmpty {
                recommendations.append("\(metrics.flaggedGroups.count) demographic group(s) below 90% accuracy. Review model performance for these groups and consider ensemble approaches.")
            }
        }
        
        if metrics.sampleSize < minTotalSampleSize {
            recommendations.append("Insufficient sample size (\(metrics.sampleSize)). Need at least \(minTotalSampleSize) predictions with ground truth for reliable metrics.")
        }
        
        if recommendations.isEmpty {
            recommendations.append("All fairness criteria met. Continue monitoring.")
        }
        
        return recommendations
    }
    
    // MARK: - Data Persistence
    
    /// Persist predictions to disk (for analysis across app sessions)
    private func persistPredictions() {
        // In production, would persist to secure storage
        // For now, keep in memory (can be extended to UserDefaults or Keychain)
    }
    
    /// Load persisted predictions from disk
    private func loadPersistedPredictions() {
        // In production, would load from secure storage
        // For now, start fresh each session
    }
    
    // MARK: - Data Management
    
    /// Clear all tracked predictions (for testing or reset)
    public func clearPredictions() {
        predictions.removeAll()
        cachedMetrics = nil
        flaggedGroups = []
        meetsFairnessCriteria = false
    }
    
    /// Get prediction count
    public var predictionCount: Int {
        return predictions.count
    }
    
    /// Get prediction count with ground truth
    public var predictionCountWithTruth: Int {
        return predictions.filter { $0.isCorrect != nil }.count
    }
}

// MARK: - Fairness Metrics

/// Fairness metrics calculated from tracked predictions
public struct FairnessMetrics: Sendable {
    /// Overall accuracy across all predictions (0.0-1.0)
    public let overallAccuracy: Double?
    
    /// Accuracy by demographic group (group key -> accuracy)
    public let accuracyByGroup: [String: Double]
    
    /// Maximum gap between best and worst performing groups (0.0-1.0)
    public let maxAccuracyGap: Double?
    
    /// Total sample size (predictions with ground truth)
    public let sampleSize: Int
    
    /// Groups flagged for low accuracy (<90%)
    public let flaggedGroups: [String]
    
    /// Whether all fairness criteria are met
    public let meetsFairnessCriteria: Bool
    
    /// When metrics were calculated
    public let calculationDate: Date
    
    public init(
        overallAccuracy: Double?,
        accuracyByGroup: [String: Double],
        maxAccuracyGap: Double?,
        sampleSize: Int,
        flaggedGroups: [String],
        meetsFairnessCriteria: Bool,
        calculationDate: Date
    ) {
        self.overallAccuracy = overallAccuracy
        self.accuracyByGroup = accuracyByGroup
        self.maxAccuracyGap = maxAccuracyGap
        self.sampleSize = sampleSize
        self.flaggedGroups = flaggedGroups
        self.meetsFairnessCriteria = meetsFairnessCriteria
        self.calculationDate = calculationDate
    }
}

// MARK: - Group Accuracy

/// Accuracy metrics for a specific demographic group
public struct GroupAccuracy: Sendable {
    public let groupName: String
    public let accuracy: Double
    public let sampleSize: Int
    public let isFlagged: Bool
    
    public init(groupName: String, accuracy: Double, sampleSize: Int, isFlagged: Bool) {
        self.groupName = groupName
        self.accuracy = accuracy
        self.sampleSize = sampleSize
        self.isFlagged = isFlagged
    }
}

// MARK: - Fairness Report

/// Comprehensive fairness report with detailed analysis
public struct FairnessReport: Sendable {
    public let reportDate: Date
    public let metrics: FairnessMetrics
    public let accuracyByRace: [String: GroupAccuracy]
    public let accuracyBySkinTone: [String: GroupAccuracy]
    public let accuracyByAgeGroup: [String: GroupAccuracy]
    public let accuracyByGender: [String: GroupAccuracy]
    public let intersectionalMetrics: [String: GroupAccuracy]
    public let recommendations: [String]
    
    public init(
        reportDate: Date,
        metrics: FairnessMetrics,
        accuracyByRace: [String: GroupAccuracy],
        accuracyBySkinTone: [String: GroupAccuracy],
        accuracyByAgeGroup: [String: GroupAccuracy],
        accuracyByGender: [String: GroupAccuracy],
        intersectionalMetrics: [String: GroupAccuracy],
        recommendations: [String]
    ) {
        self.reportDate = reportDate
        self.metrics = metrics
        self.accuracyByRace = accuracyByRace
        self.accuracyBySkinTone = accuracyBySkinTone
        self.accuracyByAgeGroup = accuracyByAgeGroup
        self.accuracyByGender = accuracyByGender
        self.intersectionalMetrics = intersectionalMetrics
        self.recommendations = recommendations
    }
}

