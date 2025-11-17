import SwiftUI

/// Main tab bar navigation
/// 
/// **Learning Note**: TabView creates the bottom tab bar navigation.
/// This is the main navigation structure after onboarding.
@available(iOS 15.0, *)
public struct MainTabView: View {
    @StateObject private var dataService = DataService()
    
    public init() {}
    
    public var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ExerciseListView()
                .tabItem {
                    Label("Exercises", systemImage: "figure.walk")
                }
            
            ProgressDashboard()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(AppColors.primary)
    }
}

