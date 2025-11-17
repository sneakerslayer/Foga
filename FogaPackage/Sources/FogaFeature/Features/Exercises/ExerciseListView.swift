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

/// Exercise detail view (placeholder)
@available(iOS 15.0, *)
struct ExerciseDetailView: View {
    let exercise: Exercise
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                Text(exercise.name)
                    .font(AppTypography.title)
                
                Text(exercise.description)
                    .font(AppTypography.body)
                
                PrimaryButton(title: "Start Exercise") {
                    // Start exercise
                }
            }
            .padding()
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

