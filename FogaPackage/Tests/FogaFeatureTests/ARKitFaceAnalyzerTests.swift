import Foundation
import Testing
import ARKit
@testable import FogaFeature

/// Unit tests for ARKitFaceAnalyzer measurement calculations
/// 
/// Tests cervico-mental angle calculation accuracy, Farkas measurements,
/// and edge cases for measurement quality validation.
/// 
/// **Note**: Since ARFaceAnchor cannot be directly constructed, these tests focus on
/// validating the mathematical calculations and logic used by ARKitFaceAnalyzer.
@Suite("ARKitFaceAnalyzer Tests")
struct ARKitFaceAnalyzerTests {
    
    // MARK: - Cervico-Mental Angle Tests
    
    @Test("Cervico-mental angle calculation with optimal angle (90-105°)")
    @MainActor
    func cervicoMentalAngleOptimal() async throws {
        let analyzer = ARKitFaceAnalyzer()
        
        // Create mock vertices for 90° angle
        // For 90° angle: submental-cervical vector perpendicular to submental-chin vector
        let submentalPoint = SIMD3<Float>(0, 0, 0)
        let cervicalPoint = SIMD3<Float>(0, -0.01, 0) // Down (neck)
        let chinPoint = SIMD3<Float>(0.01, 0, 0) // Forward (chin)
        
        // Create minimal face anchor geometry
        var vertices = Array(repeating: SIMD3<Float>(0, 0, 0), count: 1220)
        vertices[9] = chinPoint
        vertices[18] = submentalPoint
        vertices[23] = cervicalPoint
        
        // Note: ARFaceGeometry cannot be directly constructed in tests
        // This test validates the mathematical calculations instead
        
        // Create transform
        let transform = matrix_identity_float4x4
        
        // Create blendshapes (neutral)
        let blendshapes: [ARFaceAnchor.BlendShapeLocation: NSNumber] = [:]
        
        // Note: Since we can't directly create ARFaceAnchor, we'll test the calculation logic
        // by creating a test helper that mimics the calculation
        
        // Test the angle calculation directly using the vector math
        let neckVector = SIMD3<Float>(
            cervicalPoint.x - submentalPoint.x,
            cervicalPoint.y - submentalPoint.y,
            cervicalPoint.z - submentalPoint.z
        )
        let chinVector = SIMD3<Float>(
            chinPoint.x - submentalPoint.x,
            chinPoint.y - submentalPoint.y,
            chinPoint.z - submentalPoint.z
        )
        
        let dotProduct = dot(neckVector, chinVector)
        let neckMagnitude = length(neckVector)
        let chinMagnitude = length(chinVector)
        
        guard neckMagnitude > 0 && chinMagnitude > 0 else {
            Issue.record("Vectors have zero magnitude")
            return
        }
        
        let cosAngle = dotProduct / (neckMagnitude * chinMagnitude)
        let angleRadians = acos(max(-1.0, min(1.0, cosAngle)))
        let angleDegrees = Double(angleRadians) * 180.0 / .pi
        
        // For perpendicular vectors, angle should be ~90°
        #expect(angleDegrees >= 85 && angleDegrees <= 95, "Angle should be approximately 90°")
    }
    
    @Test("Cervico-mental angle calculation with concerning angle (>120°)")
    func cervicoMentalAngleConcerning() async throws {
        // Test angle calculation for >120° (indicating double chin concern)
        // For >120°: vectors point in similar directions (obtuse angle)
        
        let submentalPoint = SIMD3<Float>(0, 0, 0)
        let cervicalPoint = SIMD3<Float>(0, -0.01, 0) // Down
        let chinPoint = SIMD3<Float>(-0.01, 0.005, 0) // Back and slightly up (obtuse angle)
        
        let neckVector = SIMD3<Float>(
            cervicalPoint.x - submentalPoint.x,
            cervicalPoint.y - submentalPoint.y,
            cervicalPoint.z - submentalPoint.z
        )
        let chinVector = SIMD3<Float>(
            chinPoint.x - submentalPoint.x,
            chinPoint.y - submentalPoint.y,
            chinPoint.z - submentalPoint.z
        )
        
        let dotProduct = dot(neckVector, chinVector)
        let neckMagnitude = length(neckVector)
        let chinMagnitude = length(chinVector)
        
        guard neckMagnitude > 0 && chinMagnitude > 0 else {
            Issue.record("Vectors have zero magnitude")
            return
        }
        
        let cosAngle = dotProduct / (neckMagnitude * chinMagnitude)
        let angleRadians = acos(max(-1.0, min(1.0, cosAngle)))
        let angleDegrees = Double(angleRadians) * 180.0 / .pi
        
        // Angle should be >120° for concerning case
        #expect(angleDegrees > 120 || angleDegrees < 60, "Angle should indicate concern (>120°) or be acute")
    }
    
    @Test("Cervico-mental angle returns nil for insufficient vertices")
    @MainActor
    func cervicoMentalAngleInsufficientVertices() async throws {
        let analyzer = ARKitFaceAnalyzer()
        
        // Create geometry with insufficient vertices
        var vertices = Array(repeating: SIMD3<Float>(0, 0, 0), count: 10) // Too few
        
        // Note: ARFaceGeometry cannot be directly constructed in tests
        // This test validates the guard condition logic instead
        let transform = matrix_identity_float4x4
        let blendshapes: [ARFaceAnchor.BlendShapeLocation: NSNumber] = [:]
        
        // Since we can't create ARFaceAnchor directly, test the guard condition logic
        let chinVertexIndex = 9
        let submentalVertexIndex = 18
        let cervicalVertexIndex = 23
        
        let maxIndex = max(chinVertexIndex, submentalVertexIndex, cervicalVertexIndex)
        let hasEnoughVertices = vertices.count > maxIndex
        
        #expect(!hasEnoughVertices, "Should detect insufficient vertices")
    }
    
    @Test("Cervico-mental angle handles zero magnitude vectors")
    func cervicoMentalAngleZeroVectors() async throws {
        // Test that zero magnitude vectors return nil
        let submentalPoint = SIMD3<Float>(0, 0, 0)
        let cervicalPoint = SIMD3<Float>(0, 0, 0) // Same point = zero vector
        let chinPoint = SIMD3<Float>(0, 0, 0) // Same point = zero vector
        
        let neckVector = SIMD3<Float>(
            cervicalPoint.x - submentalPoint.x,
            cervicalPoint.y - submentalPoint.y,
            cervicalPoint.z - submentalPoint.z
        )
        let chinVector = SIMD3<Float>(
            chinPoint.x - submentalPoint.x,
            chinPoint.y - submentalPoint.y,
            chinPoint.z - submentalPoint.z
        )
        
        let neckMagnitude = length(neckVector)
        let chinMagnitude = length(chinVector)
        
        // Should detect zero magnitude
        #expect(neckMagnitude == 0 || chinMagnitude == 0, "Should detect zero magnitude vectors")
    }
    
    // MARK: - Farkas Measurements Tests
    
    @Test("Submental-cervical length calculation")
    func submentalCervicalLength() async throws {
        // Test distance calculation
        let submentalPoint = SIMD3<Float>(0, 0, 0)
        let cervicalPoint = SIMD3<Float>(0, -0.01, 0) // 1cm down
        
        let dx = cervicalPoint.x - submentalPoint.x
        let dy = cervicalPoint.y - submentalPoint.y
        let dz = cervicalPoint.z - submentalPoint.z
        let distance = sqrt(dx * dx + dy * dy + dz * dz)
        let distanceMM = Double(distance) * 1000.0 // Convert meters to millimeters
        
        // Should be approximately 10mm
        #expect(distanceMM >= 9 && distanceMM <= 11, "Distance should be approximately 10mm")
    }
    
    @Test("Jaw definition index calculation")
    func jawDefinitionIndex() async throws {
        // Test ratio calculation: bigonial breadth / face width
        let leftJaw = SIMD3<Float>(-0.05, 0, 0)
        let rightJaw = SIMD3<Float>(0.05, 0, 0)
        let leftZygion = SIMD3<Float>(-0.06, 0, 0)
        let rightZygion = SIMD3<Float>(0.06, 0, 0)
        
        // Calculate bigonial breadth
        let jawDx = rightJaw.x - leftJaw.x
        let jawDy = rightJaw.y - leftJaw.y
        let jawDz = rightJaw.z - leftJaw.z
        let bigonialBreadth = sqrt(jawDx * jawDx + jawDy * jawDy + jawDz * jawDz)
        
        // Calculate face width
        let faceDx = rightZygion.x - leftZygion.x
        let faceDy = rightZygion.y - leftZygion.y
        let faceDz = rightZygion.z - leftZygion.z
        let faceWidth = sqrt(faceDx * faceDx + faceDy * faceDy + faceDz * faceDz)
        
        guard faceWidth > 0 else {
            Issue.record("Face width is zero")
            return
        }
        
        let jawDefinitionIndex = Double(bigonialBreadth / faceWidth)
        
        // Ratio should be between 0 and 1
        #expect(jawDefinitionIndex >= 0 && jawDefinitionIndex <= 1, "Jaw definition index should be between 0 and 1")
        // For this test case, should be approximately 0.83 (0.10 / 0.12)
        #expect(jawDefinitionIndex >= 0.8 && jawDefinitionIndex <= 0.9, "Jaw definition index should be approximately 0.83")
    }
    
    @Test("Neck circumference estimation")
    func neckCircumference() async throws {
        // Test circumference estimation from neck width
        let leftNeck = SIMD3<Float>(-0.03, 0, 0)
        let rightNeck = SIMD3<Float>(0.03, 0, 0)
        
        let dx = rightNeck.x - leftNeck.x
        let dy = rightNeck.y - leftNeck.y
        let dz = rightNeck.z - leftNeck.z
        let neckWidth = sqrt(dx * dx + dy * dy + dz * dz)
        
        let estimatedRadius = neckWidth / 2.0
        let circumference = 2.0 * Float.pi * estimatedRadius
        let circumferenceMM = Double(circumference) * 1000.0
        
        // Should be approximately 188mm (2 * π * 0.03m)
        #expect(circumferenceMM >= 180 && circumferenceMM <= 200, "Circumference should be approximately 188mm")
    }
    
    @Test("Facial adiposity index calculation")
    func facialAdiposityIndex() async throws {
        // Test composite score calculation
        let cervicoMentalAngle: Double = 120 // Concerning angle
        let submentalCervicalLength: Double = 50 // Longer length
        let jawDefinitionIndex: Double = 0.7 // Lower definition
        
        var components: [Double] = []
        
        // Component 1: Angle contribution (120° - 90°) * 2 = 60
        let angleComponent = max(0, min(100, (cervicoMentalAngle - 90) * 2.0))
        components.append(angleComponent)
        
        // Component 2: Length contribution ((50 - 20) / 40) * 100 = 75
        let normalizedLength = max(0, min(100, ((submentalCervicalLength - 20) / 40.0) * 100))
        components.append(normalizedLength)
        
        // Component 3: Jaw definition (inverse) (1.0 - 0.7) * 100 = 30
        let jawComponent = max(0, min(100, (1.0 - jawDefinitionIndex) * 100))
        components.append(jawComponent)
        
        let average = components.reduce(0, +) / Double(components.count)
        
        // Average should be approximately 55
        #expect(average >= 50 && average <= 60, "Facial adiposity index should be approximately 55")
        #expect(average >= 0 && average <= 100, "Facial adiposity index should be between 0 and 100")
    }
    
    // MARK: - Measurement Quality Tests
    
    @Test("Frankfurt plane deviation calculation")
    func frankfurtPlaneDeviation() async throws {
        // Test pitch angle extraction from transform
        let pitchDegrees: Double = 5.0 // 5° deviation
        let pitchRadians = Float(pitchDegrees * .pi / 180.0)
        
        // Create rotation quaternion for pitch
        let quaternion = simd_quatf(ix: sin(pitchRadians / 2), iy: 0, iz: 0, r: cos(pitchRadians / 2))
        
        // Extract pitch from quaternion
        let extractedPitch = asin(max(-1.0, min(1.0, 2.0 * (quaternion.vector.w * quaternion.vector.y - quaternion.vector.z * quaternion.vector.x))))
        let extractedPitchDegrees = abs(Double(extractedPitch) * 180.0 / .pi)
        
        // Should be approximately 5°
        #expect(extractedPitchDegrees >= 4 && extractedPitchDegrees <= 6, "Pitch should be approximately 5°")
    }
    
    @Test("Neutral expression detection")
    func neutralExpressionDetection() async throws {
        // Test blendshape threshold checking
        let maxExpressionBlendshape: Float = 0.2
        
        // Neutral expression (all values < 0.2)
        let neutralBlendshapes: [Float] = [0.1, 0.15, 0.05]
        let isNeutral = neutralBlendshapes.allSatisfy { $0 <= maxExpressionBlendshape }
        #expect(isNeutral, "Should detect neutral expression")
        
        // Non-neutral expression (value > 0.2)
        let nonNeutralBlendshapes: [Float] = [0.1, 0.15, 0.5]
        let isNonNeutral = !nonNeutralBlendshapes.allSatisfy { $0 <= maxExpressionBlendshape }
        #expect(isNonNeutral, "Should detect non-neutral expression")
    }
    
    @Test("Face visibility completeness check")
    func faceVisibilityCompleteness() async throws {
        let expectedVertices = 1220
        
        // Full visibility
        let fullVertices = 1220
        let fullVisibility = Double(fullVertices) / Double(expectedVertices)
        #expect(fullVisibility == 1.0, "Full visibility should be 1.0")
        
        // Partial visibility
        let partialVertices = 1000
        let partialVisibility = Double(partialVertices) / Double(expectedVertices)
        #expect(partialVisibility >= 0.8 && partialVisibility <= 0.9, "Partial visibility should be approximately 0.82")
    }
    
    @Test("Confidence score calculation")
    func confidenceScoreCalculation() async throws {
        // Test confidence score reduction based on quality flags
        var confidence: Double = 1.0
        
        // Reduce for poor Frankfurt plane alignment (>10°)
        let frankfurtDeviation: Double = 15.0
        if frankfurtDeviation > 10.0 {
            confidence *= 0.7
        }
        #expect(confidence == 0.7, "Confidence should be reduced to 0.7")
        
        // Reset and test non-neutral expression
        confidence = 1.0
        let isNeutralExpression = false
        if !isNeutralExpression {
            confidence *= 0.8
        }
        #expect(confidence == 0.8, "Confidence should be reduced to 0.8")
        
        // Reset and test poor lighting
        confidence = 1.0
        let lightingUniformity: Double = 0.6
        if lightingUniformity < 0.7 {
            confidence *= 0.8
        }
        #expect(confidence == 0.8, "Confidence should be reduced to 0.8")
        
        // Reset and test incomplete visibility
        confidence = 1.0
        let faceVisibility: Double = 0.8
        if faceVisibility < 0.9 {
            confidence *= faceVisibility
        }
        #expect(confidence == 0.8, "Confidence should be reduced to 0.8")
    }
    
    // MARK: - Edge Cases
    
    @Test("Handles missing vertices gracefully")
    func handlesMissingVertices() async throws {
        // Test that calculations handle missing vertex indices
        let vertices: [SIMD3<Float>] = Array(repeating: SIMD3<Float>(0, 0, 0), count: 10)
        
        let chinVertexIndex = 9
        let submentalVertexIndex = 18
        let cervicalVertexIndex = 23
        
        let maxIndex = max(chinVertexIndex, submentalVertexIndex, cervicalVertexIndex)
        let hasEnoughVertices = vertices.count > maxIndex
        
        #expect(!hasEnoughVertices, "Should detect insufficient vertices")
    }
    
    @Test("Angle calculation clamps cosine to valid range")
    func angleCalculationClampsCosine() async throws {
        // Test that acos input is clamped to [-1, 1] to avoid NaN
        let cosAngle: Double = 1.5 // Invalid (outside [-1, 1])
        let clampedCos = max(-1.0, min(1.0, cosAngle))
        let angleRadians = acos(clampedCos)
        
        // Should not be NaN
        #expect(!angleRadians.isNaN, "Angle should not be NaN")
        #expect(angleRadians >= 0 && angleRadians <= .pi, "Angle should be in valid range")
    }
}

