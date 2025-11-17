import Foundation
import Combine

/// Service for managing user data persistence
/// 
/// **Learning Note**: This service handles saving and loading data.
/// For now, we'll use UserDefaults (simple key-value storage).
/// Later, we'll migrate to Core Data for more complex data.
/// 
/// **Swift Concepts**:
/// - `UserDefaults`: iOS's simple storage system (like a dictionary that persists)
/// - `Codable`: Converts our models to/from JSON automatically
@available(iOS 15.0, *)
@MainActor
public class DataService: ObservableObject {
    /// Current user
    @Published public var currentUser: User?
    
    /// All progress entries
    @Published public var progressEntries: [Progress] = []
    
    /// UserDefaults keys
    private enum Keys {
        static let currentUser = "currentUser"
        static let progressEntries = "progressEntries"
    }
    
    public init() {
        loadUser()
        loadProgress()
    }
    
    /// Save current user
    /// 
    /// **Learning Note**: UserDefaults stores simple data types.
    /// We convert our User model to JSON (Data) first.
    public func saveUser(_ user: User) {
        currentUser = user
        
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: Keys.currentUser)
        }
    }
    
    /// Load saved user
    public func loadUser() {
        guard let data = UserDefaults.standard.data(forKey: Keys.currentUser),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        currentUser = user
    }
    
    /// Add progress entry
    public func addProgress(_ progress: Progress) {
        progressEntries.append(progress)
        saveProgress()
    }
    
    /// Save all progress entries
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progressEntries) {
            UserDefaults.standard.set(encoded, forKey: Keys.progressEntries)
        }
    }
    
    /// Load saved progress entries
    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: Keys.progressEntries),
              let entries = try? JSONDecoder().decode([Progress].self, from: data) else {
            return
        }
        progressEntries = entries
    }
    
    /// Clear all data (for testing/reset)
    public func clearAllData() {
        UserDefaults.standard.removeObject(forKey: Keys.currentUser)
        UserDefaults.standard.removeObject(forKey: Keys.progressEntries)
        currentUser = nil
        progressEntries = []
    }
}

