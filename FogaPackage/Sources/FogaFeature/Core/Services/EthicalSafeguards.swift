import Foundation
import Combine

/// Service for screening and protecting users from body dysmorphia and unhealthy behaviors
/// 
/// **Critical Purpose**: Detects concerning patterns in user behavior and provides appropriate
/// mental health resources. Never promises dramatic transformations or encourages unhealthy
/// measurement obsessions.
/// 
/// **Screening Criteria**:
/// - Excessive measurements: >5 per day indicates obsessive behavior
/// - Unrealistic goals: Goals that promise dramatic fat loss
/// - Negative self-talk patterns: Frequent negative goal setting or measurement dissatisfaction
/// - Age-based safeguards: Stricter monitoring for users under 25
/// 
/// **Risk Levels**:
/// - Low: Normal usage patterns, no concerns
/// - Medium: Some concerning patterns detected, provide gentle guidance
/// - High: Multiple red flags, provide mental health resources immediately
@available(iOS 15.0, *)
@MainActor
public class EthicalSafeguards: ObservableObject {
    
    // MARK: - Risk Thresholds
    
    /// Maximum healthy measurements per day (5)
    /// Exceeding this indicates potential obsessive behavior
    private let maxMeasurementsPerDay: Int = 5
    
    /// Maximum healthy measurements per week (20)
    private let maxMeasurementsPerWeek: Int = 20
    
    /// Minimum days between measurements for healthy usage (1 day)
    private let minDaysBetweenMeasurements: Double = 1.0
    
    /// Number of consecutive days with excessive measurements to flag
    private let excessiveMeasurementDaysThreshold: Int = 3
    
    /// Age threshold for stricter safeguards (25 years)
    private let stricterSafeguardsAgeThreshold: Int = 25
    
    // MARK: - Behavior Tracking
    
    /// Tracked measurement event
    private struct MeasurementEvent: Codable, Sendable {
        let timestamp: Date
        let measurementId: UUID
        let userSatisfaction: MeasurementSatisfaction?
        let goalAtTime: Goal?
        
        init(
            timestamp: Date = Date(),
            measurementId: UUID,
            userSatisfaction: MeasurementSatisfaction? = nil,
            goalAtTime: Goal? = nil
        ) {
            self.timestamp = timestamp
            self.measurementId = measurementId
            self.userSatisfaction = userSatisfaction
            self.goalAtTime = goalAtTime
        }
    }
    
    /// User satisfaction with measurement result
    public enum MeasurementSatisfaction: String, Codable, Sendable {
        case verySatisfied = "very_satisfied"
        case satisfied = "satisfied"
        case neutral = "neutral"
        case dissatisfied = "dissatisfied"
        case veryDissatisfied = "very_dissatisfied"
        
        /// Check if satisfaction indicates concern
        var isConcerning: Bool {
            return self == .dissatisfied || self == .veryDissatisfied
        }
    }
    
    /// Tracked goal change event
    private struct GoalChangeEvent: Codable, Sendable {
        let timestamp: Date
        let previousGoals: [Goal]
        let newGoals: [Goal]
        let reason: GoalChangeReason?
        
        init(
            timestamp: Date = Date(),
            previousGoals: [Goal],
            newGoals: [Goal],
            reason: GoalChangeReason? = nil
        ) {
            self.timestamp = timestamp
            self.previousGoals = previousGoals
            self.newGoals = newGoals
            self.reason = reason
        }
    }
    
    /// Reason for goal change
    public enum GoalChangeReason: String, Codable, Sendable {
        case notSeeingResults = "not_seeing_results"
        case wantFasterProgress = "want_faster_progress"
        case unrealisticExpectation = "unrealistic_expectation"
        case normalUpdate = "normal_update"
        case other = "other"
        
        /// Check if reason indicates concern
        var isConcerning: Bool {
            return self == .notSeeingResults || 
                   self == .wantFasterProgress || 
                   self == .unrealisticExpectation
        }
    }
    
    // MARK: - State
    
    /// All tracked measurement events
    private var measurementEvents: [MeasurementEvent] = []
    
    /// All tracked goal change events
    private var goalChangeEvents: [GoalChangeEvent] = []
    
    /// Current risk assessment
    @Published public var currentRiskLevel: RiskLevel = .low
    
    /// Risk assessment details
    @Published public var riskAssessment: RiskAssessment?
    
    /// Whether user has been shown mental health resources
    @Published public var hasShownResources: Bool = false
    
    /// User's age (for age-based safeguards)
    private var userAge: Int?
    
    public init() {
        loadPersistedData()
        // Perform initial risk assessment
        Task {
            await assessRisk()
        }
    }
    
    // MARK: - Measurement Tracking
    
    /// Record a measurement event for screening
    /// 
    /// - Parameters:
    ///   - measurementId: Unique identifier for the measurement
    ///   - satisfaction: User's satisfaction with the result (optional)
    ///   - currentGoal: User's current goal at time of measurement
    public func recordMeasurement(
        measurementId: UUID,
        satisfaction: MeasurementSatisfaction? = nil,
        currentGoal: Goal? = nil
    ) {
        let event = MeasurementEvent(
            measurementId: measurementId,
            userSatisfaction: satisfaction,
            goalAtTime: currentGoal
        )
        
        measurementEvents.append(event)
        
        // Persist data
        persistData()
        
        // Reassess risk after recording
        Task {
            await assessRisk()
        }
    }
    
    // MARK: - Goal Change Tracking
    
    /// Record a goal change event for screening
    /// 
    /// - Parameters:
    ///   - previousGoals: User's previous goals
    ///   - newGoals: User's new goals
    ///   - reason: Reason for the change (optional)
    public func recordGoalChange(
        previousGoals: [Goal],
        newGoals: [Goal],
        reason: GoalChangeReason? = nil
    ) {
        let event = GoalChangeEvent(
            previousGoals: previousGoals,
            newGoals: newGoals,
            reason: reason
        )
        
        goalChangeEvents.append(event)
        
        // Persist data
        persistData()
        
        // Reassess risk after recording
        Task {
            await assessRisk()
        }
    }
    
    // MARK: - Risk Assessment
    
    /// Assess user's risk level based on behavior patterns
    /// 
    /// **Screening Patterns**:
    /// - Excessive measurements (>5/day, >20/week)
    /// - Frequent negative satisfaction responses
    /// - Unrealistic goal changes
    /// - Age-based risk (users under 25 at higher risk)
    @discardableResult
    public func assessRisk() async -> RiskAssessment {
        var concerns: [RiskConcern] = []
        var riskScore: Double = 0.0
        
        // Check measurement frequency
        let measurementConcerns = checkMeasurementFrequency()
        concerns.append(contentsOf: measurementConcerns)
        riskScore += Double(measurementConcerns.count) * 0.3
        
        // Check satisfaction patterns
        let satisfactionConcerns = checkSatisfactionPatterns()
        concerns.append(contentsOf: satisfactionConcerns)
        riskScore += Double(satisfactionConcerns.count) * 0.4
        
        // Check goal change patterns
        let goalConcerns = checkGoalChangePatterns()
        concerns.append(contentsOf: goalConcerns)
        riskScore += Double(goalConcerns.count) * 0.3
        
        // Age-based risk adjustment
        if let age = userAge, age < stricterSafeguardsAgeThreshold {
            concerns.append(.youngUserHigherRisk)
            riskScore += 0.2
        }
        
        // Determine risk level
        let riskLevel: RiskLevel
        if riskScore >= 1.5 || concerns.contains(where: { $0.severity == .high }) {
            riskLevel = .high
        } else if riskScore >= 0.8 || concerns.contains(where: { $0.severity == .medium }) {
            riskLevel = .medium
        } else {
            riskLevel = .low
        }
        
        let assessment = RiskAssessment(
            riskLevel: riskLevel,
            riskScore: riskScore,
            concerns: concerns,
            assessmentDate: Date(),
            recommendations: generateRecommendations(riskLevel: riskLevel, concerns: concerns)
        )
        
        currentRiskLevel = riskLevel
        riskAssessment = assessment
        
        return assessment
    }
    
    /// Check measurement frequency for concerning patterns
    private func checkMeasurementFrequency() -> [RiskConcern] {
        var concerns: [RiskConcern] = []
        
        let now = Date()
        let calendar = Calendar.current
        
        // Check measurements today
        let todayStart = calendar.startOfDay(for: now)
        let measurementsToday = measurementEvents.filter { $0.timestamp >= todayStart }.count
        
        if measurementsToday > maxMeasurementsPerDay {
            concerns.append(.excessiveDailyMeasurements(count: measurementsToday, threshold: maxMeasurementsPerDay))
        }
        
        // Check measurements this week
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let measurementsThisWeek = measurementEvents.filter { $0.timestamp >= weekAgo }.count
        
        if measurementsThisWeek > maxMeasurementsPerWeek {
            concerns.append(.excessiveWeeklyMeasurements(count: measurementsThisWeek, threshold: maxMeasurementsPerWeek))
        }
        
        // Check for consecutive days with excessive measurements
        let consecutiveDays = countConsecutiveExcessiveDays()
        if consecutiveDays >= excessiveMeasurementDaysThreshold {
            concerns.append(.consecutiveExcessiveMeasurementDays(days: consecutiveDays))
        }
        
        // Check measurement intervals (too frequent)
        if measurementEvents.count >= 2 {
            let recentMeasurements = measurementEvents.suffix(10)
            var tooFrequentCount = 0
            
            for i in 1..<recentMeasurements.count {
                let interval = recentMeasurements[i].timestamp.timeIntervalSince(recentMeasurements[i-1].timestamp)
                let daysBetween = interval / (24 * 60 * 60)
                
                if daysBetween < minDaysBetweenMeasurements {
                    tooFrequentCount += 1
                }
            }
            
            if tooFrequentCount >= 3 {
                concerns.append(.tooFrequentMeasurements)
            }
        }
        
        return concerns
    }
    
    /// Count consecutive days with excessive measurements
    private func countConsecutiveExcessiveDays() -> Int {
        let calendar = Calendar.current
        
        // Group measurements by day
        let measurementsByDay = Dictionary(grouping: measurementEvents) { event in
            calendar.startOfDay(for: event.timestamp)
        }
        
        // Sort days descending
        let sortedDays = measurementsByDay.keys.sorted(by: >)
        
        var consecutiveDays = 0
        for day in sortedDays {
            let count = measurementsByDay[day]?.count ?? 0
            if count > maxMeasurementsPerDay {
                consecutiveDays += 1
            } else {
                break // Stop counting when we hit a day without excessive measurements
            }
        }
        
        return consecutiveDays
    }
    
    /// Check satisfaction patterns for negative self-talk indicators
    private func checkSatisfactionPatterns() -> [RiskConcern] {
        var concerns: [RiskConcern] = []
        
        let recentMeasurements = measurementEvents.suffix(10)
        let satisfactionResponses = recentMeasurements.compactMap { $0.userSatisfaction }
        
        guard !satisfactionResponses.isEmpty else {
            return concerns
        }
        
        // Count concerning responses
        let concerningCount = satisfactionResponses.filter { $0.isConcerning }.count
        let concerningPercentage = Double(concerningCount) / Double(satisfactionResponses.count)
        
        if concerningPercentage >= 0.6 { // 60% or more negative responses
            concerns.append(.frequentNegativeSatisfaction(percentage: concerningPercentage))
        }
        
        // Check for all negative responses in recent measurements
        if satisfactionResponses.count >= 5 && satisfactionResponses.allSatisfy({ $0.isConcerning }) {
            concerns.append(.allNegativeSatisfactionResponses)
        }
        
        return concerns
    }
    
    /// Check goal change patterns for unrealistic expectations
    private func checkGoalChangePatterns() -> [RiskConcern] {
        var concerns: [RiskConcern] = []
        
        guard !goalChangeEvents.isEmpty else {
            return concerns
        }
        
        // Check for frequent goal changes
        let recentGoalChanges = goalChangeEvents.suffix(10)
        if recentGoalChanges.count >= 5 {
            concerns.append(.frequentGoalChanges(count: recentGoalChanges.count))
        }
        
        // Check for concerning reasons
        let concerningReasons = recentGoalChanges.filter { event in
            event.reason?.isConcerning == true
        }
        
        if concerningReasons.count >= 3 {
            concerns.append(.concerningGoalChangeReasons(count: concerningReasons.count))
        }
        
        // Check for unrealistic goal patterns
        let unrealisticGoals = recentGoalChanges.filter { event in
            // Check if user is adding goals that promise dramatic transformations
            event.newGoals.contains(where: { goal in
                goal.rawValue.lowercased().contains("dramatic") ||
                goal.rawValue.lowercased().contains("extreme")
            })
        }
        
        if !unrealisticGoals.isEmpty {
            concerns.append(.unrealisticGoalPatterns)
        }
        
        return concerns
    }
    
    // MARK: - Recommendations
    
    /// Generate recommendations based on risk level and concerns
    private func generateRecommendations(riskLevel: RiskLevel, concerns: [RiskConcern]) -> [String] {
        var recommendations: [String] = []
        
        switch riskLevel {
        case .low:
            recommendations.append("Your usage patterns look healthy. Continue using the app as a wellness tool.")
            
        case .medium:
            recommendations.append("We've noticed some patterns that may indicate you're focusing too much on measurements. Consider taking breaks between measurements.")
            recommendations.append("Remember: Facial exercises are about muscle toning and wellness, not dramatic transformations.")
            
            if concerns.contains(where: { $0.severity == .medium }) {
                recommendations.append("Consider speaking with a healthcare provider about your wellness goals.")
            }
            
        case .high:
            recommendations.append("We're concerned about your usage patterns. Please take a break from measurements.")
            recommendations.append("Consider speaking with a mental health professional or healthcare provider.")
            recommendations.append("This app is designed for general wellness, not medical treatment. If you're experiencing body image concerns, professional help is available.")
            
            // Always provide resources for high risk
            hasShownResources = true
        }
        
        return recommendations
    }
    
    // MARK: - User Age Management
    
    /// Set user's age for age-based safeguards
    /// 
    /// - Parameter age: User's age in years
    public func setUserAge(_ age: Int) {
        userAge = age
        persistData()
        
        // Reassess risk with age information
        Task {
            await assessRisk()
        }
    }
    
    // MARK: - Data Persistence
    
    /// Persist tracking data to disk
    private func persistData() {
        // In production, would persist to secure storage
        // For now, keep in memory (can be extended to UserDefaults or Keychain)
    }
    
    /// Load persisted tracking data from disk
    private func loadPersistedData() {
        // In production, would load from secure storage
        // For now, start fresh each session
    }
    
    // MARK: - Data Management
    
    /// Clear all tracking data (for testing or reset)
    public func clearTrackingData() {
        measurementEvents.removeAll()
        goalChangeEvents.removeAll()
        currentRiskLevel = .low
        riskAssessment = nil
        hasShownResources = false
    }
    
    /// Get measurement event count
    public var measurementEventCount: Int {
        return measurementEvents.count
    }
    
    /// Get goal change event count
    public var goalChangeEventCount: Int {
        return goalChangeEvents.count
    }
}

// MARK: - Risk Level

/// User risk level for body dysmorphia concerns
public enum RiskLevel: String, Codable, Sendable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    /// Display name for UI
    public var displayName: String {
        switch self {
        case .low:
            return "Low Risk"
        case .medium:
            return "Medium Risk"
        case .high:
            return "High Risk"
        }
    }
    
    /// Color for UI display
    public var colorName: String {
        switch self {
        case .low:
            return "green"
        case .medium:
            return "orange"
        case .high:
            return "red"
        }
    }
}

// MARK: - Risk Concern

/// Specific concern detected in user behavior
public struct RiskConcern: Codable, Sendable, Identifiable {
    public let id: UUID
    public let type: ConcernType
    public let severity: ConcernSeverity
    public let description: String
    public let detectedAt: Date
    
    public init(
        id: UUID = UUID(),
        type: ConcernType,
        severity: ConcernSeverity,
        description: String,
        detectedAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.severity = severity
        self.description = description
        self.detectedAt = detectedAt
    }
    
    /// Concern type enum
    public enum ConcernType: String, Codable, Sendable {
        case excessiveDailyMeasurements = "excessive_daily_measurements"
        case excessiveWeeklyMeasurements = "excessive_weekly_measurements"
        case consecutiveExcessiveMeasurementDays = "consecutive_excessive_days"
        case tooFrequentMeasurements = "too_frequent_measurements"
        case frequentNegativeSatisfaction = "frequent_negative_satisfaction"
        case allNegativeSatisfactionResponses = "all_negative_responses"
        case frequentGoalChanges = "frequent_goal_changes"
        case concerningGoalChangeReasons = "concerning_goal_reasons"
        case unrealisticGoalPatterns = "unrealistic_goal_patterns"
        case youngUserHigherRisk = "young_user_higher_risk"
    }
    
    /// Concern severity level
    public enum ConcernSeverity: String, Codable, Sendable {
        case low = "low"
        case medium = "medium"
        case high = "high"
    }
    
    /// Create concern for excessive daily measurements
    public static func excessiveDailyMeasurements(count: Int, threshold: Int) -> RiskConcern {
        return RiskConcern(
            type: .excessiveDailyMeasurements,
            severity: count > threshold * 2 ? .high : .medium,
            description: "\(count) measurements today (healthy limit: \(threshold) per day)"
        )
    }
    
    /// Create concern for excessive weekly measurements
    public static func excessiveWeeklyMeasurements(count: Int, threshold: Int) -> RiskConcern {
        return RiskConcern(
            type: .excessiveWeeklyMeasurements,
            severity: Double(count) > Double(threshold) * 1.5 ? .high : .medium,
            description: "\(count) measurements this week (healthy limit: \(threshold) per week)"
        )
    }
    
    /// Create concern for consecutive excessive measurement days
    public static func consecutiveExcessiveMeasurementDays(days: Int) -> RiskConcern {
        return RiskConcern(
            type: .consecutiveExcessiveMeasurementDays,
            severity: days >= 5 ? .high : .medium,
            description: "\(days) consecutive days with excessive measurements"
        )
    }
    
    /// Create concern for too frequent measurements
    public static var tooFrequentMeasurements: RiskConcern {
        return RiskConcern(
            type: .tooFrequentMeasurements,
            severity: .medium,
            description: "Measurements taken too frequently (less than 1 day apart)"
        )
    }
    
    /// Create concern for frequent negative satisfaction
    public static func frequentNegativeSatisfaction(percentage: Double) -> RiskConcern {
        return RiskConcern(
            type: .frequentNegativeSatisfaction,
            severity: percentage >= 0.8 ? .high : .medium,
            description: String(format: "%.0f%% of recent measurements rated as dissatisfied", percentage * 100)
        )
    }
    
    /// Create concern for all negative satisfaction responses
    public static var allNegativeSatisfactionResponses: RiskConcern {
        return RiskConcern(
            type: .allNegativeSatisfactionResponses,
            severity: .high,
            description: "All recent measurements rated as dissatisfied"
        )
    }
    
    /// Create concern for frequent goal changes
    public static func frequentGoalChanges(count: Int) -> RiskConcern {
        return RiskConcern(
            type: .frequentGoalChanges,
            severity: count >= 10 ? .high : .medium,
            description: "\(count) goal changes in recent activity"
        )
    }
    
    /// Create concern for concerning goal change reasons
    public static func concerningGoalChangeReasons(count: Int) -> RiskConcern {
        return RiskConcern(
            type: .concerningGoalChangeReasons,
            severity: count >= 5 ? .high : .medium,
            description: "\(count) goal changes due to dissatisfaction or unrealistic expectations"
        )
    }
    
    /// Create concern for unrealistic goal patterns
    public static var unrealisticGoalPatterns: RiskConcern {
        return RiskConcern(
            type: .unrealisticGoalPatterns,
            severity: .medium,
            description: "Goals set that promise dramatic or extreme transformations"
        )
    }
    
    /// Create concern for young user higher risk
    public static var youngUserHigherRisk: RiskConcern {
        return RiskConcern(
            type: .youngUserHigherRisk,
            severity: .low,
            description: "User under 25 - additional safeguards recommended"
        )
    }
}

// MARK: - Risk Assessment

/// Comprehensive risk assessment result
public struct RiskAssessment: Codable, Sendable {
    /// Current risk level
    public let riskLevel: RiskLevel
    
    /// Calculated risk score (0.0-3.0+)
    public let riskScore: Double
    
    /// Specific concerns detected
    public let concerns: [RiskConcern]
    
    /// When assessment was performed
    public let assessmentDate: Date
    
    /// Recommendations based on risk level
    public let recommendations: [String]
    
    public init(
        riskLevel: RiskLevel,
        riskScore: Double,
        concerns: [RiskConcern],
        assessmentDate: Date,
        recommendations: [String]
    ) {
        self.riskLevel = riskLevel
        self.riskScore = riskScore
        self.concerns = concerns
        self.assessmentDate = assessmentDate
        self.recommendations = recommendations
    }
}

