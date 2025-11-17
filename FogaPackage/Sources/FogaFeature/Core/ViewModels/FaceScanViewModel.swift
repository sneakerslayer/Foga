import Foundation
import SwiftUI

/// ViewModel for face scanning feature
/// 
/// **Learning Note**: This ViewModel manages ARKit face scanning state.
/// It coordinates between the ARKitService and the UI.
@MainActor
public class FaceScanViewModel: ObservableObject {
    /// ARKit service
    private let arKitService: ARKitService
    
    /// Data service
    private let dataService: DataService
    
    /// Current face measurement
    @Published public var currentMeasurement: FaceMeasurement?
    
    /// Baseline measurement (first scan)
    @Published public var baselineMeasurement: FaceMeasurement?
    
    /// Scanning state
    @Published public var isScanning: Bool = false
    
    /// Error message
    @Published public var errorMessage: String?
    
    public init(arKitService: ARKitService, dataService: DataService) {
        self.arKitService = arKitService
        self.dataService = dataService
        loadBaseline()
    }
    
    /// Start face scanning
    public func startScanning() {
        guard ARKitService.isSupported else {
            errorMessage = "Face tracking requires iPhone X or later"
            return
        }
        
        arKitService.startSession()
        isScanning = true
    }
    
    /// Stop face scanning
    public func stopScanning() {
        arKitService.stopSession()
        isScanning = false
    }
    
    /// Capture current measurement
    public func captureMeasurement() {
        guard let measurement = arKitService.captureMeasurements() else {
            errorMessage = "Could not capture measurement. Please ensure your face is visible."
            return
        }
        
        currentMeasurement = measurement
        
        // If no baseline exists, save this as baseline
        if baselineMeasurement == nil {
            baselineMeasurement = measurement
            saveBaseline()
        }
    }
    
    /// Save baseline measurement
    private func saveBaseline() {
        guard let baseline = baselineMeasurement else { return }
        
        // Save to UserDefaults for now (will migrate to Core Data later)
        if let encoded = try? JSONEncoder().encode(baseline) {
            UserDefaults.standard.set(encoded, forKey: "baselineMeasurement")
        }
    }
    
    /// Load baseline measurement
    private func loadBaseline() {
        guard let data = UserDefaults.standard.data(forKey: "baselineMeasurement"),
              let baseline = try? JSONDecoder().decode(FaceMeasurement.self, from: data) else {
            return
        }
        baselineMeasurement = baseline
    }
    
    /// Calculate progress percentage
    public func progressPercentage() -> Double {
        guard let current = currentMeasurement,
              let baseline = baselineMeasurement else {
            return 0
        }
        return current.improvementPercentage(from: baseline)
    }
}

