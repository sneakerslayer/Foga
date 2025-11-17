import Foundation

/// App-wide constants
/// 
/// **Learning Note**: Centralizing constants makes it easy to update values
/// that are used in multiple places (like API URLs, feature flags, etc.)
public struct AppConstants {
    /// App name
    public static let appName = "Foga"
    
    /// App version (will be set from build settings)
    public static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    /// Build number
    public static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    /// Minimum face tracking support (iPhone X and later)
    public static let minimumFaceTrackingDevice = "iPhone X"
    
    /// Default exercise duration (in seconds)
    public static let defaultExerciseDuration: TimeInterval = 30
    
    /// UserDefaults keys
    public struct UserDefaultsKeys {
        public static let hasCompletedOnboarding = "hasCompletedOnboarding"
        public static let baselineMeasurement = "baselineMeasurement"
        public static let currentUser = "currentUser"
        public static let progressEntries = "progressEntries"
    }
    
    /// Notification identifiers
    public struct NotificationIdentifiers {
        public static let dailyReminder = "dailyReminder"
    }
}

