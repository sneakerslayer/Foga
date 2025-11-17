import SwiftUI

/// Progress dashboard view
@available(iOS 15.0, *)
public struct ProgressDashboard: View {
    @StateObject private var dataService: DataService
    @StateObject private var viewModel: ProgressViewModel
    @State private var showPhotoCapture = false
    
    /// Initialize with shared DataService
    /// 
    /// **Learning Note**: Using the same DataService instance ensures data consistency.
    /// The viewModel observes the same data source as the view.
    public init() {
        // Create a single DataService instance shared by both properties
        let sharedDataService = DataService()
        _dataService = StateObject(wrappedValue: sharedDataService)
        _viewModel = StateObject(wrappedValue: ProgressViewModel(dataService: sharedDataService))
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    // Progress overview
                    ProgressOverviewCard(viewModel: viewModel)
                    
                    // Before/After section
                    NavigationLink(destination: BeforeAfterView(viewModel: viewModel)) {
                        BeforeAfterSection(viewModel: viewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Recent progress entries
                    RecentProgressSection(viewModel: viewModel)
                }
                .padding(.horizontal, AppSpacing.medium)
                .padding(.top, AppSpacing.small)
            }
            .background(AppColors.background)
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showPhotoCapture = true
                    }) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showPhotoCapture) {
                PhotoCaptureView(viewModel: viewModel)
            }
        }
    }
}

/// Progress overview card
@available(iOS 15.0, *)
struct ProgressOverviewCard: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            Text("Your Journey")
                .font(AppTypography.title2)
                .foregroundColor(AppColors.primaryText)
            
            ProgressRing(progress: 0.3)
                .frame(width: 150, height: 150)
            
            Text("30% Improvement")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .appShadow(AppShadows.card)
    }
}

/// Before/After section
@available(iOS 15.0, *)
struct BeforeAfterSection: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Before & After")
                .font(AppTypography.title3)
                .foregroundColor(AppColors.primaryText)
            
            HStack(spacing: AppSpacing.medium) {
                // Before placeholder
                BeforeAfterCard(title: "Before", isPlaceholder: true)
                
                // After placeholder
                BeforeAfterCard(title: "After", isPlaceholder: true)
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .appShadow(AppShadows.card)
    }
}

/// Before/After card
@available(iOS 15.0, *)
struct BeforeAfterCard: View {
    let title: String
    let isPlaceholder: Bool
    
    var body: some View {
        VStack {
            if isPlaceholder {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(AppColors.background)
        .cornerRadius(AppCornerRadius.small)
    }
}

/// Recent progress section
@available(iOS 15.0, *)
struct RecentProgressSection: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Recent Progress")
                .font(AppTypography.title3)
                .foregroundColor(AppColors.primaryText)
            
            if viewModel.progressEntries.isEmpty {
                Text("No progress entries yet. Start your journey!")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.xl)
                    .background(AppColors.background)
                    .cornerRadius(AppCornerRadius.small)
            } else {
                ForEach(viewModel.progressEntries.prefix(5)) { entry in
                    ProgressEntryRow(entry: entry)
                }
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .appShadow(AppShadows.card)
    }
}

/// Progress entry row
@available(iOS 15.0, *)
struct ProgressEntryRow: View {
    let entry: Progress
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date, style: .date)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.primaryText)
                
                if let notes = entry.notes {
                    Text(notes)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(AppSpacing.small)
        .background(AppColors.background)
        .cornerRadius(AppCornerRadius.small)
    }
}

