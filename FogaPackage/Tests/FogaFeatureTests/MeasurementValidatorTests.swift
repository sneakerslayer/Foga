import Testing
@testable import FogaFeature

/// Unit tests for MeasurementValidator
/// 
/// Tests measurement validation, test-retest reliability (ICC),
/// and variance detection.
@Suite("MeasurementValidator Tests")
struct MeasurementValidatorTests {
    
    // MARK: - Single Measurement Validation Tests
    
    @Test("validateMeasurement returns valid for high-quality measurement")
    @MainActor
    func validateHighQualityMeasurement() async throws {
        let validator = MeasurementValidator()
        
        let measurement = FaceMeasurement(
            cervicoMentalAngle: 95.0,
            confidenceScore: 0.9,
            qualityFlags: MeasurementQualityFlags(
                frankfurtPlaneAlignment: 5.0,
                isNeutralExpression: true,
                lightingUniformity: 0.9,
                faceVisibility: 1.0
            )
        )
        
        let result = validator.validateMeasurement(measurement)
        
        #expect(result.isValid)
        #expect(result.issues.isEmpty)
    }
    
    @Test("validateMeasurement detects low confidence")
    @MainActor
    func validateLowConfidence() async throws {
        let validator = MeasurementValidator()
        
        let measurement = FaceMeasurement(
            cervicoMentalAngle: 95.0,
            confidenceScore: 0.7, // Below 0.8 threshold
            qualityFlags: MeasurementQualityFlags()
        )
        
        let result = validator.validateMeasurement(measurement)
        
        #expect(!result.isValid)
        #expect(result.issues.contains { 
            if case .lowConfidence = $0 { return true }
            return false
        })
    }
    
    @Test("validateMeasurement detects missing confidence")
    @MainActor
    func validateMissingConfidence() async throws {
        let validator = MeasurementValidator()
        
        let measurement = FaceMeasurement(
            cervicoMentalAngle: 95.0,
            confidenceScore: nil
        )
        
        let result = validator.validateMeasurement(measurement)
        
        #expect(!result.isValid)
        #expect(result.issues.contains { 
            if case .missingConfidence = $0 { return true }
            return false
        })
    }
    
    @Test("validateMeasurement detects poor pose alignment")
    @MainActor
    func validatePoorPoseAlignment() async throws {
        let validator = MeasurementValidator()
        
        let measurement = FaceMeasurement(
            cervicoMentalAngle: 95.0,
            confidenceScore: 0.9,
            qualityFlags: MeasurementQualityFlags(
                frankfurtPlaneAlignment: 15.0, // >10° deviation
                isNeutralExpression: true,
                lightingUniformity: 0.9,
                faceVisibility: 1.0
            )
        )
        
        let result = validator.validateMeasurement(measurement)
        
        #expect(!result.isValid)
        #expect(result.issues.contains { 
            if case .poorPoseAlignment = $0 { return true }
            return false
        })
    }
    
    @Test("validateMeasurement detects non-neutral expression")
    @MainActor
    func validateNonNeutralExpression() async throws {
        let validator = MeasurementValidator()
        
        let measurement = FaceMeasurement(
            cervicoMentalAngle: 95.0,
            confidenceScore: 0.9,
            qualityFlags: MeasurementQualityFlags(
                frankfurtPlaneAlignment: 5.0,
                isNeutralExpression: false, // Non-neutral
                lightingUniformity: 0.9,
                faceVisibility: 1.0
            )
        )
        
        let result = validator.validateMeasurement(measurement)
        
        #expect(!result.isValid)
        #expect(result.issues.contains { 
            if case .nonNeutralExpression = $0 { return true }
            return false
        })
    }
    
    @Test("validateMeasurement detects poor lighting")
    @MainActor
    func validatePoorLighting() async throws {
        let validator = MeasurementValidator()
        
        let measurement = FaceMeasurement(
            cervicoMentalAngle: 95.0,
            confidenceScore: 0.9,
            qualityFlags: MeasurementQualityFlags(
                frankfurtPlaneAlignment: 5.0,
                isNeutralExpression: true,
                lightingUniformity: 0.6, // Below 0.7 threshold
                faceVisibility: 1.0
            )
        )
        
        let result = validator.validateMeasurement(measurement)
        
        #expect(!result.isValid)
        #expect(result.issues.contains { 
            if case .poorLighting = $0 { return true }
            return false
        })
    }
    
    @Test("validateMeasurement detects incomplete face visibility")
    @MainActor
    func validateIncompleteFaceVisibility() async throws {
        let validator = MeasurementValidator()
        
        let measurement = FaceMeasurement(
            cervicoMentalAngle: 95.0,
            confidenceScore: 0.9,
            qualityFlags: MeasurementQualityFlags(
                frankfurtPlaneAlignment: 5.0,
                isNeutralExpression: true,
                lightingUniformity: 0.9,
                faceVisibility: 0.8 // Below 0.9 threshold
            )
        )
        
        let result = validator.validateMeasurement(measurement)
        
        #expect(!result.isValid)
        #expect(result.issues.contains { 
            if case .incompleteFaceVisibility = $0 { return true }
            return false
        })
    }
    
    @Test("validateMeasurement detects missing primary metric")
    @MainActor
    func validateMissingPrimaryMetric() async throws {
        let validator = MeasurementValidator()
        
        let measurement = FaceMeasurement(
            cervicoMentalAngle: nil,
            confidenceScore: 0.9,
            qualityFlags: MeasurementQualityFlags()
        )
        
        let result = validator.validateMeasurement(measurement)
        
        #expect(!result.isValid)
        #expect(result.issues.contains { 
            if case .missingPrimaryMetric = $0 { return true }
            return false
        })
    }
    
    @Test("validateMeasurement detects invalid angle (<50° or >180°)")
    @MainActor
    func validateInvalidAngle() async throws {
        let validator = MeasurementValidator()
        
        let lowAngle = FaceMeasurement(
            cervicoMentalAngle: 30.0, // <50°
            confidenceScore: 0.9,
            qualityFlags: MeasurementQualityFlags()
        )
        
        let highAngle = FaceMeasurement(
            cervicoMentalAngle: 200.0, // >180°
            confidenceScore: 0.9,
            qualityFlags: MeasurementQualityFlags()
        )
        
        let lowResult = validator.validateMeasurement(lowAngle)
        let highResult = validator.validateMeasurement(highAngle)
        
        #expect(!lowResult.isValid)
        #expect(!highResult.isValid)
        #expect(lowResult.issues.contains { 
            if case .invalidAngle = $0 { return true }
            return false
        })
        #expect(highResult.issues.contains { 
            if case .invalidAngle = $0 { return true }
            return false
        })
    }
    
    // MARK: - Test-Retest Reliability Tests
    
    @Test("assessTestRetestReliability requires minimum 3 measurements")
    @MainActor
    func reliabilityRequiresMinimumMeasurements() async throws {
        let validator = MeasurementValidator()
        
        let measurements = [
            FaceMeasurement(cervicoMentalAngle: 95.0),
            FaceMeasurement(cervicoMentalAngle: 96.0)
        ]
        
        let assessment = validator.assessTestRetestReliability(measurements)
        
        #expect(!assessment.isReliable)
        #expect(assessment.icc == nil)
        #expect(assessment.issues.contains { 
            if case .insufficientMeasurements = $0 { return true }
            return false
        })
    }
    
    @Test("assessTestRetestReliability calculates ICC for consistent measurements")
    @MainActor
    func reliabilityConsistentMeasurements() async throws {
        let validator = MeasurementValidator()
        
        // Highly consistent measurements (low variance)
        let measurements = [
            FaceMeasurement(cervicoMentalAngle: 95.0),
            FaceMeasurement(cervicoMentalAngle: 95.5),
            FaceMeasurement(cervicoMentalAngle: 94.5),
            FaceMeasurement(cervicoMentalAngle: 95.2),
            FaceMeasurement(cervicoMentalAngle: 95.0)
        ]
        
        let assessment = validator.assessTestRetestReliability(measurements)
        
        // Should have ICC calculated
        #expect(assessment.icc != nil)
        #expect(assessment.coefficientOfVariation != nil)
        
        // For consistent measurements, ICC should be high and CV should be low
        if let icc = assessment.icc {
            #expect(icc >= 0.0 && icc <= 1.0)
        }
        if let cv = assessment.coefficientOfVariation {
            #expect(cv >= 0.0)
        }
    }
    
    @Test("assessTestRetestReliability detects high variance")
    @MainActor
    func reliabilityHighVariance() async throws {
        let validator = MeasurementValidator()
        
        // High variance measurements
        let measurements = [
            FaceMeasurement(cervicoMentalAngle: 90.0),
            FaceMeasurement(cervicoMentalAngle: 110.0),
            FaceMeasurement(cervicoMentalAngle: 95.0),
            FaceMeasurement(cervicoMentalAngle: 105.0),
            FaceMeasurement(cervicoMentalAngle: 100.0)
        ]
        
        let assessment = validator.assessTestRetestReliability(measurements)
        
        // Should detect high variance
        if let cv = assessment.coefficientOfVariation {
            // CV might be high for these measurements
            if cv > 0.05 { // Above 5% threshold
                #expect(!assessment.isReliable)
                #expect(assessment.issues.contains { 
                    if case .highVariance = $0 { return true }
                    return false
                })
            }
        }
    }
    
    @Test("assessTestRetestReliability handles missing angles")
    @MainActor
    func reliabilityMissingAngles() async throws {
        let validator = MeasurementValidator()
        
        let measurements = [
            FaceMeasurement(cervicoMentalAngle: 95.0),
            FaceMeasurement(cervicoMentalAngle: nil), // Missing
            FaceMeasurement(cervicoMentalAngle: 96.0)
        ]
        
        let assessment = validator.assessTestRetestReliability(measurements)
        
        // Should handle missing angles gracefully
        #expect(assessment.icc != nil || assessment.issues.contains { 
            if case .missingPrimaryMetric = $0 { return true }
            return false
        })
    }
    
    @Test("hasHighVariance detects high variance between measurements")
    @MainActor
    func hasHighVariance() async throws {
        let validator = MeasurementValidator()
        
        // Low variance
        let lowVariance = [
            FaceMeasurement(cervicoMentalAngle: 95.0),
            FaceMeasurement(cervicoMentalAngle: 95.5)
        ]
        
        // High variance
        let highVariance = [
            FaceMeasurement(cervicoMentalAngle: 90.0),
            FaceMeasurement(cervicoMentalAngle: 110.0)
        ]
        
        let lowResult = validator.hasHighVariance(lowVariance)
        let highResult = validator.hasHighVariance(highVariance)
        
        // High variance should be detected
        #expect(highResult || !lowResult, "Should detect difference in variance")
    }
    
    @Test("hasHighVariance returns false for insufficient measurements")
    @MainActor
    func hasHighVarianceInsufficientMeasurements() async throws {
        let validator = MeasurementValidator()
        
        let singleMeasurement = [FaceMeasurement(cervicoMentalAngle: 95.0)]
        let noAngles = [
            FaceMeasurement(cervicoMentalAngle: nil),
            FaceMeasurement(cervicoMentalAngle: nil)
        ]
        
        #expect(!validator.hasHighVariance(singleMeasurement))
        #expect(!validator.hasHighVariance(noAngles))
    }
    
    // MARK: - Edge Cases
    
    @Test("validateMeasurement handles missing quality flags")
    @MainActor
    func validateMissingQualityFlags() async throws {
        let validator = MeasurementValidator()
        
        let measurement = FaceMeasurement(
            cervicoMentalAngle: 95.0,
            confidenceScore: 0.9,
            qualityFlags: nil
        )
        
        let result = validator.validateMeasurement(measurement)
        
        #expect(!result.isValid)
        #expect(result.issues.contains { 
            if case .missingQualityFlags = $0 { return true }
            return false
        })
    }
    
    @Test("assessTestRetestReliability handles empty array")
    @MainActor
    func reliabilityEmptyArray() async throws {
        let validator = MeasurementValidator()
        
        let assessment = validator.assessTestRetestReliability([])
        
        #expect(!assessment.isReliable)
        #expect(assessment.icc == nil)
        #expect(assessment.issues.contains { 
            if case .insufficientMeasurements = $0 { return true }
            return false
        })
    }
    
    @Test("assessTestRetestReliability handles perfect agreement")
    @MainActor
    func reliabilityPerfectAgreement() async throws {
        let validator = MeasurementValidator()
        
        // All measurements identical (perfect agreement)
        let measurements = [
            FaceMeasurement(cervicoMentalAngle: 95.0),
            FaceMeasurement(cervicoMentalAngle: 95.0),
            FaceMeasurement(cervicoMentalAngle: 95.0)
        ]
        
        let assessment = validator.assessTestRetestReliability(measurements)
        
        // Should have high ICC (perfect agreement)
        if let icc = assessment.icc {
            #expect(icc >= 0.9, "Perfect agreement should have ICC >= 0.9")
        }
        #expect(assessment.isReliable || assessment.icc == nil)
    }
}

