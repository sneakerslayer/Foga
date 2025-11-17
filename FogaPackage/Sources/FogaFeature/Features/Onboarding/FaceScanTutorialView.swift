import SwiftUI

/// Tutorial view explaining how face scanning works
/// 
/// **Learning Note**: This educates users before they use ARKit features.
/// Good UX means explaining features before users encounter them.
@available(iOS 15.0, *)
public struct FaceScanTutorialView: View {
    let onNext: () -> Void
    
    public var body: some View {
        VStack(spacing: AppSpacing.large) {
            // Header
            VStack(spacing: AppSpacing.small) {
                Text("Face Scanning")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("How it works")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(.top, AppSpacing.xl)
            
            Spacer()
            
            // Tutorial steps
            VStack(spacing: AppSpacing.xl) {
                TutorialStep(
                    number: 1,
                    icon: "face.smiling",
                    title: "Position Your Face",
                    description: "Hold your phone at arm's length, facing you"
                )
                
                TutorialStep(
                    number: 2,
                    icon: "camera.fill",
                    title: "Stay Still",
                    description: "Keep your face centered and still for a few seconds"
                )
                
                TutorialStep(
                    number: 3,
                    icon: "checkmark.circle.fill",
                    title: "Get Your Baseline",
                    description: "We'll capture your starting measurements"
                )
            }
            .padding(.horizontal, AppSpacing.large)
            
            Spacer()
            
            // Continue button
            PrimaryButton(title: "Got It") {
                onNext()
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.bottom, AppSpacing.xl)
        }
    }
}

/// Tutorial step component
@available(iOS 15.0, *)
struct TutorialStep: View {
    let number: Int
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            // Number badge
            ZStack {
                Circle()
                    .fill(AppColors.primaryGradient)
                    .frame(width: 40, height: 40)
                
                Text("\(number)")
                    .font(AppTypography.headline)
                    .foregroundColor(.white)
            }
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(AppColors.primary)
                .frame(width: 50)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Text(description)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
        }
        .padding(AppSpacing.medium)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .appShadow(AppShadows.card)
    }
}

