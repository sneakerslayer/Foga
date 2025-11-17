import SwiftUI

/// Card component for displaying responder type classification
/// 
/// **Scientific Note**: Shows user's responder type (fast/moderate/minimal) based on
/// Growth Mixture Model analysis. Provides realistic expectations based on user profile.
@available(iOS 15.0, *)
public struct ResponderTypeCard: View {
    let classification: ResponderClassification
    
    public init(classification: ResponderClassification) {
        self.classification = classification
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(responderColor)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Response Profile")
                        .font(AppTypography.headline)
                        .foregroundColor(.primary)
                    
                    Text(classification.description)
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Expectations
            VStack(alignment: .leading, spacing: 12) {
                Text("What to Expect")
                    .font(AppTypography.subheadline.bold())
                    .foregroundColor(.primary)
                
                // Improvement ranges
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("3 months:")
                            .font(AppTypography.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(classification.expectations.threeMonthImprovement)
                            .font(AppTypography.body.bold())
                            .foregroundColor(responderColor)
                    }
                    
                    HStack {
                        Text("6 months:")
                            .font(AppTypography.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(classification.expectations.sixMonthImprovement)
                            .font(AppTypography.body.bold())
                            .foregroundColor(responderColor)
                    }
                }
                
                // Description
                Text(classification.expectations.description)
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                // Encouragement
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(responderColor)
                        .font(.caption)
                    
                    Text(classification.expectations.encouragement)
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            
            // Confidence indicator
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("Based on \(Int(classification.confidence * 100))% confidence analysis of your progress")
                    .font(AppTypography.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    
    private var iconName: String {
        switch classification.type {
        case .fast:
            return "bolt.fill"
        case .moderate:
            return "chart.line.uptrend.xyaxis"
        case .minimal:
            return "tortoise.fill"
        }
    }
    
    private var responderColor: Color {
        switch classification.type {
        case .fast:
            return .green
        case .moderate:
            return AppColors.primary
        case .minimal:
            return .orange
        }
    }
}

/// Preview for development
struct ResponderTypeCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Fast responder
            ResponderTypeCard(
                classification: ResponderClassification(
                    type: .fast,
                    confidence: 0.85,
                    trajectory: GrowthTrajectory(
                        initialRate: 0.12,
                        acceleration: 0.001,
                        plateauPoint: 90.0,
                        rSquared: 0.88
                    ),
                    expectations: ResponderExpectations(
                        threeMonthImprovement: "10-20°",
                        sixMonthImprovement: "15-30°",
                        description: "You're showing strong initial response. Most improvement typically occurs in the first 3 months, with continued gradual progress afterward.",
                        encouragement: "Keep up the consistent practice!"
                    )
                )
            )
            .padding()
            
            // Moderate responder
            ResponderTypeCard(
                classification: ResponderClassification(
                    type: .moderate,
                    confidence: 0.75,
                    trajectory: GrowthTrajectory(
                        initialRate: 0.05,
                        acceleration: -0.0005,
                        plateauPoint: 90.0,
                        rSquared: 0.72
                    ),
                    expectations: ResponderExpectations(
                        threeMonthImprovement: "5-15°",
                        sixMonthImprovement: "10-25°",
                        description: "You're responding at an average rate. Improvement is gradual and steady. Most users see noticeable changes within 3-6 months.",
                        encouragement: "Consistency is key - keep practicing regularly!"
                    )
                )
            )
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

