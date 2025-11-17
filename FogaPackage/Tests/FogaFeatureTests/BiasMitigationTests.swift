import Foundation
import Testing
@testable import FogaFeature

/// Unit tests for bias mitigation across demographics
/// 
/// Tests bias monitoring, fairness validation, and fairness correction mechanisms
/// to ensure >95% accuracy across all demographic groups with <5% gap between groups.
/// 
/// **Success Criteria**:
/// - Tests with diverse test dataset covering all demographic combinations
/// - Validates >95% accuracy across all groups
/// - Confirms <5% gap between best and worst performing groups
@Suite("Bias Mitigation Tests")
struct BiasMitigationTests {
    
    // MARK: - Helper Methods
    
    /// Create diverse test dataset with predictions across all demographic groups
    func createDiverseTestDataset() -> [(prediction: PredictionResult, metadata: ModelMetadata, groundTruth: (angle: Double, category: FatCategory))] {
        var dataset: [(prediction: PredictionResult, metadata: ModelMetadata, groundTruth: (angle: Double, category: FatCategory))] = []
        
        // Define demographic groups to test
        let ethnicities: [Ethnicity] = [.caucasian, .africanAmerican, .asian, .hispanic, .middleEastern]
        let skinTones = [1, 2, 3, 4, 5, 6] // Fitzpatrick scale
        let ageGroups = [20, 30, 40, 50, 60] // Ages representing different groups
        let genders: [Gender] = [.male, .female]
        
        // Create predictions for each demographic combination
        // Target: 30+ predictions per group (minimum for statistical significance)
        var groupCounts: [String: Int] = [:]
        
        for ethnicity in ethnicities {
            for skinTone in skinTones {
                for age in ageGroups {
                    for gender in genders {
                        let metadata = ModelMetadata(
                            age: age,
                            gender: gender,
                            ethnicity: ethnicity,
                            skinTone: skinTone,
                            measurementContext: .baseline
                        )
                        
                        let demoGroup = BiasMonitor.DemographicGroup(from: metadata)
                        let groupKey = demoGroup.groupKey
                        
                        // Generate 30 predictions per group (to meet minimum sample size)
                        for _ in 0..<30 {
                            // Create realistic predictions with slight variation
                            // Most predictions should be correct (to achieve >95% accuracy)
                            let isCorrect = Double.random(in: 0...1) < 0.96 // 96% accuracy target
                            
                            let groundTruthAngle = Double.random(in: 90...130)
                            let groundTruthCategory = FatCategory(from: groundTruthAngle)
                            
                            let predictedAngle: Double
                            let predictedCategory: FatCategory
                            
                            if isCorrect {
                                // Correct prediction: small variation (±2°)
                                predictedAngle = groundTruthAngle + Double.random(in: -2...2)
                                predictedCategory = groundTruthCategory
                            } else {
                                // Incorrect prediction: larger variation
                                predictedAngle = groundTruthAngle + Double.random(in: -10...10)
                                predictedCategory = FatCategory(from: predictedAngle)
                            }
                            
                            let prediction = PredictionResult(
                                cervicoMentalAngle: predictedAngle,
                                angleConfidenceInterval: (predictedAngle - 5, predictedAngle + 5),
                                fatCategory: predictedCategory,
                                categoryConfidence: isCorrect ? 0.9 : 0.6,
                                overallConfidence: isCorrect ? 0.95 : 0.7,
                                uncertainty: isCorrect ? 0.1 : 0.3
                            )
                            
                            dataset.append((
                                prediction: prediction,
                                metadata: metadata,
                                groundTruth: (angle: groundTruthAngle, category: groundTruthCategory)
                            ))
                            
                            groupCounts[groupKey, default: 0] += 1
                        }
                    }
                }
            }
        }
        
        return dataset
    }
    
    /// Create biased test dataset (one group performs poorly)
    func createBiasedTestDataset() -> [(prediction: PredictionResult, metadata: ModelMetadata, groundTruth: (angle: Double, category: FatCategory))] {
        var dataset: [(prediction: PredictionResult, metadata: ModelMetadata, groundTruth: (angle: Double, category: FatCategory))] = []
        
        // Create two groups: one with high accuracy, one with low accuracy
        let highAccuracyGroup = ModelMetadata(
            age: 30,
            gender: .male,
            ethnicity: .caucasian,
            skinTone: 2,
            measurementContext: .baseline
        )
        
        let lowAccuracyGroup = ModelMetadata(
            age: 30,
            gender: .female,
            ethnicity: .africanAmerican,
            skinTone: 5,
            measurementContext: .baseline
        )
        
        // High accuracy group: 98% accuracy
        for _ in 0..<100 {
            let groundTruthAngle = Double.random(in: 90...130)
            let groundTruthCategory = FatCategory(from: groundTruthAngle)
            let isCorrect = Double.random(in: 0...1) < 0.98
            
            let predictedAngle = isCorrect ? groundTruthAngle + Double.random(in: -2...2) : groundTruthAngle + Double.random(in: -10...10)
            let predictedCategory = FatCategory(from: predictedAngle)
            
            let prediction = PredictionResult(
                cervicoMentalAngle: predictedAngle,
                angleConfidenceInterval: (predictedAngle - 5, predictedAngle + 5),
                fatCategory: predictedCategory,
                categoryConfidence: isCorrect ? 0.9 : 0.6,
                overallConfidence: isCorrect ? 0.95 : 0.7,
                uncertainty: isCorrect ? 0.1 : 0.3
            )
            
            dataset.append((
                prediction: prediction,
                metadata: highAccuracyGroup,
                groundTruth: (angle: groundTruthAngle, category: groundTruthCategory)
            ))
        }
        
        // Low accuracy group: 85% accuracy (below 90% threshold)
        for _ in 0..<100 {
            let groundTruthAngle = Double.random(in: 90...130)
            let groundTruthCategory = FatCategory(from: groundTruthAngle)
            let isCorrect = Double.random(in: 0...1) < 0.85
            
            let predictedAngle = isCorrect ? groundTruthAngle + Double.random(in: -2...2) : groundTruthAngle + Double.random(in: -10...10)
            let predictedCategory = FatCategory(from: predictedAngle)
            
            let prediction = PredictionResult(
                cervicoMentalAngle: predictedAngle,
                angleConfidenceInterval: (predictedAngle - 5, predictedAngle + 5),
                fatCategory: predictedCategory,
                categoryConfidence: isCorrect ? 0.9 : 0.6,
                overallConfidence: isCorrect ? 0.95 : 0.7,
                uncertainty: isCorrect ? 0.1 : 0.3
            )
            
            dataset.append((
                prediction: prediction,
                metadata: lowAccuracyGroup,
                groundTruth: (angle: groundTruthAngle, category: groundTruthCategory)
            ))
        }
        
        return dataset
    }
    
    // MARK: - BiasMonitor Tests
    
    @Test("BiasMonitor records predictions correctly")
    @MainActor
    func biasMonitorRecordsPredictions() async throws {
        let monitor = BiasMonitor()
        
        let metadata = ModelMetadata(
            age: 30,
            gender: .male,
            ethnicity: .caucasian,
            skinTone: 2
        )
        
        let prediction = PredictionResult(
            cervicoMentalAngle: 95.0,
            angleConfidenceInterval: (90, 100),
            fatCategory: .low,
            categoryConfidence: 0.9,
            overallConfidence: 0.9,
            uncertainty: 0.1
        )
        
        let groundTruth: (angle: Double, category: FatCategory) = (95.0, .low)
        
        monitor.recordPrediction(prediction, metadata: metadata, groundTruth: groundTruth)
        
        #expect(monitor.predictionCount == 1)
        #expect(monitor.predictionCountWithTruth == 1)
    }
    
    @Test("BiasMonitor calculates fairness metrics with diverse dataset")
    @MainActor
    func biasMonitorCalculatesFairnessMetrics() async throws {
        let monitor = BiasMonitor()
        
        // Record diverse test dataset
        let dataset = createDiverseTestDataset()
        
        for (prediction, metadata, groundTruth) in dataset {
            monitor.recordPrediction(prediction, metadata: metadata, groundTruth: groundTruth)
        }
        
        // Calculate fairness metrics
        let metrics = monitor.calculateFairnessMetrics()
        
        // Verify we have enough data
        #expect(metrics.sampleSize >= 100)
        
        // Verify overall accuracy is calculated
        #expect(metrics.overallAccuracy != nil)
        
        // Verify we have accuracy by group
        #expect(!metrics.accuracyByGroup.isEmpty)
    }
    
    @Test("BiasMonitor validates >95% accuracy requirement")
    @MainActor
    func biasMonitorValidatesAccuracyRequirement() async throws {
        let monitor = BiasMonitor()
        
        // Record diverse test dataset (designed for 96% accuracy)
        let dataset = createDiverseTestDataset()
        
        for (prediction, metadata, groundTruth) in dataset {
            monitor.recordPrediction(prediction, metadata: metadata, groundTruth: groundTruth)
        }
        
        let metrics = monitor.calculateFairnessMetrics()
        
        // Verify overall accuracy meets requirement (>95%)
        if let overallAccuracy = metrics.overallAccuracy {
            #expect(overallAccuracy >= 0.95, "Overall accuracy (\(overallAccuracy)) must be >= 0.95")
        }
        
        // Verify all groups meet minimum accuracy (>=90%)
        for (groupKey, accuracy) in metrics.accuracyByGroup {
            #expect(accuracy >= 0.90, "Group \(groupKey) accuracy (\(accuracy)) must be >= 0.90")
        }
    }
    
    @Test("BiasMonitor validates <5% gap requirement")
    @MainActor
    func biasMonitorValidatesGapRequirement() async throws {
        let monitor = BiasMonitor()
        
        // Record diverse test dataset
        let dataset = createDiverseTestDataset()
        
        for (prediction, metadata, groundTruth) in dataset {
            monitor.recordPrediction(prediction, metadata: metadata, groundTruth: groundTruth)
        }
        
        let metrics = monitor.calculateFairnessMetrics()
        
        // Verify maximum gap is calculated
        #expect(metrics.maxAccuracyGap != nil)
        
        // Verify gap meets requirement (<5%)
        if let maxGap = metrics.maxAccuracyGap {
            #expect(maxGap <= 0.05, "Maximum accuracy gap (\(maxGap)) must be <= 0.05")
        }
    }
    
    @Test("BiasMonitor flags groups below 90% accuracy")
    @MainActor
    func biasMonitorFlagsLowAccuracyGroups() async throws {
        let monitor = BiasMonitor()
        
        // Record biased test dataset (one group at 85% accuracy)
        let dataset = createBiasedTestDataset()
        
        for (prediction, metadata, groundTruth) in dataset {
            monitor.recordPrediction(prediction, metadata: metadata, groundTruth: groundTruth)
        }
        
        let metrics = monitor.calculateFairnessMetrics()
        
        // Verify flagged groups exist
        #expect(!metrics.flaggedGroups.isEmpty, "Should flag groups below 90% accuracy")
        
        // Verify flagged groups are actually below 90%
        for groupKey in metrics.flaggedGroups {
            if let accuracy = metrics.accuracyByGroup[groupKey] {
                #expect(accuracy < 0.90, "Flagged group \(groupKey) should have accuracy < 0.90")
            }
        }
    }
    
    @Test("BiasMonitor generates fairness report")
    @MainActor
    func biasMonitorGeneratesFairnessReport() async throws {
        let monitor = BiasMonitor()
        
        // Record diverse test dataset
        let dataset = createDiverseTestDataset()
        
        for (prediction, metadata, groundTruth) in dataset {
            monitor.recordPrediction(prediction, metadata: metadata, groundTruth: groundTruth)
        }
        
        let report = monitor.generateFairnessReport()
        
        // Verify report contains all required sections
        #expect(report.metrics.sampleSize >= 100)
        #expect(!report.accuracyByRace.isEmpty)
        #expect(!report.accuracyBySkinTone.isEmpty)
        #expect(!report.accuracyByAgeGroup.isEmpty)
        #expect(!report.accuracyByGender.isEmpty)
        #expect(!report.intersectionalMetrics.isEmpty)
        #expect(!report.recommendations.isEmpty)
    }
    
    @Test("BiasMonitor calculates intersectional metrics")
    @MainActor
    func biasMonitorCalculatesIntersectionalMetrics() async throws {
        let monitor = BiasMonitor()
        
        // Record diverse test dataset
        let dataset = createDiverseTestDataset()
        
        for (prediction, metadata, groundTruth) in dataset {
            monitor.recordPrediction(prediction, metadata: metadata, groundTruth: groundTruth)
        }
        
        let report = monitor.generateFairnessReport()
        
        // Verify intersectional metrics are calculated
        #expect(!report.intersectionalMetrics.isEmpty)
        
        // Verify intersectional metrics include race × gender combinations
        let hasRaceGender = report.intersectionalMetrics.keys.contains { $0.contains("race_") && $0.contains("gender_") }
        #expect(hasRaceGender, "Should include race × gender intersectional metrics")
    }
    
    @Test("BiasMonitor handles insufficient data gracefully")
    @MainActor
    func biasMonitorHandlesInsufficientData() async throws {
        let monitor = BiasMonitor()
        
        // Record only a few predictions (below minimum threshold)
        for _ in 0..<50 {
            let metadata = ModelMetadata(
                age: 30,
                gender: .male,
                ethnicity: .caucasian,
                skinTone: 2
            )
            
            let prediction = PredictionResult(
                cervicoMentalAngle: 95.0,
                angleConfidenceInterval: (90, 100),
                fatCategory: .low,
                categoryConfidence: 0.9,
                overallConfidence: 0.9,
                uncertainty: 0.1
            )
            
            let groundTruth: (angle: Double, category: FatCategory) = (95.0, .low)
            
            monitor.recordPrediction(prediction, metadata: metadata, groundTruth: groundTruth)
        }
        
        let metrics = monitor.calculateFairnessMetrics()
        
        // Verify metrics indicate insufficient data
        #expect(metrics.sampleSize < 100)
        #expect(metrics.overallAccuracy == nil || metrics.overallAccuracy! < 0.95)
        #expect(!metrics.meetsFairnessCriteria)
    }
    
    // MARK: - FairnessValidator Tests
    
    @Test("FairnessValidator validates batch of predictions")
    @MainActor
    func fairnessValidatorValidatesBatch() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        
        // Create batch of predictions
        var predictions: [PredictionWithMetadata] = []
        var groundTruth: [UUID: (angle: Double, category: FatCategory)] = [:]
        
        for index in 0..<100 {
            let metadata = ModelMetadata(
                age: 30,
                gender: index % 2 == 0 ? .male : .female,
                ethnicity: .caucasian,
                skinTone: 2
            )
            
            let prediction = PredictionResult(
                cervicoMentalAngle: 95.0,
                angleConfidenceInterval: (90, 100),
                fatCategory: .low,
                categoryConfidence: 0.9,
                overallConfidence: 0.9,
                uncertainty: 0.1
            )
            
            let predictionId = UUID()
            predictions.append(PredictionWithMetadata(
                predictionId: predictionId,
                prediction: prediction,
                metadata: metadata
            ))
            
            groundTruth[predictionId] = (95.0, .low)
        }
        
        let result = validator.validateBatch(predictions, groundTruth: groundTruth)
        
        // Verify validation result
        #expect(result.predictionCount == 100)
        #expect(result.metrics.sampleSize >= 100)
    }
    
    @Test("FairnessValidator detects fairness violations")
    @MainActor
    func fairnessValidatorDetectsViolations() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        
        // Record biased dataset (one group below 90%)
        let dataset = createBiasedTestDataset()
        
        var predictions: [PredictionWithMetadata] = []
        var groundTruth: [UUID: (angle: Double, category: FatCategory)] = [:]
        
        for (prediction, metadata, truth) in dataset {
            let predictionId = UUID()
            predictions.append(PredictionWithMetadata(
                predictionId: predictionId,
                prediction: prediction,
                metadata: metadata
            ))
            
            groundTruth[predictionId] = truth
        }
        
        let result = validator.validateBatch(predictions, groundTruth: groundTruth)
        
        // Verify violation is detected
        #expect(!result.passesValidation || !result.flaggedGroups.isEmpty, "Should detect fairness violation")
    }
    
    @Test("FairnessValidator generates quarterly report")
    @MainActor
    func fairnessValidatorGeneratesQuarterlyReport() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        
        // Record diverse dataset
        let dataset = createDiverseTestDataset()
        
        for (prediction, metadata, groundTruth) in dataset {
            monitor.recordPrediction(prediction, metadata: metadata, groundTruth: groundTruth)
        }
        
        let report = validator.generateQuarterlyReport()
        
        // Verify report is comprehensive
        #expect(report.metrics.sampleSize >= 100)
        #expect(!report.recommendations.isEmpty)
    }
    
    @Test("FairnessValidator checks quarterly report timing")
    @MainActor
    func fairnessValidatorChecksQuarterlyReportTiming() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        
        // Should generate report if no previous report
        #expect(validator.shouldGenerateQuarterlyReport(lastReportDate: nil))
        
        // Should not generate report if less than 90 days
        let recentDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        #expect(!validator.shouldGenerateQuarterlyReport(lastReportDate: recentDate))
        
        // Should generate report if 90+ days have passed
        let oldDate = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        #expect(validator.shouldGenerateQuarterlyReport(lastReportDate: oldDate))
    }
    
    // MARK: - FairnessCorrection Tests
    
    @Test("FairnessCorrection applies conservative correction for flagged groups")
    @MainActor
    func fairnessCorrectionAppliesConservativeCorrection() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        let correction = FairnessCorrection(biasMonitor: monitor, fairnessValidator: validator)
        
        // Set ensemble config to conservative
        correction.ensembleConfig = .conservative
        
        let prediction = PredictionResult(
            cervicoMentalAngle: 95.0,
            angleConfidenceInterval: (90, 100),
            fatCategory: .low,
            categoryConfidence: 0.9,
            overallConfidence: 0.9,
            uncertainty: 0.1
        )
        
        let demographics = BiasMonitor.DemographicGroup(
            race: .caucasian,
            skinTone: 2,
            ageGroup: .adult,
            gender: .male
        )
        
        let corrected = correction.applyEnsembleCorrection(prediction, demographics: demographics)
        
        // Verify confidence intervals are widened
        let originalRange = prediction.angleConfidenceInterval.upper - prediction.angleConfidenceInterval.lower
        let correctedRange = corrected.angleConfidenceInterval.upper - corrected.angleConfidenceInterval.lower
        
        #expect(correctedRange >= originalRange, "Confidence intervals should be widened")
    }
    
    @Test("FairnessCorrection applies adaptive correction based on group performance")
    @MainActor
    func fairnessCorrectionAppliesAdaptiveCorrection() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        let correction = FairnessCorrection(biasMonitor: monitor, fairnessValidator: validator)
        
        // Set ensemble config to adaptive
        correction.ensembleConfig = .adaptive
        
        // Record some predictions for a group with lower accuracy
        let lowAccuracyMetadata = ModelMetadata(
            age: 30,
            gender: .female,
            ethnicity: .africanAmerican,
            skinTone: 5
        )
        
        // Record predictions that result in lower accuracy for this group
        for i in 0..<100 {
            let isCorrect = i < 85 // 85% accuracy
            let groundTruthAngle = 95.0
            let groundTruthCategory = FatCategory.low
            
            let predictedAngle = isCorrect ? 95.0 : 110.0
            let predictedCategory = FatCategory(from: predictedAngle)
            
            let prediction = PredictionResult(
                cervicoMentalAngle: predictedAngle,
                angleConfidenceInterval: (predictedAngle - 5, predictedAngle + 5),
                fatCategory: predictedCategory,
                categoryConfidence: isCorrect ? 0.9 : 0.6,
                overallConfidence: isCorrect ? 0.9 : 0.7,
                uncertainty: isCorrect ? 0.1 : 0.3
            )
            
            monitor.recordPrediction(
                prediction,
                metadata: lowAccuracyMetadata,
                groundTruth: (groundTruthAngle, groundTruthCategory)
            )
        }
        
        let demographics = BiasMonitor.DemographicGroup(from: lowAccuracyMetadata)
        
        let prediction = PredictionResult(
            cervicoMentalAngle: 95.0,
            angleConfidenceInterval: (90, 100),
            fatCategory: .low,
            categoryConfidence: 0.9,
            overallConfidence: 0.9,
            uncertainty: 0.1
        )
        
        let corrected = correction.applyEnsembleCorrection(prediction, demographics: demographics)
        
        // Verify correction is applied (confidence intervals widened or confidence reduced)
        let originalRange = prediction.angleConfidenceInterval.upper - prediction.angleConfidenceInterval.lower
        let correctedRange = corrected.angleConfidenceInterval.upper - corrected.angleConfidenceInterval.lower
        
        // Adaptive correction should widen intervals for lower-performing groups
        #expect(correctedRange >= originalRange || corrected.overallConfidence < prediction.overallConfidence)
    }
    
    @Test("FairnessCorrection calculates balanced sample weights")
    @MainActor
    func fairnessCorrectionCalculatesBalancedWeights() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        let correction = FairnessCorrection(biasMonitor: monitor, fairnessValidator: validator)
        
        correction.reweightingStrategy = .balanced
        
        // Create demographics with imbalanced groups
        var demographics: [BiasMonitor.DemographicGroup] = []
        
        // Group 1: 100 samples
        for _ in 0..<100 {
            demographics.append(BiasMonitor.DemographicGroup(
                race: .caucasian,
                skinTone: 2,
                ageGroup: .adult,
                gender: .male
            ))
        }
        
        // Group 2: 20 samples (minority group)
        for _ in 0..<20 {
            demographics.append(BiasMonitor.DemographicGroup(
                race: .africanAmerican,
                skinTone: 5,
                ageGroup: .adult,
                gender: .female
            ))
        }
        
        let weights = correction.calculateSampleWeights(for: demographics)
        
        // Verify weights are calculated
        #expect(weights.count == demographics.count)
        
        // Verify minority group has higher weights
        let group1Weights = weights[0..<100]
        let group2Weights = weights[100..<120]
        
        let avgGroup1Weight = group1Weights.reduce(0, +) / Double(group1Weights.count)
        let avgGroup2Weight = group2Weights.reduce(0, +) / Double(group2Weights.count)
        
        #expect(avgGroup2Weight > avgGroup1Weight, "Minority group should have higher weights")
    }
    
    @Test("FairnessCorrection calculates inverse frequency weights")
    @MainActor
    func fairnessCorrectionCalculatesInverseFrequencyWeights() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        let correction = FairnessCorrection(biasMonitor: monitor, fairnessValidator: validator)
        
        correction.reweightingStrategy = .inverseFrequency
        
        // Create demographics with imbalanced groups
        var demographics: [BiasMonitor.DemographicGroup] = []
        
        // Group 1: 100 samples (majority)
        for _ in 0..<100 {
            demographics.append(BiasMonitor.DemographicGroup(
                race: .caucasian,
                skinTone: 2,
                ageGroup: .adult,
                gender: .male
            ))
        }
        
        // Group 2: 20 samples (minority)
        for _ in 0..<20 {
            demographics.append(BiasMonitor.DemographicGroup(
                race: .africanAmerican,
                skinTone: 5,
                ageGroup: .adult,
                gender: .female
            ))
        }
        
        let weights = correction.calculateSampleWeights(for: demographics)
        
        // Verify minority group has higher weights (inverse frequency)
        let group1Weights = weights[0..<100]
        let group2Weights = weights[100..<120]
        
        let avgGroup1Weight = group1Weights.reduce(0, +) / Double(group1Weights.count)
        let avgGroup2Weight = group2Weights.reduce(0, +) / Double(group2Weights.count)
        
        #expect(avgGroup2Weight > avgGroup1Weight, "Minority group should have higher weights")
    }
    
    @Test("FairnessCorrection provides adversarial debiasing config")
    @MainActor
    func fairnessCorrectionProvidesAdversarialDebiasingConfig() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        let correction = FairnessCorrection(biasMonitor: monitor, fairnessValidator: validator)
        
        correction.adversarialDebiasingEnabled = true
        
        // Record biased dataset to trigger debiasing
        let dataset = createBiasedTestDataset()
        
        for (prediction, metadata, groundTruth) in dataset {
            monitor.recordPrediction(prediction, metadata: metadata, groundTruth: groundTruth)
        }
        
        let config = correction.getAdversarialDebiasingConfig()
        
        // Verify config is generated
        #expect(config.enabled)
        #expect(!config.protectedAttributes.isEmpty)
    }
    
    // MARK: - Comprehensive Fairness Tests
    
    @Test("Complete bias mitigation system validates >95% accuracy across all groups")
    @MainActor
    func completeSystemValidatesAccuracyAcrossAllGroups() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        let correction = FairnessCorrection(biasMonitor: monitor, fairnessValidator: validator)
        
        // Record diverse test dataset
        let dataset = createDiverseTestDataset()
        
        var predictions: [PredictionWithMetadata] = []
        var groundTruth: [UUID: (angle: Double, category: FatCategory)] = [:]
        
        for (prediction, metadata, truth) in dataset {
            let predictionId = UUID()
            predictions.append(PredictionWithMetadata(
                predictionId: predictionId,
                prediction: prediction,
                metadata: metadata
            ))
            
            groundTruth[predictionId] = truth
        }
        
        // Validate batch
        let validationResult = validator.validateBatch(predictions, groundTruth: groundTruth)
        
        // Get final metrics
        let metrics = monitor.getFairnessMetrics()
        
        // Verify overall accuracy >= 95%
        if let overallAccuracy = metrics.overallAccuracy {
            #expect(overallAccuracy >= 0.95, "Overall accuracy (\(overallAccuracy)) must be >= 0.95")
        }
        
        // Verify all groups meet minimum accuracy (>=90%)
        for (groupKey, accuracy) in metrics.accuracyByGroup {
            #expect(accuracy >= 0.90, "Group \(groupKey) accuracy (\(accuracy)) must be >= 0.90")
        }
        
        // Verify maximum gap <= 5%
        if let maxGap = metrics.maxAccuracyGap {
            #expect(maxGap <= 0.05, "Maximum accuracy gap (\(maxGap)) must be <= 0.05")
        }
    }
    
    @Test("Complete bias mitigation system detects and corrects bias")
    @MainActor
    func completeSystemDetectsAndCorrectsBias() async throws {
        let monitor = BiasMonitor()
        let validator = FairnessValidator(biasMonitor: monitor)
        let correction = FairnessCorrection(biasMonitor: monitor, fairnessValidator: validator)
        
        // Record biased dataset
        let dataset = createBiasedTestDataset()
        
        var predictions: [PredictionWithMetadata] = []
        var groundTruth: [UUID: (angle: Double, category: FatCategory)] = [:]
        
        for (prediction, metadata, truth) in dataset {
            let predictionId = UUID()
            predictions.append(PredictionWithMetadata(
                predictionId: predictionId,
                prediction: prediction,
                metadata: metadata
            ))
            
            groundTruth[predictionId] = truth
        }
        
        // Validate batch (should detect bias)
        let validationResult = validator.validateBatch(predictions, groundTruth: groundTruth)
        
        // Verify bias is detected
        #expect(!validationResult.passesValidation || !validationResult.flaggedGroups.isEmpty)
        
        // Apply correction to flagged group
        let flaggedGroup = BiasMonitor.DemographicGroup(
            race: .africanAmerican,
            skinTone: 5,
            ageGroup: .adult,
            gender: .female
        )
        
        let originalPrediction = PredictionResult(
            cervicoMentalAngle: 95.0,
            angleConfidenceInterval: (90, 100),
            fatCategory: .low,
            categoryConfidence: 0.9,
            overallConfidence: 0.9,
            uncertainty: 0.1
        )
        
        let correctedPrediction = correction.applyEnsembleCorrection(originalPrediction, demographics: flaggedGroup)
        
        // Verify correction is applied (confidence intervals widened or confidence reduced)
        let originalRange = originalPrediction.angleConfidenceInterval.upper - originalPrediction.angleConfidenceInterval.lower
        let correctedRange = correctedPrediction.angleConfidenceInterval.upper - correctedPrediction.angleConfidenceInterval.lower
        
        #expect(correctedRange >= originalRange || correctedPrediction.overallConfidence < originalPrediction.overallConfidence)
    }
}

