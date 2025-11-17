import SwiftUI
import AVKit

/// Exercise player view with video playback and timer
@available(iOS 15.0, *)
public struct ExercisePlayerView: View {
    let exercise: Exercise
    @ObservedObject var viewModel: ExerciseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    @State private var showCompletionAlert = false
    
    public init(exercise: Exercise, viewModel: ExerciseViewModel) {
        self.exercise = exercise
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.large) {
                // Video player or placeholder
                if let videoURL = exercise.videoURL, let url = URL(string: videoURL) {
                    VideoPlayer(player: player)
                        .frame(height: 300)
                        .cornerRadius(AppCornerRadius.medium)
                        .onAppear {
                            setupPlayer(url: url)
                        }
                } else {
                    // Placeholder for video
                    ZStack {
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .fill(AppColors.cardBackground)
                        
                        VStack(spacing: AppSpacing.small) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.primary)
                            
                            Text("Video Guide")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("Follow along with the exercise")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    .frame(height: 300)
                }
                
                // Exercise info
                VStack(spacing: AppSpacing.small) {
                    Text(exercise.name)
                        .font(AppTypography.title2)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(exercise.description)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppSpacing.medium)
                
                // Timer view
                ExerciseTimerView(viewModel: viewModel)
                
                // Controls
                HStack(spacing: AppSpacing.large) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("Cancel")
                        }
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.secondaryText)
                        .padding(.horizontal, AppSpacing.large)
                        .padding(.vertical, AppSpacing.medium)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppCornerRadius.medium)
                    }
                    
                    if viewModel.isPlaying {
                        Button(action: {
                            viewModel.stopExercise()
                            player?.pause()
                        }) {
                            HStack {
                                Image(systemName: "pause.fill")
                                Text("Pause")
                            }
                            .font(AppTypography.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, AppSpacing.large)
                            .padding(.vertical, AppSpacing.medium)
                            .background(AppColors.primaryGradient)
                            .cornerRadius(AppCornerRadius.medium)
                        }
                    } else {
                        Button(action: {
                            viewModel.startExercise(exercise)
                            player?.play()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Resume")
                            }
                            .font(AppTypography.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, AppSpacing.large)
                            .padding(.vertical, AppSpacing.medium)
                            .background(AppColors.secondaryGradient)
                            .cornerRadius(AppCornerRadius.medium)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.medium)
            }
            .padding(.vertical, AppSpacing.large)
        }
        .onChange(of: viewModel.timeRemaining) { newValue in
            if newValue == 0 && viewModel.isPlaying {
                showCompletionAlert = true
                player?.pause()
            }
        }
        .alert("Exercise Complete! 🎉", isPresented: $showCompletionAlert) {
            Button("Done") {
                viewModel.stopExercise()
                dismiss()
            }
        } message: {
            Text("Great job completing \(exercise.name)! Keep up the good work.")
        }
        .onDisappear {
            player?.pause()
            viewModel.stopExercise()
        }
    }
    
    private func setupPlayer(url: URL) {
        player = AVPlayer(url: url)
        player?.play()
    }
}

