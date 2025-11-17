import SwiftUI

/// Before/After photo comparison view
@available(iOS 15.0, *)
public struct BeforeAfterView: View {
    @ObservedObject var viewModel: ProgressViewModel
    @State private var selectedComparison: ProgressComparison?
    
    public init(viewModel: ProgressViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                if viewModel.progressEntries.isEmpty {
                    EmptyStateView()
                } else {
                    // Comparison cards
                    ForEach(availableComparisons()) { comparison in
                        ComparisonCard(comparison: comparison) {
                            selectedComparison = comparison
                        }
                    }
                }
            }
            .padding(AppSpacing.medium)
        }
        .background(AppColors.background)
        .navigationTitle("Before & After")
        .sheet(item: $selectedComparison) { comparison in
            ComparisonDetailView(comparison: comparison)
        }
    }
    
    private func availableComparisons() -> [ProgressComparison] {
        guard let baseline = viewModel.progressEntries.first else {
            return []
        }
        
        return viewModel.progressEntries
            .filter { $0.id != baseline.id }
            .map { ProgressComparison(before: baseline, after: $0) }
    }
}

/// Progress comparison model
@available(iOS 15.0, *)
struct ProgressComparison: Identifiable {
    let id: UUID
    let before: Progress
    let after: Progress
    let daysBetween: Int
    
    init(before: Progress, after: Progress) {
        self.id = UUID()
        self.before = before
        self.after = after
        
        let calendar = Calendar.current
        self.daysBetween = calendar.dateComponents([.day], from: before.date, to: after.date).day ?? 0
    }
}

/// Comparison card
@available(iOS 15.0, *)
struct ComparisonCard: View {
    let comparison: ProgressComparison
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppSpacing.medium) {
                // Side-by-side photos
                HStack(spacing: AppSpacing.small) {
                    PhotoView(progress: comparison.before, label: "Before")
                    PhotoView(progress: comparison.after, label: "After")
                }
                
                // Measurement comparison
                if let beforeAngle = comparison.before.measurements.cervicoMentalAngle,
                   let afterAngle = comparison.after.measurements.cervicoMentalAngle {
                    MeasurementComparisonView(
                        beforeAngle: beforeAngle,
                        afterAngle: afterAngle,
                        daysBetween: comparison.daysBetween
                    )
                }
            }
            .padding(AppSpacing.medium)
            .background(AppColors.cardBackground)
            .cornerRadius(AppCornerRadius.medium)
            .appShadow(AppShadows.card)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Photo view component
@available(iOS 15.0, *)
struct PhotoView: View {
    let progress: Progress
    let label: String
    
    var body: some View {
        VStack(spacing: AppSpacing.small) {
            #if canImport(UIKit)
            if let image = progress.photo {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(AppCornerRadius.small)
            } else {
                PlaceholderPhotoView()
            }
            #else
            PlaceholderPhotoView()
            #endif
            
            VStack(spacing: 2) {
                Text(label)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Text(progress.date, style: .date)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// Placeholder photo view
@available(iOS 15.0, *)
struct PlaceholderPhotoView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppCornerRadius.small)
                .fill(AppColors.background)
            
            VStack(spacing: AppSpacing.small) {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.secondaryText)
                
                Text("No photo")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(height: 200)
    }
}

/// Measurement comparison view
@available(iOS 15.0, *)
struct MeasurementComparisonView: View {
    let beforeAngle: Double
    let afterAngle: Double
    let daysBetween: Int
    
    private var improvement: Double {
        return beforeAngle - afterAngle // Lower angle is better
    }
    
    private var improvementPercentage: Double {
        guard beforeAngle > 0 else { return 0 }
        return (improvement / beforeAngle) * 100
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cervico-Mental Angle")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    HStack(spacing: AppSpacing.medium) {
                        Text("\(Int(beforeAngle))°")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(AppColors.secondary)
                        
                        Text("\(Int(afterAngle))°")
                            .font(AppTypography.headline)
                            .foregroundColor(improvement > 0 ? AppColors.secondary : AppColors.primaryText)
                    }
                }
                
                Spacer()
                
                if improvement > 0 {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(String(format: "%.1f", improvementPercentage))%")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.secondary)
                        
                        Text("improvement")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            
            Text("\(daysBetween) days between measurements")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(AppSpacing.small)
        .background(AppColors.background)
        .cornerRadius(AppCornerRadius.small)
    }
}

/// Comparison detail view (full screen)
@available(iOS 15.0, *)
struct ComparisonDetailView: View {
    let comparison: ProgressComparison
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    // Full-size photos
                    HStack(spacing: AppSpacing.medium) {
                        PhotoView(progress: comparison.before, label: "Before")
                        PhotoView(progress: comparison.after, label: "After")
                    }
                    
                    // Detailed measurements
                    if let beforeAngle = comparison.before.measurements.cervicoMentalAngle,
                       let afterAngle = comparison.after.measurements.cervicoMentalAngle {
                        MeasurementComparisonView(
                            beforeAngle: beforeAngle,
                            afterAngle: afterAngle,
                            daysBetween: comparison.daysBetween
                        )
                    }
                    
                    // Notes
                    if let notes = comparison.after.notes {
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text("Notes")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text(notes)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppSpacing.medium)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppCornerRadius.medium)
                    }
                }
                .padding(AppSpacing.medium)
            }
            .background(AppColors.background)
            .navigationTitle("Progress Comparison")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Empty state view
@available(iOS 15.0, *)
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(AppColors.secondaryText)
            
            Text("No Progress Photos Yet")
                .font(AppTypography.title2)
                .foregroundColor(AppColors.primaryText)
            
            Text("Capture your first progress photo to see your transformation journey")
                .font(AppTypography.body)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.large)
        }
        .padding(AppSpacing.xl)
    }
}

