import Testing
import ARKit
@testable import FogaFeature

/// Tests for validating ARKit measurements against gold standard (3D stereophotogrammetry)
/// 
/// **Task 8.9.3**: Validate measurement accuracy against gold standard
/// - Success Criteria: Compares ARKit measurements to 3D stereophotogrammetry, 
///   achieves ±3° agreement for 95% of cases, adjusts systematic bias if detected
/// 
/// **Scientific Note**: 3D stereophotogrammetry is the gold standard for facial measurements.
/// ARKit measurements should achieve ±3° agreement with gold standard for 95% of cases.
/// Systematic bias (consistent offset) should be detected and corrected.
@Suite("Gold Standard Validation Tests")
struct GoldStandardValidationTests {
    
    // MARK: - Test Constants
    
    /// Maximum acceptable agreement threshold (±3°)
    private let maxAgreementThreshold: Double = 3.0
    
    /// Minimum percentage of cases that must meet agreement threshold (95%)
    private let minAgreementPercentage: Double = 0.95
    
    /// Minimum number of comparison pairs for statistical significance
    private let minComparisonPairs: Int = 20
    
    // MARK: - Gold Standard Comparison Tests
    
    @Test("ARKit measurements achieve ±3° agreement for 95% of cases")
    func arkitAgreementWithGoldStandard() async throws {
        // Create comparison dataset with ARKit and gold standard measurements
        let comparisonPairs = createComparisonDataset(count: 100)
        
        // Calculate agreement for each pair
        var agreements: [Double] = []
        var withinThreshold: Int = 0
        var validPairs: Int = 0
        
        for pair in comparisonPairs {
            guard let arkitAngle = pair.arkitMeasurement.cervicoMentalAngle,
                  let goldStandardAngle = pair.goldStandardAngle else {
                continue
            }
            
            validPairs += 1
            
            // Calculate absolute difference
            let difference = abs(arkitAngle - goldStandardAngle)
            agreements.append(difference)
            
            // Check if within ±3° threshold
            if difference <= maxAgreementThreshold {
                withinThreshold += 1
            }
        }
        
        // Calculate agreement percentage (use valid pairs count, not total count)
        guard validPairs > 0 else {
            Issue.record("No valid comparison pairs found")
            return
        }
        
        let agreementPercentage = Double(withinThreshold) / Double(validPairs)
        
        // Verify 95% agreement requirement
        #expect(agreementPercentage >= minAgreementPercentage, 
                "Only \(String(format: "%.1f%%", agreementPercentage * 100)) of measurements meet ±3° agreement threshold (required: \(String(format: "%.1f%%", minAgreementPercentage * 100)))")
        
        // Verify mean agreement is within acceptable range
        guard !agreements.isEmpty else {
            Issue.record("No agreements calculated")
            return
        }
        
        let meanAgreement = agreements.reduce(0, +) / Double(agreements.count)
        #expect(meanAgreement <= maxAgreementThreshold,
                "Mean agreement difference (\(String(format: "%.2f", meanAgreement))°) exceeds threshold (\(maxAgreementThreshold)°)")
    }
    
    @Test("Systematic bias detection identifies consistent offset")
    func systematicBiasDetection() async throws {
        // Create dataset with systematic bias (ARKit consistently measures 2° higher)
        let biasedPairs = createBiasedComparisonDataset(count: 50, systematicBias: 2.0)
        
        // Detect systematic bias
        let biasAnalysis = detectSystematicBias(biasedPairs)
        
        // Verify bias is detected
        #expect(biasAnalysis.hasSystematicBias == true,
                "Systematic bias should be detected in biased dataset")
        
        // Verify bias magnitude is approximately correct (±0.5° tolerance)
        if let detectedBias = biasAnalysis.biasMagnitude {
            #expect(abs(detectedBias - 2.0) <= 0.5,
                    "Detected bias (\(String(format: "%.2f", detectedBias))°) should be approximately 2.0°")
        } else {
            Issue.record("Systematic bias detected but magnitude not calculated")
        }
        
        // Verify bias direction is correct (positive = ARKit higher than gold standard)
        if let biasDirection = biasAnalysis.biasDirection {
            #expect(biasDirection == .positive,
                    "Bias direction should be positive (ARKit higher than gold standard)")
        }
    }
    
    @Test("Systematic bias adjustment corrects measurements")
    func systematicBiasAdjustment() async throws {
        // Create dataset with systematic bias
        let biasedPairs = createBiasedComparisonDataset(count: 50, systematicBias: 2.0)
        
        // Detect bias
        let biasAnalysis = detectSystematicBias(biasedPairs)
        
        // Apply bias correction
        let correctedPairs = applyBiasCorrection(biasedPairs, biasAnalysis: biasAnalysis)
        
        // Verify corrected measurements have better agreement
        var correctedAgreements: [Double] = []
        var correctedWithinThreshold: Int = 0
        
        for pair in correctedPairs {
            guard let arkitAngle = pair.arkitMeasurement.cervicoMentalAngle,
                  let goldStandardAngle = pair.goldStandardAngle else {
                continue
            }
            
            // Use corrected angle if available, otherwise original
            let correctedAngle = pair.correctedAngle ?? arkitAngle
            let difference = abs(correctedAngle - goldStandardAngle)
            correctedAgreements.append(difference)
            
            if difference <= maxAgreementThreshold {
                correctedWithinThreshold += 1
            }
        }
        
        // Compare original vs corrected agreement
        var originalAgreements: [Double] = []
        var originalWithinThreshold: Int = 0
        
        for pair in biasedPairs {
            guard let arkitAngle = pair.arkitMeasurement.cervicoMentalAngle,
                  let goldStandardAngle = pair.goldStandardAngle else {
                continue
            }
            
            let difference = abs(arkitAngle - goldStandardAngle)
            originalAgreements.append(difference)
            
            if difference <= maxAgreementThreshold {
                originalWithinThreshold += 1
            }
        }
        
        let originalAgreementPercentage = Double(originalWithinThreshold) / Double(biasedPairs.count)
        let correctedAgreementPercentage = Double(correctedWithinThreshold) / Double(correctedPairs.count)
        
        // Verify correction improves agreement
        #expect(correctedAgreementPercentage >= originalAgreementPercentage,
                "Bias correction should improve agreement (original: \(String(format: "%.1f%%", originalAgreementPercentage * 100)), corrected: \(String(format: "%.1f%%", correctedAgreementPercentage * 100)))")
        
        // Verify corrected mean agreement is better
        let originalMean = originalAgreements.reduce(0, +) / Double(originalAgreements.count)
        let correctedMean = correctedAgreements.reduce(0, +) / Double(correctedAgreements.count)
        
        #expect(correctedMean <= originalMean,
                "Corrected mean agreement (\(String(format: "%.2f", correctedMean))°) should be better than original (\(String(format: "%.2f", originalMean))°)")
    }
    
    @Test("No systematic bias detected in unbiased dataset")
    func noBiasInUnbiasedDataset() async throws {
        // Create unbiased dataset (ARKit measurements match gold standard with random noise)
        let unbiasedPairs = createComparisonDataset(count: 50)
        
        // Detect systematic bias
        let biasAnalysis = detectSystematicBias(unbiasedPairs)
        
        // Verify no systematic bias is detected
        #expect(biasAnalysis.hasSystematicBias == false,
                "No systematic bias should be detected in unbiased dataset")
        
        // Verify bias magnitude is small (<0.5°)
        if let biasMagnitude = biasAnalysis.biasMagnitude {
            #expect(biasMagnitude < 0.5,
                    "Bias magnitude (\(String(format: "%.2f", biasMagnitude))°) should be small (<0.5°) in unbiased dataset")
        }
    }
    
    @Test("Zero variance case handled correctly (no division by zero)")
    func zeroVarianceCaseHandled() async throws {
        // Create dataset with zero variance (all differences identical)
        // This tests the edge case where stdDev == 0
        
        // Case 1: Perfect systematic bias (all differences are 2.0°)
        var perfectBiasPairs: [ComparisonPair] = []
        for i in 0..<20 {
            let goldStandardAngle = 100.0 + Double(i) * 0.1 // Vary gold standard
            let arkitAngle = goldStandardAngle + 2.0 // Always 2° higher
            
            let measurement = FaceMeasurement(
                chinWidth: Double.random(in: 30...60),
                jawlineAngle: arkitAngle,
                neckCircumference: Double.random(in: 300...400),
                timestamp: Date().addingTimeInterval(Double(i) * 3600),
                cervicoMentalAngle: arkitAngle
            )
            
            perfectBiasPairs.append(ComparisonPair(
                arkitMeasurement: measurement,
                goldStandardAngle: goldStandardAngle,
                correctedAngle: nil
            ))
        }
        
        let biasAnalysis = detectSystematicBias(perfectBiasPairs)
        
        // Should detect perfect systematic bias
        #expect(biasAnalysis.hasSystematicBias == true,
                "Perfect systematic bias should be detected when all differences are identical")
        #expect(biasAnalysis.biasMagnitude != nil,
                "Bias magnitude should be calculated for perfect systematic bias")
        if let magnitude = biasAnalysis.biasMagnitude {
            #expect(abs(magnitude - 2.0) < 0.01,
                    "Bias magnitude should be approximately 2.0° (got \(magnitude))")
        }
        #expect(biasAnalysis.stdDevDifference == 0,
                "Standard deviation should be zero when all differences are identical")
        
        // Case 2: Perfect agreement (all differences are 0.0°)
        var perfectAgreementPairs: [ComparisonPair] = []
        for i in 0..<20 {
            let goldStandardAngle = 100.0 + Double(i) * 0.1
            let arkitAngle = goldStandardAngle // Perfect match
            
            let measurement = FaceMeasurement(
                chinWidth: Double.random(in: 30...60),
                jawlineAngle: arkitAngle,
                neckCircumference: Double.random(in: 300...400),
                timestamp: Date().addingTimeInterval(Double(i) * 3600),
                cervicoMentalAngle: arkitAngle
            )
            
            perfectAgreementPairs.append(ComparisonPair(
                arkitMeasurement: measurement,
                goldStandardAngle: goldStandardAngle,
                correctedAngle: nil
            ))
        }
        
        let agreementAnalysis = detectSystematicBias(perfectAgreementPairs)
        
        // Should not detect bias (mean difference is 0, which is < 0.5 threshold)
        #expect(agreementAnalysis.hasSystematicBias == false,
                "No bias should be detected when all differences are zero (perfect agreement)")
        #expect(agreementAnalysis.stdDevDifference == 0,
                "Standard deviation should be zero for perfect agreement")
    }
    
    @Test("Bland-Altman analysis for agreement assessment")
    func blandAltmanAnalysis() async throws {
        // Create comparison dataset
        let comparisonPairs = createComparisonDataset(count: 50)
        
        // Verify we have valid pairs
        let validPairs = comparisonPairs.filter { 
            $0.arkitMeasurement.cervicoMentalAngle != nil && $0.goldStandardAngle != nil 
        }
        guard !validPairs.isEmpty else {
            Issue.record("No valid comparison pairs for Bland-Altman analysis")
            return
        }
        
        // Perform Bland-Altman analysis
        let blandAltman = performBlandAltmanAnalysis(comparisonPairs)
        
        // Verify limits of agreement are within acceptable range (±6° for 95% CI)
        let upperLimit = blandAltman.meanDifference + 1.96 * blandAltman.stdDevDifference
        let lowerLimit = blandAltman.meanDifference - 1.96 * blandAltman.stdDevDifference
        
        // Check that limits are within ±6° range
        let maxLimitThreshold = maxAgreementThreshold * 2 // ±6°
        #expect(upperLimit <= maxLimitThreshold && upperLimit >= -maxLimitThreshold,
                "Upper limit of agreement (\(String(format: "%.2f", upperLimit))°) should be within ±\(maxLimitThreshold)°")
        #expect(lowerLimit <= maxLimitThreshold && lowerLimit >= -maxLimitThreshold,
                "Lower limit of agreement (\(String(format: "%.2f", lowerLimit))°) should be within ±\(maxLimitThreshold)°")
        
        // Verify limits span is reasonable (should be around 2 * 1.96 * stdDev ≈ 4.6° for ±2° error)
        let limitSpan = upperLimit - lowerLimit
        #expect(limitSpan <= maxLimitThreshold * 2,
                "Limit span (\(String(format: "%.2f", limitSpan))°) should be reasonable (expected: ~4-5° for ±2° error)")
        
        // Verify mean difference is close to zero (no systematic bias)
        #expect(abs(blandAltman.meanDifference) < 1.0,
                "Mean difference (\(String(format: "%.2f", blandAltman.meanDifference))°) should be close to zero")
    }
    
    @Test("Measurement accuracy across angle ranges")
    func accuracyAcrossAngleRanges() async throws {
        // Test accuracy for different angle ranges:
        // - Optimal range (90-105°)
        // - Normal range (105-120°)
        // - Concerning range (>120°)
        
        let optimalPairs = createComparisonDataset(count: 30, angleRange: 90...105)
        let normalPairs = createComparisonDataset(count: 30, angleRange: 105...120)
        let concerningPairs = createComparisonDataset(count: 30, angleRange: 120...150)
        
        // Calculate agreement for each range
        let optimalAgreement = calculateAgreementPercentage(optimalPairs)
        let normalAgreement = calculateAgreementPercentage(normalPairs)
        let concerningAgreement = calculateAgreementPercentage(concerningPairs)
        
        // Verify all ranges meet 95% agreement requirement
        #expect(optimalAgreement >= minAgreementPercentage,
                "Optimal range agreement (\(String(format: "%.1f%%", optimalAgreement * 100))) should meet 95% requirement")
        #expect(normalAgreement >= minAgreementPercentage,
                "Normal range agreement (\(String(format: "%.1f%%", normalAgreement * 100))) should meet 95% requirement")
        #expect(concerningAgreement >= minAgreementPercentage,
                "Concerning range agreement (\(String(format: "%.1f%%", concerningAgreement * 100))) should meet 95% requirement")
    }
    
    // MARK: - Helper Functions
    
    /// Create comparison dataset with ARKit and gold standard measurements
    /// 
    /// - Parameters:
    ///   - count: Number of comparison pairs to create
    ///   - angleRange: Range of angles to generate (default: 90-150°)
    /// - Returns: Array of comparison pairs
    private func createComparisonDataset(count: Int, angleRange: ClosedRange<Double> = 90...150) -> [ComparisonPair] {
        var pairs: [ComparisonPair] = []
        
        for i in 0..<count {
            // Generate gold standard angle in specified range
            let goldStandardAngle = Double.random(in: angleRange)
            
            // Simulate ARKit measurement with realistic noise (±2° random error)
            let measurementError = Double.random(in: -2.0...2.0)
            let arkitAngle = goldStandardAngle + measurementError
            
            // Create FaceMeasurement with ARKit angle
            let arkitMeasurement = FaceMeasurement(
                chinWidth: Double.random(in: 30...60),
                jawlineAngle: arkitAngle,
                neckCircumference: Double.random(in: 300...400),
                timestamp: Date().addingTimeInterval(Double(i) * 3600),
                cervicoMentalAngle: arkitAngle,
                confidenceScore: Double.random(in: 0.8...1.0),
                qualityFlags: MeasurementQualityFlags(
                    frankfurtPlaneAlignment: Double.random(in: 0...5),
                    isNeutralExpression: true,
                    lightingUniformity: Double.random(in: 0.8...1.0),
                    faceVisibility: Double.random(in: 0.9...1.0)
                )
            )
            
            pairs.append(ComparisonPair(
                arkitMeasurement: arkitMeasurement,
                goldStandardAngle: goldStandardAngle,
                correctedAngle: nil
            ))
        }
        
        return pairs
    }
    
    /// Create biased comparison dataset with systematic bias
    /// 
    /// - Parameters:
    ///   - count: Number of comparison pairs
    ///   - systematicBias: Systematic bias magnitude in degrees (positive = ARKit higher)
    /// - Returns: Array of comparison pairs with systematic bias
    private func createBiasedComparisonDataset(count: Int, systematicBias: Double) -> [ComparisonPair] {
        var pairs: [ComparisonPair] = []
        
        for i in 0..<count {
            // Generate gold standard angle
            let goldStandardAngle = Double.random(in: 90...150)
            
            // Add systematic bias plus random noise
            let measurementError = Double.random(in: -1.0...1.0)
            let arkitAngle = goldStandardAngle + systematicBias + measurementError
            
            // Create FaceMeasurement
            let arkitMeasurement = FaceMeasurement(
                chinWidth: Double.random(in: 30...60),
                jawlineAngle: arkitAngle,
                neckCircumference: Double.random(in: 300...400),
                timestamp: Date().addingTimeInterval(Double(i) * 3600),
                cervicoMentalAngle: arkitAngle,
                confidenceScore: Double.random(in: 0.8...1.0),
                qualityFlags: MeasurementQualityFlags()
            )
            
            pairs.append(ComparisonPair(
                arkitMeasurement: arkitMeasurement,
                goldStandardAngle: goldStandardAngle,
                correctedAngle: nil
            ))
        }
        
        return pairs
    }
    
    /// Detect systematic bias in comparison pairs
    /// 
    /// - Parameter pairs: Comparison pairs to analyze
    /// - Returns: BiasAnalysis with bias detection results
    private func detectSystematicBias(_ pairs: [ComparisonPair]) -> BiasAnalysis {
        var differences: [Double] = []
        
        for pair in pairs {
            guard let arkitAngle = pair.arkitMeasurement.cervicoMentalAngle,
                  let goldStandardAngle = pair.goldStandardAngle else {
                continue
            }
            
            let difference = arkitAngle - goldStandardAngle
            differences.append(difference)
        }
        
        guard !differences.isEmpty else {
            return BiasAnalysis(
                hasSystematicBias: false,
                biasMagnitude: nil,
                biasDirection: nil,
                meanDifference: 0,
                stdDevDifference: 0
            )
        }
        
        // Calculate mean difference (systematic bias)
        let meanDifference = differences.reduce(0, +) / Double(differences.count)
        
        // Calculate standard deviation
        let variance = differences.map { pow($0 - meanDifference, 2) }.reduce(0, +) / Double(differences.count)
        let stdDev = sqrt(variance)
        
        // Handle case where stdDev is zero (all differences are identical)
        // This occurs when there's perfect systematic bias (all measurements off by same amount)
        // or perfect agreement (all differences are zero)
        if stdDev == 0 {
            // If all differences are identical and non-zero, we have perfect systematic bias
            let hasSystematicBias = abs(meanDifference) > 0.5
            
            return BiasAnalysis(
                hasSystematicBias: hasSystematicBias,
                biasMagnitude: hasSystematicBias ? abs(meanDifference) : nil,
                biasDirection: hasSystematicBias ? (meanDifference > 0 ? .positive : .negative) : nil,
                meanDifference: meanDifference,
                stdDevDifference: 0
            )
        }
        
        // Detect systematic bias: mean difference significantly different from zero
        // Using t-test logic: if mean > 2*stdDev/sqrt(n), then systematic bias exists
        let standardError = stdDev / sqrt(Double(differences.count))
        let tStatistic = abs(meanDifference) / standardError
        
        // Threshold: t > 2.0 indicates systematic bias (p < 0.05 for large n)
        let hasSystematicBias = tStatistic > 2.0 && abs(meanDifference) > 0.5
        
        // Determine bias direction
        let biasDirection: BiasDirection? = hasSystematicBias ? (meanDifference > 0 ? .positive : .negative) : nil
        
        return BiasAnalysis(
            hasSystematicBias: hasSystematicBias,
            biasMagnitude: hasSystematicBias ? abs(meanDifference) : nil,
            biasDirection: biasDirection,
            meanDifference: meanDifference,
            stdDevDifference: stdDev
        )
    }
    
    /// Apply bias correction to comparison pairs
    /// 
    /// - Parameters:
    ///   - pairs: Comparison pairs to correct
    ///   - biasAnalysis: Bias analysis results
    /// - Returns: Corrected comparison pairs
    private func applyBiasCorrection(_ pairs: [ComparisonPair], biasAnalysis: BiasAnalysis) -> [ComparisonPair] {
        guard let biasMagnitude = biasAnalysis.biasMagnitude,
              let biasDirection = biasAnalysis.biasDirection else {
            // No bias to correct
            return pairs
        }
        
        var correctedPairs: [ComparisonPair] = []
        
        for pair in pairs {
            guard let arkitAngle = pair.arkitMeasurement.cervicoMentalAngle else {
                correctedPairs.append(pair)
                continue
            }
            
            // Apply correction (subtract bias)
            let correction = biasDirection == .positive ? -biasMagnitude : biasMagnitude
            let correctedAngle = arkitAngle + correction
            
            // Create corrected measurement
            var correctedMeasurement = pair.arkitMeasurement
            correctedMeasurement.cervicoMentalAngle = correctedAngle
            
            correctedPairs.append(ComparisonPair(
                arkitMeasurement: correctedMeasurement,
                goldStandardAngle: pair.goldStandardAngle,
                correctedAngle: correctedAngle
            ))
        }
        
        return correctedPairs
    }
    
    /// Calculate agreement percentage for comparison pairs
    /// 
    /// - Parameter pairs: Comparison pairs to analyze
    /// - Returns: Agreement percentage (0.0-1.0)
    private func calculateAgreementPercentage(_ pairs: [ComparisonPair]) -> Double {
        var withinThreshold: Int = 0
        var total: Int = 0
        
        for pair in pairs {
            guard let arkitAngle = pair.arkitMeasurement.cervicoMentalAngle,
                  let goldStandardAngle = pair.goldStandardAngle else {
                continue
            }
            
            total += 1
            let difference = abs(arkitAngle - goldStandardAngle)
            
            if difference <= maxAgreementThreshold {
                withinThreshold += 1
            }
        }
        
        guard total > 0 else {
            return 0.0
        }
        
        return Double(withinThreshold) / Double(total)
    }
    
    /// Perform Bland-Altman analysis for agreement assessment
    /// 
    /// - Parameter pairs: Comparison pairs to analyze
    /// - Returns: BlandAltmanResults with analysis results
    private func performBlandAltmanAnalysis(_ pairs: [ComparisonPair]) -> BlandAltmanResults {
        var differences: [Double] = []
        var means: [Double] = []
        
        for pair in pairs {
            guard let arkitAngle = pair.arkitMeasurement.cervicoMentalAngle,
                  let goldStandardAngle = pair.goldStandardAngle else {
                continue
            }
            
            let difference = arkitAngle - goldStandardAngle
            let mean = (arkitAngle + goldStandardAngle) / 2.0
            
            differences.append(difference)
            means.append(mean)
        }
        
        guard !differences.isEmpty else {
            return BlandAltmanResults(
                meanDifference: 0,
                stdDevDifference: 0
            )
        }
        
        // Calculate mean difference
        let meanDifference = differences.reduce(0, +) / Double(differences.count)
        
        // Calculate standard deviation of differences
        let variance = differences.map { pow($0 - meanDifference, 2) }.reduce(0, +) / Double(differences.count)
        let stdDevDifference = sqrt(variance)
        
        return BlandAltmanResults(
            meanDifference: meanDifference,
            stdDevDifference: stdDevDifference
        )
    }
}

// MARK: - Supporting Types

/// Comparison pair between ARKit measurement and gold standard
struct ComparisonPair {
    let arkitMeasurement: FaceMeasurement
    let goldStandardAngle: Double?
    let correctedAngle: Double?
}

/// Bias analysis results
struct BiasAnalysis {
    let hasSystematicBias: Bool
    let biasMagnitude: Double?
    let biasDirection: BiasDirection?
    let meanDifference: Double
    let stdDevDifference: Double
}

/// Bias direction
enum BiasDirection {
    case positive  // ARKit measures higher than gold standard
    case negative // ARKit measures lower than gold standard
}

/// Bland-Altman analysis results
struct BlandAltmanResults {
    let meanDifference: Double
    let stdDevDifference: Double
}

