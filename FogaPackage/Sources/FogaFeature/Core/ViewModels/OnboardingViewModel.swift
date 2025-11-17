import Foundation
import SwiftUI

/// ViewModel for onboarding flow
/// 
/// **Learning Note**: ViewModels handle business logic and state management.
/// Views observe ViewModels and update when data changes.
/// 
/// **MVVM Pattern**:
/// - Model: Data structures (User, Goal, etc.)
/// - View: SwiftUI views (OnboardingView, etc.)
/// - ViewModel: This file - connects Models and Views
@MainActor
public class OnboardingViewModel: ObservableObject {
    /// Current onboarding step
    @Published public var currentStep: OnboardingStep = .welcome
    
    /// Selected goals
    @Published public var selectedGoals: [Goal] = []
    
    /// User's name
    @Published public var userName: String = ""
    
    /// Whether onboarding is complete
    @Published public var isComplete: Bool = false
    
    /// Data service reference
    private let dataService: DataService
    
    public init(dataService: DataService) {
        self.dataService = dataService
    }
    
    /// Move to next step
    public func nextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .benefits
        case .benefits:
            currentStep = .permissions
        case .permissions:
            currentStep = .tutorial
        case .tutorial:
            currentStep = .goals
        case .goals:
            completeOnboarding()
        }
    }
    
    /// Move to previous step
    public func previousStep() {
        switch currentStep {
        case .benefits:
            currentStep = .welcome
        case .permissions:
            currentStep = .benefits
        case .tutorial:
            currentStep = .permissions
        case .goals:
            currentStep = .tutorial
        default:
            break
        }
    }
    
    /// Complete onboarding and create user
    public func completeOnboarding() {
        let user = User(
            name: userName.isEmpty ? "User" : userName,
            goals: selectedGoals,
            premiumStatus: false
        )
        
        dataService.saveUser(user)
        isComplete = true
    }
    
    /// Toggle goal selection
    public func toggleGoal(_ goal: Goal) {
        if selectedGoals.contains(goal) {
            selectedGoals.removeAll { $0 == goal }
        } else {
            selectedGoals.append(goal)
        }
    }
}

/// Onboarding steps enum
public enum OnboardingStep {
    case welcome
    case benefits
    case permissions
    case tutorial
    case goals
}

