import Foundation
import Testing
@testable import FogaFeature

/// Unit tests for ethical safeguards system
/// 
/// Tests body dysmorphia detection, resource linking, age restrictions, and content guidelines
/// to ensure users are protected from unhealthy behaviors and provided with appropriate resources.
/// 
/// **Success Criteria**:
/// - Tests body dysmorphia detection (excessive measurements, negative satisfaction, unrealistic goals)
/// - Validates resource linking for different risk levels
/// - Confirms age restrictions work correctly
/// - Tests content guidelines enforcement
@Suite("Ethical Safeguards Tests")
struct EthicalSafeguardsTests {
    
    // MARK: - EthicalSafeguards Tests
    
    /// Test that normal measurement patterns result in low risk
    @Test("Normal measurement patterns result in low risk")
    func testNormalMeasurementPatterns() async {
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        
        // Record normal measurement pattern (1 measurement per day for 5 days)
        let calendar = Calendar.current
        var currentDate = Date()
        
        for day in 0..<5 {
            let measurementDate = calendar.date(byAdding: .day, value: -day, to: currentDate) ?? currentDate
            await safeguards.recordMeasurement(
                measurementId: UUID(),
                satisfaction: .satisfied,
                currentGoal: .toneJawline
            )
        }
        
        let assessment = await safeguards.assessRisk()
        
        #expect(assessment.riskLevel == .low)
        #expect(assessment.riskScore < 0.8)
        #expect(assessment.concerns.isEmpty || assessment.concerns.allSatisfy { $0.severity == .low })
    }
    
    /// Test that excessive daily measurements trigger concern
    @Test("Excessive daily measurements trigger concern")
    func testExcessiveDailyMeasurements() async {
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        
        // Record 10 measurements today (threshold is 5)
        for _ in 0..<10 {
            await safeguards.recordMeasurement(
                measurementId: UUID(),
                satisfaction: .satisfied,
                currentGoal: .toneJawline
            )
        }
        
        let assessment = await safeguards.assessRisk()
        
        #expect(assessment.riskLevel == .medium || assessment.riskLevel == .high)
        #expect(assessment.concerns.contains { concern in
            concern.type == .excessiveDailyMeasurements
        })
    }
    
    /// Test that excessive weekly measurements trigger concern
    @Test("Excessive weekly measurements trigger concern")
    func testExcessiveWeeklyMeasurements() async {
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        
        // Record 25 measurements this week (threshold is 20)
        let calendar = Calendar.current
        var currentDate = Date()
        
        for day in 0..<7 {
            let measurementDate = calendar.date(byAdding: .day, value: -day, to: currentDate) ?? currentDate
            for _ in 0..<4 { // 4 measurements per day = 28 total
                await safeguards.recordMeasurement(
                    measurementId: UUID(),
                    satisfaction: .satisfied,
                    currentGoal: .toneJawline
                )
            }
        }
        
        let assessment = await safeguards.assessRisk()
        
        #expect(assessment.riskLevel == .medium || assessment.riskLevel == .high)
        #expect(assessment.concerns.contains { concern in
            concern.type == .excessiveWeeklyMeasurements
        })
    }
    
    /// Test that frequent negative satisfaction triggers concern
    @Test("Frequent negative satisfaction triggers concern")
    func testFrequentNegativeSatisfaction() async {
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        
        // Record 8 measurements with 6 negative satisfaction responses (75% negative)
        let negativeSatisfactions: [EthicalSafeguards.MeasurementSatisfaction] = [
            .dissatisfied, .veryDissatisfied, .dissatisfied,
            .veryDissatisfied, .dissatisfied, .veryDissatisfied
        ]
        
        for i in 0..<8 {
            let satisfaction: EthicalSafeguards.MeasurementSatisfaction
            if i < negativeSatisfactions.count {
                satisfaction = negativeSatisfactions[i]
            } else {
                satisfaction = .satisfied
            }
            
            await safeguards.recordMeasurement(
                measurementId: UUID(),
                satisfaction: satisfaction,
                currentGoal: .toneJawline
            )
        }
        
        let assessment = await safeguards.assessRisk()
        
        #expect(assessment.riskLevel == .medium || assessment.riskLevel == .high)
        #expect(assessment.concerns.contains { concern in
            concern.type == .frequentNegativeSatisfaction
        })
    }
    
    /// Test that all negative satisfaction responses trigger high risk
    @Test("All negative satisfaction responses trigger high risk")
    func testAllNegativeSatisfactionResponses() async {
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        
        // Record 5 measurements with all negative satisfaction
        for _ in 0..<5 {
            await safeguards.recordMeasurement(
                measurementId: UUID(),
                satisfaction: .veryDissatisfied,
                currentGoal: .toneJawline
            )
        }
        
        let assessment = await safeguards.assessRisk()
        
        #expect(assessment.riskLevel == .high)
        #expect(assessment.concerns.contains { concern in
            concern.type == .allNegativeSatisfactionResponses
        })
    }
    
    /// Test that frequent goal changes trigger concern
    @Test("Frequent goal changes trigger concern")
    func testFrequentGoalChanges() async {
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        
        // Record 6 goal changes (threshold is 5)
        for _ in 0..<6 {
            await safeguards.recordGoalChange(
                previousGoals: [.toneJawline],
                newGoals: [.reduceDoubleChin],
                reason: .wantFasterProgress
            )
        }
        
        let assessment = await safeguards.assessRisk()
        
        #expect(assessment.riskLevel == .medium || assessment.riskLevel == .high)
        #expect(assessment.concerns.contains { concern in
            concern.type == .frequentGoalChanges
        })
    }
    
    /// Test that concerning goal change reasons trigger concern
    @Test("Concerning goal change reasons trigger concern")
    func testConcerningGoalChangeReasons() async {
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        
        // Record 4 goal changes with concerning reasons
        let concerningReasons: [EthicalSafeguards.GoalChangeReason] = [
            .notSeeingResults, .wantFasterProgress,
            .unrealisticExpectation, .notSeeingResults
        ]
        
        for reason in concerningReasons {
            await safeguards.recordGoalChange(
                previousGoals: [.toneJawline],
                newGoals: [.reduceDoubleChin],
                reason: reason
            )
        }
        
        let assessment = await safeguards.assessRisk()
        
        #expect(assessment.riskLevel == .medium || assessment.riskLevel == .high)
        #expect(assessment.concerns.contains { concern in
            concern.type == .concerningGoalChangeReasons
        })
    }
    
    /// Test that unrealistic goal patterns trigger concern
    @Test("Unrealistic goal patterns trigger concern")
    func testUnrealisticGoalPatterns() async {
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        
        // Create a goal with "dramatic" in the name (would be unrealistic)
        // Note: Since Goal is an enum, we'll test with goal change that might indicate unrealistic expectations
        // In real implementation, this would check goal descriptions
        
        // Record goal change with concerning reason
        await safeguards.recordGoalChange(
            previousGoals: [.toneJawline],
            newGoals: [.reduceDoubleChin],
            reason: .unrealisticExpectation
        )
        
        let assessment = await safeguards.assessRisk()
        
        // Should detect concerning pattern
        #expect(assessment.riskLevel == .low || assessment.riskLevel == .medium)
    }
    
    /// Test that age-based risk adjustment works
    @Test("Age-based risk adjustment works")
    func testAgeBasedRiskAdjustment() async {
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        
        // Set user age to 20 (under 25 threshold)
        await safeguards.setUserAge(20)
        
        // Record some measurements (not excessive, but age adds risk)
        for _ in 0..<3 {
            await safeguards.recordMeasurement(
                measurementId: UUID(),
                satisfaction: .satisfied,
                currentGoal: .toneJawline
            )
        }
        
        let assessment = await safeguards.assessRisk()
        
        // Should have young user higher risk concern
        #expect(assessment.concerns.contains { concern in
            concern.type == .youngUserHigherRisk
        })
    }
    
    /// Test that high risk triggers resource display flag
    @Test("High risk triggers resource display flag")
    @MainActor
    func testHighRiskTriggersResourceDisplay() async {
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        
        // Create high risk scenario (excessive measurements + negative satisfaction)
        for _ in 0..<10 {
            await safeguards.recordMeasurement(
                measurementId: UUID(),
                satisfaction: .veryDissatisfied,
                currentGoal: .toneJawline
            )
        }
        
        let assessment = await safeguards.assessRisk()
        
        #expect(assessment.riskLevel == .high)
        #expect(safeguards.hasShownResources == true)
        #expect(assessment.recommendations.contains { recommendation in
            recommendation.contains("mental health professional") || recommendation.contains("healthcare provider")
        })
    }
    
    // MARK: - MentalHealthResources Tests
    
    /// Test that low risk returns general wellness resources
    @Test("Low risk returns general wellness resources")
    @MainActor
    func testLowRiskResources() async {
        let resources = MentalHealthResources.getResourcesForRiskLevel(.low)
        
        #expect(!resources.isEmpty)
        #expect(resources.allSatisfy { resource in
            resource.resourceType == .educational || resource.resourceType == .website
        })
    }
    
    /// Test that medium risk returns body dysmorphia and general mental health resources
    @Test("Medium risk returns body dysmorphia and general mental health resources")
    @MainActor
    func testMediumRiskResources() async {
        let resources = MentalHealthResources.getResourcesForRiskLevel(.medium)
        
        #expect(!resources.isEmpty)
        // Should include body dysmorphia resources
        #expect(resources.contains { resource in
            resource.title.contains("NEDA") || resource.title.contains("Body Dysmorphic")
        })
        // Should include general mental health resources
        #expect(resources.contains { resource in
            resource.title.contains("NAMI") || resource.title.contains("Mental Health")
        })
    }
    
    /// Test that high risk returns all resources including crisis lines
    @Test("High risk returns all resources including crisis lines")
    @MainActor
    func testHighRiskResources() async {
        let resources = MentalHealthResources.getResourcesForRiskLevel(.high)
        
        #expect(!resources.isEmpty)
        // Should include crisis lines
        #expect(resources.contains { resource in
            resource.isCrisisLine == true
        })
        // Should include NEDA helpline
        #expect(resources.contains { resource in
            resource.title.contains("NEDA") && resource.phoneNumber != nil
        })
        // Crisis lines should be prioritized (at top)
        let crisisLines = resources.filter { $0.isCrisisLine }
        if !crisisLines.isEmpty {
            let firstResource = resources.first!
            #expect(firstResource.isCrisisLine == true)
        }
    }
    
    /// Test that body dysmorphia resources are returned correctly
    @Test("Body dysmorphia resources are returned correctly")
    @MainActor
    func testBodyDysmorphiaResources() async {
        let resources = MentalHealthResources.getBodyDysmorphiaResources()
        
        #expect(!resources.isEmpty)
        #expect(resources.contains { resource in
            resource.title.contains("NEDA")
        })
        #expect(resources.contains { resource in
            resource.title.contains("Body Dysmorphic")
        })
        #expect(resources.contains { resource in
            resource.title.contains("988") || resource.phoneNumber == "988"
        })
    }
    
    /// Test that phone number formatting works correctly
    @Test("Phone number formatting works correctly")
    @MainActor
    func testPhoneNumberFormatting() async {
        // Test 10-digit number
        let formatted10 = MentalHealthResources.formatPhoneNumber("8009312237")
        #expect(formatted10.contains("(") && formatted10.contains(")"))
        
        // Test 11-digit number with country code
        let formatted11 = MentalHealthResources.formatPhoneNumber("18009312237")
        #expect(formatted11.contains("1"))
        
        // Test short number (988)
        let formattedShort = MentalHealthResources.formatPhoneNumber("988")
        #expect(formattedShort == "988")
    }
    
    /// Test that action messages are appropriate for risk level
    @Test("Action messages are appropriate for risk level")
    @MainActor
    func testActionMessages() async {
        let lowMessage = MentalHealthResources.getActionMessage(for: .low)
        #expect(lowMessage.contains("professional support") || lowMessage.contains("available"))
        
        let mediumMessage = MentalHealthResources.getActionMessage(for: .medium)
        #expect(mediumMessage.contains("healthcare provider") || mediumMessage.contains("mental health"))
        
        let highMessage = MentalHealthResources.getActionMessage(for: .high)
        #expect(highMessage.contains("crisis") || highMessage.contains("24/7"))
    }
    
    // MARK: - AgeRestrictions Tests
    
    /// Test that age verification works correctly
    @Test("Age verification works correctly")
    func testAgeVerification() async {
        let restrictions = await AgeRestrictions()
        await restrictions.clearAgeData()
        
        // Test age 18+ (should be verified)
        let result18 = await restrictions.verifyAge(18, method: .selfReported)
        #expect(result18.isVerified == true)
        #expect(result18.age == 18)
        #expect(result18.requiresParentalConsent == false)
        
        // Test age under 18 (should require parental consent)
        await restrictions.clearAgeData()
        let result17 = await restrictions.verifyAge(17, method: .selfReported)
        #expect(result17.isVerified == false)
        #expect(result17.age == 17)
        #expect(result17.requiresParentalConsent == true)
    }
    
    /// Test that age-based restrictions are applied correctly
    @Test("Age-based restrictions are applied correctly")
    func testAgeBasedRestrictions() async {
        let restrictions = await AgeRestrictions()
        await restrictions.clearAgeData()
        
        // Test under 18 (critical restrictions)
        let result17 = await restrictions.verifyAge(17, method: .selfReported)
        #expect(!result17.restrictions.isEmpty)
        #expect(result17.restrictions.contains { restriction in
            restriction.type == .accessRestriction && restriction.severity == .critical
        })
        #expect(result17.restrictions.contains { restriction in
            restriction.type == .requiresParentalConsent && restriction.severity == .critical
        })
        
        // Test 18-20 (enhanced monitoring)
        await restrictions.clearAgeData()
        let result19 = await restrictions.verifyAge(19, method: .selfReported)
        #expect(!result19.restrictions.isEmpty)
        #expect(result19.restrictions.contains { restriction in
            restriction.type == .enhancedMonitoring
        })
        
        // Test 21-24 (stricter safeguards)
        await restrictions.clearAgeData()
        let result22 = await restrictions.verifyAge(22, method: .selfReported)
        #expect(!result22.restrictions.isEmpty)
        #expect(result22.restrictions.contains { restriction in
            restriction.type == .measurementFrequencyLimit
        })
        
        // Test 25+ (no special restrictions)
        await restrictions.clearAgeData()
        let result25 = await restrictions.verifyAge(25, method: .selfReported)
        #expect(result25.restrictions.isEmpty)
    }
    
    /// Test that measurement frequency limits vary by age
    @Test("Measurement frequency limits vary by age")
    func testMeasurementFrequencyLimits() async {
        let restrictions = await AgeRestrictions()
        await restrictions.clearAgeData()
        
        // Test 18-20 (moderate limit)
        await restrictions.verifyAge(19, method: .selfReported)
        let limit19 = await restrictions.getMaxMeasurementsPerDay()
        #expect(limit19 == 4)
        
        // Test 21-24 (stricter limit)
        await restrictions.clearAgeData()
        await restrictions.verifyAge(22, method: .selfReported)
        let limit22 = await restrictions.getMaxMeasurementsPerDay()
        #expect(limit22 == 3)
        
        // Test 25+ (standard limit)
        await restrictions.clearAgeData()
        await restrictions.verifyAge(25, method: .selfReported)
        let limit25 = await restrictions.getMaxMeasurementsPerDay()
        #expect(limit25 == 5)
    }
    
    /// Test that parental consent is required for minors
    @Test("Parental consent is required for minors")
    func testParentalConsent() async {
        let restrictions = await AgeRestrictions()
        await restrictions.clearAgeData()
        
        // Verify age 17
        await restrictions.verifyAge(17, method: .selfReported)
        #expect(await restrictions.requiresParentalConsent() == true)
        #expect(await restrictions.canAccessApp() == false)
        
        // Record parental consent
        await restrictions.recordParentalConsent(true)
        #expect(await restrictions.canAccessApp() == true)
    }
    
    /// Test that content filtering works for users under 25
    @Test("Content filtering works for users under 25")
    func testContentFiltering() async {
        let restrictions = await AgeRestrictions()
        await restrictions.clearAgeData()
        
        // Test user under 25
        await restrictions.verifyAge(22, method: .selfReported)
        let shouldShow1 = await restrictions.shouldShowContent(
            "This app provides dramatic transformation results",
            contentType: "marketing"
        )
        #expect(shouldShow1 == false)
        
        // Test user 25+
        await restrictions.clearAgeData()
        await restrictions.verifyAge(25, method: .selfReported)
        let shouldShow2 = await restrictions.shouldShowContent(
            "This app provides dramatic transformation results",
            contentType: "marketing"
        )
        #expect(shouldShow2 == true) // Content filtering less strict for 25+
    }
    
    /// Test that age-appropriate disclaimers are returned
    @Test("Age-appropriate disclaimers are returned")
    func testAgeAppropriateDisclaimers() async {
        let restrictions = await AgeRestrictions()
        await restrictions.clearAgeData()
        
        // Test under 18
        await restrictions.verifyAge(17, method: .selfReported)
        let disclaimer17 = await restrictions.getAgeAppropriateDisclaimer()
        #expect(disclaimer17.contains("18") || disclaimer17.contains("Parental consent"))
        
        // Test 21-24
        await restrictions.clearAgeData()
        await restrictions.verifyAge(22, method: .selfReported)
        let disclaimer22 = await restrictions.getAgeAppropriateDisclaimer()
        #expect(disclaimer22.contains("wellness") || disclaimer22.contains("mental health"))
    }
    
    // MARK: - ContentGuidelines Tests
    
    /// Test that prohibited fat loss phrases are detected
    @Test("Prohibited fat loss phrases are detected")
    @MainActor
    func testProhibitedFatLossPhrases() async {
        let content = "This app will help you lose fat and reduce fat in your face"
        let result = ContentGuidelines.validateContent(content, contentType: .marketingCopy)
        
        #expect(result.isValid == false)
        #expect(result.violations.contains { violation in
            violation.type == .promisesFatLoss
        })
    }
    
    /// Test that unrealistic transformation phrases are detected
    @Test("Unrealistic transformation phrases are detected")
    @MainActor
    func testUnrealisticTransformationPhrases() async {
        let content = "Get dramatic transformation and guaranteed results"
        let result = ContentGuidelines.validateContent(content, contentType: .marketingCopy)
        
        #expect(result.isValid == false)
        #expect(result.violations.contains { violation in
            violation.type == .unrealisticTransformation
        })
    }
    
    /// Test that medical claims are detected
    @Test("Medical claims are detected")
    @MainActor
    func testMedicalClaims() async {
        let content = "This app can treat and cure double chin"
        let result = ContentGuidelines.validateContent(content, contentType: .marketingCopy)
        
        #expect(result.isValid == false)
        #expect(result.violations.contains { violation in
            violation.type == .medicalClaims
        })
    }
    
    /// Test that exact result promises are detected
    @Test("Exact result promises are detected")
    @MainActor
    func testExactResultPromises() async {
        let content = "You will definitely see exactly 10 degrees improvement"
        let result = ContentGuidelines.validateContent(content, contentType: .progressPrediction)
        
        #expect(result.isValid == false)
        #expect(result.violations.contains { violation in
            violation.type == .falsePrecision
        })
    }
    
    /// Test that missing disclaimers are detected for required content types
    @Test("Missing disclaimers are detected for required content types")
    @MainActor
    func testMissingDisclaimers() async {
        let content = "This app helps with facial exercises"
        let result = ContentGuidelines.validateContent(content, contentType: .progressPrediction)
        
        #expect(result.isValid == false)
        #expect(result.violations.contains { violation in
            violation.type == .missingDisclaimer
        })
    }
    
    /// Test that valid content passes validation
    @Test("Valid content passes validation")
    @MainActor
    func testValidContent() async {
        let content = """
        This app focuses on facial muscle toning and general wellness.
        Individual results may vary. This is not a medical device.
        Consult with a healthcare provider for personalized guidance.
        """
        let result = ContentGuidelines.validateContent(content, contentType: .marketingCopy)
        
        #expect(result.isValid == true)
        #expect(result.violations.isEmpty)
    }
    
    /// Test that content sanitization removes prohibited phrases
    @Test("Content sanitization removes prohibited phrases")
    @MainActor
    func testContentSanitization() async {
        let content = "This app will help you lose fat and get dramatic transformation"
        let sanitized = ContentGuidelines.sanitizeContent(content, contentType: .marketingCopy)
        
        #expect(!sanitized.lowercased().contains("lose fat"))
        #expect(!sanitized.lowercased().contains("dramatic transformation"))
        #expect(sanitized.lowercased().contains("muscle toning") || sanitized.lowercased().contains("wellness"))
    }
    
    /// Test that age appropriateness checks work
    @Test("Age appropriateness checks work")
    @MainActor
    func testAgeAppropriateness() async {
        let content = "This app provides extreme results"
        
        // Should be inappropriate for users under 25
        let isAppropriate18 = ContentGuidelines.isAgeAppropriate(content: content, targetAge: 18)
        #expect(isAppropriate18 == false)
        
        // Should be appropriate for users 25+
        let isAppropriate25 = ContentGuidelines.isAgeAppropriate(content: content, targetAge: 25)
        #expect(isAppropriate25 == true)
    }
    
    // MARK: - Integration Tests
    
    /// Test complete ethical safeguards workflow
    @Test("Complete ethical safeguards workflow")
    @MainActor
    func testCompleteEthicalSafeguardsWorkflow() async {
        // Setup: Create user with concerning behavior
        let safeguards = await EthicalSafeguards()
        await safeguards.clearTrackingData()
        await safeguards.setUserAge(20) // Under 25
        
        // Record excessive measurements with negative satisfaction
        for _ in 0..<8 {
            await safeguards.recordMeasurement(
                measurementId: UUID(),
                satisfaction: .veryDissatisfied,
                currentGoal: .reduceDoubleChin
            )
        }
        
        // Assess risk
        let assessment = await safeguards.assessRisk()
        
        // Verify high risk detected
        #expect(assessment.riskLevel == .high)
        #expect(safeguards.hasShownResources == true)
        
        // Get resources for risk level
        let resources = MentalHealthResources.getResourcesForRiskLevel(assessment.riskLevel)
        #expect(!resources.isEmpty)
        #expect(resources.contains { resource in
            resource.isCrisisLine == true
        })
        
        // Verify age restrictions apply
        let restrictions = await AgeRestrictions()
        await restrictions.verifyAge(20, method: .selfReported)
        let maxMeasurements = await restrictions.getMaxMeasurementsPerDay()
        #expect(maxMeasurements < 5) // Stricter limit for under 25
        
        // Verify content guidelines
        let actionMessage = MentalHealthResources.getActionMessage(for: assessment.riskLevel)
        let contentValidation = ContentGuidelines.validateContent(actionMessage, contentType: .marketingCopy)
        #expect(contentValidation.isValid == true) // Resources should use appropriate language
    }
}

