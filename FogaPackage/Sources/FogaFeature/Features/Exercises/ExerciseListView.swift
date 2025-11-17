import SwiftUI

/// List of all available exercises
@available(iOS 15.0, *)
public struct ExerciseListView: View {
    @StateObject private var viewModel = ExerciseViewModel()
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.exercises) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        ExerciseRow(exercise: exercise)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Exercises")
            .background(AppColors.background)
        }
    }
}

/// Exercise row in list
@available(iOS 15.0, *)
struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            // Icon
            Image(systemName: "figure.walk")
                .font(.system(size: 30))
                .foregroundColor(exercise.isPremium ? AppColors.secondary : AppColors.primary)
                .frame(width: 50)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(exercise.name)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    if exercise.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.secondary)
                    }
                }
                
                Text(exercise.description)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
                
                Text("\(Int(exercise.duration)) seconds")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.vertical, AppSpacing.small)
    }
}

/// Exercise detail view
@available(iOS 15.0, *)
struct ExerciseDetailView: View {
    let exercise: Exercise
    @StateObject private var viewModel = ExerciseViewModel()
    @StateObject private var subscriptionService = SubscriptionService()
    @State private var showExercisePlayer = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                // Exercise header
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    HStack {
                        Text(exercise.name)
                            .font(AppTypography.title)
                            .foregroundColor(AppColors.primaryText)
                        
                        Spacer()
                        
                        if exercise.isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16))
                                Text("Premium")
                                    .font(AppTypography.caption)
                            }
                            .foregroundColor(AppColors.secondary)
                        }
                    }
                    
                    HStack(spacing: AppSpacing.medium) {
                        Label("\(Int(exercise.duration))s", systemImage: "clock")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Label(exercise.category.rawValue, systemImage: "tag")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                // Description
                Text(exercise.description)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.primaryText)
                    .padding(.vertical, AppSpacing.small)
                
                // Instructions
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Instructions")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(getInstructions(for: exercise))
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.secondaryText)
                }
                .padding(AppSpacing.medium)
                .background(AppColors.cardBackground)
                .cornerRadius(AppCornerRadius.medium)
                
                // Start button
                if exercise.isPremium && !subscriptionService.isPremium {
                    VStack(spacing: AppSpacing.small) {
                        PrimaryButton(title: "Unlock Premium Exercise", style: .secondary) {
                            // Navigate to paywall
                        }
                        
                        Text("This exercise requires a premium subscription")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                } else {
                    PrimaryButton(title: "Start Exercise") {
                        viewModel.startExercise(exercise)
                        showExercisePlayer = true
                    }
                }
            }
            .padding(AppSpacing.medium)
        }
        .background(AppColors.background)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showExercisePlayer) {
            if let selectedExercise = viewModel.selectedExercise {
                ExercisePlayerView(exercise: selectedExercise, viewModel: viewModel)
            }
        }
    }
    
    private func getInstructions(for exercise: Exercise) -> String {
        switch exercise.name {
        case "Jawline Lift":
            return "1. Sit or stand with your back straight\n2. Tilt your head back gently\n3. Push your lower jaw forward\n4. Hold for 5 seconds\n5. Return to starting position\n6. Repeat 5 times"
        case "Neck Stretch":
            return "1. Sit comfortably with your back straight\n2. Slowly turn your head to the right\n3. Hold for 5 seconds\n4. Return to center\n5. Turn your head to the left\n6. Hold for 5 seconds\n7. Repeat 3 times each side"
        case "Chin Tuck":
            return "1. Sit or stand with good posture\n2. Pull your chin back and down\n3. Create a double chin position\n4. Hold for 10 seconds\n5. Release slowly\n6. Repeat 5 times"
        default:
            return exercise.description
        }
    }
}

