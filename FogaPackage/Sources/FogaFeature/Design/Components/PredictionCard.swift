import SwiftUI

/// Card component for displaying progress predictions with confidence intervals
/// 
/// **Scientific Note**: Always displays predictions with confidence intervals,
/// never promises exact numbers. Format: "5-15° improvement in 3 months (80% confidence)"
@available(iOS 15.0, *)
public struct PredictionCard: View {
    let prediction: ProgressPredictionModel.Prediction
    let baselineAngle: Double
    
    public init(
        prediction: ProgressPredictionModel.Prediction,
        baselineAngle: Double
    ) {
        self.prediction = prediction
        self.baselineAngle = baselineAngle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(AppColors.primary)
                    .font(.title2)
                
                Text(timeframeText)
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Divider()
            
            // Prediction display
            VStack(alignment: .leading, spacing: 8) {
                // Improvement range
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(improvementRangeText)
                        .font(AppTypography.title2)
                        .foregroundColor(AppColors.primary)
                    
                    Text("improvement")
                        .font(AppTypography.body)
                        .foregroundColor(.secondary)
                }
                
                // Confidence interval
                HStack(spacing: 4) {
                    Text("Predicted angle:")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    
                    Text(angleRangeText)
                        .font(AppTypography.caption.bold())
                        .foregroundColor(.primary)
                }
                
                // Confidence level
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(confidenceColor)
                        .font(.caption)
                    
                    Text("\(Int(prediction.confidenceLevel * 100))% confidence")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Uncertainty indicator
            if prediction.uncertainty > 0.3 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("Higher uncertainty due to limited data")
                        .font(AppTypography.caption)
                        .foregroundColor(.orange)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    
    private var timeframeText: String {
        let months = prediction.daysFromBaseline / 30
        if months == 1 {
            return "1 Month Prediction"
        } else {
            return "\(months) Months Prediction"
        }
    }
    
    private var improvementRangeText: String {
        let _ = prediction.confidenceInterval.upper - prediction.confidenceInterval.lower // improvement range (not used)
        let lowerImprovement = max(0, baselineAngle - prediction.confidenceInterval.upper)
        let upperImprovement = max(0, baselineAngle - prediction.confidenceInterval.lower)
        
        // Format as range (e.g., "5-15°")
        if lowerImprovement < 1 && upperImprovement < 1 {
            return "0-1°"
        } else {
            return "\(Int(lowerImprovement))-\(Int(upperImprovement))°"
        }
    }
    
    private var angleRangeText: String {
        let lower = Int(prediction.confidenceInterval.lower)
        let upper = Int(prediction.confidenceInterval.upper)
        return "\(lower)-\(upper)°"
    }
    
    private var confidenceColor: Color {
        if prediction.confidenceLevel >= 0.8 {
            return .green
        } else if prediction.confidenceLevel >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

/// List view for displaying multiple predictions
public struct PredictionListView: View {
    let predictions: [ProgressPredictionModel.Prediction]
    let baselineAngle: Double
    
    public init(
        predictions: [ProgressPredictionModel.Prediction],
        baselineAngle: Double
    ) {
        self.predictions = predictions
        self.baselineAngle = baselineAngle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Progress Predictions")
                    .font(AppTypography.title)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Disclaimer
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("Predictions are based on population averages and your historical data. Individual results may vary. These are estimates, not guarantees.")
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Prediction cards
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
}

/// Preview for development
struct PredictionCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Single prediction card
            PredictionCard(
                prediction: ProgressPredictionModel.Prediction(
                    predictedAngle: 95.0,
                    confidenceInterval: (lower: 90.0, upper: 100.0),
                    confidenceLevel: 0.8,
                    daysFromBaseline: 90,
                    uncertainty: 0.2
                ),
                baselineAngle: 110.0
            )
            .padding()
            
            // Multiple predictions
            PredictionListView(
                predictions: [
                    ProgressPredictionModel.Prediction(
                        predictedAngle: 105.0,
                        confidenceInterval: (lower: 100.0, upper: 110.0),
                        confidenceLevel: 0.75,
                        daysFromBaseline: 30,
                        uncertainty: 0.25
                    ),
                    ProgressPredictionModel.Prediction(
                        predictedAngle: 95.0,
                        confidenceInterval: (lower: 90.0, upper: 100.0),
                        confidenceLevel: 0.8,
                        daysFromBaseline: 90,
                        uncertainty: 0.2
                    ),
                    ProgressPredictionModel.Prediction(
                        predictedAngle: 90.0,
                        confidenceInterval: (lower: 85.0, upper: 95.0),
                        confidenceLevel: 0.7,
                        daysFromBaseline: 180,
                        uncertainty: 0.3
                    )
                ],
                baselineAngle: 110.0
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

