import Foundation

/// User model representing app user data
/// 
/// **Learning Note**: Models represent data structures in your app.
/// This follows the MVVM pattern - Models hold data, ViewModels handle logic, Views display UI.
/// 
/// **Swift Concepts**:
/// - `Codable`: Lets us easily save/load from JSON or UserDefaults
/// - `Identifiable`: Required for SwiftUI lists (each item needs unique ID)
/// - `Equatable`: Required for SwiftUI's `onChange` modifier to detect changes
public struct User: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var goals: [Goal]
    public var premiumStatus: Bool
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        goals: [Goal] = [],
        premiumStatus: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.goals = goals
        self.premiumStatus = premiumStatus
        self.createdAt = createdAt
    }
}

/// User goals enum
/// 
/// **Learning Note**: Enums are perfect for fixed sets of options.
/// This ensures users can only select valid goals.
public enum Goal: String, Codable, CaseIterable, Sendable {
    case reduceDoubleChin = "Reduce double chin"
    case toneJawline = "Tone jawline"
    case faceFitness = "Face fitness"
    
    /// Display name for UI
    public var displayName: String {
        return rawValue
    }
    
    /// Icon name (for future use)
    public var iconName: String {
        switch self {
        case .reduceDoubleChin:
            return "face.smiling"
        case .toneJawline:
            return "face.dashed"
        case .faceFitness:
            return "figure.walk"
        }
    }
}

