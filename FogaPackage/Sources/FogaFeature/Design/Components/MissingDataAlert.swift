import SwiftUI

/// Alert component for displaying missing data analysis
/// 
/// **Scientific Note**: Shows gaps in measurement timeline and MNAR patterns.
/// Provides recommendations for better prediction accuracy.
@available(iOS 15.0, *)
public struct MissingDataAlert: View {
    let analysis: MissingDataAnalysis
    @Binding var isPresented: Bool
    
    public init(
        analysis: MissingDataAnalysis,
        isPresented: Binding<Bool>
    ) {
        self.analysis = analysis
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Measurement Gaps Detected")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            
            Divider()
            
            // Gap summary
            if !analysis.gaps.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Found \(analysis.gaps.count) gap\(analysis.gaps.count == 1 ? "" : "s") in your measurements")
                        .font(AppTypography.body)
                        .foregroundColor(.primary)
                    
                    // Show largest gaps
                    ForEach(Array(analysis.gaps.prefix(3).enumerated()), id: \.offset) { index, gap in
                        HStack {
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text("\(gap.days) days between measurements")
                                .font(AppTypography.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // MNAR pattern warning
            if let mnar = analysis.mnarPattern, mnar.detected {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "eye.slash.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pattern Detected")
                            .font(AppTypography.caption.bold())
                            .foregroundColor(.red)
                        
                        Text("Missing measurements may indicate avoidance during regression. Regular measurements help track progress accurately.")
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Impact
            VStack(alignment: .leading, spacing: 8) {
                Text("Impact on Predictions")
                    .font(AppTypography.subheadline.bold())
                    .foregroundColor(.primary)
                
                HStack {
                    Text("Prediction uncertainty:")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("+\(Int(analysis.impact.predictionUncertaintyIncrease * 100))%")
                        .font(AppTypography.caption.bold())
                        .foregroundColor(impactColor)
                }
            }
            
            // Recommendations
            if !analysis.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendations")
                        .font(AppTypography.subheadline.bold())
                        .foregroundColor(.primary)
                    
                    ForEach(Array(analysis.recommendations.enumerated()), id: \.offset) { index, recommendation in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(AppColors.primary)
                            
                            Text(recommendation)
                                .font(AppTypography.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Action button
            Button(action: { isPresented = false }) {
                Text("Got it")
                    .font(AppTypography.body.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Computed Properties
    
    private var impactColor: Color {
        if analysis.impact.predictionUncertaintyIncrease < 0.3 {
            return .green
        } else if analysis.impact.predictionUncertaintyIncrease < 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

/// Preview for development
struct MissingDataAlert_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            MissingDataAlert(
                analysis: MissingDataAnalysis(
                    gaps: [
                        MeasurementGap(
                            startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
                            endDate: Date(),
                            days: 30,
                            expectedDays: 7
                        )
                    ],
                    mnarPattern: MNARPattern(
                        detected: true,
                        probability: 0.7,
                        regressingGapsCount: 1,
                        totalGapsCount: 1
                    ),
                    impact: MissingDataImpact(
                        predictionUncertaintyIncrease: 0.4,
                        recommendationConfidence: 0.8,
                        requiresInterpolation: true
                    ),
                    recommendations: [
                        "Consider more frequent measurements for better prediction accuracy.",
                        "Missing measurements may indicate avoidance during regression. Regular measurements help track progress accurately."
                    ]
                ),
                isPresented: .constant(true)
            )
            .padding()
        }
    }
}

