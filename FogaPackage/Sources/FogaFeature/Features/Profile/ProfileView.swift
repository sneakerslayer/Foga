import SwiftUI

/// User profile view
@available(iOS 15.0, *)
public struct ProfileView: View {
    @StateObject private var dataService = DataService()
    
    public var body: some View {
        NavigationView {
            List {
                // User info section
                Section {
                    HStack(spacing: AppSpacing.medium) {
                        // Avatar
                        Circle()
                            .fill(AppColors.primaryGradient)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text((dataService.currentUser?.name.prefix(1) ?? "U").uppercased())
                                    .font(AppTypography.title2)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dataService.currentUser?.name ?? "User")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("Member since \(dataService.currentUser?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "")")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, AppSpacing.small)
                }
                
                // Goals section
                if let goals = dataService.currentUser?.goals, !goals.isEmpty {
                    Section("Goals") {
                        ForEach(goals, id: \.self) { goal in
                            HStack {
                                Image(systemName: goal.iconName)
                                    .foregroundColor(AppColors.primary)
                                Text(goal.displayName)
                            }
                        }
                    }
                }
                
                // Settings section
                Section("Settings") {
                    NavigationLink(destination: Text("Notifications Settings")) {
                        Label("Notifications", systemImage: "bell")
                    }
                    
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy", systemImage: "lock")
                    }
                    
                    NavigationLink(destination: UserFeedbackView()) {
                        Label("Send Feedback", systemImage: "envelope")
                    }
                    
                    NavigationLink(destination: Text("About")) {
                        Label("About", systemImage: "info.circle")
                    }
                }
                
                // Premium section
                Section {
                    NavigationLink(destination: Text("Premium Features")) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(AppColors.secondary)
                            Text("Premium")
                                .foregroundColor(AppColors.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

