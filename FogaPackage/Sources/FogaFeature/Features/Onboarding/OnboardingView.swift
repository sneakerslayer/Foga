import SwiftUI

/// Main onboarding view that coordinates all onboarding steps
/// 
/// **Learning Note**: This is the main container for the onboarding flow.
/// It uses a switch statement to show different views based on the current step.
/// 
/// **Critical**: Accepts an optional DataService parameter to share the same instance
/// with RootView. This ensures data synchronization - when onboarding completes,
/// RootView immediately sees the user creation and transitions to the main app.
@available(iOS 15.0, *)
public struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @ObservedObject private var dataService: DataService
    @StateObject private var notificationService = NotificationService()
    
    /// Animation state for logo
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    
    /// Initialize with optional shared DataService
    /// 
    /// **Learning Note**: If no DataService is provided, creates a new one.
    /// If provided (from RootView), uses the shared instance for data synchronization.
    public init(dataService: DataService? = nil) {
        // Use provided DataService or create new one
        let service = dataService ?? DataService()
        _dataService = ObservedObject(wrappedValue: service)
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(dataService: service))
        _notificationService = StateObject(wrappedValue: NotificationService())
    }
    
    public var body: some View {
        ZStack {
            // Background
            GradientBackground()
            
            // Content based on current step
            switch viewModel.currentStep {
            case .welcome:
                WelcomeStepView(
                    logoScale: $logoScale,
                    logoOpacity: $logoOpacity,
                    onNext: { viewModel.nextStep() }
                )
            case .benefits:
                BenefitsCarouselView(onNext: { viewModel.nextStep() })
            case .permissions:
                PermissionsView(
                    notificationService: notificationService,
                    onNext: { viewModel.nextStep() }
                )
            case .tutorial:
                FaceScanTutorialView(onNext: { viewModel.nextStep() })
            case .goals:
                GoalSettingView(
                    viewModel: viewModel,
                    onComplete: { viewModel.completeOnboarding() }
                )
            }
        }
        .onAppear {
            // Animate logo on appear
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

/// Welcome screen with animated logo
@available(iOS 15.0, *)
struct WelcomeStepView: View {
    @Binding var logoScale: CGFloat
    @Binding var logoOpacity: Double
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            // App Logo/Icon
            Image(systemName: "face.smiling")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.primaryGradient)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
            
            // App Name
            Text("Foga")
                .font(AppTypography.largeTitle)
                .foregroundColor(AppColors.primaryText)
                .opacity(logoOpacity)
            
            // Tagline
            Text("Transform your face with guided exercises")
                .font(AppTypography.body)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.large)
                .opacity(logoOpacity)
            
            Spacer()
            
            // Next Button
            PrimaryButton(title: "Get Started") {
                onNext()
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.bottom, AppSpacing.xl)
            .opacity(logoOpacity)
        }
    }
}

/// Benefits carousel with 3 slides
@available(iOS 15.0, *)
struct BenefitsCarouselView: View {
    let onNext: () -> Void
    @State private var currentPage = 0
    
    private let benefits = [
        Benefit(
            icon: "face.smiling",
            title: "Track Your Progress",
            description: "Use ARKit to measure your facial changes over time"
        ),
        Benefit(
            icon: "figure.walk",
            title: "Guided Exercises",
            description: "Follow along with video tutorials designed by experts"
        ),
        Benefit(
            icon: "chart.line.uptrend.xyaxis",
            title: "See Results",
            description: "Compare before and after photos to see your transformation"
        )
    ]
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Page indicator
            HStack(spacing: AppSpacing.small) {
                ForEach(0..<benefits.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? AppColors.primary : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, AppSpacing.xl)
            
            // Carousel content
            TabView(selection: $currentPage) {
                ForEach(0..<benefits.count, id: \.self) { index in
                    BenefitCard(benefit: benefits[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 400)
            
            // Navigation buttons
            HStack(spacing: AppSpacing.medium) {
                if currentPage > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .foregroundColor(AppColors.primary)
                }
                
                Spacer()
                
                PrimaryButton(
                    title: currentPage == benefits.count - 1 ? "Continue" : "Next"
                ) {
                    if currentPage < benefits.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onNext()
                    }
                }
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.bottom, AppSpacing.xl)
        }
    }
}

/// Benefit card component
@available(iOS 15.0, *)
struct BenefitCard: View {
    let benefit: Benefit
    
    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Image(systemName: benefit.icon)
                .font(.system(size: 60))
                .foregroundStyle(AppColors.primaryGradient)
            
            Text(benefit.title)
                .font(AppTypography.title2)
                .foregroundColor(AppColors.primaryText)
            
            Text(benefit.description)
                .font(AppTypography.body)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.large)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .appShadow(AppShadows.card)
        .padding(.horizontal, AppSpacing.large)
    }
}

/// Benefit data model
struct Benefit {
    let icon: String
    let title: String
    let description: String
}

