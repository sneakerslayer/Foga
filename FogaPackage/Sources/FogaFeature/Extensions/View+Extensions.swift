import SwiftUI

/// View extensions for common functionality
/// 
/// **Learning Note**: Extensions let us add reusable functionality to existing types.
/// These are convenience methods we'll use throughout the app.
extension View {
    /// Hide keyboard
    /// 
    /// **Learning Note**: Dismisses the keyboard when called.
    /// Useful for text fields and search bars.
    public func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    /// Conditional modifier
    /// 
    /// **Learning Note**: Applies a modifier only if condition is true.
    /// This is cleaner than using if-else statements in views.
    @ViewBuilder
    public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

