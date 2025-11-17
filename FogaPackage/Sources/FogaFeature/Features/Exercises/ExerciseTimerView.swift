import SwiftUI

/// Exercise timer view with circular progress indicator
@available(iOS 15.0, *)
public struct ExerciseTimerView: View {
    @ObservedObject var viewModel: ExerciseViewModel
    
    public init(viewModel: ExerciseViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: AppSpacing.medium) {
            // Circular progress ring
            ZStack {
                // Background circle
                Circle()
                    .stroke(AppColors.cardBackground, lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AppColors.primaryGradient,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: progress)
                
                // Time remaining
                VStack(spacing: 4) {
                    Text("\(Int(viewModel.timeRemaining))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("seconds")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            // Status text
            if viewModel.isPlaying {
                Text("Exercise in progress...")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.primary)
            } else {
                Text("Ready to start")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding(AppSpacing.large)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.large)
        .appShadow(AppShadows.card)
    }
    
    private var progress: Double {
        guard let exercise = viewModel.selectedExercise, exercise.duration > 0 else {
            return 0
        }
        return 1.0 - (viewModel.timeRemaining / exercise.duration)
    }
}

