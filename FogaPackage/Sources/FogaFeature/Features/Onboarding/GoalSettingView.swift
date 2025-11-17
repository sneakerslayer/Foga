import SwiftUI

/// View for setting user goals
/// 
/// **Learning Note**: This lets users customize their experience.
/// We store their goals so we can personalize content later.
@available(iOS 15.0, *)
public struct GoalSettingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void
    
    public var body: some View {
        VStack(spacing: AppSpacing.large) {
            // Header
            VStack(spacing: AppSpacing.small) {
                Text("What's Your Goal?")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Select one or more goals to personalize your experience")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, AppSpacing.xl)
            .padding(.horizontal, AppSpacing.large)
            
            Spacer()
            
            // Goal selection
            VStack(spacing: AppSpacing.medium) {
                ForEach(Goal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: viewModel.selectedGoals.contains(goal),
                        action: { viewModel.toggleGoal(goal) }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.large)
            
            Spacer()
            
            // Complete button
            PrimaryButton(
                title: "Start My Journey",
                style: viewModel.selectedGoals.isEmpty ? .outline : .primary
            ) {
                if !viewModel.selectedGoals.isEmpty {
                    onComplete()
                }
            }
            .disabled(viewModel.selectedGoals.isEmpty)
            .padding(.horizontal, AppSpacing.large)
            .padding(.bottom, AppSpacing.xl)
        }
    }
}

/// Goal card component
@available(iOS 15.0, *)
struct GoalCard: View {
    let goal: Goal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.medium) {
                Image(systemName: goal.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : AppColors.primary)
                    .frame(width: 40)
                
                Text(goal.displayName)
                    .font(AppTypography.headline)
                    .foregroundColor(isSelected ? .white : AppColors.primaryText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(AppSpacing.medium)
            .background(
                Group {
                    if isSelected {
                        AppColors.primaryGradient
                    } else {
                        AppColors.cardBackground
                    }
                }
            )
            .cornerRadius(AppCornerRadius.medium)
            .appShadow(AppShadows.card)
        }
        .buttonStyle(.plain)
    }
}

