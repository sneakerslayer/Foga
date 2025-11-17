import SwiftUI

/// Home/Dashboard view
/// 
/// **Learning Note**: This is the main screen users see after onboarding.
/// It shows their progress, today's exercises, and quick actions.
@available(iOS 15.0, *)
public struct HomeView: View {
    @StateObject private var dataService: DataService
    @StateObject private var progressViewModel: ProgressViewModel
    
    /// Initialize with shared DataService
    /// 
    /// **Learning Note**: Using the same DataService instance ensures data consistency.
    /// All views share the same data source, so updates are synchronized.
    public init() {
        // Create a single DataService instance shared by both properties
        let sharedDataService = DataService()
        _dataService = StateObject(wrappedValue: sharedDataService)
        _progressViewModel = StateObject(wrappedValue: ProgressViewModel(dataService: sharedDataService))
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    // Welcome section
                    WelcomeSection(userName: dataService.currentUser?.name ?? "User")
                    
                    // Progress ring
                    ProgressSection(progressViewModel: progressViewModel)
                    
                    // Today's exercises
                    TodaysExercisesSection()
                    
                    // Quick actions
                    QuickActionsSection(dataService: dataService)
                }
                .padding(.horizontal, AppSpacing.medium)
                .padding(.top, AppSpacing.small)
            }
            .background(AppColors.background)
            .navigationTitle("Home")
        }
    }
}

/// Welcome section
@available(iOS 15.0, *)
struct WelcomeSection: View {
    let userName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("Welcome back, \(userName)! 👋")
                .font(AppTypography.title2)
                .foregroundColor(AppColors.primaryText)
            
            Text("Ready for today's face yoga session?")
                .font(AppTypography.body)
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.medium)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .appShadow(AppShadows.card)
    }
}

/// Progress section with ring
@available(iOS 15.0, *)
struct ProgressSection: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    
    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            Text("Your Progress")
                .font(AppTypography.title3)
                .foregroundColor(AppColors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: AppSpacing.xl) {
                // Progress ring
                ProgressRing(progress: 0.3)
                    .frame(width: 120, height: 120)
                
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("30% Complete")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Keep up the great work!")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .appShadow(AppShadows.card)
    }
}

/// Today's exercises section
@available(iOS 15.0, *)
struct TodaysExercisesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Today's Exercises")
                .font(AppTypography.title3)
                .foregroundColor(AppColors.primaryText)
            
            ExerciseCard(
                name: "Jawline Lift",
                duration: "30 sec",
                isCompleted: false
            )
            
            ExerciseCard(
                name: "Neck Stretch",
                duration: "60 sec",
                isCompleted: false
            )
        }
        .padding(AppSpacing.medium)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .appShadow(AppShadows.card)
    }
}

/// Exercise card
@available(iOS 15.0, *)
struct ExerciseCard: View {
    let name: String
    let duration: String
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Text(duration)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.secondary)
            } else {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(AppSpacing.small)
        .background(AppColors.background)
        .cornerRadius(AppCornerRadius.small)
    }
}

/// Quick actions section
@available(iOS 15.0, *)
struct QuickActionsSection: View {
    let dataService: DataService
    @State private var showFaceScan = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Quick Actions")
                .font(AppTypography.title3)
                .foregroundColor(AppColors.primaryText)
            
            HStack(spacing: AppSpacing.medium) {
                Button(action: {
                    showFaceScan = true
                }) {
                    QuickActionButton(
                        icon: "camera.fill",
                        title: "Scan Face",
                        color: AppColors.primary
                    )
                }
                
                QuickActionButton(
                    icon: "photo.on.rectangle",
                    title: "Progress",
                    color: AppColors.secondary
                )
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .appShadow(AppShadows.card)
        .sheet(isPresented: $showFaceScan) {
            NavigationView {
                FaceScanView(dataService: dataService)
            }
        }
    }
}

/// Quick action button
@available(iOS 15.0, *)
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.small) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .cornerRadius(AppCornerRadius.small)
            
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.medium)
        .background(AppColors.background)
        .cornerRadius(AppCornerRadius.small)
    }
}

