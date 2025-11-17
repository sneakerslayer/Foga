import SwiftUI

/// Root view that decides whether to show onboarding or main app
/// 
/// **Learning Note**: This is the entry point that checks if user has completed onboarding.
/// If not, show onboarding. If yes, show main app.
/// 
/// **Critical**: Shares the same DataService instance with OnboardingView to ensure
/// data synchronization. When onboarding completes and saves the user, RootView
/// immediately sees the update and transitions to the main app.
@available(iOS 15.0, *)
public struct RootView: View {
    @StateObject private var dataService = DataService()
    @State private var showOnboarding = true
    
    public init() {}
    
    public var body: some View {
        Group {
            if showOnboarding {
                // Pass the shared DataService to OnboardingView
                // This ensures both views observe the same data instance
                OnboardingView(dataService: dataService)
                    .onAppear {
                        checkOnboardingStatus()
                    }
            } else {
                MainTabView()
            }
        }
        .onChange(of: dataService.currentUser) { _ in
            // When user is created, hide onboarding
            if dataService.currentUser != nil {
                showOnboarding = false
            }
        }
    }
    
    /// Check if user has completed onboarding
    private func checkOnboardingStatus() {
        // If user exists, onboarding is complete
        showOnboarding = dataService.currentUser == nil
    }
}

