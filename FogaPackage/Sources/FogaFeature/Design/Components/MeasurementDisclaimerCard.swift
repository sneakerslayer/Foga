import SwiftUI

/// Card component for displaying disclaimers in measurement results
/// 
/// **Critical Purpose**: Ensures all measurement results include appropriate disclaimers
/// that explain limitations, individual variation, and measurement accuracy.
@available(iOS 15.0, *)
public struct MeasurementDisclaimerCard: View {
    @StateObject private var disclaimerService = ProgressDisclaimers()
    
    let measurementType: String
    let confidence: Double
    let angle: Double?
    let qualityFlags: [String]
    let showFullDisclaimer: Bool
    
    public init(
        measurementType: String = "cervico-mental angle",
        confidence: Double,
        angle: Double? = nil,
        qualityFlags: [String] = [],
        showFullDisclaimer: Bool = false
    ) {
        self.measurementType = measurementType
        self.confidence = confidence
        self.angle = angle
        self.qualityFlags = qualityFlags
        self.showFullDisclaimer = showFullDisclaimer
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text("Measurement Disclaimer")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Divider()
            
            if showFullDisclaimer {
                // Full Disclaimer
                Text(disclaimerService.generateMeasurementDisclaimer(
                    measurementType: measurementType,
                    confidence: confidence,
                    angle: angle
                ))
                .font(AppTypography.body)
                .foregroundColor(.secondary)
            } else {
                // Short Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    // Short disclaimer text
                    Text(disclaimerService.generateShortDisclaimer(for: .measurement))
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    
                    // Quality-based disclaimer (if quality issues)
                    if !qualityFlags.isEmpty {
                        Divider()
                        
                        Text(disclaimerService.generateQualityBasedDisclaimer(
                            qualityFlags: qualityFlags,
                            confidence: confidence
                        ))
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    // Confidence indicator
                    HStack(spacing: 6) {
                        Image(systemName: confidence >= 0.8 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(confidence >= 0.8 ? .green : .orange)
                            .font(.caption)
                        
                        Text("Confidence: \(Int(confidence * 100))%")
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

/// Prediction disclaimer card
public struct PredictionDisclaimerCard: View {
    @StateObject private var disclaimerService = ProgressDisclaimers()
    
    let timeFrame: String
    let confidenceInterval: (lower: Double, upper: Double)
    let confidence: Double
    let responderType: String?
    let showFullDisclaimer: Bool
    
    public init(
        timeFrame: String,
        confidenceInterval: (lower: Double, upper: Double),
        confidence: Double,
        responderType: String? = nil,
        showFullDisclaimer: Bool = false
    ) {
        self.timeFrame = timeFrame
        self.confidenceInterval = confidenceInterval
        self.confidence = confidence
        self.responderType = responderType
        self.showFullDisclaimer = showFullDisclaimer
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text("Prediction Disclaimer")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Divider()
            
            if showFullDisclaimer {
                // Full Disclaimer
                Text(disclaimerService.generatePredictionDisclaimer(
                    timeFrame: timeFrame,
                    confidenceInterval: confidenceInterval,
                    confidence: confidence,
                    responderType: responderType
                ))
                .font(AppTypography.body)
                .foregroundColor(.secondary)
            } else {
                // Short Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    // Short disclaimer text
                    Text(disclaimerService.generateShortDisclaimer(for: .prediction))
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    
                    // Confidence interval display
                    HStack(spacing: 6) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("Range: \(Int(confidenceInterval.lower))-\(Int(confidenceInterval.upper))° over \(timeFrame)")
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                    
                    // Confidence level
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(confidence >= 0.8 ? .green : .orange)
                            .font(.caption)
                        
                        Text("Confidence: \(Int(confidence * 100))%")
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

/// General wellness disclaimer card
public struct WellnessDisclaimerCard: View {
    @StateObject private var disclaimerService = ProgressDisclaimers()
    
    let showFullDisclaimer: Bool
    
    public init(showFullDisclaimer: Bool = false) {
        self.showFullDisclaimer = showFullDisclaimer
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "heart.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.title3)
                
                Text("Wellness Disclaimer")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Divider()
            
            if showFullDisclaimer {
                // Full Disclaimer
                Text(disclaimerService.generateGeneralWellnessDisclaimer())
                    .font(AppTypography.body)
                    .foregroundColor(.secondary)
            } else {
                // Short Disclaimer
                Text(disclaimerService.generateShortDisclaimer(for: .generalWellness))
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

/// Missing data disclaimer card
public struct MissingDataDisclaimerCard: View {
    @StateObject private var disclaimerService = ProgressDisclaimers()
    
    let gapDays: Int
    let impact: String
    
    public init(gapDays: Int, impact: String) {
        self.gapDays = gapDays
        self.impact = impact
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text("Missing Data Notice")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Divider()
            
            // Disclaimer
            Text(disclaimerService.generateMissingDataDisclaimer(
                gapDays: gapDays,
                impact: impact
            ))
            .font(AppTypography.body)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

/// Preview
struct MeasurementDisclaimerCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            MeasurementDisclaimerCard(
                measurementType: "cervico-mental angle",
                confidence: 0.85,
                angle: 110.0,
                qualityFlags: [],
                showFullDisclaimer: false
            )
            
            MeasurementDisclaimerCard(
                measurementType: "cervico-mental angle",
                confidence: 0.65,
                angle: 115.0,
                qualityFlags: ["Poor lighting", "Head pose misalignment"],
                showFullDisclaimer: false
            )
            
            PredictionDisclaimerCard(
                timeFrame: "3 months",
                confidenceInterval: (lower: 5.0, upper: 15.0),
                confidence: 0.8,
                responderType: "Moderate",
                showFullDisclaimer: false
            )
            
            WellnessDisclaimerCard(showFullDisclaimer: false)
            
            MissingDataDisclaimerCard(
                gapDays: 45,
                impact: "Missing data increases prediction uncertainty by approximately 15%."
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

