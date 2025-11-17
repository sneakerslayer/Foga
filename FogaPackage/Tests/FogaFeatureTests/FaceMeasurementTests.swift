import Foundation
import Testing
@testable import FogaFeature

/// Unit tests for FaceMeasurement model
/// 
/// Tests computed properties, validation logic, and improvement calculations.
@Suite("FaceMeasurement Tests")
struct FaceMeasurementTests {
    
    // MARK: - Computed Properties Tests
    
    @Test("isCervicoMentalAngleOptimal returns true for optimal range (90-105°)")
    func cervicoMentalAngleOptimal() {
        let measurement = FaceMeasurement(
            chinWidth: 0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            cervicoMentalAngle: 95.0,
            confidenceScore: 0.9
        )
        
        #expect(measurement.isCervicoMentalAngleOptimal)
    }
    
    @Test("isCervicoMentalAngleOptimal returns false for angles outside optimal range")
    func cervicoMentalAngleNotOptimal() {
        let lowAngle = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date(), cervicoMentalAngle: 85.0)
        let highAngle = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date(), cervicoMentalAngle: 110.0)
        let nilAngle = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date(), cervicoMentalAngle: nil)
        
        #expect(!lowAngle.isCervicoMentalAngleOptimal)
        #expect(!highAngle.isCervicoMentalAngleOptimal)
        #expect(!nilAngle.isCervicoMentalAngleOptimal)
    }
    
    @Test("isCervicoMentalAngleConcerning returns true for angles >120°")
    func cervicoMentalAngleConcerning() {
        let concerningAngle = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date(), cervicoMentalAngle: 125.0)
        let optimalAngle = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date(), cervicoMentalAngle: 95.0)
        let nilAngle = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date(), cervicoMentalAngle: nil)
        
        #expect(concerningAngle.isCervicoMentalAngleConcerning)
        #expect(!optimalAngle.isCervicoMentalAngleConcerning)
        #expect(!nilAngle.isCervicoMentalAngleConcerning)
    }
    
    @Test("hasSufficientConfidence returns true for confidence >= 0.8")
    func hasSufficientConfidence() {
        let highConfidence = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date(), confidenceScore: 0.9)
        let lowConfidence = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date(), confidenceScore: 0.7)
        let nilConfidence = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date(), confidenceScore: nil)
        
        #expect(highConfidence.hasSufficientConfidence)
        #expect(!lowConfidence.hasSufficientConfidence)
        #expect(!nilConfidence.hasSufficientConfidence)
    }
    
    @Test("hasAcceptableQuality returns true when all quality flags are acceptable")
    func hasAcceptableQuality() {
        let goodQuality = FaceMeasurement(
            chinWidth: 0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            qualityFlags: MeasurementQualityFlags(
                frankfurtPlaneAlignment: 5.0,
                isNeutralExpression: true,
                lightingUniformity: 0.9,
                faceVisibility: 1.0
            )
        )
        
        let poorQuality = FaceMeasurement(
            chinWidth: 0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            qualityFlags: MeasurementQualityFlags(
                frankfurtPlaneAlignment: 15.0, // >10° deviation
                isNeutralExpression: true,
                lightingUniformity: 0.9,
                faceVisibility: 1.0
            )
        )
        
        let nilQuality = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date(), qualityFlags: nil)
        
        #expect(goodQuality.hasAcceptableQuality)
        #expect(!poorQuality.hasAcceptableQuality)
        #expect(!nilQuality.hasAcceptableQuality)
    }
    
    // MARK: - Improvement Calculation Tests
    
    @Test("improvementPercentage calculates improvement using cervico-mental angle")
    func improvementPercentageWithAngle() {
        let baseline = FaceMeasurement(
            chinWidth: 50.0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            cervicoMentalAngle: 120.0
        )
        
        let current = FaceMeasurement(
            chinWidth: 45.0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            cervicoMentalAngle: 105.0 // Improved (closer to optimal)
        )
        
        let improvement = current.improvementPercentage(from: baseline)
        
        // Should show improvement (angle decreased from 120° to 105°)
        #expect(improvement >= 0 && improvement <= 100)
        #expect(improvement > 0, "Should show positive improvement")
    }
    
    @Test("improvementPercentage falls back to chinWidth when angle not available")
    func improvementPercentageFallbackToChinWidth() {
        let baseline = FaceMeasurement(
            chinWidth: 50.0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date()
        )
        
        let current = FaceMeasurement(
            chinWidth: 45.0, // 10% reduction
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date()
        )
        
        let improvement = current.improvementPercentage(from: baseline)
        
        // Should be approximately 10% improvement
        #expect(improvement >= 9 && improvement <= 11)
    }
    
    @Test("improvementPercentage returns 0 for invalid baseline")
    func improvementPercentageInvalidBaseline() {
        let baseline = FaceMeasurement(chinWidth: 0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date()) // Invalid baseline
        let current = FaceMeasurement(chinWidth: 45.0, jawlineAngle: 0, neckCircumference: 0, timestamp: Date())
        
        let improvement = current.improvementPercentage(from: baseline)
        
        #expect(improvement == 0)
    }
    
    @Test("improvementPercentage validates angle bounds (>50° and <180°)")
    func improvementPercentageValidatesAngleBounds() {
        // Test with invalid angles (should fall back to chinWidth)
        let baseline = FaceMeasurement(
            chinWidth: 50.0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            cervicoMentalAngle: 30.0 // Invalid (<50°)
        )
        
        let current = FaceMeasurement(
            chinWidth: 45.0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            cervicoMentalAngle: 200.0 // Invalid (>180°)
        )
        
        let improvement = current.improvementPercentage(from: baseline)
        
        // Should fall back to chinWidth calculation
        #expect(improvement >= 9 && improvement <= 11)
    }
    
    @Test("improvementPercentage handles zero improvement")
    func improvementPercentageZeroImprovement() {
        let baseline = FaceMeasurement(
            chinWidth: 50.0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            cervicoMentalAngle: 100.0
        )
        
        let current = FaceMeasurement(
            chinWidth: 50.0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            cervicoMentalAngle: 100.0 // No change
        )
        
        let improvement = current.improvementPercentage(from: baseline)
        
        #expect(improvement == 0)
    }
    
    @Test("improvementPercentage clamps result to 0-100% range")
    func improvementPercentageClampsRange() {
        // Test extreme improvement (should be clamped)
        let baseline = FaceMeasurement(
            chinWidth: 100.0,
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            cervicoMentalAngle: 150.0
        )
        
        let current = FaceMeasurement(
            chinWidth: 10.0, // Large reduction
            jawlineAngle: 0,
            neckCircumference: 0,
            timestamp: Date(),
            cervicoMentalAngle: 90.0 // Large improvement
        )
        
        let improvement = current.improvementPercentage(from: baseline)
        
        // Should be clamped to 0-100%
        #expect(improvement >= 0 && improvement <= 100)
    }
    
    // MARK: - Edge Cases
    
    @Test("FaceMeasurement initializes with default values")
    func faceMeasurementInitialization() {
        let measurement = FaceMeasurement()
        
        #expect(measurement.chinWidth == 0)
        #expect(measurement.jawlineAngle == 0)
        #expect(measurement.neckCircumference == 0)
        #expect(measurement.cervicoMentalAngle == nil)
        #expect(measurement.confidenceScore == nil)
    }
    
    @Test("FaceMeasurement preserves all properties")
    func faceMeasurementPreservesProperties() {
        let qualityFlags = MeasurementQualityFlags(
            frankfurtPlaneAlignment: 5.0,
            isNeutralExpression: true,
            lightingUniformity: 0.9,
            faceVisibility: 1.0
        )
        
        let measurement = FaceMeasurement(
            chinWidth: 50.0,
            jawlineAngle: 90.0,
            neckCircumference: 300.0,
            timestamp: Date(),
            cervicoMentalAngle: 95.0,
            submentalCervicalLength: 30.0,
            jawDefinitionIndex: 0.8,
            facialAdiposityIndex: 25.0,
            confidenceScore: 0.9,
            qualityFlags: qualityFlags
        )
        
        #expect(measurement.chinWidth == 50.0)
        #expect(measurement.jawlineAngle == 90.0)
        #expect(measurement.neckCircumference == 300.0)
        #expect(measurement.cervicoMentalAngle == 95.0)
        #expect(measurement.submentalCervicalLength == 30.0)
        #expect(measurement.jawDefinitionIndex == 0.8)
        #expect(measurement.facialAdiposityIndex == 25.0)
        #expect(measurement.confidenceScore == 0.9)
        #expect(measurement.qualityFlags?.frankfurtPlaneAlignment == 5.0)
    }
}

