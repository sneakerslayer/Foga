import SwiftUI

/// Comprehensive view for displaying face measurement results with scientific transparency
/// 
/// **Critical Purpose**: Displays measurement results honestly, showing:
/// - Current measurement with confidence scores
/// - Optimal ranges (90-105° for cervico-mental angle)
/// - Clear explanations of what measurements mean
/// - Progress predictions with confidence intervals
/// - Scientific disclaimers and transparency information
/// - Mental health resources when appropriate
@available(iOS 15.0, *)
public struct MeasurementResultView: View {
    @StateObject private var predictionModel = ProgressPredictionModel()
    @StateObject private var ethicalSafeguards = EthicalSafeguards()
    @StateObject private var scientificDisclosure = ScientificDisclosureViewModel()
    
    let measurement: FaceMeasurement
    let baselineMeasurement: FaceMeasurement?
    let onDismiss: (() -> Void)?
    
    @State private var showEvidenceDisclosure = false
    @State private var showMedicalAlternatives = false
    @State private var showWellbeingResources = false
    
    public init(
        measurement: FaceMeasurement,
        baselineMeasurement: FaceMeasurement? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.measurement = measurement
        self.baselineMeasurement = baselineMeasurement
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Current Measurement
                currentMeasurementSection
                
                // Optimal Range Explanation
                optimalRangeSection
                
                // Progress Prediction (if baseline exists)
                if let baseline = baselineMeasurement {
                    progressPredictionSection(baseline: baseline)
                }
                
                // Measurement Quality Warnings
                if !measurement.hasAcceptableQuality || !measurement.hasSufficientConfidence {
                    qualityWarningSection
                }
                
                // Scientific Evidence Disclosure
                EvidenceDisclosure()
                    .padding(.horizontal)
                
                // Measurement Disclaimer
                MeasurementDisclaimerCard(
                    measurementType: "cervico-mental angle",
                    confidence: measurement.confidenceScore ?? 0.0,
                    angle: measurement.cervicoMentalAngle,
                    qualityFlags: qualityFlagsArray,
                    showFullDisclaimer: false
                )
                .padding(.horizontal)
                
                // Wellbeing Resources (if risk detected)
                if ethicalSafeguards.currentRiskLevel != .low {
                    WellbeingResourcesCard(
                        riskLevel: ethicalSafeguards.currentRiskLevel,
                        riskAssessment: ethicalSafeguards.riskAssessment
                    )
                    .padding(.horizontal)
                }
                
                // Medical Alternatives (if angle is concerning)
                if measurement.isCervicoMentalAngleConcerning {
                    MedicalAlternativesCard()
                        .padding(.horizontal)
                }
                
                // Action Buttons
                actionButtonsSection
            }
            .padding(.vertical)
        }
        .navigationTitle("Measurement Results")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Load historical measurements for prediction
            await loadHistoricalMeasurements()
            
            // Assess risk level
            await ethicalSafeguards.assessRisk()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(measurement.hasAcceptableQuality ? .green : .orange)
                .font(.system(size: 48))
            
            Text(measurement.hasAcceptableQuality ? "Measurement Captured" : "Measurement Needs Attention")
                .font(AppTypography.title)
                .foregroundColor(.primary)
            
            Text("Captured on \(formattedDate)")
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - Current Measurement Section
    
    private var currentMeasurementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Current Measurement")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Divider()
            
            // Primary Metric: Cervico-mental Angle
            if let angle = measurement.cervicoMentalAngle {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Cervico-mental Angle")
                            .font(AppTypography.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(angle))°")
                            .font(AppTypography.title2.bold())
                            .foregroundColor(angleColor(angle))
                    }
                    
                    // Status indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(angleStatusColor(angle))
                            .frame(width: 8, height: 8)
                        
                        Text(angleStatusText(angle))
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Confidence score
                    if let confidence = measurement.confidenceScore {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(confidenceColor(confidence))
                                .font(.caption)
                            
                            Text("\(Int(confidence * 100))% confidence")
                                .font(AppTypography.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            
            // Secondary Metrics
            if let submentalLength = measurement.submentalCervicalLength {
                secondaryMetricRow(
                    title: "Submental-cervical Length",
                    value: String(format: "%.1f mm", submentalLength),
                    icon: "ruler"
                )
            }
            
            if let jawIndex = measurement.jawDefinitionIndex {
                secondaryMetricRow(
                    title: "Jaw Definition Index",
                    value: String(format: "%.2f", jawIndex),
                    icon: "square.stack.3d.up"
                )
            }
            
            if let adiposityIndex = measurement.facialAdiposityIndex {
                secondaryMetricRow(
                    title: "Facial Adiposity Index",
                    value: String(format: "%.0f", adiposityIndex),
                    icon: "chart.bar"
                )
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }
    
    private func secondaryMetricRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .font(.caption)
            
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(AppTypography.caption.bold())
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Optimal Range Section
    
    private var optimalRangeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text("Optimal Range")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
            }
            
            Text("The optimal cervico-mental angle range is 90-105°. Angles above 120° may indicate submental fullness. This measurement is based on Farkas anthropometric standards used in clinical research.")
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
            
            // Visual range indicator
            if let angle = measurement.cervicoMentalAngle {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 24)
                        
                        // Optimal range
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.3))
                            .frame(width: optimalRangeWidth(in: geometry.size.width), height: 24)
                        
                        // Current angle indicator
                        Circle()
                            .fill(angleColor(angle))
                            .frame(width: 20, height: 20)
                            .offset(x: currentAnglePosition(in: geometry.size.width, angle: angle) - 10)
                    }
                }
                .frame(height: 24)
                
                // Range labels
                HStack {
                    Text("70°")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("90-105° (Optimal)")
                        .font(AppTypography.caption.bold())
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text("150°")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Progress Prediction Section
    
    private func progressPredictionSection(baseline: FaceMeasurement) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progress Predictions")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text("Based on population averages and your historical data. Individual results may vary.")
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
            
            if let baselineAngle = baseline.cervicoMentalAngle {
                let predictions = predictionModel.predictStandardIntervals()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(predictions.enumerated()), id: \.offset) { index, prediction in
                            PredictionCard(
                                prediction: prediction,
                                baselineAngle: baselineAngle
                            )
                            .frame(width: 280)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Quality Warning Section
    
    private var qualityWarningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text("Measurement Quality")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
            }
            
            if !measurement.hasSufficientConfidence {
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(.orange)
                    Text("Low confidence score. Consider retaking the measurement in better lighting with a neutral expression.")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let qualityFlags = measurement.qualityFlags {
                if qualityFlags.frankfurtPlaneAlignment > 10.0 {
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.orange)
                        Text("Head pose may not be optimal. Keep your head level and face forward.")
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !qualityFlags.isNeutralExpression {
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.orange)
                        Text("Expression detected. Please maintain a neutral expression for accurate measurements.")
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if qualityFlags.lightingUniformity < 0.7 {
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.orange)
                        Text("Lighting may be uneven. Try moving to a location with more uniform lighting.")
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Text("Done")
                        .font(AppTypography.body.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: measurement.timestamp)
    }
    
    private var qualityFlagsArray: [String] {
        var flags: [String] = []
        
        if let qualityFlags = measurement.qualityFlags {
            if qualityFlags.frankfurtPlaneAlignment > 10.0 {
                flags.append("Poor pose alignment")
            }
            if !qualityFlags.isNeutralExpression {
                flags.append("Non-neutral expression")
            }
            if qualityFlags.lightingUniformity < 0.7 {
                flags.append("Poor lighting")
            }
            if qualityFlags.faceVisibility < 0.9 {
                flags.append("Incomplete face visibility")
            }
        }
        
        return flags
    }
    
    private func angleColor(_ angle: Double) -> Color {
        if angle >= 90 && angle <= 105 {
            return .green
        } else if angle > 105 && angle <= 120 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func angleStatusColor(_ angle: Double) -> Color {
        return angleColor(angle)
    }
    
    private func angleStatusText(_ angle: Double) -> String {
        if angle >= 90 && angle <= 105 {
            return "Optimal range"
        } else if angle > 105 && angle <= 120 {
            return "Slightly elevated"
        } else if angle > 120 {
            return "Above optimal range"
        } else {
            return "Below optimal range"
        }
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 {
            return .green
        } else if confidence >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func optimalRangeWidth(in totalWidth: CGFloat) -> CGFloat {
        // Optimal range is 90-105°, total range shown is 70-150° (80° range)
        // Optimal range is 15° out of 80°, so 15/80 = 18.75% of width
        return totalWidth * 0.1875
    }
    
    private func currentAnglePosition(in totalWidth: CGFloat, angle: Double) -> CGFloat {
        // Map angle from 70-150° range to 0-totalWidth
        let minAngle: Double = 70
        let maxAngle: Double = 150
        let angleRange = maxAngle - minAngle
        
        let normalizedAngle = (angle - minAngle) / angleRange
        return CGFloat(normalizedAngle) * totalWidth
    }
    
    private func loadHistoricalMeasurements() async {
        // Load historical measurements into prediction model
        if let baseline = baselineMeasurement {
            predictionModel.updateWithMeasurement(baseline)
        }
        predictionModel.updateWithMeasurement(measurement)
    }
}

// MARK: - Preview

struct MeasurementResultView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MeasurementResultView(
                measurement: FaceMeasurement(
                    chinWidth: 120,
                    jawlineAngle: 95,
                    neckCircumference: 350,
                    timestamp: Date(),
                    cervicoMentalAngle: 98,
                    submentalCervicalLength: 45.2,
                    jawDefinitionIndex: 0.85,
                    facialAdiposityIndex: 65,
                    confidenceScore: 0.92,
                    qualityFlags: MeasurementQualityFlags(
                        frankfurtPlaneAlignment: 5.0,
                        isNeutralExpression: true,
                        lightingUniformity: 0.85,
                        faceVisibility: 0.95
                    )
                ),
                baselineMeasurement: FaceMeasurement(
                    chinWidth: 125,
                    jawlineAngle: 110,
                    neckCircumference: 360,
                    timestamp: Date().addingTimeInterval(-30 * 24 * 60 * 60),
                    cervicoMentalAngle: 110,
                    confidenceScore: 0.88
                )
            )
        }
    }
}

