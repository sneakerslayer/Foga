import SwiftUI
import AVFoundation

/// View for requesting app permissions
/// 
/// **Learning Note**: iOS requires explicit permission for sensitive features.
/// This view explains why we need each permission and requests them.
@available(iOS 15.0, *)
public struct PermissionsView: View {
    @ObservedObject var notificationService: NotificationService
    let onNext: () -> Void
    
    @State private var cameraPermissionGranted = false
    @State private var photoPermissionGranted = false
    
    public var body: some View {
        VStack(spacing: AppSpacing.large) {
            // Header
            VStack(spacing: AppSpacing.small) {
                Text("Permissions")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Foga needs a few permissions to work properly")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, AppSpacing.xl)
            .padding(.horizontal, AppSpacing.large)
            
            Spacer()
            
            // Permission cards
            VStack(spacing: AppSpacing.medium) {
                PermissionCard(
                    icon: "camera.fill",
                    title: "Camera Access",
                    description: "Required for face tracking and ARKit features",
                    isGranted: cameraPermissionGranted,
                    action: requestCameraPermission
                )
                
                PermissionCard(
                    icon: "photo.on.rectangle",
                    title: "Photo Library",
                    description: "Save your progress photos",
                    isGranted: photoPermissionGranted,
                    action: requestPhotoPermission
                )
                
                PermissionCard(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Daily reminders for your exercises",
                    isGranted: notificationService.authorizationStatus == .authorized,
                    action: requestNotificationPermission
                )
            }
            .padding(.horizontal, AppSpacing.large)
            
            Spacer()
            
            // Continue button
            PrimaryButton(title: "Continue") {
                onNext()
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.bottom, AppSpacing.xl)
        }
        .task {
            // Check authorization status when view appears
            await notificationService.initialize()
        }
    }
    
    /// Request camera permission
    /// 
    /// **Learning Note**: AVFoundation handles camera access.
    /// We check the current status and request if needed.
    private func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                }
            }
        case .authorized:
            cameraPermissionGranted = true
        default:
            // Show alert to go to Settings
            break
        }
    }
    
    /// Request photo library permission
    private func requestPhotoPermission() {
        // In production, use PHPhotoLibrary.requestAuthorization
        // For now, we'll handle this in the actual photo capture view
        photoPermissionGranted = true
    }
    
    /// Request notification permission
    private func requestNotificationPermission() {
        Task {
            await notificationService.requestAuthorization()
        }
    }
}

/// Permission card component
@available(iOS 15.0, *)
struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(isGranted ? AppColors.secondary : AppColors.primary)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Text(description)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.secondary)
            } else {
                Button(action: action) {
                    Text("Allow")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, AppSpacing.medium)
                        .padding(.vertical, AppSpacing.small)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(AppCornerRadius.small)
                }
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .appShadow(AppShadows.card)
    }
}

