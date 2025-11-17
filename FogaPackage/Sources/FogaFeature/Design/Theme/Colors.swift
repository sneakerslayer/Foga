import SwiftUI

/// Color theme for Foga app
/// 
/// This file defines all the colors used throughout the app.
/// Using a centralized color system makes it easy to update the app's appearance.
/// 
/// **Learning Note**: In SwiftUI, we use `Color` which works with both light and dark mode.
/// The `#FF6B6B` format is a hex color code (Red-Green-Blue in hexadecimal).
@available(iOS 15.0, *)
public struct AppColors {
    /// Primary coral color - used for main actions and highlights
    /// Hex: #FF6B6B
    public static let primary = Color(hex: "FF6B6B")
    
    /// Secondary teal color - used for secondary actions and accents
    /// Hex: #4ECDC4
    public static let secondary = Color(hex: "4ECDC4")
    
    /// Background color - light gray for main backgrounds
    /// Hex: #F7F7F7
    public static let background = Color(hex: "F7F7F7")
    
    /// Card background - white for content cards
    public static let cardBackground = Color.white
    
    /// Text colors
    public static let primaryText = Color.primary
    public static let secondaryText = Color.secondary
    
    /// Gradient for buttons and highlights
    public static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primary, Color(hex: "FF8787")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Secondary gradient
    public static var secondaryGradient: LinearGradient {
        LinearGradient(
            colors: [secondary, Color(hex: "6EDDD6")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Color Extension for Hex Support
/// Extension to create Color from hex string
/// 
/// **Learning Note**: Extensions let us add new functionality to existing types.
/// This makes it easy to create colors from hex codes like web developers do.
extension Color {
    /// Initialize Color from hex string (e.g., "FF6B6B")
    /// 
    /// **How it works**:
    /// 1. Remove "#" if present
    /// 2. Convert hex string to integer
    /// 3. Extract red, green, blue components
    /// 4. Divide by 255 to get 0-1 range SwiftUI expects
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

