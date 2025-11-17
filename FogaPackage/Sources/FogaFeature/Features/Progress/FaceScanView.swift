import SwiftUI
import ARKit
import SceneKit

/// Face scanning view with ARKit camera feed and measurement capture
/// 
/// **Critical Purpose**: Displays ARKit camera feed, allows users to capture measurements,
/// and navigates to MeasurementResultView with all transparency components after capture.
@available(iOS 15.0, *)
public struct FaceScanView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FaceScanViewModel
    @StateObject private var arKitService: ARKitService
    
    @State private var showMeasurementResults = false
    @State private var capturedMeasurement: FaceMeasurement?
    @State private var showError = false
    
    let dataService: DataService
    
    public init(dataService: DataService) {
        self.dataService = dataService
        let arService = ARKitService()
        _arKitService = StateObject(wrappedValue: arService)
        _viewModel = StateObject(wrappedValue: FaceScanViewModel(arKitService: arService, dataService: dataService))
    }
    
    public var body: some View {
        ZStack {
            // ARKit camera view
            ARViewRepresentable(session: arKitService.session)
                .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top instructions
                VStack(spacing: 8) {
                    if arKitService.isTracking {
                        if arKitService.faceAnchor != nil {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Face detected")
                                    .font(AppTypography.body)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Position your face in the frame")
                                    .font(AppTypography.body)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Bottom controls
                VStack(spacing: 20) {
                    // Instructions
                    VStack(spacing: 8) {
                        Text("Keep your face centered and still")
                            .font(AppTypography.headline)
                            .foregroundColor(.white)
                        
                        Text("Maintain a neutral expression")
                            .font(AppTypography.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(16)
                    
                    // Capture button
                    Button(action: captureMeasurement) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .stroke(Color.black, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "camera.fill")
                                .foregroundColor(.black)
                                .font(.system(size: 32))
                        }
                    }
                    .disabled(!arKitService.isTracking || arKitService.faceAnchor == nil)
                    .opacity((arKitService.isTracking && arKitService.faceAnchor != nil) ? 1.0 : 0.5)
                    
                    // Cancel button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(AppTypography.body)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .navigationTitle("Face Scan")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
        .sheet(isPresented: $showMeasurementResults) {
            if let measurement = capturedMeasurement {
                NavigationView {
                    MeasurementResultView(
                        measurement: measurement,
                        baselineMeasurement: viewModel.baselineMeasurement,
                        onDismiss: {
                            showMeasurementResults = false
                        }
                    )
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            showError = newValue != nil
        }
    }
    
    private func captureMeasurement() {
        viewModel.captureMeasurement()
        
        if let measurement = viewModel.currentMeasurement {
            capturedMeasurement = measurement
            showMeasurementResults = true
            
            // Save measurement as Progress entry
            let progress = Progress(measurements: measurement, date: measurement.timestamp)
            dataService.addProgress(progress)
        }
    }
}

/// UIViewRepresentable wrapper for ARKit ARView
/// 
/// **Learning Note**: ARKit uses UIKit (ARSCNView), so we need UIViewRepresentable
/// to integrate it into SwiftUI.
@available(iOS 15.0, *)
struct ARViewRepresentable: UIViewRepresentable {
    let session: ARSession
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.session = session
        arView.automaticallyUpdatesLighting = true
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // No updates needed - session is already set
    }
}

