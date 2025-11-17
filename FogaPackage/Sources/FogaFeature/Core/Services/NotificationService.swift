import Foundation
import UserNotifications

/// Service for managing push notifications and reminders
/// 
/// **Learning Note**: UserNotifications framework handles all notification features.
/// This includes requesting permission, scheduling notifications, and handling responses.
/// 
/// **Types of notifications**:
/// - Local: Scheduled by your app (like daily reminders)
/// - Remote: Sent from your server (like workout reminders)
@available(iOS 15.0, *)
@MainActor
public class NotificationService: ObservableObject {
    /// Current authorization status
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    public init() {
        // Status starts as .notDetermined and will be checked lazily when needed
        // Call initialize() or requestAuthorization() to update the status
    }
    
    /// Request notification permissions
    /// 
    /// **Learning Note**: iOS requires explicit permission for notifications.
    /// Users can grant or deny this permission.
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    /// 
    /// **Note**: This should be called asynchronously after initialization.
    /// The status will be automatically checked when `requestAuthorization()` is called.
    public func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    /// Initialize the service by checking authorization status
    /// 
    /// **Note**: Call this method from a SwiftUI `.task` modifier or similar async context
    /// to check the authorization status after initialization.
    /// 
    /// Example:
    /// ```swift
    /// .task {
    ///     await notificationService.initialize()
    /// }
    /// ```
    public func initialize() async {
        await checkAuthorizationStatus()
    }
    
    /// Schedule daily reminder notification
    /// 
    /// **Learning Note**: This creates a local notification that repeats daily.
    /// The notification triggers at the specified time each day.
    public func scheduleDailyReminder(at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time for Face Yoga! 🧘"
        content.body = "Don't forget your daily Foga exercises"
        content.sound = .default
        
        // Create date components for the reminder time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // Create trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    /// Cancel all scheduled notifications
    public func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

