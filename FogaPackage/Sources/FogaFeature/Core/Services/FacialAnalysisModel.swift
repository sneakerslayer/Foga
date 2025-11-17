import Foundation
import CoreML
import Vision
import ARKit
#if canImport(UIKit)
import UIKit
#endif
#if canImport(CoreGraphics)
import CoreGraphics
#endif

/// Core ML model wrapper for facial fat classification and angle prediction
/// 
/// **Scientific Note**: Multi-modal model combining image, metadata, and ARKit 3D data.
/// Uses MobileNetV2 backbone (4M parameters) optimized for on-device inference.
/// 
/// **Architecture**:
/// - Image input: 224x224 RGB (MobileNetV2 feature extraction)
/// - Metadata input: 6 features (age, gender, BMI, etc.)
/// - ARKit input: 10 features (3D measurements from face mesh)
/// - Outputs: Cervico-mental angle regression, fat category classification, confidence score
/// 
/// **Privacy**: All processing happens on-device. No data leaves the device.
@available(iOS 15.0, *)
@MainActor
public class FacialAnalysisModel: ObservableObject {
    
    // MARK: - Model Configuration
    
    /// Model file name (will be added to bundle)
    private let modelFileName = "FacialAnalysisModel"
    private let modelFileExtension = "mlmodelc"
    
    /// Expected input image size
    public static let inputImageSize = CGSize(width: 224, height: 224)
    
    /// Model instance (lazy-loaded)
    private var model: MLModel?
    
    /// Vision framework model wrapper for image preprocessing
    private var visionModel: VNCoreMLModel?
    
    /// Model loading error
    @Published public var loadingError: String?
    
    /// Whether model is loaded and ready
    public var isLoaded: Bool {
        return model != nil && visionModel != nil
    }
    
    // MARK: - Initialization
    
    public init() {
        // Model will be loaded lazily on first use
    }
    
    // MARK: - Model Loading
    
    /// Load the Core ML model from bundle
    /// 
    /// **Note**: Model file must be added to app bundle.
    /// For now, this creates a placeholder structure - actual model will be added after training.
    /// 
    /// - Returns: True if model loaded successfully, false otherwise
    @discardableResult
    public func loadModel() -> Bool {
        guard model == nil else {
            return true // Already loaded
        }
        
        // Try to load model from bundle
        guard let modelURL = Bundle.main.url(
            forResource: modelFileName,
            withExtension: modelFileExtension
        ) else {
            // Model not found - this is expected during development
            // Will be available after Python training script generates it
            loadingError = "Model file not found in bundle. Run Python training script to generate model."
            return false
        }
        
        do {
            // Load Core ML model
            let config = MLModelConfiguration()
            config.computeUnits = .all // Use Neural Engine when available
            model = try MLModel(contentsOf: modelURL, configuration: config)
            
            // Create Vision framework wrapper for image preprocessing
            if let coreMLModel = model {
                visionModel = try? VNCoreMLModel(for: coreMLModel)
            }
            
            loadingError = nil
            return true
        } catch {
            loadingError = "Failed to load model: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Prediction Interface
    
    /// Perform facial analysis prediction
    /// 
    /// **Multi-modal Input**:
    /// - Image: Face photo (224x224 RGB)
    /// - Metadata: User demographics and context (6 features)
    /// - ARKit: 3D measurements from face mesh (10 features)
    /// 
    /// **Outputs**:
    /// - Cervico-mental angle prediction (degrees)
    /// - Fat category classification (Low/Moderate/High)
    /// - Confidence score (0.0-1.0)
    /// - Uncertainty quantification (confidence intervals)
    /// 
    /// - Parameters:
    ///   - image: Face image (will be resized to 224x224)
    ///   - metadata: User metadata (age, gender, BMI, etc.)
    ///   - arkitFeatures: ARKit 3D measurements
    /// - Returns: PredictionResult with all outputs, or nil if prediction fails
    public func predict(
        image: UIImage,
        metadata: ModelMetadata,
        arkitFeatures: ARKitFeatures
    ) async throws -> PredictionResult {
        guard loadModel(), let model = model else {
            throw ModelError.modelNotLoaded
        }
        
        // Preprocess inputs
        let imageInput = try preprocessImage(image)
        let metadataInput = preprocessMetadata(metadata)
        let arkitInput = preprocessARKitFeatures(arkitFeatures)
        
        // Create model input
        guard let input = createModelInput(
            image: imageInput,
            metadata: metadataInput,
            arkit: arkitInput
        ) else {
            throw ModelError.inputPreprocessingFailed
        }
        
        // Perform prediction
        do {
            let prediction = try model.prediction(from: input)
            return parsePrediction(prediction)
        } catch {
            throw ModelError.predictionFailed(error.localizedDescription)
        }
    }
    
    /// Perform prediction using Vision framework (simpler interface for image-only)
    /// 
    /// **Note**: This is a convenience method. Full multi-modal prediction uses `predict()`.
    /// 
    /// - Parameter image: Face image
    /// - Returns: PredictionResult, or nil if prediction fails
    public func predict(image: UIImage) async throws -> PredictionResult {
        guard loadModel() else {
            throw ModelError.modelNotLoaded
        }
        
        // For now, use placeholder metadata and ARKit features
        // In production, these would come from user profile and ARKit session
        let metadata = ModelMetadata(
            age: nil,
            gender: nil,
            bmi: nil,
            ethnicity: nil,
            skinTone: nil,
            measurementContext: .baseline
        )
        
        let arkitFeatures = ARKitFeatures(
            cervicoMentalAngle: nil,
            submentalCervicalLength: nil,
            jawDefinitionIndex: nil,
            neckCircumference: nil,
            facialAdiposityIndex: nil,
            faceWidth: nil,
            faceHeight: nil,
            headPosePitch: nil,
            headPoseYaw: nil,
            headPoseRoll: nil
        )
        
        return try await predict(image: image, metadata: metadata, arkitFeatures: arkitFeatures)
    }
    
    // MARK: - Input Preprocessing
    
    /// Preprocess image to model input format (224x224 RGB)
    private func preprocessImage(_ image: UIImage) throws -> CVPixelBuffer {
        // Resize to 224x224
        let targetSize = Self.inputImageSize
        guard let resizedImage = image.resized(to: targetSize) else {
            throw ModelError.imagePreprocessingFailed
        }
        
        // Convert to CVPixelBuffer
        guard let pixelBuffer = resizedImage.pixelBuffer() else {
            throw ModelError.imagePreprocessingFailed
        }
        
        return pixelBuffer
    }
    
    /// Preprocess metadata to model input format (6 features)
    private func preprocessMetadata(_ metadata: ModelMetadata) -> [Double] {
        // Normalize metadata features
        // Age: normalize to 0-1 (assuming 18-80 range)
        let ageNormalized = metadata.age.map { Double($0 - 18) / 62.0 } ?? 0.5
        
        // Gender: encode as 0.0 (male), 0.5 (other), 1.0 (female)
        let genderEncoded: Double
        switch metadata.gender {
        case .male:
            genderEncoded = 0.0
        case .female:
            genderEncoded = 1.0
        case .other:
            genderEncoded = 0.5
        case .none:
            genderEncoded = 0.5 // Default to middle value
        }
        
        // BMI: normalize to 0-1 (assuming 15-40 range)
        let bmiNormalized = metadata.bmi.map { Double($0 - 15) / 25.0 } ?? 0.5
        
        // Ethnicity: one-hot encoding (simplified to single value for now)
        // In production, would use proper one-hot encoding
        let ethnicityEncoded: Double = 0.5 // Placeholder
        
        // Skin tone: normalize to 0-1 (Fitzpatrick scale 1-6)
        let skinToneNormalized = metadata.skinTone.map { Double($0 - 1) / 5.0 } ?? 0.5
        
        // Measurement context: encode as 0.0 (baseline), 0.5 (progress), 1.0 (followup)
        let contextEncoded: Double
        switch metadata.measurementContext {
        case .baseline:
            contextEncoded = 0.0
        case .progress:
            contextEncoded = 0.5
        case .followup:
            contextEncoded = 1.0
        }
        
        return [
            ageNormalized,
            genderEncoded,
            bmiNormalized,
            ethnicityEncoded,
            skinToneNormalized,
            contextEncoded
        ]
    }
    
    /// Preprocess ARKit features to model input format (10 features)
    private func preprocessARKitFeatures(_ features: ARKitFeatures) -> [Double] {
        // Normalize ARKit measurements
        // Cervico-mental angle: normalize to 0-1 (assuming 70-150° range)
        let angleNormalized = features.cervicoMentalAngle.map { Double($0 - 70) / 80.0 } ?? 0.5
        
        // Submental-cervical length: normalize to 0-1 (assuming 15-60mm range)
        let lengthNormalized = features.submentalCervicalLength.map { Double($0 - 15) / 45.0 } ?? 0.5
        
        // Jaw definition index: already normalized (0-1 ratio)
        let jawIndexNormalized = features.jawDefinitionIndex ?? 0.5
        
        // Neck circumference: normalize to 0-1 (assuming 300-500mm range)
        let neckNormalized = features.neckCircumference.map { Double($0 - 300) / 200.0 } ?? 0.5
        
        // Facial adiposity index: already normalized (0-100, convert to 0-1)
        let adiposityNormalized = features.facialAdiposityIndex.map { $0 / 100.0 } ?? 0.5
        
        // Face width: normalize to 0-1 (assuming 120-180mm range)
        let faceWidthNormalized = features.faceWidth.map { Double($0 - 120) / 60.0 } ?? 0.5
        
        // Face height: normalize to 0-1 (assuming 180-250mm range)
        let faceHeightNormalized = features.faceHeight.map { Double($0 - 180) / 70.0 } ?? 0.5
        
        // Head pose angles: normalize to -1 to 1 (assuming ±30° range)
        let pitchNormalized = features.headPosePitch.map { Double($0) / 30.0 } ?? 0.0
        let yawNormalized = features.headPoseYaw.map { Double($0) / 30.0 } ?? 0.0
        let rollNormalized = features.headPoseRoll.map { Double($0) / 30.0 } ?? 0.0
        
        return [
            angleNormalized,
            lengthNormalized,
            jawIndexNormalized,
            neckNormalized,
            adiposityNormalized,
            faceWidthNormalized,
            faceHeightNormalized,
            pitchNormalized,
            yawNormalized,
            rollNormalized
        ]
    }
    
    /// Create Core ML model input from preprocessed data
    private func createModelInput(
        image: CVPixelBuffer,
        metadata: [Double],
        arkit: [Double]
    ) -> MLFeatureProvider? {
        // This will be implemented based on actual model input structure
        // For now, return nil (model not yet trained)
        // In production, would create MLMultiArray or MLFeatureValue instances
        
        // Placeholder: Actual implementation depends on model architecture
        return nil
    }
    
    /// Parse Core ML prediction output to PredictionResult
    private func parsePrediction(_ prediction: MLFeatureProvider) -> PredictionResult {
        // This will be implemented based on actual model output structure
        // For now, return placeholder result
        
        // Placeholder: Actual implementation depends on model outputs
        return PredictionResult(
            cervicoMentalAngle: 100.0,
            angleConfidenceInterval: (95.0, 105.0),
            fatCategory: .moderate,
            categoryConfidence: 0.75,
            overallConfidence: 0.80,
            uncertainty: 0.15
        )
    }
}

// MARK: - Model Errors

public enum ModelError: LocalizedError {
    case modelNotLoaded
    case inputPreprocessingFailed
    case imagePreprocessingFailed
    case predictionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Model is not loaded. Call loadModel() first."
        case .inputPreprocessingFailed:
            return "Failed to preprocess input data."
        case .imagePreprocessingFailed:
            return "Failed to preprocess image."
        case .predictionFailed(let message):
            return "Prediction failed: \(message)"
        }
    }
}

// MARK: - UIImage Extensions for Preprocessing

private extension UIImage {
    /// Resize image to target size
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Convert UIImage to CVPixelBuffer
    func pixelBuffer() -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        guard let cgContext = context else {
            return nil
        }
        
        cgContext.translateBy(x: 0, y: size.height)
        cgContext.scaleBy(x: 1.0, y: -1.0)
        cgContext.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        
        return buffer
    }
}


